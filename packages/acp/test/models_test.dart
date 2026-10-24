import 'package:acp/acp.dart';
import 'package:test/test.dart';

void main() {
  group('Ndjson encoder', () {
    test('appends a newline', () {
      expect(encodeNdjson(<String, Object?>{'a': 1}), '{"a":1}\n');
    });
  });

  group('ReconnectPolicy', () {
    test('grows exponentially and caps at maxDelay', () {
      const policy = ReconnectPolicy(
        initialDelay: Duration(milliseconds: 100),
        maxDelay: Duration(seconds: 1),
        multiplier: 2,
      );

      expect(policy.delayForAttempt(0), const Duration(milliseconds: 100));
      expect(policy.delayForAttempt(1), const Duration(milliseconds: 200));
      expect(policy.delayForAttempt(2), const Duration(milliseconds: 400));
      expect(policy.delayForAttempt(10), const Duration(seconds: 1));
      expect(policy.maxOutboxFrames, 200);
    });

    test('supports a multiplier below one', () {
      const policy = ReconnectPolicy(
        initialDelay: Duration(milliseconds: 100),
        maxDelay: Duration(seconds: 1),
        multiplier: 0.5,
      );

      expect(policy.delayForAttempt(1), const Duration(milliseconds: 50));
    });
  });

  group('errors', () {
    test('expose English messages and a readable toString', () {
      const remote = AcpRemoteError(-32000, 'nope', <String, Object?>{});
      expect(remote.message, 'ACP error -32000: nope');
      expect(remote.toString(), contains('AcpRemoteError'));

      const timeout = AcpRequestTimeout('session/new');
      expect(timeout.message, 'Request timed out: session/new');

      const closed = AcpTransportClosed('socket gone');
      expect(closed.message, 'Transport closed: socket gone');

      const protocol = AcpProtocolError('bad frame');
      expect(protocol.message, 'bad frame');
    });

    test('expose the JSON-RPC codes', () {
      expect(JsonRpcCode.parseError, -32700);
      expect(JsonRpcCode.invalidRequest, -32600);
      expect(JsonRpcCode.methodNotFound, -32601);
      expect(JsonRpcCode.invalidParams, -32602);
      expect(JsonRpcCode.internalError, -32603);
      expect(JsonRpcCode.serverError, -32000);
    });
  });

  group('content models', () {
    test('PromptResult parses stop reasons', () {
      expect(
        PromptResult.fromJson(const <String, Object?>{}).stopReason,
        'unknown',
      );
      expect(
        PromptResult.fromJson(const <String, Object?>{
          'stopReason': 'cancelled',
        }).isCancelled,
        isTrue,
      );
      expect(
        PromptResult.fromJson(const <String, Object?>{'stopReason': 'end_turn'})
            .isCancelled,
        isFalse,
      );
    });

    test('AuthMethod falls back to id when name is missing', () {
      final method = AuthMethod.fromJson(const <String, Object?>{
        'id': 'oauth',
      });
      expect(method.id, 'oauth');
      expect(method.name, 'oauth');
    });

    test('InitializeResult defaults to protocol 1 and no capabilities', () {
      final result = InitializeResult.fromJson(const <String, Object?>{});
      expect(result.protocolVersion, 1);
      expect(result.supportsLoadSession, isFalse);
      expect(result.supportsSessionList, isFalse);
      expect(result.supportsSessionDelete, isFalse);
      expect(result.authMethods, isEmpty);
    });

    test('ClientInfo serializes its identity', () {
      const info = ClientInfo(name: 'aria', title: 'Aria', version: '1.0.0');
      expect(info.toJson(), <String, Object?>{
        'name': 'aria',
        'title': 'Aria',
        'version': '1.0.0',
      });
    });
  });

  group('tool calls', () {
    test('reports completion and keeps fields when copyWith gets nulls', () {
      final call = ToolCallInfo.fromJson(const <String, Object?>{
        'toolCallId': 't1',
        'title': 'Run',
        'kind': 'bash',
        'status': 'completed',
      });

      expect(call.isCompleted, isTrue);
      final copy = call.copyWith();
      expect(copy.id, 't1');
      expect(copy.title, 'Run');
      expect(copy.kind, 'bash');
      expect(copy.status, 'completed');
    });

    test('extracts text from a rawOutput list', () {
      final call = ToolCallInfo.fromJson(const <String, Object?>{
        'toolCallId': 't1',
        'title': 'Run',
        'rawOutput': <Object?>[
          <String, Object?>{
            'type': 'content',
            'content': <String, Object?>{'type': 'text', 'text': 'output'},
          },
        ],
      });

      expect(call.contentText, 'output');
    });

    test('returns empty text for non-list content', () {
      final call = ToolCallInfo.fromJson(const <String, Object?>{
        'toolCallId': 't1',
        'title': 'Run',
        'content': 'not a list',
        'locations': 'not a list',
      });

      expect(call.contentText, '');
      expect(call.locations, isNull);
    });

    test('ignores non-map values in content lists', () {
      final call = ToolCallInfo.fromJson(const <String, Object?>{
        'toolCallId': 't1',
        'title': 'Run',
        'content': <Object?>[
          1,
          'two',
          <String, Object?>{'content': 'x'},
        ],
      });

      expect(call.contentText, '');
      expect(call.content, hasLength(1));
    });

    test('derives a tool name only for Claude Code metadata', () {
      final claude = ToolCallInfo.fromJson(const <String, Object?>{
        'toolCallId': 't1',
        'title': 'Run',
        '_meta': <String, Object?>{
          'claudeCode': <String, Object?>{'toolName': 'Bash'},
        },
      });
      expect(claude.toolName, 'Bash');

      final other = ToolCallInfo.fromJson(const <String, Object?>{
        'toolCallId': 't1',
        'title': 'Run',
        '_meta': <String, Object?>{'claudeCode': 'not a map'},
      });
      expect(other.toolName, isNull);
    });
  });

  group('permissions', () {
    test('PermissionOption identifies allow options', () {
      const allow = PermissionOption(
        kind: 'allow_once',
        name: 'Allow',
        optionId: 'a',
      );
      const reject = PermissionOption(
        kind: 'reject_once',
        name: 'Reject',
        optionId: 'r',
      );
      expect(allow.isAllow, isTrue);
      expect(reject.isAllow, isFalse);
      expect(
        PermissionOption.fromJson(const <String, Object?>{}).kind,
        'other',
      );
    });
  });

  group('sessions', () {
    test('SessionSummary round-trips and parses int timestamps', () {
      final summary = SessionSummary.fromJson(const <String, Object?>{
        'sessionId': 's1',
        'cwd': '/tmp',
        'title': 'First',
        'updatedAt': 1234,
      });

      expect(summary.updatedAt?.millisecondsSinceEpoch, 1234);
      expect(summary.toJson()['updatedAt'], 1234);

      final copy = summary.copyWith(title: 'Second');
      expect(copy.title, 'Second');
      expect(copy.sessionId, 's1');

      final unchanged = summary.copyWith();
      expect(unchanged.title, summary.title);
      expect(unchanged.updatedAt, summary.updatedAt);
    });

    test('SessionSummary tolerates missing timestamps', () {
      final summary = SessionSummary.fromJson(const <String, Object?>{
        'updatedAt': null,
      });
      expect(summary.updatedAt, isNull);
      expect(summary.sessionId, '');
    });

    test('SessionModels displays colon-separated ids and first options', () {
      final colon = SessionModels.fromSessionResult(<String, Object?>{
        'models': <String, Object?>{
          'availableModels': <Object?>[
            <String, Object?>{'modelId': 'provider:model-x'},
          ],
          'currentModelId': 'provider:model-x',
        },
      });
      expect(colon.currentDisplay, 'model-x');

      final first = SessionModels.fromSessionResult(<String, Object?>{
        'models': <String, Object?>{
          'availableModels': <Object?>[
            <String, Object?>{'modelId': 'm1', 'name': 'Model 1'},
          ],
        },
      });
      expect(first.currentDisplay, 'Model 1');
    });

    test('SessionModels falls back to the raw current id', () {
      const models = SessionModels(
        available: <SessionModel>[SessionModel(modelId: 'm1', name: 'Model 1')],
        currentModelId: 'missing',
      );
      expect(models.currentDisplay, 'missing');
    });

    test('SessionModels falls back to the option value when name is empty', () {
      final models = SessionModels.fromConfigOptions(<Object?>[
        <String, Object?>{
          'id': 'model',
          'category': 'model',
          'currentValue': 'm1',
          'options': <Object?>[
            <String, Object?>{'value': 'm1'},
          ],
        },
      ]);
      expect(models.available.single.name, 'm1');
    });

    test(
      'SessionEfforts falls back to the option value when name is empty',
      () {
        final efforts = SessionEfforts.fromConfigOptions(<Object?>[
          <String, Object?>{
            'id': 'effort',
            'category': 'thought_level',
            'currentValue': 'low',
            'options': <Object?>[
              <String, Object?>{'value': 'low'},
            ],
          },
        ]);
        expect(efforts.available.single.name, 'low');
      },
    );

    test('SessionModes falls back to the id and to the first option', () {
      const unknown = SessionModes(
        available: <SessionMode>[SessionMode(id: 'code', name: 'Code')],
        currentModeId: 'missing',
      );
      expect(unknown.currentDisplay, 'missing');

      const first = SessionModes(
        available: <SessionMode>[SessionMode(id: 'code', name: '')],
      );
      expect(first.currentDisplay, 'code');
    });

    test('SessionEfforts falls back to the value and to the first option', () {
      const unknown = SessionEfforts(
        available: <SessionEffort>[SessionEffort(value: 'low', name: 'Low')],
        currentValue: 'missing',
      );
      expect(unknown.currentDisplay, 'missing');

      const first = SessionEfforts(
        available: <SessionEffort>[SessionEffort(value: 'low', name: '')],
      );
      expect(first.currentDisplay, 'low');
    });
  });
}
