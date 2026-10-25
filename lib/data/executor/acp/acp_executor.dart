import 'dart:async';
import 'dart:convert';

import 'package:acp/acp.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/app_error.dart';
import '../../../domain/chat/work_step.dart';
import '../../../domain/decision/decision.dart';
import '../../../domain/executor/executor.dart';
import '../../../domain/profile/server_profile.dart';
import '../../../domain/session/agent_session.dart';
import 'acp_debug_log.dart';

/// The ACP implementation of [Executor].
///
/// This is the only place that knows about [AcpClient], sessions, and permission
/// requests. Everything above it works with [ExecutorEvent], so a second
/// executor would not change a single screen.
final class AcpExecutor implements Executor {
  AcpExecutor({required this.profile});

  final ConnectedProfile profile;

  static const Uuid _ids = Uuid();

  final StreamController<ExecutorEvent> _events =
      StreamController<ExecutorEvent>.broadcast();
  final StreamController<ExecutorConnection> _connection =
      StreamController<ExecutorConnection>.broadcast();

  AcpClient? _client;
  Future<AcpClient>? _connecting;
  StreamSubscription<AcpTransportState>? _stateSubscription;
  StreamSubscription<PermissionRequest>? _permissionSubscription;

  AcpSession? _session;
  StreamSubscription<SessionUpdate>? _updates;

  /// Unanswered decisions, in arrival order.
  final List<MapEntry<String, PermissionRequest>> _permissions =
      <MapEntry<String, PermissionRequest>>[];

  /// Latest tool call per id. Patches only carry the fields that changed, and
  /// a later frame usually omits `rawInput`, so the previous value is what
  /// keeps a step's input from disappearing.
  final Map<String, ToolCallInfo> _calls = <String, ToolCallInfo>{};

  /// Debug-only transcript of the raw ACP wire. Off in release builds.
  late final AcpDebugLog? _frameLog =
      kDebugMode ? AcpDebugLog.open() : null;

  InitializeResult? _initialized;
  bool _disposed = false;

  @override
  Stream<ExecutorEvent> get events => _events.stream;

  @override
  Stream<ExecutorConnection> get connection => _connection.stream;

  @override
  SessionSurfaces get surfaces => _readSurfaces();

  // ── Connection ──────────────────────────────────────────────────────────

  @override
  Future<AgentCapabilities> connect() async {
    final client = await _connect();
    final init = await _initialize(client);
    return AgentCapabilities(
      canLoadSession: init.supportsLoadSession,
      canListSessions: init.supportsSessionList,
      canDeleteSession: init.supportsSessionDelete,
    );
  }

  Future<AcpClient> _connect() {
    final existing = _client;
    if (existing != null) return Future<AcpClient>.value(existing);
    return _connecting ??= _open();
  }

  Future<AcpClient> _open() async {
    _emitConnection(ExecutorConnection.connecting);
    AcpClient? client;
    try {
      final transport = await WsTransport.connect(
        Uri.parse(profile.profile.url),
        token: profile.token.isEmpty ? null : profile.token,
      );
      client = AcpClient(transport, onFrameLog: _frameLog?.call);
      _stateSubscription = client.states.listen(_onTransportState);
      _permissionSubscription = client.permissionRequests.listen(_onPermission);
      _client = client;
      return client;
    } on Object catch (failure) {
      _connecting = null;
      await _discard(client);
      _emitConnection(ExecutorConnection.failed);
      throw AppError.from(failure);
    }
  }

  Future<InitializeResult> _initialize(AcpClient client) async {
    try {
      final init = _initialized ?? await client.initialize();
      _initialized = init;
      _emitConnection(ExecutorConnection.connected);
      return init;
    } on Object catch (failure) {
      // Nothing came of this attempt: drop its subscriptions and close the
      // socket, or a failed handshake leaves a connection nobody owns.
      _connecting = null;
      await _discard(client);
      _client = null;
      _emitConnection(ExecutorConnection.failed);
      throw AppError.from(failure);
    }
  }

  Future<void> _discard(AcpClient? client) async {
    final states = _stateSubscription;
    _stateSubscription = null;
    await states?.cancel();
    final permissions = _permissionSubscription;
    _permissionSubscription = null;
    await permissions?.cancel();
    await client?.close();
  }

  void _onTransportState(AcpTransportState state) {
    final mapped = switch (state) {
      AcpTransportState.connecting => ExecutorConnection.connecting,
      AcpTransportState.connected => ExecutorConnection.connected,
      AcpTransportState.reconnecting => ExecutorConnection.reconnecting,
      AcpTransportState.closed => ExecutorConnection.closed,
    };
    _emitConnection(mapped);
  }

  // ── Sessions ────────────────────────────────────────────────────────────

  @override
  Future<List<AgentSessionSummary>> listSessions({String? cwd}) async {
    final client = await _clientOrThrow();
    final summaries = await client.listSessions(cwd: cwd);
    return <AgentSessionSummary>[
      for (final summary in summaries)
        AgentSessionSummary(
          id: summary.sessionId,
          cwd: summary.cwd,
          title: summary.title,
          updatedAt: summary.updatedAt,
        ),
    ];
  }

