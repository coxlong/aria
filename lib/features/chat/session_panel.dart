import 'dart:async';

import 'package:acp/acp.dart';
import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../l10n/app_localizations.dart';
import '../../state/connection_controller.dart';
import '../connect/settings_page.dart';

/// Side panel with the new-chat action, recent sessions and connection exits.
///
/// Shown as a drawer on narrow layouts and as a fixed column on wide ones.
final class SessionPanel extends StatelessWidget {
  const SessionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return ListenableBuilder(
      listenable: scope.connection,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final connection = scope.connection;
        return ListView(
          children: [
            ListTile(
              title: Text(l10n.appName),
              subtitle: Text(
                connection.profile?.displayName ?? l10n.currentConnection,
              ),
            ),
            ListTile(
              title: Text(l10n.newChat),
              onTap: () {
                _closeDrawer(context);
                unawaited(connection.newSession());
              },
            ),
            ListTile(
              title: Text(l10n.recentSessions),
              trailing: TextButton(
                onPressed: () => unawaited(connection.refreshSessions()),
                child: Text(l10n.refresh),
              ),
            ),
            if (connection.sessions.isEmpty)
              ListTile(title: Text(l10n.noSessions))
            else
              for (final session in connection.sessions)
                ListTile(
                  title: Text(
                    session.title.isEmpty
                        ? l10n.sessionUntitled
                        : session.title,
                  ),
                  subtitle: session.cwd.isEmpty ? null : Text(session.cwd),
                  selected: session.sessionId == connection.session?.id,
                  trailing: connection.canDeleteSessions
                      ? IconButton(
                          tooltip: l10n.deleteSession,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteSession(
                            context,
                            connection,
                            session,
                            l10n,
                          ),
                        )
                      : null,
                  onTap: () {
                    _closeDrawer(context);
                    unawaited(connection.openSession(session.sessionId));
                  },
                ),
            const Divider(),
            ListTile(
              title: Text(l10n.switchServer),
              onTap: () {
                _closeDrawer(context);
                unawaited(connection.disconnect());
              },
            ),
            ListTile(
              title: Text(l10n.settings),
              onTap: () {
                _closeDrawer(context);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> _deleteSession(
    BuildContext context,
    ConnectionController connection,
    SessionSummary session,
    AppLocalizations l10n,
  ) async {
    final name = session.title.isEmpty ? l10n.sessionUntitled : session.title;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteSession),
        content: Text(l10n.deleteServerConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await connection.deleteSession(session.sessionId);
    }
  }

  static void _closeDrawer(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) {
      scaffold.closeDrawer();
    }
  }
}
