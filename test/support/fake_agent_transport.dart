import 'dart:async';
import 'dart:convert';

import 'package:acp/acp.dart';

/// An in-memory ACP agent used by the controller tests.
///
/// Requests are answered synchronously; prompts are held until the test calls
/// [completePrompt], which lets a test interleave `session/update` frames with
/// the in-flight turn.
final class FakeAgentTransport implements AcpTransport {
  FakeAgentTransport({Map<String, Object?>? sessionResult})
    : _sessionResult = sessionResult ?? defaultSessionResult;

  /// Config options + modes, the standard agent shape.
  static const Map<String, Object?> defaultSessionResult = <String, Object?>{
    'configOptions': <Object?>[
      <String, Object?>{
        'id': 'model',
        'category': 'model',
        'currentValue': 'm1',
        'options': <Object?>[
          <String, Object?>{'value': 'm1', 'name': 'Model One'},
          <String, Object?>{'value': 'm2', 'name': 'Model Two'},
        ],
      },
      <String, Object?>{
        'id': 'thought_level',
        'category': 'thought_level',
        'currentValue': 'medium',
        'options': <Object?>[
          <String, Object?>{'value': 'low', 'name': 'Low'},
          <String, Object?>{'value': 'high', 'name': 'High'},
        ],
      },
    ],
    'modes': <String, Object?>{
      'currentModeId': 'code',
      'availableModes': <Object?>[
        <String, Object?>{'id': 'code', 'name': 'Code'},
        <String, Object?>{'id': 'plan', 'name': 'Plan'},
      ],
    },
  };

  final Map<String, Object?> _sessionResult;
  final StreamController<String> _frames = StreamController<String>(sync: true);
  final StreamController<AcpTransportState> _states =
      StreamController<AcpTransportState>.broadcast(sync: true);

  /// Every frame the client sent, in order.
  final List<Map<String, Object?>> sent = <Map<String, Object?>>[];

  /// Ids of prompts that are still waiting for a stop reason.
  final List<Object?> promptIds = <Object?>[];

  AcpTransportState _state = AcpTransportState.connected;
  int _sessionCount = 0;

  bool closed = false;

  String cwd = '/tmp';

  @override
  Stream<String> get frames => _frames.stream;

  @override
  Stream<AcpTransportState> get states => _states.stream;

  @override
  AcpTransportState get state => _state;

  @override
  String? get clientId => null;

  @override
  Future<void> send(String line) async {
    final decoded = jsonDecode(line);
    if (decoded is! Map<String, Object?>) return;
    sent.add(decoded);

    final method = decoded['method'];
    // Frames without a method are responses from the client (permissions).
    if (method is! String) return;
    final id = decoded['id'];
    // Notifications never get a response.
    if (id == null) return;

    _answer(id, method, decoded['params']);
  }

  void _answer(Object id, String method, Object? rawParams) {
    final params = rawParams is Map<String, Object?>
        ? rawParams
        : const <String, Object?>{};

    switch (method) {
      case AcpMethods.initialize:
        _reply(id, <String, Object?>{
          'protocolVersion': 1,
          'agentCapabilities': <String, Object?>{
            'loadSession': true,
            'sessionCapabilities': <String, Object?>{
              'list': <String, Object?>{},
              'delete': <String, Object?>{},
            },
          },
          'authMethods': const <Object?>[],
        });
      case AcpMethods.newSession:
        _sessionCount++;
        cwd = params['cwd'] as String? ?? cwd;
        _reply(id, _sessionPayload('s$_sessionCount'));
      case AcpMethods.loadSession:
        final sessionId = params['sessionId'] as String? ?? '';
        cwd = params['cwd'] as String? ?? cwd;
        emitText(
          sessionId,
          SessionUpdateKind.userMessageChunk,
          'previous question',
        );
        emitText(
          sessionId,
          SessionUpdateKind.agentMessageChunk,
          'previous answer',
        );
        _reply(id, _sessionPayload(sessionId));
      case AcpMethods.listSessions:
        _reply(id, <String, Object?>{
          'sessions': <Object?>[
            <String, Object?>{
              'sessionId': 'older',
              'cwd': cwd,
              'title': 'Earlier session',
              'updatedAt': 1700000000000,
            },
          ],
        });
      case AcpMethods.prompt:
        promptIds.add(id);
      case AcpMethods.authenticate:
      case AcpMethods.deleteSession:
      case AcpMethods.closeSession:
      case AcpMethods.setMode:
      case AcpMethods.setModel:
      case AcpMethods.setConfigOption:
        _reply(id, const <String, Object?>{});
      default:
        _reply(id, const <String, Object?>{});
    }
  }

  Map<String, Object?> _sessionPayload(String sessionId) => <String, Object?>{
    'sessionId': sessionId,
    ..._sessionResult,
  };

  void _reply(Object? id, Map<String, Object?> result) {
    _frames.add(
      jsonEncode(<String, Object?>{
        'jsonrpc': '2.0',
        'id': id,
        'result': result,
      }),
    );
  }

  /// Emits one `session/update` notification.
  void emitUpdate(String sessionId, Map<String, Object?> update) {
    _frames.add(
      jsonEncode(<String, Object?>{
        'jsonrpc': '2.0',
        'method': AcpMethods.sessionUpdate,
        'params': <String, Object?>{'sessionId': sessionId, 'update': update},
      }),
    );
  }

  /// Emits a text chunk of [kind].
  void emitText(String sessionId, String kind, String text) {
    emitUpdate(sessionId, <String, Object?>{
      'sessionUpdate': kind,
      'content': <String, Object?>{'type': 'text', 'text': text},
    });
  }

  /// Emits a `session/request_permission` request (id 900).
  void emitPermission({String sessionId = 's1', String toolCallId = 'call-1'}) {
    _frames.add(
      jsonEncode(<String, Object?>{
        'jsonrpc': '2.0',
        'id': 900,
        'method': AcpMethods.requestPermission,
        'params': <String, Object?>{
          'sessionId': sessionId,
          'toolCall': <String, Object?>{
            'toolCallId': toolCallId,
            'title': 'Write file',
            'kind': 'edit',
          },
          'options': <Object?>[
            <String, Object?>{
              'optionId': 'allow_once',
              'kind': 'allow_once',
              'name': 'Allow once',
            },
            <String, Object?>{
              'optionId': 'reject_once',
              'kind': 'reject_once',
              'name': 'Reject',
            },
          ],
        },
      }),
    );
  }

  /// Answers the oldest pending prompt.
  void completePrompt({String stopReason = 'end_turn'}) {
    final id = promptIds.removeAt(0);
    _reply(id, <String, Object?>{'stopReason': stopReason});
  }

  /// Pushes a transport state change.
  void emitState(AcpTransportState next) {
    _state = next;
    _states.add(next);
  }

  @override
  Future<void> close() async {
    if (closed) return;
    closed = true;
    _state = AcpTransportState.closed;
    await _frames.close();
    await _states.close();
  }
}
