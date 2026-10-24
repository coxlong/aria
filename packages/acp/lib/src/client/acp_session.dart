part of 'acp_client.dart';

/// A live ACP session.
///
/// Updates are delivered on a single-subscription stream that buffers frames
/// until the caller subscribes. This matters for `session/load`: the agent
/// replays history before the load request resolves, so a caller that only
/// subscribes after awaiting [AcpClient.loadSession] would otherwise lose it.
final class AcpSession {
  final AcpClient _client;

  /// Agent-assigned session id.
  final String id;

  /// Working directory this session was created with.
  final String cwd;

  final StreamController<SessionUpdate> _updates =
      StreamController<SessionUpdate>(sync: true);

  /// Model surface advertised by the agent.
  SessionModels models;

  /// Mode surface advertised by the agent.
  SessionModes modes;

  /// Reasoning-effort surface advertised by the agent.
  SessionEfforts efforts;

  bool _running = false;
  bool _replaying = false;
  bool _disposed = false;
  int? _promptRequestId;
  Timer? _cancelWatchdog;

  AcpSession._({
    required this._client,
    required this.id,
    required this.cwd,
    required Map<String, Object?> initial,
  }) : models = SessionModels.fromSessionResult(initial),
       modes = SessionModes.fromSessionResult(initial),
       efforts = SessionEfforts.fromSessionResult(initial);

  /// Ordered session updates. Single subscription; late subscribers receive
  /// the updates that were buffered before they attached.
  Stream<SessionUpdate> get updates => _updates.stream;

  /// Whether a prompt turn is currently running.
  bool get isRunning => _running;

  /// Whether history replay is in flight.
  bool get isReplaying => _replaying;

  /// Sends a text prompt and resolves when the turn ends.
  ///
  /// The protocol has no request timeout for prompts: the response only
  /// arrives at the stop reason, possibly after a long tool call or a
  /// permission wait.
  Future<PromptResult> prompt(String text) async {
    if (_disposed) throw StateError('Session $id is closed');
    if (_running) {
      throw StateError('A prompt turn is already running for session $id');
    }
    _running = true;
    try {
      final response = await _client._request(
        AcpMethods.prompt,
        <String, Object?>{
          'sessionId': id,
          'prompt': <Object?>[
            <String, Object?>{'type': 'text', 'text': text},
          ],
        },
        noTimeout: true,
        onId: (requestId) => _promptRequestId = requestId,
      );
      return PromptResult.fromJson(AcpClient._result(response));
    } finally {
      _promptRequestId = null;
      _running = false;
      _cancelWatchdog?.cancel();
      _cancelWatchdog = null;
    }
  }

  /// Cancels the running turn.
  ///
  /// Any unanswered permission request is answered as cancelled first, because
  /// the agent blocks the turn on that response. A watchdog completes the
  /// prompt locally if the agent never replies to the cancellation.
  Future<void> cancel() async {
    await _client._answerPermissionsFor(id);
    await _client._notify(AcpMethods.cancel, <String, Object?>{
      'sessionId': id,
    });

    final requestId = _promptRequestId;
    if (!_running || requestId == null) return;
    _cancelWatchdog?.cancel();
    _cancelWatchdog = Timer(_client.cancelTimeout, () {
      _client._abandon(requestId, 'cancelled');
    });
  }

  /// Switches the model, using the shape the agent advertised.
  Future<void> setModel(String modelId) async {
    final configId = models.configId;
    if (configId != null) {
      await _client._request(AcpMethods.setConfigOption, <String, Object?>{
        'sessionId': id,
        'configId': configId,
        'value': modelId,
      });
    } else {
      await _client._request(AcpMethods.setModel, <String, Object?>{
        'sessionId': id,
        'modelId': modelId,
      });
    }
    models = SessionModels(
      available: models.available,
      currentModelId: modelId,
      configId: models.configId,
    );
  }

  /// Switches the session mode.
  Future<void> setMode(String modeId) async {
    await _client._request(AcpMethods.setMode, <String, Object?>{
      'sessionId': id,
      'modeId': modeId,
    });
    modes = SessionModes(available: modes.available, currentModeId: modeId);
  }

  /// Sets an arbitrary session config option.
  Future<void> setConfigOption(String configId, String value) async {
    await _client._request(AcpMethods.setConfigOption, <String, Object?>{
      'sessionId': id,
      'configId': configId,
      'value': value,
    });
    if (configId == models.configId) {
      models = SessionModels(
        available: models.available,
        currentModelId: value,
        configId: models.configId,
      );
    }
    if (configId == efforts.configId) {
      efforts = SessionEfforts(
        available: efforts.available,
        currentValue: value,
        configId: efforts.configId,
      );
    }
  }

  /// Releases the session on the agent and locally.
  Future<void> close() async {
    if (_disposed) return;
    if (_running) {
      try {
        await cancel();
      } on Object {
        // Best effort: the agent may already be gone.
      }
      // The session is going away, so the in-flight turn must settle even if
      // the agent never acknowledges the cancellation.
      final pendingPrompt = _promptRequestId;
      if (pendingPrompt != null) {
        _client._abandon(pendingPrompt, 'cancelled');
      }
    }
    try {
      await _client._request(AcpMethods.closeSession, <String, Object?>{
        'sessionId': id,
      });
    } on Object {
      // Closing is best effort; local teardown must still happen.
    }
    _client._forgetSession(this);
    _dispose();
  }

  // ── Internal hooks used by AcpClient ────────────────────────────────────

  void _emit(SessionUpdate update) {
    if (_disposed || _updates.isClosed) return;
    switch (update) {
      case CurrentModeUpdate(:final modeId):
        modes = SessionModes(available: modes.available, currentModeId: modeId);
      case ConfigOptionUpdate(:final configOptions):
        final nextModels = SessionModels.fromConfigOptions(configOptions);
        final nextEfforts = SessionEfforts.fromConfigOptions(configOptions);
        if (nextModels.hasModels) models = nextModels;
        if (nextEfforts.hasEfforts) efforts = nextEfforts;
      default:
        break;
    }
    _updates.add(update);
  }

  void _applySessionResult(Map<String, Object?> result) {
    if (result.isEmpty) return;
    final nextModels = SessionModels.fromSessionResult(result);
    final nextModes = SessionModes.fromSessionResult(result);
    final nextEfforts = SessionEfforts.fromSessionResult(result);
    if (nextModels.hasModels) models = nextModels;
    if (nextModes.hasModes) modes = nextModes;
    if (nextEfforts.hasEfforts) efforts = nextEfforts;
  }

  void _beginReplay() => _replaying = true;

  void _endReplay() => _replaying = false;

  void _onTransportClosed() {
    _running = false;
    _promptRequestId = null;
    _cancelWatchdog?.cancel();
    _cancelWatchdog = null;
  }

  void _dispose() {
    if (_disposed) return;
    _disposed = true;
    // Every disposal path (close, delete, replace, release) must settle the
    // in-flight prompt locally: the agent will not answer a request for a
    // session this client no longer follows, and a prompt has no timeout.
    final pendingPrompt = _promptRequestId;
    _promptRequestId = null;
    if (pendingPrompt != null) _client._abandon(pendingPrompt, 'cancelled');
    _running = false;
    _cancelWatchdog?.cancel();
    _cancelWatchdog = null;
    if (!_updates.isClosed) unawaited(_updates.close());
  }
}
