import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/app_error.dart';
import '../../../domain/chat/chat_session.dart';
import '../../../domain/chat/chat_turn.dart';
import '../../../domain/chat/work_step.dart';
import '../../../domain/decision/decision.dart';
import '../../../domain/executor/executor.dart';
import '../../../domain/profile/server_profile.dart';
import '../../../domain/session/agent_connection.dart';
import '../../../domain/session/agent_session.dart';
import '../../../domain/session/session_ref.dart';
import '../../settings/application/settings_controller.dart';
import 'agent_manager_state.dart';
import 'executor_factory.dart';

part 'agent_manager.g.dart';

/// Owns every agent connection and every conversation in the app.
///
/// Nothing here depends on a page being mounted. The manager subscribes to an
/// executor once, folds events into per-session state, and keeps that state
/// alive; pages only read it and send commands. That is what lets a running
/// turn survive leaving the conversation, keeps drafts per conversation, and
/// lets several agents stay connected at the same time.
@Riverpod(keepAlive: true)
class AgentManager extends _$AgentManager {
  /// Blocks are batched at roughly one frame; a chunk-per-state-update rebuilds
  /// the list far faster than it can be painted.
  static const Duration _flushInterval = Duration(milliseconds: 24);

  /// How long a cancelled turn may stay silent before it is settled anyway.
  static const Duration _stopGrace = Duration(seconds: 10);

  final Map<String, _AgentRuntime> _runtimes = <String, _AgentRuntime>{};
  final Set<SessionRef> _dirty = <SessionRef>{};
  final Map<String, int> _attempts = <String, int>{};
  int _attemptSeq = 0;
  Timer? _flushTimer;
  bool _disposed = false;

  @override
  AgentManagerState build() {
    ref.onDispose(() {
      _disposed = true;
      _flushTimer?.cancel();
      for (final runtime in _runtimes.values.toList(growable: false)) {
        unawaited(runtime.dispose());
      }
      _runtimes.clear();
    });
    return const AgentManagerState();
  }

  // ── Agents ──────────────────────────────────────────────────────────────

  /// Connects [profile] and makes it the agent on screen.
  ///
  /// A different agent that is already connected is left alone: its runtime
  /// keeps receiving events, so switching back is instant.
  Future<void> connect(ServerProfile profile) async {
    final agentId = profile.id;
    final existing = _runtimes[agentId];
    if (existing != null && existing.connecting) return;
    if (existing != null && _isConnected(existing)) {
      _activate(agentId);
      await refreshSessions(agentId);
      return;
    }
    if (existing != null) await _dropRuntime(agentId);

    final attempt = ++_attemptSeq;
    _attempts[agentId] = attempt;

    _upsertAgent(
      AgentConnection(profile: profile, status: AgentStatus.connecting),
      activate: true,
    );

    try {
      final connected = await ref
          .read(settingsProvider.notifier)
          .connected(agentId);
      if (connected == null) {
        throw const UnknownFailure('The executor is not configured');
      }

      final executor = ref.read(executorFactoryProvider)(connected);
      final runtime = _AgentRuntime(profile: profile, executor: executor);
      _runtimes[agentId] = runtime;
      runtime.connecting = true;

      // Subscribe before connecting: no event can arrive before the manager is
      // listening, whichever session it names.
      runtime.events = executor.events.listen(
        (event) => _onEvent(runtime, event),
      );
      runtime.connection = executor.connection.listen(
        (status) => _onConnection(runtime, status),
      );

      final capabilities = await executor.connect();
      runtime.connecting = false;
      if (!_isCurrent(runtime) || _attempts[agentId] != attempt) return;

      _updateAgent(
        agentId,
        (agent) => agent.copyWith(
          status: AgentStatus.connected,
          capabilities: capabilities,
          error: null,
        ),
      );
      await refreshSessions(agentId);
    } on Object catch (failure) {
      if (_disposed || _attempts[agentId] != attempt) return;
      await _dropRuntime(agentId);
      _upsertAgent(
        AgentConnection(
          profile: profile,
          status: AgentStatus.failed,
          error: AppError.from(failure),
        ),
        activate: true,
      );
    }
  }

