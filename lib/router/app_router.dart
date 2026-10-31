import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/chat/presentation/chat_page.dart';
import '../features/connect/presentation/connect_page.dart';
import '../features/connection/application/agent_manager.dart';
import '../features/home/presentation/home_page.dart';

part 'app_router.g.dart';

/// Aria has one entrance and two surfaces: home, and one conversation.
///
/// A connection is not a conversation: home opens as soon as an agent answers,
/// and a session exists only once a conversation is opened. Every connected
/// agent keeps running in the background; the router only follows the active
/// one. Settings and agent configuration live in sheets, not routes, so the
/// back stack only means one thing.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(agentManagerProvider, (previous, next) {
    final changed =
        previous?.activeAgentId != next.activeAgentId ||
        previous?.activeAgent?.status != next.activeAgent?.status ||
        previous?.activeSessionId != next.activeSessionId;
    if (changed) refresh.value++;
  });

  final router = GoRouter(
    initialLocation: '/connect',
    refreshListenable: refresh,
    redirect: (context, state) {
      final manager = ref.read(agentManagerProvider);
      final location = state.matchedLocation;

      if (!manager.isConnected) {
        return location == '/connect' ? null : '/connect';
      }
      // `/connect` is left in place while the wake screen holds its success
      // bloom; that page goes home itself. Anything else connected belongs home.
      if (location == '/') return '/home';
      if (location == '/chat' && manager.activeSessionRef == null) {
        return '/home';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/connect',
        builder: (context, state) => const ConnectPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/chat',
        builder: (context, state) => ChatPage(
          initialText: state.extra is String ? state.extra as String : null,
        ),
      ),
    ],
  );

  ref.onDispose(() {
    refresh.dispose();
    router.dispose();
  });
  return router;
}