  @override
  Future<AgentSession> newSession({required String cwd}) async {
    final client = await _clientOrThrow();
    final session = await client.newSession(cwd: cwd);
    _hold(session);
    return AgentSession(id: session.id, cwd: session.cwd);
  }

  @override
  Future<AgentSession> openSession({
    required String id,
    required String cwd,
  }) async {
    final client = await _clientOrThrow();
    final session = await client.loadSession(sessionId: id, cwd: cwd);
    _hold(session);
    return AgentSession(id: session.id, cwd: session.cwd);
  }

  @override
  Future<void> deleteSession(String id) async {
    final client = await _clientOrThrow();
    await client.deleteSession(id);
  }

  /// Takes ownership of a session without subscribing to it yet.
  ///
  /// A resumed session replays its history before `loadSession` resolves, and
  /// the session buffers those frames until someone listens. Holding them back
  /// until [attach] means the chat surface is already listening when history
  /// arrives, so none of it is dropped.
  ///
  /// This executor follows one session at a time, so taking a new one releases
  /// the old one: its pending permissions are denied, its turn settles, and the
  /// client stops buffering updates nobody will read.
  void _hold(AcpSession session) {
    final previous = _session;
    unawaited(_updates?.cancel());
    _updates = null;
    _session = session;
    _calls.clear();
    if (previous == null || previous.id == session.id) return;

    _permissions.removeWhere((entry) => entry.value.sessionId == previous.id);
    unawaited(_client?.releaseSession(previous.id));
  }

  @override
  void attach(String sessionId) {
    final session = _session;
    if (session == null || session.id != sessionId) return;
    if (_updates != null) return;

    _updates = session.updates.listen(
      (update) => _onUpdate(session.id, update),
    );
  }

  Future<AcpClient> _clientOrThrow() async {
    final client = _client;
    if (client == null) {
      throw const UnknownFailure('The connection was closed');
    }
    return client;
  }

  // ── Turns ───────────────────────────────────────────────────────────────

  @override
  Future<void> prompt({required String sessionId, required String text}) async {
    try {
      final session = _session;
      if (session == null || session.id != sessionId) {
        throw const UnknownFailure('The session was closed');
      }
      final result = await session.prompt(text);
      _emit(ExecutionFinished(sessionId, stopReason: result.stopReason));
    } on Object catch (failure) {
      _emit(ExecutionFailed(sessionId, AppError.from(failure)));
    } finally {
      // Only this session's requests: another session may be showing an
      // approval of its own, and a turn ending elsewhere must not deny it.
      await _settlePendingPermissions(sessionId);
    }
  }

  @override
  Future<void> cancel(String sessionId) async {
    final session = _session;
    if (session == null || session.id != sessionId) return;
    await session.cancel();
  }

  @override
  Future<void> answer(DecisionAnswer answer) async {
    final index = _permissions.indexWhere(
      (entry) => entry.key == answer.decisionId,
    );
    if (index < 0) return;
    final request = _permissions.removeAt(index).value;

    final optionId = answer.optionId;
    if (optionId == null) {
      await request.deny();
      return;
    }
    // An option the agent did not offer cannot be sent.
    final offered = request.options.any(
      (candidate) => candidate.optionId == optionId,
    );
    await (offered ? request.allow(optionId) : request.deny());
  }

  /// A turn that has ended can no longer wait on a permission request. Anything
  /// this session still has unanswered is denied, so the agent is never left
  /// blocked on us.
  ///
  /// Scoped to [sessionId]: decisions belong to the session that raised them,
  /// and a turn ending in one session must leave another session's open
  /// approval alone.
  Future<void> _settlePendingPermissions(String sessionId) async {
    final pending = <MapEntry<String, PermissionRequest>>[];
    _permissions.removeWhere((entry) {
      if (entry.value.sessionId != sessionId) return false;
      pending.add(entry);
      return true;
    });
    for (final entry in pending) {
      try {
        await entry.value.deny();
      } on Object {
        // The turn is already over; a failed denial changes nothing here.
      }
    }
  }

  // ── Configuration ───────────────────────────────────────────────────────

  @override
  Future<void> setModel(String id) async {
    final session = _requireSession();
    await session.setModel(id);
    _emitSurfaces(session);
  }

  @override
  Future<void> setMode(String id) async {
    final session = _requireSession();
    await session.setMode(id);
    _emitSurfaces(session);
  }

  @override
  Future<void> setConfigOption(String configId, String value) async {
    final session = _requireSession();
    await session.setConfigOption(configId, value);
    _emitSurfaces(session);
  }

  AcpSession _requireSession() {
    final session = _session;
    if (session == null) {
      throw const UnknownFailure('No session is open');
    }
    return session;
  }

