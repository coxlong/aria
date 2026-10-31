import 'dart:async';

import 'package:aria/core/error/app_error.dart';
import 'package:aria/domain/chat/chat_turn.dart';
import 'package:aria/domain/decision/decision.dart';
import 'package:aria/domain/executor/executor.dart';
import 'package:aria/domain/profile/server_profile.dart';
import 'package:aria/domain/session/agent_connection.dart';
import 'package:aria/domain/session/agent_session.dart';
import 'package:aria/features/connection/application/agent_manager.dart';
import 'package:aria/features/connection/application/executor_factory.dart';
import 'package:aria/features/settings/application/settings_controller.dart';
import 'package:aria/features/settings/domain/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The manager owns conversation state, not the pages. These tests drive an
/// executor directly and never mount a widget: if state still arrives, it does
/// not depend on a screen being alive.

final ServerProfile _agentA = const ServerProfile(
  id: 'a',
  name: 'Agent A',
  url: 'ws://a',
  cwd: '/work',
);

final ServerProfile _agentB = const ServerProfile(
  id: 'b',
  name: 'Agent B',
  url: 'ws://b',
  cwd: '/other',
);

final class _FakeSettings extends Settings {
  _FakeSettings(this.profiles);

  final List<ServerProfile> profiles;

  @override
  AppSettings build() =>
      AppSettings(profiles: profiles, activeProfileId: profiles.first.id);

  @override
  Future<ConnectedProfile?> connected(String profileId) async {
    for (final profile in profiles) {
      if (profile.id == profileId) {
        return ConnectedProfile(profile: profile, token: '');
      }
    }
    return null;
  }
}

final class _FakeExecutor implements Executor {
  _FakeExecutor(this.profile);

  final ConnectedProfile profile;

  final StreamController<ExecutorEvent> _events =
      StreamController<ExecutorEvent>.broadcast();
  final StreamController<ExecutorConnection> _connection =
      StreamController<ExecutorConnection>.broadcast();

  final Map<String, SessionSurfaces> _surfaces = <String, SessionSurfaces>{};
  final Map<String, String> _held = <String, String>{};

  final List<String> loads = <String>[];
  final List<String> prompts = <String>[];
  final List<String> cancels = <String>[];
  List<AgentSessionSummary> summaries = <AgentSessionSummary>[];

  int _newCount = 0;

  @override
  Stream<ExecutorEvent> get events => _events.stream;

  @override
  Stream<ExecutorConnection> get connection => _connection.stream;

  @override
  Future<AgentCapabilities> connect() async {
    _connection.add(ExecutorConnection.connected);
    return const AgentCapabilities(
      canLoadSession: true,
      canListSessions: true,
      canDeleteSession: true,
    );
  }

  @override
  Future<List<AgentSessionSummary>> listSessions({String? cwd}) async =>
      summaries;

  @override
  Future<AgentSession> newSession({required String cwd}) async {
    final id = 'new-${_newCount++}';
    _held[id] = cwd;
    _surfaces[id] = const SessionSurfaces(
      models: <SessionOption>[SessionOption(id: 'm1', label: 'Model one')],
      currentModelId: 'm1',
    );
    summaries = <AgentSessionSummary>[
      AgentSessionSummary(id: id, title: 'New conversation', cwd: cwd),
      ...summaries,
    ];
    return AgentSession(id: id, cwd: cwd);
  }

  @override
  Future<AgentSession> openSession({
    required String id,
    required String cwd,
  }) async {
    loads.add(id);
    _held[id] = cwd;
    _surfaces[id] = SessionSurfaces.none;
    return AgentSession(id: id, cwd: cwd);
  }

  @override
  Future<void> deleteSession(String id) async {
    _held.remove(id);
    summaries = summaries.where((summary) => summary.id != id).toList();
  }

  @override
  bool holds(String sessionId) => _held.containsKey(sessionId);

  @override
  SessionSurfaces surfacesOf(String sessionId) =>
      _surfaces[sessionId] ?? SessionSurfaces.none;

  @override
  Future<void> prompt({required String sessionId, required String text}) async {
    prompts.add('$sessionId:$text');
  }

  @override
  Future<void> cancel(String sessionId) async {
    cancels.add(sessionId);
  }

  @override
  Future<void> answer(DecisionAnswer answer) async {}

  @override
  Future<void> setModel(String sessionId, String id) async {
    final current = surfacesOf(sessionId);
    _surfaces[sessionId] = current.copyWith(currentModelId: id);
    _events.add(SurfacesChanged(sessionId));
  }