  /// Drops one agent and everything attached to it.
  Future<void> disconnect(String agentId) async {
    // Any connect still in flight for this agent is now stale.
    _attempts.remove(agentId);
    final wasActive = state.activeAgentId == agentId;
    await _dropRuntime(agentId);

    final agents = Map<String, AgentConnection>.of(state.agents)
      ..remove(agentId);
    final order = state.order
        .where((id) => id != agentId)
        .toList(growable: false);
    final fallback = wasActive
        ? order.where((id) => agents[id]?.isConnected ?? false).firstOrNull
        : state.activeAgentId;

    state = state.copyWith(
      agents: agents,
      order: order,
      activeAgentId: wasActive ? fallback : state.activeAgentId,
    );
  }

  /// Makes an already-connected agent the one on screen.
  void activate(String agentId) {
    if (_runtimes[agentId] == null) return;
    _activate(agentId);
  }

  Future<void> refreshSessions(String agentId) async {
    final runtime = _runtimes[agentId];
    final agent = state.agents[agentId];
    if (runtime == null || agent == null) return;

    try {
      final sessions = await runtime.executor.listSessions(
        cwd: _cwdFor(runtime) ?? agent.profile.effectiveCwd,
      );
      if (!_isCurrent(runtime)) return;
      _updateAgent(
        agentId,
        (current) => current.copyWith(sessions: sessions, error: null),
      );
    } on Object catch (failure) {
      if (!_isCurrent(runtime)) return;
      // The agent is the only source of truth for this list. A failed refresh
      // keeps the rows already on screen and reports why.
      _updateAgent(
        agentId,
        (current) => current.copyWith(error: AppError.from(failure)),
      );
    }
  }

  // ── Sessions ────────────────────────────────────────────────────────────

  /// Creates a conversation and opens it. Returns whether it was created.
  Future<bool> newSession(String agentId) async {
    final runtime = _runtimes[agentId];
    if (runtime == null || runtime.switching) return false;
    final cwd = _cwdFor(runtime);
    if (cwd == null) return false;

    runtime.switching = true;
    try {
      final session = await runtime.executor.newSession(cwd: cwd);
      if (!_isCurrent(runtime)) return false;

      final buffer = runtime.sessions.putIfAbsent(
        session.id,
        () => _SessionBuffer(cwd: session.cwd),
      );
      buffer
        ..cwd = session.cwd
        ..loaded = true
        ..loading = false
        ..surfaces = runtime.executor.surfacesOf(session.id);
      runtime.openSessionId = session.id;
      _dirty.add(SessionRef(agentId, session.id));
      _setOpen(agentId, session.id);
      await _flushNow();
      await refreshSessions(agentId);
      return true;
    } on Object catch (failure) {
      if (!_isCurrent(runtime)) return false;
      _updateAgent(
        agentId,
        (agent) => agent.copyWith(error: AppError.from(failure)),
      );
      return false;
    } finally {
      runtime.switching = false;
    }
  }

  /// Opens a conversation, loading it only when the executor does not already
  /// hold it. Reopening the conversation already in memory is a pure switch:
  /// the transcript, draft and running turn stay exactly as they were.
  Future<bool> openSession(String agentId, String sessionId) async {
    final runtime = _runtimes[agentId];
    if (runtime == null || runtime.switching) return false;

    if (runtime.executor.holds(sessionId)) {
      runtime.openSessionId = sessionId;
      _setOpen(agentId, sessionId);
      return true;
    }

    runtime.switching = true;
    final ref = SessionRef(agentId, sessionId);
    // The executor does not hold this session, so any state under this id is
    // stale. Start from a fresh transcript; the agent replays the real one.
    final buffer = _SessionBuffer();
    runtime.sessions[sessionId] = buffer;
    buffer
      ..loading = true
      ..loaded = false;
    _dirty.add(ref);
    await _flushNow();

    try {
      final opened = await runtime.executor.openSession(
        id: sessionId,
        cwd: _cwdFor(runtime) ?? runtime.profile.effectiveCwd,
      );
      if (!_isCurrent(runtime)) return false;

      buffer
        ..cwd = opened.cwd
        ..loading = false
        ..loaded = true
        ..surfaces = runtime.executor.surfacesOf(sessionId);
      runtime.openSessionId = sessionId;
      _dirty.add(ref);
      _setOpen(agentId, sessionId);
      await _flushNow();
      return true;
    } on Object catch (failure) {
      if (!_isCurrent(runtime)) return false;
      buffer
        ..loading = false
        ..loaded = false
        ..error = AppError.from(failure);
      _dirty.add(ref);
      await _flushNow();
      _updateAgent(
        agentId,
        (agent) => agent.copyWith(error: AppError.from(failure)),
      );
      return false;
    } finally {
      runtime.switching = false;
    }
  }