  SessionSurfaces _readSurfaces() {
    final session = _session;
    if (session == null) return SessionSurfaces.none;

    final models = session.models;
    final modes = session.modes;
    final efforts = session.efforts;
    return SessionSurfaces(
      models: <SessionOption>[
        for (final model in models.available)
          SessionOption(id: model.modelId, label: model.name),
      ],
      currentModelId: models.currentModelId,
      modes: <SessionOption>[
        for (final mode in modes.available)
          SessionOption(id: mode.id, label: mode.name),
      ],
      currentModeId: modes.currentModeId,
      efforts: <SessionOption>[
        for (final effort in efforts.available)
          SessionOption(id: effort.value, label: effort.name),
      ],
      currentEffortValue: efforts.currentValue,
      effortConfigId: efforts.configId,
    );
  }

  void _emitSurfaces(AcpSession session) {
    _emit(SurfacesChanged(session.id));
  }

  // ── Updates ─────────────────────────────────────────────────────────────

  void _onUpdate(String sessionId, SessionUpdate update) {
    switch (update) {
      case UserMessageChunk(:final text):
        _emit(UserPrompt(sessionId, text));
      case AgentMessageChunk(:final text):
        _emit(AgentText(sessionId, text));
      case AgentThoughtChunk(:final text):
        _emit(AgentThought(sessionId, text));
      case ToolCallStarted(:final toolCall):
        _emit(StepChanged(sessionId, _stepOf(toolCall)));
      case ToolCallPatched(
        :final toolCallId,
        :final title,
        :final status,
        :final rawInput,
        :final rawOutput,
        :final content,
        :final meta,
      ):
        // Merge onto the last frame that carried each field: null means
        // "unchanged" in the protocol, and a patch that only reports status
        // must not wipe the input the start frame supplied.
        final merged = (_calls[toolCallId] ??
                ToolCallInfo(id: toolCallId, title: title ?? ''))
            .copyWith(
              title: title,
              status: status,
              rawInput: rawInput,
              rawOutput: rawOutput,
              content: content,
              meta: meta,
            );
        _emit(StepChanged(sessionId, _stepOf(merged)));
      case CurrentModeUpdate():
      case ConfigOptionUpdate():
        _emit(SurfacesChanged(sessionId));
      case UnknownSessionUpdate():
        break;
    }
  }

  void _onPermission(PermissionRequest request) {
    final session = _session;
    if (session == null || session.id != request.sessionId) {
      // A permission request must be answered exactly once, even when it
      // arrives for a session this client no longer holds.
      unawaited(request.deny());
      return;
    }

    final decision = Decision(
      id: _ids.v4(),
      prompt: request.toolCall.title,
      detail: _permissionDetail(request),
      options: request.options
          .map(
            (option) => DecisionOption(
              id: option.optionId,
              label: option.name,
              kind: DecisionOptionKind.parse(option.kind),
            ),
          )
          .toList(growable: false),
      createdAt: DateTime.now(),
      highImpact: _isHighImpact(request.toolCall),
    );
    _permissions.add(MapEntry<String, PermissionRequest>(decision.id, request));
    _emit(DecisionRaised(session.id, decision));
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  void _emit(ExecutorEvent event) {
    if (_disposed) return;
    _events.add(event);
  }

  void _emitConnection(ExecutorConnection state) {
    if (_disposed) return;
    _connection.add(state);
  }

  WorkStep _stepOf(ToolCallInfo call) {
    _calls[call.id] = call;
    return WorkStep(
      id: call.id,
      title: call.title,
      status: _stepStatus(call.status),
      detail: _detailOf(call.content),
      input: _encode(call.rawInput),
      output: _encode(call.rawOutput),
    );
  }

  static StepStatus _stepStatus(String? status) => switch (status) {
    'completed' => StepStatus.completed,
    'failed' => StepStatus.failed,
    'in_progress' => StepStatus.running,
    _ => StepStatus.pending,
  };

  static String? _detailOf(List<Map<String, Object?>>? content) {
    if (content == null || content.isEmpty) return null;
    final buffer = StringBuffer();
    for (final block in content) {
      final inner = block['content'];
      if (inner is Map<String, Object?> && inner['text'] is String) {
        if (buffer.isNotEmpty) buffer.write('\n');
        buffer.write(inner['text'] as String);
      }
    }
    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String? _encode(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } on JsonUnsupportedObjectError {
      return '$value';
    }
  }

  static String? _permissionDetail(PermissionRequest request) {
    final text = request.toolCall.contentText.trim();
    if (text.isNotEmpty) return text;
    final targets = request.toolCall.locations;
    if (targets != null && targets.isNotEmpty) {
      final path = targets.first['path'];
      if (path is String) return path;
    }
    final kind = request.toolCall.kind;
    return kind == null || kind.isEmpty ? null : kind;
  }

  /// Irreversible or outward-facing actions are marked in the approval sheet.
  static bool _isHighImpact(ToolCallInfo call) {
    final name = '${call.toolName ?? ''} ${call.kind ?? ''} ${call.title}'
        .toLowerCase();
    const markers = <String>[
      'publish',
      'deploy',
      'delete',
      'remove',
      'push',
      'release',
      'payment',
      'purchase',
    ];
    return markers.any(name.contains);
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _updates?.cancel();
    await _discard(_client);
    _client = null;
    _session = null;
    _permissions.clear();
    _calls.clear();
    _frameLog?.close();
    await _events.close();
    await _connection.close();
  }
}
