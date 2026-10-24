import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/error/error_text.dart';
import '../../../core/theme/aria_colors.dart';
import '../../../core/theme/aria_tokens.dart';
import '../../../core/theme/aria_type.dart';
import '../../../core/widgets/aria_composer.dart';
import '../../../core/widgets/aria_error_line.dart';
import '../../../core/widgets/connection_note.dart';
import '../../../domain/profile/server_profile.dart';
import '../../../l10n/app_localizations.dart';
import '../../connection/application/connection_controller.dart';
import '../application/chat_controller.dart';
import '../application/chat_view.dart';
import 'widgets/message_list.dart';
import 'widgets/permission_sheet.dart';
import 'widgets/selector_sheet.dart';
import 'widgets/session_panel.dart';

/// The workspace: sessions on the left, one conversation in the middle, the
/// composer at the bottom.
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  /// The decision currently on screen, so a rebuild never opens a second one.
  String? _showingDecisionId;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final connection = ref.watch(connectionProvider);
    final session = connection.session;

    // The route guard sends the person back to /connect when the session goes
    // away; this only covers the frame before that happens.
    if (session == null) return const Scaffold(body: SizedBox.shrink());

    final chat = ref.watch(chatProvider(session.id));
    _syncPermission(connection);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final panelWidth = constraints.maxWidth >= 1100 ? 320.0 : 240.0;

        return Scaffold(
          key: _scaffold,
          drawer: wide
              ? null
              : Drawer(
                  width: constraints.maxWidth * 0.82,
                  backgroundColor: colors.canvas,
                  child: SessionPanel(
                    onNavigate: () => Navigator.of(context).maybePop(),
                  ),
                ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (wide) ...<Widget>[
                SizedBox(width: panelWidth, child: const SessionPanel()),
                VerticalDivider(width: 1, color: colors.border),
              ],
              Expanded(
                child: SafeArea(
                  left: false,
                  child: Column(
                    children: <Widget>[
                      _TopBar(
                        compact: !wide,
                        onMenu: () => _scaffold.currentState?.openDrawer(),
                      ),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AriaSpacing.readingColumn,
                            ),
                            child: MessageList(
                              // A new session starts at its own top rather than
                              // inheriting the previous session's scroll offset.
                              key: ValueKey<String>(session.id),
                              view: chat,
                            ),
                          ),
                        ),
                      ),
                      if (connection.status == ConnectionStatus.reconnecting)
                        ConnectionNote(
                          message: AppLocalizations.of(context).reconnecting,
                        ),
                      if (chat.error != null || connection.error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AriaSpacing.md,
                          ),
                          child: AriaErrorLine(
                            error: chat.error ?? connection.error!,
                          ),
                        ),
                      _ComposerBar(chat: chat, connection: connection),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Opens the approval sheet for the head of the decision queue, once.
  void _syncPermission(ConnectionSnapshot connection) {
    final decision = connection.pendingDecision;
    if (decision == null) {
      _showingDecisionId = null;
      return;
    }
    if (_showingDecisionId == decision.id) return;
    _showingDecisionId = decision.id;

    final queued = connection.queuedDecisions;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        showPermission(
          context,
          decision,
          queued: queued,
          onAnswer: (option) =>
              unawaited(ref.read(connectionProvider.notifier).answer(option)),
        ).whenComplete(() {
          if (!mounted) return;
          // The sheet is gone. If another decision's sheet opened in the
          // meantime it owns the marker now, so leave it alone.
          if (_showingDecisionId != decision.id) return;
          _showingDecisionId = null;
          // A failed answer leaves the decision open; ask again rather than
          // pretending it was delivered.
          if (ref.read(connectionProvider).pendingDecision?.id == decision.id) {
            setState(() {});
          }
        }),
      );
    });
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.compact, required this.onMenu});

  final bool compact;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final connection = ref.watch(connectionProvider);
    final session = connection.session;
    final turns = session == null
        ? 0
        : ref.watch(chatProvider(session.id)).turns.length;

    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AriaSpacing.xs),
        child: Row(
          children: <Widget>[
            if (compact)
              IconButton(
                tooltip: l10n.sessions,
                onPressed: onMenu,
                icon: const Icon(Icons.segment_rounded),
                color: colors.textMuted,
              ),
            if (compact)
              Expanded(
                child: Text(
                  connection.profile?.displayName ?? l10n.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.ariaType.title.copyWith(color: colors.text),
                ),
              )
            else
              const Spacer(),
            _ConnectionBadge(status: connection.status),
            const SizedBox(width: AriaSpacing.xs),
            if (turns > 0)
              IconButton(
                tooltip: l10n.newChat,
                onPressed: () => unawaited(
                  ref.read(connectionProvider.notifier).newSession(),
                ),
                icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                color: colors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;

    final (color, label) = switch (status) {
      ConnectionStatus.connected => (colors.primary, l10n.connected),
      ConnectionStatus.connecting => (colors.textMuted, l10n.connecting),
      ConnectionStatus.reconnecting => (
        colors.textMuted,
        l10n.reconnectingShort,
      ),
      ConnectionStatus.failed => (colors.error, l10n.disconnected),
      ConnectionStatus.idle => (colors.textMuted, l10n.disconnected),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 8,
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: AriaSpacing.xxs),
        Text(label, style: context.ariaType.caption.copyWith(color: color)),
      ],
    );
  }
}

