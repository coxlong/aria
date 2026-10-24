import 'package:acp/acp.dart';
import 'package:aria/core/error_mapping.dart';
import 'package:aria/core/models/server_profile.dart';
import 'package:aria/core/persistence/server_store.dart';
import 'package:aria/state/connection_controller.dart';
import 'package:aria/state/conversation_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_agent_transport.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const ServerProfile profile = ServerProfile(
    id: 'server-1',
    name: 'Local',
    url: 'ws://127.0.0.1:3000',
    token: '',
    cwd: '/tmp',
  );

  late FakeAgentTransport transport;
  late ConversationController conversation;
  late ConnectionController connection;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    transport = FakeAgentTransport();
    conversation = ConversationController();
    connection = ConnectionController(
      conversation: conversation,
      store: const ServerStore(),
      factory: (_) async => AcpClient(transport),
    );
  });

  tearDown(() async {
    await connection.disconnect();
    connection.dispose();
  });

  group('connect', () {
    test('performs the handshake and starts a session', () async {
      await connection.connect(profile);

      expect(connection.status, ConnectionStatus.connected);
      expect(connection.profile, profile);
      expect(connection.session?.id, 's1');
      expect(
        transport.sent.map((frame) => frame['method']),
        containsAll(<String>[AcpMethods.initialize, AcpMethods.newSession]),
      );
      expect(connection.models.currentModelId, 'm1');
      expect(connection.modes.currentModeId, 'code');
      expect(connection.efforts.currentValue, 'medium');
    });

    test('maps a failure to an error state', () async {
      final failing = ConnectionController(
        conversation: conversation,
        store: const ServerStore(),
        factory: (_) async => throw const AcpTransportClosed('refused'),
      );

      await failing.connect(profile);

      expect(failing.status, ConnectionStatus.error);
      expect(failing.error?.kind, AriaErrorKind.network);
      expect(failing.session, isNull);
      failing.dispose();
    });

    test('loads the agent session list', () async {
      await connection.connect(profile);
      await connection.refreshSessions();

      expect(connection.sessions, hasLength(1));
      expect(connection.sessions.single.sessionId, 'older');
    });
  });

  group('turns', () {
    test('streams a reply and ends the turn', () async {
      await connection.connect(profile);

      final turn = connection.send('hello');
      expect(connection.running, isTrue);
      expect(conversation.messages.single.role, 'user');

      transport
        ..emitText('s1', SessionUpdateKind.agentThoughtChunk, 'thinking')
        ..emitText('s1', SessionUpdateKind.agentMessageChunk, 'Hel')
        ..emitText('s1', SessionUpdateKind.agentMessageChunk, 'lo');

      expect(conversation.messages.last.content, 'Hello');
      expect(conversation.messages.last.streaming, isTrue);

      transport.completePrompt();
      await turn;

      expect(connection.running, isFalse);
      expect(conversation.messages.last.streaming, isFalse);
    });

    test('stop cancels the running turn', () async {
      await connection.connect(profile);
      final turn = connection.send('work');

      await connection.stop();

      expect(
        transport.sent.where((frame) => frame['method'] == AcpMethods.cancel),
        hasLength(1),
      );

      transport.completePrompt(stopReason: 'cancelled');
      await turn;

      expect(connection.running, isFalse);
      expect(conversation.messages.last.streaming, isFalse);
    });

    test('ignores a second send while a turn is running', () async {
      await connection.connect(profile);
      final turn = connection.send('one');

      await connection.send('two');

      expect(connection.running, isTrue);
      expect(conversation.messages, hasLength(1));

      transport.completePrompt();
      await turn;
    });
  });

  group('permissions', () {
    test('allows a request and clears the queue', () async {
      await connection.connect(profile);
      transport.emitPermission();

      expect(connection.pendingPermission, isNotNull);

      await connection.allowPermission('allow_once');

      expect(connection.pendingPermission, isNull);
      final response = transport.sent.lastWhere((frame) => frame['id'] == 900);
      expect(response['result'], <String, Object?>{
        'outcome': <String, Object?>{
          'outcome': 'selected',
          'optionId': 'allow_once',
        },
      });
    });

    test('denies a request as cancelled', () async {
      await connection.connect(profile);
      transport.emitPermission();

      await connection.denyPermission();

      final response = transport.sent.lastWhere((frame) => frame['id'] == 900);
      expect(response['result'], <String, Object?>{
        'outcome': <String, Object?>{'outcome': 'cancelled'},
      });
    });
  });

  group('surfaces', () {
    test('switches model, mode and effort', () async {
      await connection.connect(profile);

      await connection.selectModel('m2');
      expect(connection.models.currentModelId, 'm2');
      expect(transport.sent.last['method'], AcpMethods.setConfigOption);
      expect(transport.sent.last['params'], containsPair('configId', 'model'));
      expect(transport.sent.last['params'], containsPair('value', 'm2'));

      await connection.selectMode('plan');
      expect(connection.modes.currentModeId, 'plan');
      expect(transport.sent.last['method'], AcpMethods.setMode);
      expect(transport.sent.last['params'], containsPair('modeId', 'plan'));

      await connection.selectEffort('high');
      expect(connection.efforts.currentValue, 'high');
      expect(
        transport.sent.last['params'],
        containsPair('configId', 'thought_level'),
      );
    });

    test('uses session/set_model for the models-object shape', () async {
      final modelsTransport = FakeAgentTransport(
        sessionResult: <String, Object?>{
          'models': <String, Object?>{
            'currentModelId': 'auto',
            'availableModels': <Object?>[
              <String, Object?>{'modelId': 'auto', 'name': 'Auto'},
              <String, Object?>{'modelId': 'pro', 'name': 'Pro'},
            ],
          },
        },
      );
      final controller = ConnectionController(
        conversation: ConversationController(),
        store: const ServerStore(),
        factory: (_) async => AcpClient(modelsTransport),
      );

      await controller.connect(profile);
      await controller.selectModel('pro');

      expect(modelsTransport.sent.last['method'], AcpMethods.setModel);
      expect(
        modelsTransport.sent.last['params'],
        containsPair('modelId', 'pro'),
      );

      await controller.disconnect();
      controller.dispose();
    });
  });

  group('reconnect', () {
    test('reflects transport states without ending the session', () async {
      await connection.connect(profile);
      final session = connection.session;

      transport.emitState(AcpTransportState.reconnecting);
      expect(connection.status, ConnectionStatus.reconnecting);
      expect(connection.session, same(session));

      transport.emitState(AcpTransportState.connected);
      expect(connection.status, ConnectionStatus.connected);

      transport.emitState(AcpTransportState.closed);
      expect(connection.status, ConnectionStatus.error);
      expect(connection.error?.kind, AriaErrorKind.network);
    });
  });

  group('sessions', () {
    test('loads a session and replays history without streaming', () async {
      await connection.connect(profile);

      await connection.openSession('older');
      await Future<void>.delayed(Duration.zero);

      expect(conversation.messages, hasLength(2));
      expect(conversation.messages.first.role, 'user');
      expect(conversation.messages.first.content, 'previous question');
      expect(conversation.messages.last.content, 'previous answer');
      expect(
        conversation.messages.every((message) => !message.streaming),
        isTrue,
      );
      expect(connection.session?.id, 'older');
    });

    test('starts a fresh session', () async {
      await connection.connect(profile);

      await connection.newSession();

      expect(connection.session?.id, 's2');
      expect(conversation.messages, isEmpty);
    });

    test('deletes a listed session', () async {
      await connection.connect(profile);
      await connection.refreshSessions();
      expect(connection.canDeleteSessions, isTrue);
      expect(connection.sessions, hasLength(1));

      await connection.deleteSession('older');

      expect(connection.sessions, isEmpty);
      final request = transport.sent.lastWhere(
        (frame) => frame['method'] == AcpMethods.deleteSession,
      );
      expect(request['params'], <String, Object?>{'sessionId': 'older'});
      expect(connection.session?.id, 's1');
    });

    test('deleting the active session starts a fresh one', () async {
      await connection.connect(profile);
      expect(connection.session?.id, 's1');

      await connection.deleteSession('s1');

      expect(connection.session?.id, 's2');
      expect(conversation.messages, isEmpty);
      expect(
        transport.sent.where(
          (frame) => frame['method'] == AcpMethods.closeSession,
        ),
        hasLength(1),
      );
    });

    test('disconnect tears the client down', () async {
      await connection.connect(profile);

      await connection.disconnect();

      expect(connection.status, ConnectionStatus.disconnected);
      expect(connection.session, isNull);
      expect(connection.profile, isNull);
      expect(connection.sessions, isEmpty);
      expect(transport.closed, isTrue);
    });
  });
}
