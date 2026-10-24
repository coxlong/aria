import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/aria_colors.dart';
import '../../../core/theme/aria_tokens.dart';
import '../../../core/theme/aria_type.dart';
import '../../../domain/profile/server_profile.dart';
import '../../../l10n/app_localizations.dart';
import '../application/settings_controller.dart';

/// Configuration lives here, never in the conversation.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.back,
          // There is no route at `/`; the guard turns `/connect` into `/chat`
          // when a session is open, so this works from a cold deep link too.
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/connect'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.settings),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AriaSpacing.lg,
              vertical: AriaSpacing.md,
            ),
            children: <Widget>[
              _SectionTitle(l10n.executorProfiles),
              if (settings.profiles.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AriaSpacing.sm),
                  child: Text(
                    l10n.noExecutorsBody,
                    style: context.ariaType.ui.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                )
              else
                for (final profile in settings.profiles)
                  _ProfileRow(
                    key: ValueKey<String>(profile.id),
                    profile: profile,
                    onTap: () => context.push('/settings/server/${profile.id}'),
                    onDelete: () =>
                        unawaited(_confirmDelete(context, ref, profile)),
                  ),
              const SizedBox(height: AriaSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.push('/settings/server/new'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.addExecutor),
                ),
              ),
              const SizedBox(height: AriaSpacing.lg),
              _SectionTitle(l10n.language),
              _LanguageRow(
                label: l10n.languageSystem,
                value: 'system',
                selected: settings.locale,
              ),
              _LanguageRow(
                label: l10n.languageEnglish,
                value: 'en',
                selected: settings.locale,
              ),
              _LanguageRow(
                label: l10n.languageChinese,
                value: 'zh',
                selected: settings.locale,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ServerProfile profile,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deleteExecutorConfirm(profile.displayName)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(settingsProvider.notifier).deleteProfile(profile.id);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AriaSpacing.xs),
      child: Text(
        label,
        style: context.ariaType.caption.copyWith(
          color: context.ariaColors.textMuted,
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    super.key,
    required this.profile,
    required this.onTap,
    required this.onDelete,
  });

  final ServerProfile profile;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;

    return Container(
      margin: const EdgeInsets.only(bottom: AriaSpacing.xxs),
      decoration: BoxDecoration(
        borderRadius: AriaRadius.mdAll,
        border: Border.all(color: colors.border),
      ),
      child: InkWell(
        onTap: onTap,
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
                Icon(Icons.dns_outlined, size: 18, color: colors.textMuted),
                const SizedBox(width: AriaSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        profile.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: type.ui.copyWith(color: colors.text),
                      ),
                      Text(
                        profile.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: type.caption.copyWith(color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.deleteExecutor,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageRow extends ConsumerWidget {
  const _LanguageRow({
    required this.label,
    required this.value,
    required this.selected,
  });

  final String label;
  final String value;
  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.ariaColors;
    final isSelected = selected == value;
    return InkWell(
      onTap: () =>
          unawaited(ref.read(settingsProvider.notifier).setLocale(value)),
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
                  label,
                  style: context.ariaType.ui.copyWith(color: colors.text),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_rounded, size: 18, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