  Future<void> deleteSession(String agentId, String sessionId) async {
    final runtime = _runtimes[agentId];
    if (runtime == null) return;
    final ref = SessionRef(agentId, sessionId);

    try {
      await runtime.executor.deleteSession(sessionId);
      if (!_isCurrent(runtime)) return;
      runtime.sessions.remove(sessionId)?.dispose();
      _dirty.remove(ref);

      final sessions = Map<SessionRef, ChatSession>.of(state.sessions)
        ..remove(ref);
      final drafts = Map<SessionRef, String>.of(state.drafts)..remove(ref);
      final open = Map<String, String>.of(state.openSessions);
      if (open[agentId] == sessionId) {
        open.remove(agentId);
        runtime.openSessionId = null;
      }
      state = state.copyWith(
        sessions: sessions,
        drafts: drafts,
        openSessions: open,
      );
      _updateAgent(
        agentId,
        (agent) => agent.copyWith(
          sessions: agent.sessions
              .where((summary) => summary.id != sessionId)
              .toList(growable: false),
        ),
      );
    } on Object catch (failure) {
      if (!_isCurrent(runtime)) return;
      _updateAgent(
        agentId,
        (agent) => agent.copyWith(error: AppError.from(failure)),
      );
    }
  }

  // ── Turns ───────────────────────────────────────────────────────────────

  /// Sends a turn. Returns whether it was accepted, so the composer knows
  /// whether it may clear its draft.
  Future<bool> send(SessionRef ref, String text) async {
    final trimmed = text.trim();
    final runtime = _runtimes[ref.agentId];
    final buffer = runtime?.sessions[ref.sessionId];
    if (trimmed.isEmpty || runtime == null || buffer == null) return false;
    if (buffer.running) return false;

    buffer.beginSend(trimmed);
    _clearDraft(ref);
    _dirty.add(ref);
    await _flushNow();

    // Not awaited: a prompt resolves only at the stop reason, which may be a
    // long time, and progress arrives on the event stream.
    unawaited(runtime.executor.prompt(sessionId: ref.sessionId, text: trimmed));
    return true;
  }

  /// Stops the running turn, keeping whatever was already produced.
  Future<void> stop(SessionRef ref) async {
    final runtime = _runtimes[ref.agentId];
    final buffer = runtime?.sessions[ref.sessionId];
    if (runtime == null || buffer == null || !buffer.running) return;

    buffer
      ..stopRequested = true
      ..stopping = true;
    _dirty.add(ref);
    await _flushNow();

    buffer.stopGuard?.cancel();
    buffer.stopGuard = Timer(_stopGrace, () {
      if (!buffer.running) return;
      buffer.finish(stopReason: 'cancelled');
      _dirty.add(ref);
      unawaited(_flushNow());
      _afterTurn(runtime);
    });

    try {
      await runtime.executor.cancel(ref.sessionId);
    } on Object catch (failure) {
      buffer.fail(AppError.from(failure));
      _dirty.add(ref);
      await _flushNow();
    }
  }