class _ComposerBar extends ConsumerWidget {
  const _ComposerBar({required this.chat, required this.connection});

  final ChatView chat;
  final ConnectionSnapshot connection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final surfaces = connection.surfaces;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AriaSpacing.md,
        AriaSpacing.xs,
        AriaSpacing.md,
        AriaSpacing.md,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AriaSpacing.readingColumn,
          ),
          child: AriaComposer(
            hint: l10n.composerHint,
            running: chat.running,
            enabled: connection.isConnected,
            onStop: () => unawaited(
              ref.read(chatProvider(chat.sessionId).notifier).stop(),
            ),
            onSubmit: (text) =>
                ref.read(chatProvider(chat.sessionId).notifier).send(text),
            chips: <Widget>[
              if (surfaces?.hasModels ?? false)
                _OptionChip(
                  // The agent may offer models without naming the current one;
                  // the chip then reads "Model" instead of inventing a choice.
                  label: surfaces!.modelLabel ?? l10n.model,
                  onTap: () => _pickModel(context, ref),
                ),
              if (surfaces?.hasModes ?? false)
                _OptionChip(
                  label: surfaces!.modeLabel ?? l10n.mode,
                  onTap: () => _pickMode(context, ref),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickModel(BuildContext context, WidgetRef ref) async {
    final surfaces = ref.read(connectionProvider).surfaces;
    if (surfaces == null) return;
    final picked = await showModelSheet(context: context, surfaces: surfaces);
    if (picked == null) return;

    final notifier = ref.read(connectionProvider.notifier);
    if (picked.modelId != null) await notifier.selectModel(picked.modelId!);
    if (picked.effortValue != null) {
      await notifier.selectEffort(picked.effortValue!);
    }
    if (!context.mounted) return;
    _reportFailure(context, ref);
  }

  Future<void> _pickMode(BuildContext context, WidgetRef ref) async {
    final current = ref.read(connectionProvider).surfaces;
    if (current == null) return;
    final picked = await showOptionSheet(
      context: context,
      title: AppLocalizations.of(context).mode,
      options: current.modes,
      selectedId: current.currentModeId,
    );
    if (picked == null) return;
    await ref.read(connectionProvider.notifier).selectMode(picked);
    if (!context.mounted) return;
    _reportFailure(context, ref);
  }

  /// Selector failures are otherwise invisible: the sheet has already closed.
  void _reportFailure(BuildContext context, WidgetRef ref) {
    final error = ref.read(connectionProvider).error;
    if (error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(describeError(AppLocalizations.of(context), error)),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({required this.label, required this.onTap});

  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    if (label == null) return const SizedBox.shrink();

    return Material(
      color: colors.inset,
      borderRadius: AriaRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AriaRadius.pillAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110, minHeight: 28),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AriaSpacing.sm,
              vertical: AriaSpacing.xxs,
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.ariaType.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
