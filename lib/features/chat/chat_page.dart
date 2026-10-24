import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/error_text.dart';
import '../../l10n/app_localizations.dart';
import '../../state/connection_controller.dart';
import 'message_list.dart';
import 'permission_prompt.dart';
import 'selector_sheet.dart';
import 'session_panel.dart';

/// Conversation with the connected agent.
final class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final connection = scope.connection;
    final conversation = scope.conversation;

    return ListenableBuilder(
      listenable: Listenable.merge([connection, conversation]),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final messages = conversation.messages;
        final permission = connection.pendingPermission;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });

        return Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                return Scaffold(
                  appBar: _appBar(context, l10n, connection),
                  drawer: wide ? null : const SessionPanel(),
                  body: Row(
                    children: [
                      if (wide) ...[
                        const SizedBox(width: 280, child: SessionPanel()),
                        const VerticalDivider(width: 1),
                      ],
                      Expanded(
                        child: Column(
                          children: [
                            if (connection.status ==
                                ConnectionStatus.reconnecting)
                              ListTile(
                                leading: const Icon(Icons.wifi_off),
                                title: Text(l10n.reconnecting),
                              ),
                            if (connection.error != null)
                              ListTile(
                                leading: const Icon(Icons.error_outline),
                                title: Text(
                                  localizeError(l10n, connection.error!),
                                ),
                                subtitle: Text(
                                  connection.error!.technicalMessage,
                                ),
                              ),
                            Expanded(
                              child: messages.isEmpty
                                  ? Center(child: Text(l10n.emptyChatBody))
                                  : MessageList(
                                      controller: _scroll,
                                      messages: messages,
                                    ),
                            ),
                            _Composer(
                              controller: _composer,
                              connection: connection,
                              onSend: _send,
                              onStop: _stop,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (permission != null)
              PermissionPrompt(
                request: permission,
                onAllow: connection.allowPermission,
                onDeny: connection.denyPermission,
              ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _appBar(
    BuildContext context,
    AppLocalizations l10n,
    ConnectionController connection,
  ) {
    final hasSurfaces =
        connection.models.hasModels ||
        connection.modes.hasModes ||
        connection.efforts.hasEfforts;

    return AppBar(
      title: Text(connection.profile?.displayName ?? l10n.appName),
      actions: [
        if (hasSurfaces)
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune),
            onSelected: (value) {
              switch (value) {
                case 'model':
                  unawaited(_pickModel(context, connection));
                case 'mode':
                  unawaited(_pickMode(context, connection));
                case 'effort':
                  unawaited(_pickEffort(context, connection));
              }
            },
            itemBuilder: (context) => [
              if (connection.models.hasModels)
                PopupMenuItem(
                  value: 'model',
                  child: Text(
                    '${l10n.model}: ${connection.models.currentDisplay ?? ''}',
                  ),
                ),
              if (connection.modes.hasModes)
                PopupMenuItem(
                  value: 'mode',
                  child: Text(
                    '${l10n.mode}: ${connection.modes.currentDisplay ?? ''}',
                  ),
                ),
              if (connection.efforts.hasEfforts)
                PopupMenuItem(
                  value: 'effort',
                  child: Text(
                    '${l10n.effort}: ${connection.efforts.currentDisplay ?? ''}',
                  ),
                ),
            ],
          ),
      ],
    );
  }

  void _send(ConnectionController connection) {
    final text = _composer.text.trim();
    if (text.isEmpty || !connection.canSend) return;
    _composer.clear();
    unawaited(connection.send(text));
  }

  void _stop(ConnectionController connection) {
    unawaited(connection.stop());
  }

  Future<void> _pickModel(
    BuildContext context,
    ConnectionController connection,
  ) => _pick(
    context,
    selected: connection.models.currentModelId,
    options: [
      for (final model in connection.models.available)
        (value: model.modelId, label: model.name),
    ],
    onSelected: connection.selectModel,
  );

  Future<void> _pickMode(
    BuildContext context,
    ConnectionController connection,
  ) => _pick(
    context,
    selected: connection.modes.currentModeId,
    options: [
      for (final mode in connection.modes.available)
        (value: mode.id, label: mode.name),
    ],
    onSelected: connection.selectMode,
  );

  Future<void> _pickEffort(
    BuildContext context,
    ConnectionController connection,
  ) => _pick(
    context,
    selected: connection.efforts.currentValue,
    options: [
      for (final effort in connection.efforts.available)
        (value: effort.value, label: effort.name),
    ],
    onSelected: connection.selectEffort,
  );

  static Future<void> _pick(
    BuildContext context, {
    required String? selected,
    required List<SelectorChoice> options,
    required Future<void> Function(String value) onSelected,
  }) async {
    final value = await showSelectorSheet(
      context: context,
      selected: selected,
      options: options,
    );
    if (value != null) await onSelected(value);
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.connection,
    required this.onSend,
    required this.onStop,
  });

  final TextEditingController controller;
  final ConnectionController connection;
  final void Function(ConnectionController connection) onSend;
  final void Function(ConnectionController connection) onStop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 5,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(connection),
            decoration: InputDecoration(hintText: l10n.composerHint),
          ),
        ),
        if (connection.running)
          IconButton(
            tooltip: l10n.stop,
            onPressed: connection.stopping ? null : () => onStop(connection),
            icon: const Icon(Icons.stop),
          )
        else
          IconButton(
            tooltip: l10n.send,
            onPressed: connection.canSend ? () => onSend(connection) : null,
            icon: const Icon(Icons.send),
          ),
      ],
    );
  }
}