  /// Answers the one pending decision of [ref].
  Future<void> answer(SessionRef ref, DecisionOption? option) async {
    final runtime = _runtimes[ref.agentId];
    final buffer = runtime?.sessions[ref.sessionId];
    final decision = buffer?.pendingDecision;
    if (runtime == null || buffer == null || decision == null) return;

    buffer.answer(decision, option);
    _dirty.add(ref);
    await _flushNow();

    try {
      await runtime.executor.answer(
        DecisionAnswer(decisionId: decision.id, optionId: option?.id),
      );
    } on Object catch (failure) {
      // The agent never received this answer, so the decision is still open.
      // Putting it back means the sheet can ask again instead of the UI
      // claiming a decision that was never delivered.
      buffer.reopen(decision);
      buffer.error = AppError.from(failure);
      _dirty.add(ref);
      await _flushNow();
    }
  }

  // ── Configuration ───────────────────────────────────────────────────────

  Future<bool> selectModel(SessionRef ref, String id) =>
      _applySurfaces(ref, (executor) => executor.setModel(ref.sessionId, id));

  Future<bool> selectMode(SessionRef ref, String id) =>
      _applySurfaces(ref, (executor) => executor.setMode(ref.sessionId, id));

  Future<bool> selectEffort(SessionRef ref, String value) {
    final configId = _runtimes[ref.agentId]
        ?.sessions[ref.sessionId]
        ?.surfaces
        .effortConfigId;
    if (configId == null) return Future<bool>.value(false);
    return _applySurfaces(
      ref,
      (executor) => executor.setConfigOption(ref.sessionId, configId, value),
    );
  }

  Future<bool> _applySurfaces(
    SessionRef ref,
    Future<void> Function(Executor executor) apply,
  ) async {
    final runtime = _runtimes[ref.agentId];
    final buffer = runtime?.sessions[ref.sessionId];
    if (runtime == null || buffer == null) return false;

    try {
      await apply(runtime.executor);
      if (!_isCurrent(runtime)) return false;
      buffer
        ..surfaces = runtime.executor.surfacesOf(ref.sessionId)
        ..error = null;
      _dirty.add(ref);
      await _flushNow();
      return true;
    } on Object catch (failure) {
      if (!_isCurrent(runtime)) return false;
      buffer.error = AppError.from(failure);
      _dirty.add(ref);
      await _flushNow();
      return false;
    }
  }

  // ── Drafts ──────────────────────────────────────────────────────────────

  /// Keeps unfinished composer text with its conversation, not its page.
  void setDraft(SessionRef ref, String text) {
    final current = state.drafts[ref] ?? '';
    if (current == text) return;

    final drafts = Map<SessionRef, String>.of(state.drafts);
    if (text.isEmpty) {
      drafts.remove(ref);
    } else {
      drafts[ref] = text;
    }
    state = state.copyWith(drafts: drafts);
  }

  void _clearDraft(SessionRef ref) {
    if (!state.drafts.containsKey(ref)) return;
    final drafts = Map<SessionRef, String>.of(state.drafts)..remove(ref);
    state = state.copyWith(drafts: drafts);
  }

  // ── Executor events ─────────────────────────────────────────────────────

  void _onEvent(_AgentRuntime runtime, ExecutorEvent event) {
    if (_disposed) return;
    final buffer = runtime.sessions[event.sessionId];
    if (buffer == null) return;

    final ref = SessionRef(runtime.profile.id, event.sessionId);
    switch (event) {
      case UserPrompt(:final text):
        // A live turn is opened by `send`; the only user message that starts a
        // new turn here is one the agent replays as history.
        if (buffer.awaitingEcho) {
          buffer.awaitingEcho = false;
        } else {
          buffer.startTurn(text, live: false);
          _dirty.add(ref);
          _scheduleFlush();
        }
      case AgentText(:final text):
        buffer.appendText(text);
        _dirty.add(ref);
        _scheduleFlush();
      case AgentThought(:final text):
        buffer.appendThought(text);
        _dirty.add(ref);
        _scheduleFlush();
      case StepChanged(:final step):
        buffer.applyStep(step);
        _dirty.add(ref);
        _scheduleFlush();
      case DecisionRaised(:final decision):
        buffer.addDecision(decision);
        _dirty.add(ref);
        unawaited(_flushNow());
      case ExecutionFinished(:final stopReason):
        buffer.finish(stopReason: stopReason);
        _dirty.add(ref);
        unawaited(_flushNow());
        _afterTurn(runtime);
      case ExecutionFailed(:final error):
        buffer.fail(error);
        _dirty.add(ref);
        unawaited(_flushNow());
        _afterTurn(runtime);
      case SurfacesChanged():
        buffer.surfaces = runtime.executor.surfacesOf(event.sessionId);
        _dirty.add(ref);
        _scheduleFlush();
    }
  }

