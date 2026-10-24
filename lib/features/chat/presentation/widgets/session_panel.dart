import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/aria_colors.dart';
import '../../../../core/theme/aria_tokens.dart';
import '../../../../core/theme/aria_type.dart';
import '../../../../domain/profile/server_profile.dart';
import '../../../../domain/session/agent_session.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../connection/application/connection_controller.dart';
import '../../../settings/application/settings_controller.dart';

/// The session list: new chat, recent sessions, and the way out.
///
/// A fixed column on wide screens, a drawer on compact ones. The list comes
/// from the agent every time; Aria keeps no copy of it.
class SessionPanel extends ConsumerWidget {
  const SessionPanel({super.key, this.onNavigate});

  /// Called after an action that should close a drawer.
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;
    final connection = ref.watch(connectionProvider);
    final profile = connection.profile;

    return SafeArea(
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AriaSpacing.md,
              AriaSpacing.md,
              AriaSpacing.md,
              AriaSpacing.sm,
            ),
            child: Text(
              profile?.displayName ?? l10n.appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: type.title.copyWith(color: colors.text),
            ),
          ),
          _ActionRow(
            icon: Icons.auto_awesome_rounded,
            label: l10n.newChat,
            color: colors.primary,
            onTap: () {
              unawaited(ref.read(connectionProvider.notifier).newSession());
              onNavigate?.call();
            },
          ),
          const Divider(height: AriaSpacing.md),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AriaSpacing.md,
              AriaSpacing.xxs,
              AriaSpacing.xs,
              AriaSpacing.xxs,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.sessions,
                    style: type.caption.copyWith(color: colors.textMuted),
                  ),
                ),
                IconButton(
                  tooltip: l10n.refresh,
                  onPressed: connection.canRefresh
                      ? () => unawaited(
                          ref
                              .read(connectionProvider.notifier)
                              .refreshSessions(),
                        )
                      : null,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
          Expanded(
            child: connection.sessions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AriaSpacing.md,
                      vertical: AriaSpacing.sm,
                    ),
                    child: Text(
                      l10n.noSessions,
                      style: type.ui.copyWith(color: colors.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AriaSpacing.xs,
                    ),
                    itemCount: connection.sessions.length,
                    itemBuilder: (context, index) {
                      final session = connection.sessions[index];
                      final active = session.id == connection.session?.id;
                      final resumable = connection.capabilities.canLoadSession;
                      return _SessionRow(
                        key: ValueKey<String>(session.id),
                        session: session,
                        active: active,
                        enabled: active || resumable,
                        onTap: () {
                          if (active || !resumable) return;
                          unawaited(
                            ref
                                .read(connectionProvider.notifier)
                                .openSession(session.id),
                          );
                          onNavigate?.call();
                        },
                      );
                    },
                  ),
          ),
          Divider(height: 1, color: colors.border),
          _ActionRow(
            icon: Icons.swap_horiz_rounded,
            label: l10n.switchConnection,
            onTap: () => _showSwitchSheet(context, ref),
          ),
          _ActionRow(
            icon: Icons.settings_outlined,
            label: l10n.settings,
            onTap: () {
              onNavigate?.call();
              context.push('/settings');
            },
          ),
          _ActionRow(
            icon: Icons.logout_rounded,
            label: l10n.signOut,
            onTap: () =>
                unawaited(ref.read(connectionProvider.notifier).disconnect()),
          ),
          const SizedBox(height: AriaSpacing.xs),
        ],
      ),
    );
  }

  Future<void> _showSwitchSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final profiles = ref.read(settingsProvider).profiles;
    final current = ref.read(connectionProvider).profile?.id;

    final picked = await showModalBottomSheet<ServerProfile>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final colors = context.ariaColors;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: AriaSpacing.xs),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AriaSpacing.lg,
                  0,
                  AriaSpacing.lg,
                  AriaSpacing.sm,
                ),
                child: Text(
                  l10n.switchConnection,
                  style: context.ariaType.title.copyWith(color: colors.text),
                ),
              ),
              for (final profile in profiles)
                ListTile(
                  leading: Icon(
                    Icons.dns_outlined,
                    color: profile.id == current
                        ? colors.primary
                        : colors.textMuted,
                  ),
                  title: Text(profile.displayName),
                  subtitle: Text(
                    profile.url,
                    style: context.ariaType.code.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                  trailing: profile.id == current
                      ? Icon(Icons.check_rounded, color: colors.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(profile),
                ),
              ListTile(
                leading: Icon(Icons.settings_outlined, color: colors.textMuted),
                title: Text(l10n.manageExecutors),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );

    if (picked == null || !context.mounted) return;
    if (picked.id == current) return;
    await ref.read(connectionProvider.notifier).connect(picked);
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    super.key,
    required this.session,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  final AgentSessionSummary session;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: AriaRadius.mdAll,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: ariaMinTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AriaSpacing.sm,
            vertical: AriaSpacing.xs,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  session.hasTitle ? session.title : l10n.untitled,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: type.ui.copyWith(
                    color: active
                        ? colors.primary
                        : (enabled ? colors.text : colors.textMuted),
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (!enabled)
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: colors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final tint = color ?? colors.textMuted;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: ariaMinTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AriaSpacing.md,
            vertical: AriaSpacing.xs,
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 18, color: tint),
              const SizedBox(width: AriaSpacing.sm),
              Text(
                label,
                style: context.ariaType.ui.copyWith(
                  color: color ?? colors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
