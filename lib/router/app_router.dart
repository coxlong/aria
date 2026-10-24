import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/chat/presentation/chat_page.dart';
import '../features/connect/presentation/connect_page.dart';
import '../features/connection/application/connection_controller.dart';
import '../features/settings/presentation/server_edit_page.dart';
import '../features/settings/presentation/settings_page.dart';

part 'app_router.g.dart';

/// Aria has one entry and one workspace.
///
/// The app always opens on the server list; a session exists only after a
/// connection succeeds, and losing it sends the person back to that list. There
/// is no way to reach the chat surface without a live session, which is exactly
/// the state the old home screen could not guarantee.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(connectionProvider, (previous, next) {
    final changed =
        previous?.status != next.status ||
        previous?.session?.id != next.session?.id;
    if (changed) refresh.value++;
  });

  final router = GoRouter(
    initialLocation: '/connect',
    refreshListenable: refresh,
    redirect: (context, state) {
      final hasSession = ref.read(connectionProvider).session != null;
      final location = state.matchedLocation;
      final onSettings = location.startsWith('/settings');

      if (!hasSession) {
        if (location == '/connect' || onSettings) return null;
        return '/connect';
      }
      if (location == '/connect') return '/chat';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/connect',
        builder: (context, state) => const ConnectPage(),
      ),
      GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        routes: <RouteBase>[
          GoRoute(
            path: 'server/:id',
            builder: (context, state) =>
                ServerEditPage(profileId: state.pathParameters['id'] ?? 'new'),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    refresh.dispose();
    router.dispose();
  });
  return router;
}