  void _onConnection(_AgentRuntime runtime, ExecutorConnection connection) {
    if (!_isCurrent(runtime)) return;
    if (connection == ExecutorConnection.closed) {
      unawaited(_lost(runtime));
      return;
    }
    if (connection == ExecutorConnection.connected && runtime.connecting) {
      // The transport is up, but the handshake is still running. Reporting
      // "connected" here would re-enable the connect button mid-attempt.
      return;
    }

    final status = switch (connection) {
      ExecutorConnection.connecting => AgentStatus.connecting,
      ExecutorConnection.connected => AgentStatus.connected,
      ExecutorConnection.reconnecting => AgentStatus.reconnecting,
      ExecutorConnection.closed ||
      ExecutorConnection.failed => AgentStatus.failed,
    };
    _updateAgent(
      runtime.profile.id,
      (agent) =>
          agent.status == status ? agent : agent.copyWith(status: status),
    );
  }

  /// The transport is gone for good, and this agent's sessions went with it.
  Future<void> _lost(_AgentRuntime runtime) async {
    if (!_isCurrent(runtime)) return;
    final agentId = runtime.profile.id;
    final profile = runtime.profile;

    await _dropRuntime(agentId);
    _upsertAgent(
      AgentConnection(
        profile: profile,
        status: AgentStatus.failed,
        error: const NetworkUnavailable(
          'The connection to the agent was lost.',
        ),
      ),
      activate: true,
    );

    if (state.activeAgentId == agentId) {
      final fallback = state.order
          .where((id) => state.agents[id]?.isConnected ?? false)
          .firstOrNull;
      state = state.copyWith(activeAgentId: fallback);
    }
  }

  void _afterTurn(_AgentRuntime runtime) {
    final agent = state.agents[runtime.profile.id];
    if (agent != null && agent.canRefresh) {
      unawaited(refreshSessions(runtime.profile.id));
    }
  }

  // ── State plumbing ──────────────────────────────────────────────────────

  void _upsertAgent(AgentConnection agent, {bool activate = false}) {
    final agentId = agent.profile.id;
    final agents = Map<String, AgentConnection>.of(state.agents)
      ..[agentId] = agent;
    final order = state.order.contains(agentId)
        ? state.order
        : <String>[...state.order, agentId];
    state = state.copyWith(
      agents: agents,
      order: order,
      activeAgentId: activate ? agentId : state.activeAgentId,
    );
  }

  void _updateAgent(
    String agentId,
    AgentConnection Function(AgentConnection agent) update,
  ) {
    final agent = state.agents[agentId];
    if (agent == null) return;
    final next = update(agent);
    if (identical(next, agent)) return;
    state = state.copyWith(
      agents: <String, AgentConnection>{...state.agents, agentId: next},
    );
  }

  void _activate(String agentId) {
    if (state.activeAgentId == agentId) return;
    state = state.copyWith(activeAgentId: agentId);
  }

  void _setOpen(String agentId, String sessionId) {
    state = state.copyWith(
      activeAgentId: agentId,
      openSessions: <String, String>{...state.openSessions, agentId: sessionId},
    );
  }

  Future<void> _dropRuntime(String agentId) async {
    final runtime = _runtimes.remove(agentId);
    if (runtime == null) return;

    await runtime.dispose();
    for (final sessionId in runtime.sessions.keys) {
      _dirty.remove(SessionRef(agentId, sessionId));
    }

    final sessions = Map<SessionRef, ChatSession>.of(state.sessions)
      ..removeWhere((ref, _) => ref.agentId == agentId);
    final drafts = Map<SessionRef, String>.of(state.drafts)
      ..removeWhere((ref, _) => ref.agentId == agentId);
    final open = Map<String, String>.of(state.openSessions)..remove(agentId);
    state = state.copyWith(
      sessions: sessions,
      drafts: drafts,
      openSessions: open,
    );
  }

