import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/aria_colors.dart';
import '../../../core/theme/aria_tokens.dart';
import '../../../core/theme/aria_type.dart';
import '../../../core/widgets/aria_error_line.dart';
import '../../../domain/profile/server_profile.dart';
import '../../../l10n/app_localizations.dart';
import '../../connection/application/connection_controller.dart';
import '../../settings/application/settings_controller.dart';

/// The first screen, and the only way into a session.
///
/// Nothing connects implicitly: the person picks a saved executor, and only a
/// successful connection produces a session. If it fails, they stay here with
/// the error and a retry, rather than landing in an empty workspace.
class ConnectPage extends ConsumerStatefulWidget {
  const ConnectPage({super.key});

  @override
  ConsumerState<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends ConsumerState<ConnectPage> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;

    final settings = ref.watch(settingsProvider);
    final connection = ref.watch(connectionProvider);
    final profiles = settings.profiles;

    final selectedId =
        _picked ??
        settings.activeProfileId ??
        (profiles.isEmpty ? null : profiles.first.id);
    final selected = profiles
        .where((profile) => profile.id == selectedId)
        .firstOrNull;

    final connecting = connection.status == ConnectionStatus.connecting;
    final failed = connection.status == ConnectionStatus.failed;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AriaSpacing.lg,
                vertical: AriaSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    l10n.appName,
                    style: type.display.copyWith(color: colors.text),
                  ),
                  const SizedBox(height: AriaSpacing.xs),
                  Text(
                    l10n.connectSubtitle,
                    style: type.ui.copyWith(color: colors.textMuted),
                  ),
                  const SizedBox(height: AriaSpacing.xl),
                  if (profiles.isEmpty)
                    _EmptyServers(
                      title: l10n.noExecutors,
                      body: l10n.noExecutorsBody,
                      action: l10n.addExecutor,
                      onPressed: () => context.push('/settings/server/new'),
                    )
                  else
                    for (final profile in profiles)
                      _ServerRow(
                        key: ValueKey<String>(profile.id),
                        profile: profile,
                        selected: profile.id == selectedId,
                        connecting: connecting && profile.id == selectedId,
                        onTap: connecting
                            ? null
                            : () => setState(() => _picked = profile.id),
                      ),
                  if (failed && connection.error != null) ...<Widget>[
                    const SizedBox(height: AriaSpacing.md),
                    AriaErrorLine(
                      error: connection.error!,
                      onRetry: selected == null
                          ? null
                          : () => unawaited(
                              ref
                                  .read(connectionProvider.notifier)
                                  .connect(selected),
                            ),
                    ),
                  ],
                  const SizedBox(height: AriaSpacing.lg),
                  FilledButton(
                    onPressed: selected == null || connecting
                        ? null
                        : () => unawaited(
                            ref
                                .read(connectionProvider.notifier)
                                .connect(selected),
                          ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: connecting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onPrimary,
                                ),
                              ),
                              const SizedBox(width: AriaSpacing.xs),
                              Text(l10n.connecting),
                            ],
                          )
                        : Text(l10n.connect),
                  ),
                  const SizedBox(height: AriaSpacing.xs),
                  TextButton.icon(
                    onPressed: () => context.push('/settings'),
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    label: Text(l10n.manageExecutors),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.textMuted,
                      minimumSize: const Size.fromHeight(ariaMinTarget),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServerRow extends StatelessWidget {
  const _ServerRow({
    super.key,
    required this.profile,
    required this.selected,
    required this.connecting,
    required this.onTap,
  });

  final ServerProfile profile;
  final bool selected;
  final bool connecting;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;
    final hasName = profile.name.trim().isNotEmpty;
    final detail = hasName
        ? '${profile.url}  ·  ${profile.effectiveCwd}'
        : profile.effectiveCwd;

    return Padding(
      padding: const EdgeInsets.only(bottom: AriaSpacing.xs),
      child: Material(
        color: selected ? colors.selected : colors.surface,
        borderRadius: AriaRadius.lgAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AriaRadius.lgAll,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AriaRadius.lgAll,
              border: Border.all(
                color: selected ? colors.primary : colors.border,
              ),
            ),
            padding: const EdgeInsets.all(AriaSpacing.md),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.dns_outlined,
                  size: 20,
                  color: selected ? colors.primary : colors.textMuted,
                ),
                const SizedBox(width: AriaSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        hasName ? profile.name : profile.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: type.ui.copyWith(
                          color: colors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: type.code.copyWith(color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AriaSpacing.xs),
                if (connecting)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyServers extends StatelessWidget {
  const _EmptyServers({
    required this.title,
    required this.body,
    required this.action,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;

    return Container(
      padding: const EdgeInsets.all(AriaSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AriaRadius.lgAll,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: type.title.copyWith(color: colors.text)),
          const SizedBox(height: AriaSpacing.xxs),
          Text(body, style: type.ui.copyWith(color: colors.textMuted)),
          const SizedBox(height: AriaSpacing.md),
          TextButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(action),
          ),
        ],
      ),
    );
  }
}
