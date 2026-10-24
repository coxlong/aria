import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A scripted ACP bridge for end-to-end tests.
///
/// It speaks just enough of the wire format to exercise the real app: the
/// initialize handshake with its capability surface, a session list, session
/// create/load, model and mode switching, one permission request, and a
/// streamed turn. No agent and no network involved.
final class FakeBridge {
  FakeBridge._(this._server);

  static const String sessionId = 'fake-session-1';
  static const String previousSessionId = 'fake-session-0';

  final HttpServer _server;
  final List<WebSocket> _sockets = <WebSocket>[];
  final Map<int, Completer<Map<String, Object?>>> _pending =
      <int, Completer<Map<String, Object?>>>{};
  int _nextId = 1000;
  String _modelId = 'sonnet';
  String _modeId = 'default';
  String _effort = 'medium';

  /// Port the bridge listens on.
  int get port => _server.port;

  String get url => 'ws://127.0.0.1:$port';

  /// Whether the permission request was answered by the client.
  bool answeredPermission = false;

  /// Whether the client selected an option rather than cancelling.
  bool permissionAllowed = false;

  /// The option the client sent back for the permission request.
  String? lastPermissionOptionId;

  /// The session the client last asked to load with `session/load`.
  String? lastLoadedSessionId;

  /// Requests the client made, in order, for assertions.
  final List<String> methods = <String>[];