  @override
  Future<void> setMode(String sessionId, String id) async {
    final current = surfacesOf(sessionId);
    _surfaces[sessionId] = current.copyWith(currentModeId: id);
    _events.add(SurfacesChanged(sessionId));
  }

  @override
  Future<void> setConfigOption(
    String sessionId,
    String configId,
    String value,
  ) async {
    final current = surfacesOf(sessionId);
    _surfaces[sessionId] = current.copyWith(currentEffortValue: value);
    _events.add(SurfacesChanged(sessionId));
  }

  @override
  Future<void> dispose() async {
    await _events.close();
    await _connection.close();
  }

  void emit(ExecutorEvent event) => _events.add(event);

  void drop() => _connection.add(ExecutorConnection.closed);
}

void main() {
  late Map<String, _FakeExecutor> executors;
  late ProviderContainer container;
  late AgentManager manager;

  ProviderContainer create(List<ServerProfile> profiles) {
    executors = <String, _FakeExecutor>{};
    final testContainer = ProviderContainer.test(
      overrides: [
        settingsProvider.overrideWith(() => _FakeSettings(profiles)),
        executorFactoryProvider.overrideWithValue((profile) {
          final executor = _FakeExecutor(profile);
          executors[profile.profile.id] = executor;
          return executor;
        }),
      ],
    );
    manager = testContainer.read(agentManagerProvider.notifier);
    return testContainer;
  }

  setUp(() {
    container = create(<ServerProfile>[_agentA, _agentB]);
  });

  test('a turn is folded with no page listening', () async {
    await manager.connect(_agentA);
    final state = container.read(agentManagerProvider);
    expect(state.activeAgent?.status, AgentStatus.connected);

    await manager.newSession('a');
    final ref = container.read(agentManagerProvider).activeSessionRef;
    expect(ref, isNotNull);

    final accepted = await manager.send(ref!, 'Ship the beta');
    expect(accepted, isTrue);
    expect(container.read(agentManagerProvider).session(ref).running, isTrue);
    expect(executors['a']!.prompts, <String>['${ref.sessionId}:Ship the beta']);

    // The agent echoes the user message, then streams text and finishes.
    final executor = executors['a']!;
    executor.emit(UserPrompt(ref.sessionId, 'Ship the beta'));
    executor.emit(AgentText(ref.sessionId, 'The build is ready.'));
    executor.emit(ExecutionFinished(ref.sessionId, stopReason: 'end_turn'));
    await pumpEventQueue();

    final chat = container.read(agentManagerProvider).session(ref);
    expect(chat.running, isFalse);
    expect(chat.turns, hasLength(1));
    expect(chat.turns.single.userText, 'Ship the beta');
    expect(chat.turns.single.blocks.single, isA<TextBlock>());
    expect(
      (chat.turns.single.blocks.single as TextBlock).text,
      'The build is ready.',
    );
  });

  test('a running turn keeps running while another session is open', () async {
    await manager.connect(_agentA);
    executors['a']!.summaries = const <AgentSessionSummary>[
      AgentSessionSummary(id: 's1', title: 'First', cwd: '/work'),
      AgentSessionSummary(id: 's2', title: 'Second', cwd: '/work'),
    ];

    await manager.openSession('a', 's1');
    final first = container.read(agentManagerProvider).activeSessionRef!;
    await manager.send(first, 'Work on it');
    expect(container.read(agentManagerProvider).session(first).running, isTrue);

    await manager.openSession('a', 's2');
    final state = container.read(agentManagerProvider);
    expect(state.activeSessionRef?.sessionId, 's2');
    expect(
      state.session(first).running,
      isTrue,
      reason: 'leaving the page must not end the turn',
    );
    expect(executors['a']!.loads, <String>['s1', 's2']);
  });

  test('reopening a held session switches without reloading', () async {
    await manager.connect(_agentA);
    executors['a']!.summaries = const <AgentSessionSummary>[
      AgentSessionSummary(id: 's1', title: 'First', cwd: '/work'),
      AgentSessionSummary(id: 's2', title: 'Second', cwd: '/work'),
    ];

    await manager.openSession('a', 's1');
    final ref = container.read(agentManagerProvider).activeSessionRef!;
    await manager.send(ref, 'Keep this');
    executors['a']!.emit(UserPrompt('s1', 'Keep this'));
    executors['a']!.emit(AgentText('s1', 'Kept.'));
    await pumpEventQueue(times: 20);

    await manager.openSession('a', 's2');
    await manager.openSession('a', 's1');

    expect(executors['a']!.loads, <String>['s1', 's2']);
    final chat = container.read(agentManagerProvider).session(ref);
    expect(chat.turns.single.userText, 'Keep this');
    expect((chat.turns.single.blocks.single as TextBlock).text, 'Kept.');
  });

  test('a draft belongs to the conversation, not the page', () async {
    await manager.connect(_agentA);
    await manager.newSession('a');
    final ref = container.read(agentManagerProvider).activeSessionRef!;

    manager.setDraft(ref, 'half a thought');
    expect(container.read(agentManagerProvider).draft(ref), 'half a thought');

    await manager.send(ref, 'Send it');
    expect(container.read(agentManagerProvider).draft(ref), isEmpty);
  });

  test('two agents stay connected at the same time', () async {
    await manager.connect(_agentA);
    await manager.newSession('a');
    final refA = container.read(agentManagerProvider).activeSessionRef!;

    await manager.connect(_agentB);
    await manager.newSession('b');

    final state = container.read(agentManagerProvider);
    expect(state.activeAgentId, 'b');
    expect(state.agents['a']?.status, AgentStatus.connected);
    expect(state.agents['b']?.status, AgentStatus.connected);
    expect(state.session(refA).sessionId, refA.sessionId);

    // A still receives its own events while B is on screen.
    executors['a']!.emit(AgentText(refA.sessionId, 'Still here.'));
    await Future<void>.delayed(const Duration(milliseconds: 40));
    final chatA = container.read(agentManagerProvider).session(refA);
    expect(chatA.turns, isNotEmpty);
  });

  test('disconnecting one agent leaves the other untouched', () async {
    await manager.connect(_agentA);
    await manager.connect(_agentB);
    await manager.newSession('b');
    final refB = container.read(agentManagerProvider).activeSessionRef!;

    await manager.disconnect('a');

    final state = container.read(agentManagerProvider);
    expect(state.agents.containsKey('a'), isFalse);
    expect(state.activeAgentId, 'b');
    expect(state.session(refB).sessionId, refB.sessionId);
  });

  test('a lost connection clears only that agent sessions', () async {
    await manager.connect(_agentA);
    await manager.newSession('a');
    final refA = container.read(agentManagerProvider).activeSessionRef!;

    await manager.connect(_agentB);
    await manager.newSession('b');

    executors['a']!.drop();
    await pumpEventQueue();

    final state = container.read(agentManagerProvider);
    expect(state.agents['a']?.status, AgentStatus.failed);
    expect(state.activeAgentId, 'b');
    expect(state.sessions.containsKey(refA), isFalse);
    expect(state.isConnected, isTrue);
  });

  test('an executor failure surfaces on that conversation', () async {
    await manager.connect(_agentA);
    await manager.newSession('a');
    final ref = container.read(agentManagerProvider).activeSessionRef!;
    await manager.send(ref, 'Try');

    executors['a']!.emit(
      ExecutionFailed(ref.sessionId, const NetworkUnavailable('gone')),
    );
    await pumpEventQueue();

    final chat = container.read(agentManagerProvider).session(ref);
    expect(chat.running, isFalse);
    expect(chat.error, isA<NetworkUnavailable>());
  });

  test('a decision waits in the session that raised it', () async {
    await manager.connect(_agentA);
    await manager.newSession('a');
    final ref = container.read(agentManagerProvider).activeSessionRef!;

    final decision = Decision(
      id: 'd1',
      prompt: 'Allow publishing?',
      options: const <DecisionOption>[
        DecisionOption(
          id: 'allow',
          label: 'Allow once',
          kind: DecisionOptionKind.allowOnce,
        ),
      ],
      createdAt: DateTime.now(),
    );
    executors['a']!.emit(DecisionRaised(ref.sessionId, decision));
    await pumpEventQueue();

    final chat = container.read(agentManagerProvider).session(ref);
    expect(chat.waiting, isTrue);
    expect(chat.pendingDecision?.id, 'd1');

    await manager.answer(ref, decision.options.first);
    expect(container.read(agentManagerProvider).session(ref).waiting, isFalse);
  });

  test('finishing a turn settles approvals the agent abandoned', () async {
    await manager.connect(_agentA);
    await manager.newSession('a');
    final ref = container.read(agentManagerProvider).activeSessionRef!;

    executors['a']!.emit(
      DecisionRaised(
        ref.sessionId,
        Decision(
          id: 'd1',
          prompt: 'Allow publishing?',
          options: const <DecisionOption>[],
          createdAt: DateTime.now(),
        ),
      ),
    );
    await pumpEventQueue();
    expect(container.read(agentManagerProvider).session(ref).waiting, isTrue);

    executors['a']!.emit(
      ExecutionFinished(ref.sessionId, stopReason: 'cancelled'),
    );
    await pumpEventQueue();

    expect(container.read(agentManagerProvider).session(ref).waiting, isFalse);
  });
}
