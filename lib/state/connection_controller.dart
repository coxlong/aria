import 'dart:async';

import 'package:acp/acp.dart';
import 'package:flutter/foundation.dart';

import '../core/error_mapping.dart';
import '../core/models/server_profile.dart';
import '../core/persistence/server_store.dart';
import 'conversation_controller.dart';

/// App-level lifecycle of the active connection.
enum ConnectionStatus {
  /// No client; the connect page is showing.
  disconnected,

  /// The transport is opening or the handshake is running.
  connecting,

  /// A session is live and prompts can be sent.
  connected,

  /// The socket dropped and the transport is retrying.
  reconnecting,

  /// The connection failed and is no longer usable.
  error,
}

/// Builds an [AcpClient] for [profile]. Replaced in tests.
typedef AcpClientFactory = Future<AcpClient> Function(ServerProfile profile);

/// Opens a WebSocket transport and wraps it in a client.
Future<AcpClient> openWebSocketClient(ServerProfile profile) async {
  final transport = await WsTransport.connect(
    Uri.parse(profile.url),
    token: profile.token.isEmpty ? null : profile.token,
  );
  return AcpClient(transport);
}

/// Owns the ACP client, the active session and the reconnect state.
///
/// The controller is the only place that creates an [AcpClient]. It keeps
/// connection state and turn state separate: a reconnect never ends a turn and
/// a turn never changes the connection state.
final class ConnectionController extends ChangeNotifier {
  ConnectionController({
    required this.conversation,
    required this.store,
    AcpClientFactory? factory,
  }) : _factory = factory ?? openWebSocketClient;

  final ConversationController conversation;
  final ServerStore store;
  final AcpClientFactory _factory;

  AcpClient? _client;
  AcpSession? _session;
  StreamSubscription<AcpTransportState>? _stateSubscription;
  StreamSubscription<PermissionRequest>? _permissionSubscription;
  StreamSubscription<SessionUpdate>? _updateSubscription;
  final List<PermissionRequest> _permissions = <PermissionRequest>[];

  bool _disposed = false;

  /// Server the current connection belongs to.
  ServerProfile? profile;

  ConnectionStatus status = ConnectionStatus.disconnected;

  /// Last failure, mapped to a localizable category.
  AriaError? error;

  /// Sessions reported by the agent (or the local cache).
  List<SessionSummary> sessions = const <SessionSummary>[];

  /// Whether the agent accepts `session/delete`.
  bool canDeleteSessions = false;

  /// Whether a prompt turn is in flight.
  bool running = false;

  /// Whether the running turn is being cancelled.
  bool stopping = false;

  AcpSession? get session => _session;

  bool get canSend =>
      status == ConnectionStatus.connected && _session != null && !running;

  /// The permission request the agent is currently blocked on.
  PermissionRequest? get pendingPermission =>
      _permissions.isEmpty ? null : _permissions.first;

  SessionModels get models =>
      _session?.models ?? const SessionModels(available: <SessionModel>[]);

  SessionModes get modes =>
      _session?.modes ?? const SessionModes(available: <SessionMode>[]);

  SessionEfforts get efforts =>
      _session?.efforts ?? const SessionEfforts(available: <SessionEffort>[]);

  // ── Connection lifecycle ────────────────────────────────────────────────

  /// Opens a connection to [target] and starts a fresh session.
  Future<void> connect(ServerProfile target) async {
    if (status == ConnectionStatus.connecting) return;

    await _closeConnection();

    profile = target;
    status = ConnectionStatus.connecting;
    error = null;
    sessions = const <SessionSummary>[];
    canDeleteSessions = false;
    running = false;
    stopping = false;
    conversation.reset();
    _notify();

    try {
      final client = await _factory(target);
      _client = client;
      _stateSubscription = client.states.listen(_onTransportState);
      _permissionSubscription = client.permissionRequests.listen(
        _onPermissionRequest,
      );

      final init = await client.initialize();
      canDeleteSessions = init.supportsSessionDelete;
      final session = await client.newSession(cwd: _cwdOf(target));
      _session = session;
      _listenToSession(session);

      status = ConnectionStatus.connected;
      _notify();

      try {
        final cached = await store.loadSessions(target.id);
        if (cached.isNotEmpty) {
          sessions = cached;
          _notify();
        }
      } on Object {
        // A cache miss must never block the connection.
      }
      unawaited(refreshSessions());
    } on Object catch (failure) {
      error = mapAriaError(failure);
      status = ConnectionStatus.error;
      await _closeConnection();
      _notify();
    }
  }