  String? _cwdFor(_AgentRuntime runtime) {
    final open = runtime.openSessionId;
    final openCwd = open == null ? null : runtime.sessions[open]?.cwd;
    if (openCwd != null && openCwd.isNotEmpty) return openCwd;
    final profileCwd = runtime.profile.effectiveCwd;
    return profileCwd.isEmpty ? null : profileCwd;
  }

  bool _isConnected(_AgentRuntime runtime) =>
      state.agents[runtime.profile.id]?.isConnected ?? false;

  bool _isCurrent(_AgentRuntime runtime) =>
      !_disposed && identical(_runtimes[runtime.profile.id], runtime);

  // ── Flushing ────────────────────────────────────────────────────────────

  void _scheduleFlush() {
    if (_flushTimer != null) return;
    _flushTimer = Timer(_flushInterval, () {
      _flushTimer = null;
      _publishSessions();
    });
  }

  Future<void> _flushNow() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    _publishSessions();
  }

  void _publishSessions() {
    if (_disposed || _dirty.isEmpty) return;

    final sessions = Map<SessionRef, ChatSession>.of(state.sessions);
    for (final ref in _dirty) {
      final buffer = _runtimes[ref.agentId]?.sessions[ref.sessionId];
      if (buffer == null) {
        sessions.remove(ref);
        continue;
      }
      sessions[ref] = buffer.toState(ref);
    }
    _dirty.clear();
    state = state.copyWith(sessions: sessions);
  }
}

/// One agent's executor and the sessions it is following.
final class _AgentRuntime {
  _AgentRuntime({required this.profile, required this.executor});

  final ServerProfile profile;
  final Executor executor;
  StreamSubscription<ExecutorEvent>? events;
  StreamSubscription<ExecutorConnection>? connection;

  /// A connect attempt is in flight end to end — transport and handshake.
  bool connecting = false;

  /// A session switch or create is in flight, so a second one would race it.
  bool switching = false;

  /// The conversation to show when this agent becomes active again.
  String? openSessionId;

  final Map<String, _SessionBuffer> sessions = <String, _SessionBuffer>{};

  Future<void> dispose() async {
    await events?.cancel();
    events = null;
    await connection?.cancel();
    connection = null;
    for (final buffer in sessions.values) {
      buffer.dispose();
    }
    sessions.clear();
    await executor.dispose();
  }
}

/// The transcript being built for one session.
///
/// Mutable on purpose: event chunks arrive far faster than the UI should
/// rebuild. The manager publishes an immutable [ChatSession] on a short timer.
final class _SessionBuffer {
  _SessionBuffer({this.cwd = ''});

  String cwd;
  bool loaded = false;
  bool loading = false;
  bool running = false;
  bool stopping = false;
  bool awaitingEcho = false;
  bool stopRequested = false;
  AppError? error;
  SessionSurfaces surfaces = SessionSurfaces.none;
  Timer? stopGuard;

  final List<ChatTurn> _finished = <ChatTurn>[];
  final List<TurnBlock> _blocks = <TurnBlock>[];
  final List<Decision> _decisions = <Decision>[];
  ChatTurn? _live;
  int _seq = 0;

  Decision? get pendingDecision {
    for (final decision in _decisions) {
      if (decision.isPending) return decision;
    }
    return null;
  }

  ChatSession toState(SessionRef ref) {
    final live = _live;
    return ChatSession(
      ref: ref,
      cwd: cwd,
      turns: <ChatTurn>[
        ..._finished,
        if (live != null) live.copyWith(blocks: List<TurnBlock>.of(_blocks)),
      ],
      running: running,
      stopping: stopping,
      loaded: loaded,
      loading: loading,
      surfaces: surfaces,
      decisions: _decisions,
      error: error,
    );
  }

  void beginSend(String text) {
    startTurn(text);
    awaitingEcho = true;
  }