  /// Starts the bridge. Port 0 asks the OS for a free one.
  static Future<FakeBridge> start([int port = 0]) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    final bridge = FakeBridge._(server);
    server.listen(bridge._onRequest);
    return bridge;
  }

  Future<void> close() async {
    for (final socket in _sockets) {
      await socket.close();
    }
    _sockets.clear();
    await _server.close(force: true);
  }

  Future<void> _onRequest(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }
    final socket = await WebSocketTransformer.upgrade(
      request,
      protocolSelector: (protocols) =>
          protocols.contains('acp.v1') ? 'acp.v1' : null,
    );
    _sockets.add(socket);
    socket.listen(
      (data) => _onFrame(socket, data as String),
      onDone: () => _sockets.remove(socket),
      onError: (Object _) => _sockets.remove(socket),
    );
  }

  void _onFrame(WebSocket socket, String raw) {
    for (final line in const LineSplitter().convert(raw)) {
      if (line.trim().isEmpty) continue;
      final Object? decoded;
      try {
        decoded = jsonDecode(line);
      } on FormatException {
        continue;
      }
      if (decoded is! Map<String, Object?>) continue;

      final id = decoded['id'];
      final method = decoded['method'];

      if (method is String && id != null) {
        methods.add(method);
        _onClientRequest(socket, id, method, decoded['params']);
      } else if (method is String) {
        _onNotification(socket, method, decoded['params']);
      } else if (id != null) {
        // A response to one of our requests (the permission answer).
        _pending.remove(id)?.complete(decoded);
      }
    }
  }

  void _onClientRequest(
    WebSocket socket,
    Object id,
    String method,
    Object? params,
  ) {
    switch (method) {
      case 'initialize':
        _reply(socket, id, <String, Object?>{
          'protocolVersion': 1,
          'agentCapabilities': <String, Object?>{
            'loadSession': true,
            'sessionCapabilities': <String, Object?>{
              'list': <String, Object?>{},
              'delete': <String, Object?>{},
            },
          },
        });
      case 'session/new':
        _reply(socket, id, _sessionResult(sessionId));
      case 'session/load':
        final requested = params is Map<String, Object?>
            ? params['sessionId'] as String? ?? sessionId
            : sessionId;
        unawaited(_replayThenReply(socket, id, requested));
      case 'session/list':
        _reply(socket, id, <String, Object?>{
          'sessions': <Object?>[
            <String, Object?>{
              'sessionId': sessionId,
              'cwd': '/work',
              'title': 'Prepare the beta release',
              'updatedAt': '2026-10-24T09:30:00Z',
            },
            <String, Object?>{
              'sessionId': previousSessionId,
              'cwd': '/work',
              'title': 'Audit the billing migration',
              'updatedAt': '2026-10-23T18:00:00Z',
            },
          ],
        });
      case 'session/delete':
        _reply(socket, id, const <String, Object?>{});
      case 'session/set_model':
        _modelId = (params is Map<String, Object?>)
            ? params['modelId'] as String? ?? _modelId
            : _modelId;
        _reply(socket, id, const <String, Object?>{});
      case 'session/set_mode':
        _modeId = (params is Map<String, Object?>)
            ? params['modeId'] as String? ?? _modeId
            : _modeId;
        _reply(socket, id, const <String, Object?>{});
      case 'session/set_config_option':
        if (params is Map<String, Object?>) {
          final value = params['value'];
          if (value is String) _effort = value;
        }
        _reply(socket, id, const <String, Object?>{});
      case 'session/prompt':
        unawaited(_runTurn(socket, id));
      case 'session/close':
        _reply(socket, id, const <String, Object?>{});
      default:
        _send(socket, <String, Object?>{
          'jsonrpc': '2.0',
          'id': id,
          'error': <String, Object?>{
            'code': -32601,
            'message': 'Method not found: $method',
          },
        });
    }
  }

  Map<String, Object?> _sessionResult(String id) => <String, Object?>{
    'sessionId': id,
    'models': <String, Object?>{
      'availableModels': <Object?>[
        <String, Object?>{'modelId': 'sonnet', 'name': 'Sonnet 4.5'},
        <String, Object?>{'modelId': 'opus', 'name': 'Opus 5'},
      ],
      'currentModelId': _modelId,
    },
    'modes': <String, Object?>{
      'availableModes': <Object?>[
        <String, Object?>{'id': 'default', 'name': 'Default'},
        <String, Object?>{'id': 'plan', 'name': 'Plan'},
      ],
      'currentModeId': _modeId,
    },
    'configOptions': <Object?>[
      <String, Object?>{
        'id': 'effort',
        'category': 'thought_level',
        'currentValue': _effort,
        'options': <Object?>[
          <String, Object?>{'value': 'low', 'name': 'Low'},
          <String, Object?>{'value': 'medium', 'name': 'Medium'},
          <String, Object?>{'value': 'high', 'name': 'High'},
        ],
      },
    ],
  };

  /// `session/load` replays history before it answers, the way real agents do.
  ///
  /// Each session has its own history: the previous one talks about the billing
  /// migration, the current one about the release checklist. A client that
  /// loads the wrong session, or replays into the one still open, then shows
  /// text the test is not looking for.
  Future<void> _replayThenReply(
    WebSocket socket,
    Object id,
    String loaded,
  ) async {
    lastLoadedSessionId = loaded;
    final history = loaded == previousSessionId
        ? const <(String, String)>[
            (
              'Audit the billing migration',
              'The migration is clean; 3 invoices need a manual look.',
            ),
          ]
        : const <(String, String)>[
            (
              'Prepare the beta release',
              'The checklist is drafted and waiting for the build.',
            ),
          ];

    for (final (question, answer) in history) {
      _send(socket, <String, Object?>{
        'jsonrpc': '2.0',
        'method': 'session/update',
        'params': <String, Object?>{
          'sessionId': loaded,
          'update': <String, Object?>{
            'sessionUpdate': 'user_message_chunk',
            'content': <String, Object?>{'type': 'text', 'text': question},
          },
        },
      });
      _send(socket, <String, Object?>{
        'jsonrpc': '2.0',
        'method': 'session/update',
        'params': <String, Object?>{
          'sessionId': loaded,
          'update': <String, Object?>{
            'sessionUpdate': 'agent_message_chunk',
            'content': <String, Object?>{'type': 'text', 'text': answer},
          },
        },
      });
    }
    await _pause();
    _reply(socket, id, _sessionResult(loaded));
  }

  void _onNotification(WebSocket socket, String method, Object? params) {
    if (method == 'session/cancel') {
      // The turn future is completed by whoever is awaiting the prompt.
    }
  }

  /// The scripted turn: thinking, two tool calls, partial answer, one decision,
  /// one more tool call, then the rest of the answer.
  Future<void> _runTurn(WebSocket socket, Object id) async {
    await _update(socket, <String, Object?>{
      'sessionUpdate': 'agent_thought_chunk',
      'content': <String, Object?>{
        'type': 'text',
        'text': 'Checking the release checklist first. ',
      },
    });
    await _toolCall(socket, 'tc1', 'Read the release checklist');
    await _pause();
    await _toolDone(socket, 'tc1', '12 items, 3 blocked');

    await _toolCall(socket, 'tc2', 'Run the integration suite');
    await _pause();
    await _toolDone(socket, 'tc2', '38 passed, 0 failed');

    await _chunk(socket, 'The build is ready and the notes are written. ');

    await _askPermission(socket);

    if (permissionAllowed) {
      await _toolCall(socket, 'tc3', 'Publish the beta');
      await _pause();
      await _toolDone(socket, 'tc3', 'Published aria@0.1.0-beta.1');
      await _chunk(socket, 'The beta is published to the public channel.');
    } else {
      await _chunk(socket, 'Publishing is waiting on your approval.');
    }

    _reply(socket, id, <String, Object?>{'stopReason': 'end_turn'});
  }

  Future<void> _askPermission(WebSocket socket) async {
    final id = _nextId++;
    final completer = Completer<Map<String, Object?>>();
    _pending[id] = completer;

    _send(socket, <String, Object?>{
      'jsonrpc': '2.0',
      'id': id,
      'method': 'session/request_permission',
      'params': <String, Object?>{
        'sessionId': sessionId,
        'toolCall': <String, Object?>{
          'toolCallId': 'tc3',
          'title': 'Allow publishing the beta?',
          'kind': 'execute',
          'status': 'pending',
          'content': <Object?>[
            <String, Object?>{
              'type': 'content',
              'content': <String, Object?>{
                'type': 'text',
                'text': 'npm publish aria@0.1.0-beta.1 --tag beta',
              },
            },
          ],
        },
        'options': <Object?>[
          <String, Object?>{
            'optionId': 'allow_once',
            'name': 'Allow once',
            'kind': 'allow_once',
          },
          <String, Object?>{
            'optionId': 'reject_once',
            'name': 'Not now',
            'kind': 'reject_once',
          },
        ],
      },
    });

    final response = await completer.future;
    answeredPermission = true;
    final result = response['result'];
    if (result is! Map<String, Object?>) return;
    final outcome = result['outcome'];
    if (outcome is! Map<String, Object?>) return;
    final selected = outcome['outcome'] == 'selected';
    final optionId = outcome['optionId'];
    lastPermissionOptionId = optionId is String ? optionId : null;
    // "selected" is only an approval when it names an allow option: a client
    // that sends the reject id (or a made-up one) must not be counted as
    // having been allowed to publish.
    permissionAllowed = selected && optionId == 'allow_once';
  }

  Future<void> _toolCall(WebSocket socket, String id, String title) =>
      _update(socket, <String, Object?>{
        'sessionUpdate': 'tool_call',
        'toolCall': <String, Object?>{
          'toolCallId': id,
          'title': title,
          'kind': 'execute',
          'status': 'pending',
        },
      });

  Future<void> _toolDone(WebSocket socket, String id, String output) =>
      _update(socket, <String, Object?>{
        'sessionUpdate': 'tool_call_update',
        'toolCallId': id,
        'status': 'completed',
        'content': <Object?>[
          <String, Object?>{
            'type': 'content',
            'content': <String, Object?>{'type': 'text', 'text': output},
          },
        ],
      });

  Future<void> _chunk(WebSocket socket, String text) =>
      _update(socket, <String, Object?>{
        'sessionUpdate': 'agent_message_chunk',
        'content': <String, Object?>{'type': 'text', 'text': text},
      });

  Future<void> _update(WebSocket socket, Map<String, Object?> update) async {
    _send(socket, <String, Object?>{
      'jsonrpc': '2.0',
      'method': 'session/update',
      'params': <String, Object?>{'sessionId': sessionId, 'update': update},
    });
    await _pause();
  }

  void _reply(WebSocket socket, Object id, Map<String, Object?> result) =>
      _send(socket, <String, Object?>{
        'jsonrpc': '2.0',
        'id': id,
        'result': result,
      });

  void _send(WebSocket socket, Map<String, Object?> frame) {
    // The app may close the socket at any time (teardown, stop, disconnect).
    if (socket.readyState != WebSocket.open) return;
    try {
      socket.add('${jsonEncode(frame)}\n');
    } on StateError {
      // Racing with the close handshake is expected, not an error.
    }
  }

  static Future<void> _pause() =>
      Future<void>.delayed(const Duration(milliseconds: 30));
}

/// Runs the bridge standalone: `dart run tool/fake_bridge.dart [port]`.
Future<void> main(List<String> arguments) async {
  final requested = arguments.isEmpty ? 3000 : int.parse(arguments.first);
  final bridge = await FakeBridge.start(requested);
  stdout.writeln('Fake ACP bridge listening on ${bridge.url}');
}
