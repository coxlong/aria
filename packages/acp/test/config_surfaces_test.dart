import 'package:acp/acp.dart';
import 'package:test/test.dart';

void main() {
  group('SessionModels', () {
    test('parses the hermes models object', () {
      final models = SessionModels.fromSessionResult(<String, Object?>{
        'models': <String, Object?>{
          'availableModels': <Object?>[
            <String, Object?>{
              'modelId': 'gateway · model-a',
              'name': 'gateway · model-a',
            },
            <String, Object?>{'modelId': 'model-b', 'name': 'model-b'},
          ],
          'currentModelId': 'model-b',
        },
      });

      expect(models.hasModels, isTrue);
      expect(models.currentModelId, 'model-b');
      expect(models.configId, isNull);
      expect(models.currentDisplay, 'model-b');
      expect(models.available, hasLength(2));
    });

    test('parses the standard configOptions model shape', () {
      final models = SessionModels.fromSessionResult(<String, Object?>{
        'configOptions': <Object?>[
          <String, Object?>{
            'id': 'model',
            'category': 'model',
            'currentValue': 'm2',
            'options': <Object?>[
              <String, Object?>{'value': 'm1', 'name': 'Model 1'},
              <String, Object?>{'value': 'm2', 'name': 'Model 2'},
            ],
          },
        ],
      });

      expect(models.hasModels, isTrue);
      expect(models.configId, 'model');
      expect(models.currentModelId, 'm2');
      expect(models.currentDisplay, 'Model 2');
    });

    test('parses the model_config category', () {
      final models = SessionModels.fromSessionResult(<String, Object?>{
        'configOptions': <Object?>[
          <String, Object?>{
            'id': 'primary_model',
            'category': 'model_config',
            'currentValue': 'm1',
            'options': <Object?>[
              <String, Object?>{'value': 'm1', 'name': 'Model 1'},
            ],
          },
        ],
      });

      expect(models.hasModels, isTrue);
      expect(models.configId, 'primary_model');
    });

    test('is empty when the agent advertises nothing', () {
      final models = SessionModels.fromSessionResult(const <String, Object?>{});
      expect(models.hasModels, isFalse);
      expect(models.currentDisplay, isNull);
    });
  });

  group('SessionModes', () {
    test('parses modes from the session result', () {
      final modes = SessionModes.fromSessionResult(<String, Object?>{
        'modes': <String, Object?>{
          'currentModeId': 'code',
          'availableModes': <Object?>[
            <String, Object?>{'id': 'code', 'name': 'Code'},
            <String, Object?>{'id': 'chat', 'name': 'Chat'},
          ],
        },
      });

      expect(modes.hasModes, isTrue);
      expect(modes.currentModeId, 'code');
      expect(modes.currentDisplay, 'Code');
    });

    test('is empty without modes', () {
      expect(
        SessionModes.fromSessionResult(const <String, Object?>{}).hasModes,
        isFalse,
      );
    });
  });

  group('SessionEfforts', () {
    test('parses a thought_level config option', () {
      final efforts = SessionEfforts.fromSessionResult(<String, Object?>{
        'configOptions': <Object?>[
          <String, Object?>{
            'id': 'effort',
            'category': 'thought_level',
            'currentValue': 'medium',
            'options': <Object?>[
              <String, Object?>{'value': 'low', 'name': 'Low'},
              <String, Object?>{'value': 'medium', 'name': 'Medium'},
              <String, Object?>{'value': 'high', 'name': 'High'},
            ],
          },
        ],
      });

      expect(efforts.hasEfforts, isTrue);
      expect(efforts.configId, 'effort');
      expect(efforts.currentValue, 'medium');
      expect(efforts.currentDisplay, 'Medium');
    });

    test('ignores options without a thought_level category', () {
      final efforts = SessionEfforts.fromConfigOptions(<Object?>[
        <String, Object?>{
          'id': 'model',
          'category': 'model',
          'currentValue': 'm1',
          'options': <Object?>[
            <String, Object?>{'value': 'm1', 'name': 'Model 1'},
          ],
        },
      ]);

      expect(efforts.hasEfforts, isFalse);
    });
  });

  group('InitializeResult', () {
    test('parses loadSession and session/list capabilities', () {
      final result = InitializeResult.fromJson(<String, Object?>{
        'protocolVersion': 1,
        'agentCapabilities': <String, Object?>{
          'loadSession': true,
          'sessionCapabilities': <String, Object?>{'list': true},
        },
        'authMethods': <Object?>[
          <String, Object?>{'id': 'none', 'name': 'None'},
        ],
      });

      expect(result.supportsLoadSession, isTrue);
      expect(result.supportsSessionList, isTrue);
      expect(result.authMethods.single.id, 'none');
    });
  });

  group('ToolCallInfo', () {
    test('merges _meta across updates instead of replacing it', () {
      const base = ToolCallInfo(
        id: 'call_1',
        title: 'Tool',
        meta: <String, Object?>{
          'claudeCode': <String, Object?>{'toolName': 'Bash'},
        },
      );

      final patched = base.copyWith(
        title: 'Running tests',
        meta: <String, Object?>{
          'claudeCode': <String, Object?>{'title': 'flutter test'},
        },
      );

      expect(patched.title, 'Running tests');
      expect(patched.toolName, 'Bash');
      expect(
        (patched.meta!['claudeCode'] as Map<String, Object?>)['title'],
        'flutter test',
      );
    });

    test('extracts text from content blocks', () {
      final call = ToolCallInfo.fromJson(<String, Object?>{
        'toolCallId': 'c1',
        'title': 'Read',
        'content': <Object?>[
          <String, Object?>{
            'type': 'content',
            'content': <String, Object?>{'type': 'text', 'text': 'line 1'},
          },
          <String, Object?>{
            'type': 'content',
            'content': <String, Object?>{'type': 'text', 'text': 'line 2'},
          },
        ],
      });

      expect(call.contentText, 'line 1\nline 2');
    });
  });
}
