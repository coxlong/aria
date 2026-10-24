import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/app_error.dart';
import '../../../data/executor/acp/acp_executor.dart';
import '../../../domain/decision/decision.dart';
import '../../../domain/executor/executor.dart';
import '../../../domain/profile/server_profile.dart';
import '../../../domain/session/agent_session.dart';
import '../../settings/application/settings_controller.dart';

part 'connection_controller.freezed.dart';
part 'connection_controller.g.dart';

/// Where the connection stands.
///
/// [reconnecting] is deliberately its own state: the transport is retrying and
/// the session is still alive, so a running turn must not read as finished.
enum ConnectionStatus { idle, connecting, connected, reconnecting, failed }

/// Everything the app needs to know about the current connection.
@freezed
abstract class ConnectionSnapshot with _$ConnectionSnapshot {
  const factory ConnectionSnapshot({
    ServerProfile? profile,
    @Default(ConnectionStatus.idle) ConnectionStatus status,
    AppError? error,
    AgentSession? session,
    SessionSurfaces? surfaces,
    @Default(<AgentSessionSummary>[]) List<AgentSessionSummary> sessions,
    @Default(AgentCapabilities()) AgentCapabilities capabilities,

    /// Every decision raised in this session, answered or not, oldest first.
    @Default(<Decision>[]) List<Decision> decisions,
  }) = _ConnectionSnapshot;

  const ConnectionSnapshot._();

  bool get isConnected =>
      status == ConnectionStatus.connected ||
      status == ConnectionStatus.reconnecting;

  bool get isBusy =>
      status == ConnectionStatus.connecting ||
      status == ConnectionStatus.reconnecting;

  /// Whether the session list can be fetched again right now.
  bool get canRefresh =>
      status == ConnectionStatus.connected && capabilities.canListSessions;

  /// The one decision that needs the person. Later ones wait their turn.
  Decision? get pendingDecision {
    for (final decision in decisions) {
      if (decision.isPending) return decision;
    }
    return null;
  }

  /// How many decisions are waiting behind the one being shown.
  int get queuedDecisions {
    var pending = 0;
    for (final decision in decisions) {
      if (decision.isPending) pending++;
    }
    return pending > 1 ? pending - 1 : 0;
  }
}

/// Owns the agent connection: one client, one open session, one session list.
///
/// Nothing else in the app creates an [Executor] or talks to the protocol.
@Riverpod(keepAlive: true)
class Connection extends _$Connection {
  Executor? _executor;
  StreamSubscription<ExecutorEvent>? _events;
  StreamSubscription<ExecutorConnection>? _connection;
  bool _tearingDown = false;

  /// A connect attempt is in flight end to end — transport, handshake, and the
  /// first session. The transport reports `connected` halfway through that
  /// sequence, so this flag, not `status`, is what keeps a second tap out.
  bool _connecting = false;

  /// A session switch is in flight, so a second one would race it.
  bool _switching = false;

  /// The live executor, for the chat surface to subscribe to.
  Executor? get executor => _executor;