  /// Closes the connection and returns to the connect page.
  Future<void> disconnect() async {
    await _closeConnection();
    profile = null;
    status = ConnectionStatus.disconnected;
    error = null;
    sessions = const <SessionSummary>[];
    canDeleteSessions = false;
    conversation.reset();
    _notify();
  }

  /// Replaces the active session with a fresh one.
  Future<void> newSession() async {
    final client = _client;
    final current = profile;
    if (client == null || current == null) return;

    final previous = _session;
    await _updateSubscription?.cancel();
    _updateSubscription = null;

    try {
      final session = await client.newSession(cwd: _cwdOf(current));
      _session = session;
      _listenToSession(session);
      conversation.reset();
      error = null;
      if (previous != null && previous.id != session.id) {
        unawaited(previous.close());
      }
    } on Object catch (failure) {
      error = mapAriaError(failure);
    }
    _notify();
  }

  /// Loads a session and replays its history into the conversation.
  Future<void> openSession(String sessionId) async {
    final client = _client;
    final current = profile;
    if (client == null || current == null) return;

    final previous = _session;
    await _updateSubscription?.cancel();
    _updateSubscription = null;

    conversation.reset();
    conversation.beginReplay();
    try {
      final session = await client.loadSession(
        sessionId: sessionId,
        cwd: _cwdOf(current),
      );
      _session = session;
      _listenToSession(session);
      error = null;
      // Replayed frames are buffered by the session and delivered one
      // microtask each, so ending replay in a microtask would race them. A
      // zero-delay timer runs after the microtask queue has drained.
      Timer(Duration.zero, conversation.endReplay);
      if (previous != null && previous.id != session.id) {
        unawaited(previous.close());
      }
    } on Object catch (failure) {
      conversation.endReplay();
      error = mapAriaError(failure);
    }
    _notify();
  }

  /// Deletes a conversation on the agent and in the local list.
  ///
  /// Deleting the active session closes it and starts a fresh one, because the
  /// UI always needs a session to keep chatting.
  Future<void> deleteSession(String sessionId) async {
    final client = _client;
    final current = profile;
    if (client == null || current == null) return;

    final deletingActive = _session?.id == sessionId;
    if (deletingActive) {
      final session = _session;
      _session = null;
      await _updateSubscription?.cancel();
      _updateSubscription = null;
      try {
        await session?.close();
      } on Object {
        // The agent may already consider the session gone.
      }
    }

    try {
      await client.deleteSession(sessionId);
      sessions = sessions
          .where((session) => session.sessionId != sessionId)
          .toList(growable: false);
      try {
        await store.saveSessions(current.id, sessions);
      } on Object {
        // The cache is best effort.
      }
    } on Object catch (failure) {
      error = mapAriaError(failure);
    }

    if (deletingActive) await newSession();
    _notify();
  }

  /// Refreshes the session list from the agent. Best effort: agents that do
  /// not implement `session/list` keep the cached list.
  Future<void> refreshSessions() async {
    final client = _client;
    final current = profile;
    if (client == null || current == null) return;

    final List<SessionSummary> fetched;
    try {
      fetched = await client.listSessions(cwd: _cwdOf(current));
    } on Object {
      return;
    }
    // The connection may have been replaced or closed while awaiting.
    if (_client != client) return;
    sessions = fetched;
    _notify();
    try {
      await store.saveSessions(current.id, fetched);
    } on Object {
      // The cache is a convenience; failing to write it is not an error.
    }
  }

  // ── Turn lifecycle ──────────────────────────────────────────────────────