  void startTurn(String userText, {bool live = true}) {
    final previous = _live;
    if (previous != null) {
      // A replayed turn never receives a finish event; starting the next one is
      // what settles it.
      _finished.add(
        previous.copyWith(blocks: List<TurnBlock>.of(_blocks), running: false),
      );
    }
    _live = ChatTurn(id: _nextId('turn'), userText: userText, running: live);
    _blocks.clear();
    stopRequested = false;
    error = null;
    if (live) {
      running = true;
      stopping = false;
    }
  }

  void appendText(String text) {
    _ensureTurn();
    final last = _blocks.isEmpty ? null : _blocks.last;
    if (last is TextBlock) {
      _blocks[_blocks.length - 1] = TextBlock(
        id: last.id,
        text: last.text + text,
      );
    } else {
      _blocks.add(TextBlock(id: _nextId('prose'), text: text));
    }
  }

  void appendThought(String text) {
    _ensureTurn();
    final last = _blocks.isEmpty ? null : _blocks.last;
    if (last is ThoughtBlock) {
      _blocks[_blocks.length - 1] = ThoughtBlock(
        id: last.id,
        text: last.text + text,
      );
    } else {
      _blocks.add(ThoughtBlock(id: _nextId('thought'), text: text));
    }
  }

  void applyStep(WorkStep step) {
    _ensureTurn();
    final now = DateTime.now();
    final index = _blocks.indexWhere(
      (block) => block is ToolBlock && block.step.id == step.id,
    );

    if (index < 0) {
      _blocks.add(
        ToolBlock(
          step: step.copyWith(
            startedAt: step.startedAt ?? now,
            endedAt: step.status.isTerminal ? (step.endedAt ?? now) : null,
          ),
        ),
      );
    } else {
      final previous = (_blocks[index] as ToolBlock).step;
      _blocks[index] = ToolBlock(
        step: step.copyWith(
          startedAt: previous.startedAt ?? now,
          endedAt: step.status.isTerminal ? (previous.endedAt ?? now) : null,
        ),
      );
    }
  }

  void addDecision(Decision decision) {
    _decisions.add(decision);
  }

  void answer(Decision decision, DecisionOption? option) {
    final index = _decisions.indexWhere((entry) => entry.id == decision.id);
    if (index < 0) return;
    _decisions[index] = decision.resolve(option);
  }

  void reopen(Decision decision) {
    final index = _decisions.indexWhere((entry) => entry.id == decision.id);
    if (index < 0) return;
    _decisions[index] = decision;
  }

  void finish({String? stopReason}) {
    _cancelGuard();
    awaitingEcho = false;

    final live = _live;
    if (live != null) {
      _live = live.copyWith(
        blocks: List<TurnBlock>.of(_blocks),
        running: false,
        stopped: stopRequested,
      );
    }
    stopRequested = false;
    running = false;
    stopping = false;
    error = _stopError(stopReason);
    _settleDecisions();
  }

  void fail(AppError failure) {
    _cancelGuard();
    awaitingEcho = false;

    final live = _live;
    if (live != null) {
      _live = live.copyWith(
        blocks: List<TurnBlock>.of(_blocks),
        running: false,
      );
    }
    running = false;
    stopping = false;
    error = failure;
    _settleDecisions();
  }

  /// A turn that ended can no longer wait on an approval. The executor has
  /// denied anything still open, so the surface must stop asking too.
  void _settleDecisions() {
    for (var index = 0; index < _decisions.length; index++) {
      if (_decisions[index].isPending) {
        _decisions[index] = _decisions[index].resolve(null);
      }
    }
  }

  void dispose() {
    _cancelGuard();
  }

  void _cancelGuard() {
    stopGuard?.cancel();
    stopGuard = null;
  }

  void _ensureTurn() {
    if (_live != null) return;
    // Replay can begin with agent text; it is history, not a running turn.
    _live = ChatTurn(id: _nextId('turn'), userText: '', running: false);
  }

  String _nextId(String prefix) => '$prefix-${_seq++}';

  /// Stop reasons that mean the turn did not finish on its own terms.
  static AppError? _stopError(String? stopReason) {
    if (stopReason == null) return null;
    return switch (stopReason) {
      'error' || 'refusal' || 'max_tokens' => ExecutionStopped(stopReason),
      _ => null,
    };
  }
}
