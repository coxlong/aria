import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/error_text.dart';
import '../../core/models/server_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../state/connection_controller.dart';
import '../../state/servers_controller.dart';
import 'server_edit_page.dart';
import 'settings_page.dart';

/// Server picker and connection entry point.
final class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([scope.servers, scope.connection]),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final connection = scope.connection;
        final servers = scope.servers;
        final connecting = connection.status == ConnectionStatus.connecting;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appName),
            actions: [
              IconButton(
                tooltip: l10n.settings,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
                ),
              ),
            ],
          ),
          body: servers.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    ListTile(
                      title: Text(l10n.connectTitle),
                      subtitle: Text(l10n.connectSubtitle),
                    ),
                    if (connection.error != null)
                      ListTile(
                        leading: const Icon(Icons.error_outline),
                        title: Text(localizeError(l10n, connection.error!)),
                        subtitle: Text(connection.error!.technicalMessage),
                        trailing: connection.profile == null
                            ? null
                            : TextButton(
                                onPressed: () =>
                                    connection.connect(connection.profile!),
                                child: Text(l10n.retry),
                              ),
                      ),
                    if (servers.servers.isEmpty)
                      ListTile(
                        leading: const Icon(Icons.dns_outlined),
                        title: Text(l10n.noServersTitle),
                        subtitle: Text(l10n.noServersBody),
                        trailing: TextButton(
                          key: const Key('addServer'),
                          onPressed: () => _openEditor(context, null),
                          child: Text(l10n.addServer),
                        ),
                      )
                    else ...[
                      for (final server in servers.servers)
                        _ServerTile(
                          server: server,
                          busy:
                              connecting && connection.profile?.id == server.id,
                          enabled: !connecting,
                          onConnect: () => connection.connect(server),
                          onEdit: () => _openEditor(context, server),
                          onDelete: () =>
                              _confirmDelete(context, servers, server),
                        ),
                      ListTile(
                        leading: const Icon(Icons.add),
                        title: Text(l10n.addServer),
                        onTap: connecting
                            ? null
                            : () => _openEditor(context, null),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }

  static Future<void> _openEditor(
    BuildContext context,
    ServerProfile? profile,
  ) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => ServerEditPage(profile: profile)),
  );

  static Future<void> _confirmDelete(
    BuildContext context,
    ServersController servers,
    ServerProfile server,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteServer),
        content: Text(l10n.deleteServerConfirm(server.displayName)),
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
      await servers.delete(server.id);
    }
  }
}

class _ServerTile extends StatelessWidget {
  const _ServerTile({
    required this.server,
    required this.busy,
    required this.enabled,
    required this.onConnect,
    required this.onEdit,
    required this.onDelete,
  });

  final ServerProfile server;
  final bool busy;
  final bool enabled;
  final VoidCallback onConnect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.dns_outlined),
      title: Text(server.displayName),
      subtitle: Text(server.url),
      onTap: enabled ? onConnect : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            TextButton(
              onPressed: enabled ? onConnect : null,
              child: Text(l10n.connect),
            ),
          PopupMenuButton<String>(
            onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text(l10n.editServer)),
              PopupMenuItem(value: 'delete', child: Text(l10n.deleteServer)),
            ],
          ),
        ],
      ),
    );
  }
}
