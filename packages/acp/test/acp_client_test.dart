import 'dart:async';
import 'dart:convert';

import 'package:acp/acp.dart';
import 'package:test/test.dart';

import 'support/fake_transport.dart';

(AcpClient, FakeTransport) createClient({
  Duration? timeout,
  Duration? cancelTimeout,
}) {
  final transport = FakeTransport();
  final client = AcpClient(
    transport,
    requestTimeout: timeout ?? const Duration(seconds: 5),
    cancelTimeout: cancelTimeout ?? const Duration(seconds: 15),
  );
  addTearDown(client.close);
  return (client, transport);
}

/// Emits a successful response for the last request the client sent.
void reply(FakeTransport transport, Map<String, Object?> result) {
  transport.emit(<String, Object?>{
    'jsonrpc': '2.0',
    'id': transport.lastSent['id'],
    'result': result,
  });
}

Map<String, Object?> updateFrame(
  String sessionId,
  Map<String, Object?> update,
) => <String, Object?>{
  'jsonrpc': '2.0',
  'method': 'session/update',
  'params': <String, Object?>{'sessionId': sessionId, 'update': update},
};

void main() {
  group('initialize', () {
    test('sends protocol version 1 and disables fs capabilities', () async {
      final (client, transport) = createClient();

      final future = client.initialize();
      final request = transport.lastSent;
      expect(request['method'], 'initialize');

      final params = request['params'] as Map<String, Object?>;
      expect(params['protocolVersion'], 1);
      final caps = params['clientCapabilities'] as Map<String, Object?>;
      final fs = caps['fs'] as Map<String, Object?>;
      expect(fs['readTextFile'], isFalse);
      expect(fs['writeTextFile'], isFalse);
      final info = params['clientInfo'] as Map<String, Object?>;
      expect(info['name'], 'aria');

      reply(transport, <String, Object?>{
        'protocolVersion': 1,
        'agentCapabilities': <String, Object?>{'loadSession': true},
      });

      final result = await future;
      expect(result.protocolVersion, 1);
      expect(result.supportsLoadSession, isTrue);
    });
  });

  group('sessions', () {
    test(
      'newSession registers the session and parses config surfaces',
      () async {
        final (client, transport) = createClient();

        final future = client.newSession(cwd: '/tmp/project');
        expect(transport.lastSent['method'], 'session/new');
        reply(transport, <String, Object?>{
          'sessionId': 's1',
          'models': <String, Object?>{
            'availableModels': <Object?>[
              <String, Object?>{'modelId': 'm1', 'name': 'Model 1'},
            ],
            'currentModelId': 'm1',
          },
          'modes': <String, Object?>{
            'currentModeId': 'code',
            'availableModes': <Object?>[
              <String, Object?>{'id': 'code', 'name': 'Code'},
            ],
          },
        });

        final session = await future;
        expect(session.id, 's1');
        expect(session.cwd, '/tmp/project');
        expect(session.models.hasModels, isTrue);
        expect(session.modes.currentModeId, 'code');
        expect(client.session('s1'), same(session));
      },
    );

    test('listSessions parses ISO timestamps', () async {
      final (client, transport) = createClient();

      final future = client.listSessions(cwd: '/tmp');
      expect(transport.lastSent['method'], 'session/list');
      reply(transport, <String, Object?>{
        'sessions': <Object?>[
          <String, Object?>{
            'sessionId': 's1',
            'cwd': '/tmp',
            'title': 'First',
            'updatedAt': '2026-10-24T10:00:00Z',
          },
        ],
      });

      final sessions = await future;
      expect(sessions, hasLength(1));
      expect(sessions.single.title, 'First');
      expect(sessions.single.updatedAt, isNotNull);
    });

    test(
      'session/load buffers replay updates until the caller listens',
      () async {
        final (client, transport) = createClient();

        final loadFuture = client.loadSession(sessionId: 's9', cwd: '/tmp');
        expect(transport.lastSent['method'], 'session/load');
        expect(client.session('s9')?.isReplaying, isTrue);

        transport.emit(
          updateFrame('s9', <String, Object?>{
            'sessionUpdate': 'user_message_chunk',
            'content': <String, Object?>{
              'type': 'text',
              'text': 'old question',
            },
          }),
        );
        transport.emit(
          updateFrame('s9', <String, Object?>{
            'sessionUpdate': 'agent_message_chunk',
            'content': <String, Object?>{'type': 'text', 'text': 'old answer'},
          }),
        );
        reply(transport, const <String, Object?>{});

        final session = await loadFuture;
        expect(session.isReplaying, isFalse);

        final updates = <SessionUpdate>[];
        session.updates.listen(updates.add);
        await Future<void>.delayed(Duration.zero);

        expect(updates, hasLength(2));
        expect(updates[0], isA<UserMessageChunk>());
        expect((updates[0] as UserMessageChunk).text, 'old question');
        expect((updates[1] as AgentMessageChunk).text, 'old answer');
      },
    );
  });

  group('session updates', () {
    test('dispatches text, thought and tool updates in wire order', () async {
      final (client, transport) = createClient();
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{'sessionId': 's1'});
      final session = await sessionFuture;

      final updates = <SessionUpdate>[];
      session.updates.listen(updates.add);

      transport.emit(
        updateFrame('s1', <String, Object?>{
          'sessionUpdate': 'agent_thought_chunk',
          'content': <String, Object?>{'text': 'thinking'},
        }),
      );
      transport.emit(
        updateFrame('s1', <String, Object?>{
          'sessionUpdate': 'tool_call',
          'toolCall': <String, Object?>{
            'toolCallId': 't1',
            'title': 'Run tests',
            'kind': 'bash',
            'status': 'in_progress',
          },
        }),
      );
      transport.emit(
        updateFrame('s1', <String, Object?>{
          'sessionUpdate': 'agent_message_chunk',
          'content': <String, Object?>{'text': 'done'},
        }),
      );

      await Future<void>.delayed(Duration.zero);
      expect(updates, hasLength(3));
      expect(updates[0], isA<AgentThoughtChunk>());
      expect(updates[1], isA<ToolCallStarted>());
      expect((updates[1] as ToolCallStarted).toolCall.id, 't1');
      expect(updates[2], isA<AgentMessageChunk>());
    });

    test('unknown update kinds are preserved, not dropped', () async {
      final (client, transport) = createClient();
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{'sessionId': 's1'});
      final session = await sessionFuture;

      final updates = <SessionUpdate>[];
      session.updates.listen(updates.add);

      transport.emit(
        updateFrame('s1', <String, Object?>{
          'sessionUpdate': 'plan',
          'entries': <Object?>[],
        }),
      );

      await Future<void>.delayed(Duration.zero);
      expect(updates.single, isA<UnknownSessionUpdate>());
      expect((updates.single as UnknownSessionUpdate).kind, 'plan');
    });

    test('config_option_update refreshes model and effort surfaces', () async {
      final (client, transport) = createClient();
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{
        'sessionId': 's1',
        'configOptions': <Object?>[
          <String, Object?>{
            'id': 'model',
            'category': 'model',
            'currentValue': 'm1',
            'options': <Object?>[
              <String, Object?>{'value': 'm1', 'name': 'Model 1'},
              <String, Object?>{'value': 'm2', 'name': 'Model 2'},
            ],
          },
        ],
      });
      final session = await sessionFuture;
      session.updates.listen((_) {});

      transport.emit(
        updateFrame('s1', <String, Object?>{
          'sessionUpdate': 'config_option_update',
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
            <String, Object?>{
              'id': 'effort',
              'category': 'thought_level',
              'currentValue': 'high',
              'options': <Object?>[
                <String, Object?>{'value': 'low', 'name': 'Low'},
                <String, Object?>{'value': 'high', 'name': 'High'},
              ],
            },
          ],
        }),
      );

      await Future<void>.delayed(Duration.zero);
      expect(session.models.currentModelId, 'm2');
      expect(session.efforts.currentValue, 'high');
    });
  });

  group('prompt', () {
    test(
      'does not apply the request timeout and clears running on completion',
      () async {
        final (client, transport) = createClient(
          timeout: const Duration(milliseconds: 20),
        );
        final sessionFuture = client.newSession(cwd: '/tmp');
        reply(transport, <String, Object?>{'sessionId': 's1'});
        final session = await sessionFuture;

        final promptFuture = session.prompt('hello');
        expect(session.isRunning, isTrue);
        await Future<void>.delayed(const Duration(milliseconds: 60));
        expect(session.isRunning, isTrue, reason: 'prompt must not time out');

        final request = transport.lastSent;
        expect(request['method'], 'session/prompt');
        transport.emit(<String, Object?>{
          'jsonrpc': '2.0',
          'id': request['id'],
          'result': <String, Object?>{'stopReason': 'end_turn'},
        });

        final result = await promptFuture;
        expect(result.stopReason, 'end_turn');
        expect(session.isRunning, isFalse);
      },
    );

    test('rejects a second concurrent prompt', () async {
      final (client, transport) = createClient();
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{'sessionId': 's1'});
      final session = await sessionFuture;

      final first = session.prompt('first');
      await expectLater(session.prompt('second'), throwsA(isA<StateError>()));

      // Complete the first turn so teardown has nothing in flight.
      final request = transport.lastSent;
      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'id': request['id'],
        'result': <String, Object?>{'stopReason': 'end_turn'},
      });
      await first;
      expect(session.isRunning, isFalse);
    });
  });

  group('permissions', () {
    test('answers exactly once and sends the selected option', () async {
      final (client, transport) = createClient();
      final requests = <PermissionRequest>[];
      client.permissionRequests.listen(requests.add);

      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'id': 77,
        'method': 'session/request_permission',
        'params': <String, Object?>{
          'sessionId': 's1',
          'toolCall': <String, Object?>{
            'toolCallId': 't1',
            'title': 'Run command',
            'kind': 'bash',
          },
          'options': <Object?>[
            <String, Object?>{
              'kind': 'allow_once',
              'name': 'Allow once',
              'optionId': 'allow',
            },
            <String, Object?>{
              'kind': 'reject_once',
              'name': 'Reject',
              'optionId': 'reject',
            },
          ],
        },
      });

      expect(requests, hasLength(1));
      final request = requests.single;
      expect(request.toolCall.id, 't1');
      expect(request.options, hasLength(2));

      await request.allow('allow');
      expect(transport.sent, hasLength(1));
      final response = transport.lastSent;
      expect(response['id'], 77);
      expect(response['result'], <String, Object?>{
        'outcome': <String, Object?>{
          'outcome': 'selected',
          'optionId': 'allow',
        },
      });

      await request.allow('allow');
      expect(transport.sent, hasLength(1), reason: 'must not answer twice');
    });

    test('deny sends the cancelled outcome', () async {
      final (client, transport) = createClient();
      final requests = <PermissionRequest>[];
      client.permissionRequests.listen(requests.add);

      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'id': 88,
        'method': 'session/request_permission',
        'params': <String, Object?>{
          'sessionId': 's1',
          'toolCall': <String, Object?>{'toolCallId': 't1', 'title': 'Write'},
          'options': <Object?>[],
        },
      });

      await requests.single.deny();
      expect(transport.lastSent['result'], <String, Object?>{
        'outcome': <String, Object?>{'outcome': 'cancelled'},
      });
    });

    test(
      'cancel answers a pending permission before sending session/cancel',
      () async {
        final (client, transport) = createClient();
        final sessionFuture = client.newSession(cwd: '/tmp');
        reply(transport, <String, Object?>{'sessionId': 's1'});
        final session = await sessionFuture;
        session.updates.listen((_) {});

        transport.emit(<String, Object?>{
          'jsonrpc': '2.0',
          'id': 99,
          'method': 'session/request_permission',
          'params': <String, Object?>{
            'sessionId': 's1',
            'toolCall': <String, Object?>{'toolCallId': 't1', 'title': 'Write'},
            'options': <Object?>[],
          },
        });

        await session.cancel();

        expect(transport.sent, hasLength(3));
        final permissionResponse = jsonDecode(transport.sent[1]);
        expect(permissionResponse['id'], 99);
        expect(permissionResponse['result'], <String, Object?>{
          'outcome': <String, Object?>{'outcome': 'cancelled'},
        });
        final cancelNotification = jsonDecode(transport.sent[2]);
        expect(cancelNotification['method'], 'session/cancel');
      },
    );
  });

  group('agent requests', () {
    test('unknown methods are answered with -32601', () async {
      final (client, transport) = createClient();

      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'id': 5,
        'method': 'fs/read_text_file',
        'params': <String, Object?>{'path': '/etc/passwd'},
      });

      final response = transport.lastSent;
      expect(response['id'], 5);
      final error = response['error'] as Map<String, Object?>;
      expect(error['code'], -32601);
    });

    test('malformed frames are ignored', () async {
      final (client, transport) = createClient();
      transport.emitRaw('not json');
      transport.emitRaw('[1,2,3]');
      await Future<void>.delayed(Duration.zero);
      expect(transport.sent, isEmpty);
    });
  });

  group('model switching', () {
    test('uses session/set_model for the models object shape', () async {
      final (client, transport) = createClient();
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{
        'sessionId': 's1',
        'models': <String, Object?>{
          'availableModels': <Object?>[
            <String, Object?>{'modelId': 'm1', 'name': 'Model 1'},
          ],
          'currentModelId': 'm1',
        },
      });
      final session = await sessionFuture;

      final future = session.setModel('m2');
      final request = transport.lastSent;
      expect(request['method'], 'session/set_model');
      final params = request['params'] as Map<String, Object?>;
      expect(params['modelId'], 'm2');
      reply(transport, const <String, Object?>{});
      await future;
      expect(session.models.currentModelId, 'm2');
    });

    test(
      'uses session/set_config_option for the configOptions shape',
      () async {
        final (client, transport) = createClient();
        final sessionFuture = client.newSession(cwd: '/tmp');
        reply(transport, <String, Object?>{
          'sessionId': 's1',
          'configOptions': <Object?>[
            <String, Object?>{
              'id': 'model',
              'category': 'model',
              'currentValue': 'm1',
              'options': <Object?>[
                <String, Object?>{'value': 'm1', 'name': 'Model 1'},
                <String, Object?>{'value': 'm2', 'name': 'Model 2'},
              ],
            },
          ],
        });
        final session = await sessionFuture;

        final future = session.setModel('m2');
        final request = transport.lastSent;
        expect(request['method'], 'session/set_config_option');
        final params = request['params'] as Map<String, Object?>;
        expect(params['configId'], 'model');
        expect(params['value'], 'm2');
        reply(transport, const <String, Object?>{});
        await future;
      },
    );
  });

  group('lifecycle', () {
    test('request times out', () async {
      final (client, transport) = createClient(
        timeout: const Duration(milliseconds: 20),
      );
      await expectLater(
        client.newSession(cwd: '/tmp'),
        throwsA(isA<AcpRequestTimeout>()),
      );
      expect(transport.sent, hasLength(1));
    });

    test('close rejects in-flight requests', () async {
      final (client, transport) = createClient();
      final future = client.newSession(cwd: '/tmp');
      final expectation = expectLater(
        future,
        throwsA(isA<AcpTransportClosed>()),
      );
      await client.close();
      await expectation;
      expect(transport.state, AcpTransportState.closed);
    });

    test('closing local session disposes the handle', () async {
      final (client, transport) = createClient();
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{'sessionId': 's1'});
      final session = await sessionFuture;

      final closing = session.close();
      reply(transport, const <String, Object?>{});
      await closing;

      expect(client.session('s1'), isNull);
      expect(() => session.prompt('after close'), throwsA(isA<StateError>()));
    });
  });

  group('coverage', () {
    test('authenticate sends the method id', () async {
      final (client, transport) = createClient();

      final future = client.authenticate(methodId: 'oauth');
      expect(transport.lastSent['method'], 'authenticate');
      expect(
        (transport.lastSent['params'] as Map<String, Object?>)['methodId'],
        'oauth',
      );

      reply(transport, const <String, Object?>{});
      await future;
    });

    test('exposes state and client id and emits closed', () async {
      final (client, transport) = createClient();

      expect(client.state, AcpTransportState.connected);
      expect(client.clientId, isNull);

      final states = <AcpTransportState>[];
      client.states.listen(states.add);
      await client.close();
      await Future<void>.delayed(Duration.zero);

      expect(states, contains(AcpTransportState.closed));
    });

    test('setMode sends session/set_mode and updates local state', () async {
      final (client, transport) = createClient();
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{
        'sessionId': 's1',
        'modes': <String, Object?>{
          'currentModeId': 'code',
          'availableModes': <Object?>[
            <String, Object?>{'id': 'code', 'name': 'Code'},
            <String, Object?>{'id': 'chat', 'name': 'Chat'},
          ],
        },
      });
      final session = await sessionFuture;

      final future = session.setMode('chat');
      final request = transport.lastSent;
      expect(request['method'], 'session/set_mode');
      expect((request['params'] as Map<String, Object?>)['modeId'], 'chat');

      reply(transport, const <String, Object?>{});
      await future;
      expect(session.modes.currentModeId, 'chat');
    });

    test('setConfigOption updates model and effort surfaces', () async {
      final (client, transport) = createClient();
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{
        'sessionId': 's1',
        'configOptions': <Object?>[
          <String, Object?>{
            'id': 'model',
            'category': 'model',
            'currentValue': 'm1',
            'options': <Object?>[
              <String, Object?>{'value': 'm1', 'name': 'Model 1'},
              <String, Object?>{'value': 'm2', 'name': 'Model 2'},
            ],
          },
          <String, Object?>{
            'id': 'effort',
            'category': 'thought_level',
            'currentValue': 'low',
            'options': <Object?>[
              <String, Object?>{'value': 'low', 'name': 'Low'},
              <String, Object?>{'value': 'high', 'name': 'High'},
            ],
          },
        ],
      });
      final session = await sessionFuture;

      final effortFuture = session.setConfigOption('effort', 'high');
      final effortRequest = transport.lastSent;
      expect(effortRequest['method'], 'session/set_config_option');
      final effortParams = effortRequest['params'] as Map<String, Object?>;
      expect(effortParams['configId'], 'effort');
      expect(effortParams['value'], 'high');
      reply(transport, const <String, Object?>{});
      await effortFuture;
      expect(session.efforts.currentValue, 'high');

      final modelFuture = session.setConfigOption('model', 'm2');
      reply(transport, const <String, Object?>{});
      await modelFuture;
      expect(session.models.currentModelId, 'm2');
    });

    test('current_mode_update updates the mode surface', () async {
      final (client, transport) = createClient();
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{
        'sessionId': 's1',
        'modes': <String, Object?>{
          'currentModeId': 'code',
          'availableModes': <Object?>[
            <String, Object?>{'id': 'code', 'name': 'Code'},
            <String, Object?>{'id': 'chat', 'name': 'Chat'},
          ],
        },
      });
      final session = await sessionFuture;
      final updates = <SessionUpdate>[];
      session.updates.listen(updates.add);

      transport.emit(
        updateFrame('s1', <String, Object?>{
          'sessionUpdate': 'current_mode_update',
          'currentModeId': 'chat',
        }),
      );

      await Future<void>.delayed(Duration.zero);
      expect(updates.single, isA<CurrentModeUpdate>());
      expect(session.modes.currentModeId, 'chat');
    });

    test('tool_call_update is parsed as a patch', () async {
      final (client, transport) = createClient();
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{'sessionId': 's1'});
      final session = await sessionFuture;
      final updates = <SessionUpdate>[];
      session.updates.listen(updates.add);

      transport.emit(
        updateFrame('s1', <String, Object?>{
          'sessionUpdate': 'tool_call_update',
          'toolCallId': 't1',
          'title': 'Done',
          'status': 'completed',
          'rawOutput': 'ok',
          'content': <Object?>[
            <String, Object?>{
              'type': 'content',
              'content': <String, Object?>{'type': 'text', 'text': 'ok'},
            },
          ],
          '_meta': <String, Object?>{
            'claudeCode': <String, Object?>{'toolName': 'Bash'},
          },
        }),
      );

      await Future<void>.delayed(Duration.zero);
      final patch = updates.single as ToolCallPatched;
      expect(patch.toolCallId, 't1');
      expect(patch.title, 'Done');
      expect(patch.status, 'completed');
      expect(patch.rawOutput, 'ok');
      expect(patch.content, hasLength(1));
      expect(patch.meta, isNotNull);
    });

    test('external transport close rejects in-flight requests', () async {
      final (client, transport) = createClient();
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{'sessionId': 's1'});
      final session = await sessionFuture;
      session.updates.listen((_) {});

      final promptFuture = session.prompt('hello');
      final expectation = expectLater(
        promptFuture,
        throwsA(isA<AcpTransportClosed>()),
      );

      await transport.closeFrames();
      await expectation;
      await Future<void>.delayed(Duration.zero);
      expect(session.isRunning, isFalse);
    });

    test('cancel watchdog completes the turn locally', () async {
      final (client, transport) = createClient(
        cancelTimeout: const Duration(milliseconds: 30),
      );
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{'sessionId': 's1'});
      final session = await sessionFuture;
      session.updates.listen((_) {});

      final promptFuture = session.prompt('hello');
      await Future<void>.delayed(Duration.zero);
      await session.cancel();

      final result = await promptFuture;
      expect(result.stopReason, 'cancelled');
      expect(session.isRunning, isFalse);
    });

    test('closing a running session cancels first', () async {
      final (client, transport) = createClient(
        cancelTimeout: const Duration(milliseconds: 30),
      );
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{'sessionId': 's1'});
      final session = await sessionFuture;
      session.updates.listen((_) {});

      final promptFuture = session.prompt('hello');
      await Future<void>.delayed(Duration.zero);

      final closing = session.close();
      await Future<void>.delayed(Duration.zero);

      final closeRequest = transport.sent
          .map((line) => jsonDecode(line) as Map<String, Object?>)
          .lastWhere((frame) => frame['method'] == 'session/close');
      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'id': closeRequest['id'],
        'result': const <String, Object?>{},
      });
      await closing;

      final result = await promptFuture;
      expect(result.stopReason, 'cancelled');
      expect(session.isRunning, isFalse);
      expect(client.session('s1'), isNull);
    });

    test('session close swallows agent errors', () async {
      final (client, transport) = createClient();
      final sessionFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{'sessionId': 's1'});
      final session = await sessionFuture;

      final closing = session.close();
      await Future<void>.delayed(Duration.zero);
      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'id': transport.lastSent['id'],
        'error': <String, Object?>{
          'code': -32601,
          'message': 'Method not found',
        },
      });

      await closing;
      expect(client.session('s1'), isNull);
    });

    test('missing permission fields are tolerated', () async {
      final (client, transport) = createClient();
      final requests = <PermissionRequest>[];
      client.permissionRequests.listen(requests.add);

      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'id': 12,
        'method': 'session/request_permission',
        'params': const <String, Object?>{},
      });

      expect(requests.single.sessionId, '');
      expect(requests.single.toolCall.id, '');
      expect(requests.single.options, isEmpty);
      await requests.single.deny();
      expect(transport.lastSent['result'], <String, Object?>{
        'outcome': <String, Object?>{'outcome': 'cancelled'},
      });
    });

    test('non-map results become empty maps', () async {
      final (client, transport) = createClient();

      final future = client.listSessions();
      final request = transport.lastSent;
      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'id': request['id'],
        'result': null,
      });

      expect(await future, isEmpty);
    });

    test('unknown response ids are ignored', () async {
      final (client, transport) = createClient();

      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'id': 424242,
        'result': const <String, Object?>{},
      });
      await Future<void>.delayed(Duration.zero);

      expect(transport.sent, isEmpty);
    });

    test('string request ids are matched on responses', () async {
      final (client, transport) = createClient();

      final future = client.newSession(cwd: '/tmp');
      final id = transport.lastSent['id'];
      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'id': '$id',
        'result': <String, Object?>{'sessionId': 's1'},
      });

      final session = await future;
      expect(session.id, 's1');
    });

    test('unparseable agent request ids get no reply', () async {
      final (client, transport) = createClient();

      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'id': 'not-a-number',
        'method': 'fs/read_text_file',
        'params': const <String, Object?>{},
      });
      await Future<void>.delayed(Duration.zero);

      expect(transport.sent, isEmpty);
    });

    test('malformed session updates are ignored', () async {
      final (client, transport) = createClient();

      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'method': 'session/update',
        'params': <Object?>[],
      });
      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'method': 'session/update',
        'params': <String, Object?>{'sessionId': 's1', 'update': 'x'},
      });
      await Future<void>.delayed(Duration.zero);

      expect(transport.sent, isEmpty);
    });

    test('close is idempotent', () async {
      final (client, transport) = createClient();
      await client.close();
      await client.close();
      expect(transport.state, AcpTransportState.closed);
    });

    test('loadSession applies config surfaces from the response', () async {
      final (client, transport) = createClient();

      final future = client.loadSession(sessionId: 's9', cwd: '/tmp');
      reply(transport, <String, Object?>{
        'models': <String, Object?>{
          'availableModels': <Object?>[
            <String, Object?>{'modelId': 'm1', 'name': 'Model 1'},
          ],
          'currentModelId': 'm1',
        },
        'modes': <String, Object?>{
          'currentModeId': 'code',
          'availableModes': <Object?>[
            <String, Object?>{'id': 'code', 'name': 'Code'},
          ],
        },
        'configOptions': <Object?>[
          <String, Object?>{
            'id': 'effort',
            'category': 'thought_level',
            'currentValue': 'low',
            'options': <Object?>[
              <String, Object?>{'value': 'low', 'name': 'Low'},
            ],
          },
        ],
      });

      final session = await future;
      expect(session.models.currentModelId, 'm1');
      expect(session.modes.currentModeId, 'code');
      expect(session.efforts.currentValue, 'low');
    });

    test('loadSession failure disposes the attempt', () async {
      final (client, transport) = createClient();

      final future = client.loadSession(sessionId: 's9', cwd: '/tmp');
      final expectation = expectLater(future, throwsA(isA<AcpRemoteError>()));
      transport.emit(<String, Object?>{
        'jsonrpc': '2.0',
        'id': transport.lastSent['id'],
        'error': <String, Object?>{'code': -32000, 'message': 'gone'},
      });

      await expectation;
      expect(client.session('s9'), isNull);
    });

    test('newSession replaces an existing handle with the same id', () async {
      final (client, transport) = createClient();

      final firstFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{'sessionId': 's1'});
      final first = await firstFuture;

      final secondFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{'sessionId': 's1'});
      final second = await secondFuture;

      expect(second, isNot(same(first)));
      expect(client.session('s1'), same(second));
    });

    test('loadSession replaces an existing handle with the same id', () async {
      final (client, transport) = createClient();

      final firstFuture = client.newSession(cwd: '/tmp');
      reply(transport, <String, Object?>{'sessionId': 's1'});
      final first = await firstFuture;

      final loadFuture = client.loadSession(sessionId: 's1', cwd: '/tmp');
      reply(transport, const <String, Object?>{});
      final loaded = await loadFuture;

      expect(loaded, isNot(same(first)));
      expect(client.session('s1'), same(loaded));
    });

    test('frames stream errors reject in-flight requests', () async {
      final (client, transport) = createClient();

      final future = client.newSession(cwd: '/tmp');
      final expectation = expectLater(
        future,
        throwsA(isA<AcpTransportClosed>()),
      );
      transport.emitError(StateError('socket blew up'));

      await expectation;
    });
  });
}