  /// Sends [text] as a new turn. Resolves when the turn ends.
  Future<void> send(String text) async {
    final session = _session;
    final trimmed = text.trim();
    if (session == null || trimmed.isEmpty || running) return;
    if (status != ConnectionStatus.connected) return;

    running = true;
    stopping = false;
    error = null;
    conversation.beginTurn(trimmed);
    _notify();

    try {
      final result = await session.prompt(trimmed);
      conversation.endTurn(result.stopReason);
    } on Object catch (failure) {
      error = mapAriaError(failure);
      conversation.endTurn('error');
    } finally {
      running = false;
      stopping = false;
      _notify();
    }
  }

  /// Cancels the running turn. Pending permissions are answered as cancelled
  /// by the session before the cancel notification is sent.
  Future<void> stop() async {
    final session = _session;
    if (session == null || !running || stopping) return;

    stopping = true;
    _permissions.clear();
    _notify();
    try {
      await session.cancel();
    } on Object catch (failure) {
      error = mapAriaError(failure);
    }
    _notify();
  }

  // ── Permissions ─────────────────────────────────────────────────────────

  /// Answers the head permission request with [optionId].
  Future<void> allowPermission(String optionId) async {
    final request = pendingPermission;
    if (request == null) return;
    _permissions.remove(request);
    _notify();
    await request.allow(optionId);
  }

  /// Answers the head permission request as cancelled.
  Future<void> denyPermission() async {
    final request = pendingPermission;
    if (request == null) return;
    _permissions.remove(request);
    _notify();
    await request.deny();
  }

  // ── Configuration surfaces ──────────────────────────────────────────────

  Future<void> selectModel(String modelId) =>
      _apply((session) => session.setModel(modelId));

  Future<void> selectMode(String modeId) =>
      _apply((session) => session.setMode(modeId));

  Future<void> selectEffort(String value) async {
    final configId = _session?.efforts.configId;
    if (configId == null) return;
    await _apply((session) => session.setConfigOption(configId, value));
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_closeConnection());
    super.dispose();
  }

  // ── Internals ───────────────────────────────────────────────────────────

  Future<void> _apply(Future<void> Function(AcpSession session) action) async {
    final session = _session;
    if (session == null) return;
    try {
      await action(session);
      error = null;
    } on Object catch (failure) {
      error = mapAriaError(failure);
    }
    _notify();
  }

  void _listenToSession(AcpSession session) {
    _updateSubscription = session.updates.listen(
      _onUpdate,
      onError: (Object failure) {
        error = mapAriaError(failure);
        _notify();
      },
    );
  }

  void _onUpdate(SessionUpdate update) {
    conversation.apply(update);
    _notify();
  }

  void _onPermissionRequest(PermissionRequest request) {
    _permissions.add(request);
    _notify();
  }

  void _onTransportState(AcpTransportState next) {
    switch (next) {
      case AcpTransportState.connecting:
        if (status == ConnectionStatus.disconnected) {
          status = ConnectionStatus.connecting;
          _notify();
        }
      case AcpTransportState.connected:
        if (status == ConnectionStatus.reconnecting) {
          status = ConnectionStatus.connected;
          _notify();
        }
      case AcpTransportState.reconnecting:
        if (status == ConnectionStatus.connected) {
          status = ConnectionStatus.reconnecting;
          _notify();
        }
      case AcpTransportState.closed:
        if (status != ConnectionStatus.disconnected) {
          status = ConnectionStatus.error;
          error = AriaError(
            AriaErrorKind.network,
            const AcpTransportClosed('connection closed'),
          );
          _notify();
        }
    }
  }

  Future<void> _closeConnection() async {
    await _updateSubscription?.cancel();
    _updateSubscription = null;
    await _permissionSubscription?.cancel();
    _permissionSubscription = null;
    await _stateSubscription?.cancel();
    _stateSubscription = null;
    _permissions.clear();
    _session = null;
    running = false;
    stopping = false;

    final client = _client;
    _client = null;
    await client?.close();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  static String _cwdOf(ServerProfile profile) {
    final cwd = profile.cwd.trim();
    return cwd.isEmpty ? '/' : cwd;
  }
}