  @override
  ConnectionSnapshot build() {
    ref.onDispose(() {
      unawaited(_teardown());
    });
    return const ConnectionSnapshot();
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────

  Future<void> connect(ServerProfile profile) async {
    if (_connecting) return;
    _connecting = true;
    try {
      await _teardown();
      state = ConnectionSnapshot(
        profile: profile,
        status: ConnectionStatus.connecting,
      );

      final connected = await ref
          .read(settingsProvider.notifier)
          .connected(profile.id);
      if (connected == null) {
        throw const UnknownFailure('The executor is not configured');
      }

      final executor = AcpExecutor(profile: connected);
      _executor = executor;
      _events = executor.events.listen(_onEvent);
      _connection = executor.connection.listen(_onConnection);

      final capabilities = await executor.connect();
      final session = await executor.newSession(cwd: profile.effectiveCwd);

      if (state.status == ConnectionStatus.failed) return;
      state = state.copyWith(
        status: ConnectionStatus.connected,
        session: session,
        surfaces: executor.surfaces,
        capabilities: capabilities,
        error: null,
      );
      await refreshSessions();
    } on Object catch (failure) {
      await _teardown();
      state = state.copyWith(
        status: ConnectionStatus.failed,
        error: AppError.from(failure),
        session: null,
      );
    } finally {
      _connecting = false;
    }
  }

  /// Drops the connection and everything attached to it.
  Future<void> disconnect() async {
    await _teardown();
    state = const ConnectionSnapshot();
  }

  Future<void> _teardown() async {
    if (_tearingDown) return;
    _tearingDown = true;
    try {
      final events = _events;
      _events = null;
      await events?.cancel();
      final connection = _connection;
      _connection = null;
      await connection?.cancel();
      final executor = _executor;
      _executor = null;
      await executor?.dispose();
    } finally {
      _tearingDown = false;
    }
  }

  // ── Sessions ────────────────────────────────────────────────────────────

  Future<void> refreshSessions() async {
    final executor = _executor;
    final session = state.session;
    if (executor == null) return;

    try {
      final sessions = await executor.listSessions(cwd: session?.cwd);
      state = state.copyWith(sessions: sessions, error: null);
    } on Object catch (failure) {
      // The agent is the only source of truth for this list. A failed refresh
      // keeps the rows already on screen and reports why, so a transient
      // failure does not make every session disappear.
      state = state.copyWith(error: AppError.from(failure));
    }
  }

  Future<void> newSession() async {
    final executor = _executor;
    final cwd = state.session?.cwd ?? state.profile?.effectiveCwd;
    if (executor == null || cwd == null || _switching) return;

    _switching = true;
    try {
      final session = await executor.newSession(cwd: cwd);
      state = state.copyWith(
        session: session,
        surfaces: executor.surfaces,
        decisions: const <Decision>[],
        error: null,
      );
      await refreshSessions();
    } on Object catch (failure) {
      state = state.copyWith(error: AppError.from(failure));
    } finally {
      _switching = false;
    }
  }

  Future<void> openSession(String sessionId) async {
    final executor = _executor;
    final session = state.session;
    if (executor == null || session == null || _switching) return;
    if (session.id == sessionId) return;

    _switching = true;
    try {
      final opened = await executor.openSession(
        id: sessionId,
        cwd: session.cwd,
      );
      state = state.copyWith(
        session: opened,
        surfaces: executor.surfaces,
        decisions: const <Decision>[],
        error: null,
      );
    } on Object catch (failure) {
      state = state.copyWith(error: AppError.from(failure));
    } finally {
      _switching = false;
    }
  }

  Future<void> deleteSession(String sessionId) async {
    final executor = _executor;
    if (executor == null) return;

    try {
      await executor.deleteSession(sessionId);
      state = state.copyWith(
        sessions: state.sessions
            .where((summary) => summary.id != sessionId)
            .toList(growable: false),
      );
      if (state.session?.id == sessionId) await newSession();
    } on Object catch (failure) {
      state = state.copyWith(error: AppError.from(failure));
    }
  }

  // ── Configuration ───────────────────────────────────────────────────────

  Future<void> selectModel(String id) =>
      _applySurfaces((executor) => executor.setModel(id));

  Future<void> selectMode(String id) =>
      _applySurfaces((executor) => executor.setMode(id));

  Future<void> selectEffort(String value) async {
    final executor = _executor;
    final configId = state.surfaces?.effortConfigId;
    if (executor == null || configId == null) return;
    await _applySurfaces(
      (executor) => executor.setConfigOption(configId, value),
    );
  }

  Future<bool> _applySurfaces(
    Future<void> Function(Executor executor) apply,
  ) async {
    final executor = _executor;
    if (executor == null) return false;
    try {
      await apply(executor);
      state = state.copyWith(surfaces: executor.surfaces, error: null);
      return true;
    } on Object catch (failure) {
      state = state.copyWith(error: AppError.from(failure));
      return false;
    }
  }

  // ── Decisions ───────────────────────────────────────────────────────────

  /// Answers the one pending decision.
  Future<void> answer(DecisionOption? option) async {
    final executor = _executor;
    final decision = state.pendingDecision;
    if (executor == null || decision == null) return;

    final resolved = decision.resolve(option);
    state = state.copyWith(
      decisions: <Decision>[
        for (final existing in state.decisions)
          if (existing.id == decision.id) resolved else existing,
      ],
    );

    try {
      await executor.answer(
        DecisionAnswer(decisionId: decision.id, optionId: option?.id),
      );
    } on Object catch (failure) {
      // The agent never received this answer, so the decision is still open.
      // Putting it back means the approval sheet can ask again instead of the
      // UI claiming a decision that was never delivered.
      state = state.copyWith(
        decisions: <Decision>[
          for (final existing in state.decisions)
            if (existing.id == decision.id) decision else existing,
        ],
        error: AppError.from(failure),
      );
    }
  }

  // ── Events ──────────────────────────────────────────────────────────────

  void _onEvent(ExecutorEvent event) {
    switch (event) {
      case DecisionRaised(:final decision):
        state = state.copyWith(
          decisions: <Decision>[...state.decisions, decision],
        );
      case SurfacesChanged():
        final executor = _executor;
        if (executor != null) {
          state = state.copyWith(surfaces: executor.surfaces);
        }
      default:
        break;
    }
  }

  void _onConnection(ExecutorConnection connection) {
    if (connection == ExecutorConnection.closed) {
      unawaited(_lost());
      return;
    }
    if (connection == ExecutorConnection.connected && _connecting) {
      // The transport is up, but the handshake and the first session are still
      // running. Reporting "connected" here would re-enable the connect button
      // in the middle of the attempt.
      return;
    }

    final status = switch (connection) {
      ExecutorConnection.connecting => ConnectionStatus.connecting,
      ExecutorConnection.connected => ConnectionStatus.connected,
      ExecutorConnection.reconnecting => ConnectionStatus.reconnecting,
      ExecutorConnection.closed ||
      ExecutorConnection.failed => ConnectionStatus.failed,
    };
    if (status == state.status) return;
    state = state.copyWith(status: status);
  }

  /// The transport is gone for good, and the session went with it.
  ///
  /// Keeping the session would strand the person in a chat whose composer is
  /// disabled and whose only exit is the session panel. Dropping it lets the
  /// route guard take them back to the server list, where the reason and a
  /// retry are on screen.
  Future<void> _lost() async {
    final profile = state.profile;
    await _teardown();
    state = ConnectionSnapshot(
      profile: profile,
      status: ConnectionStatus.failed,
      error: const NetworkUnavailable('The connection to the agent was lost.'),
    );
  }
}
