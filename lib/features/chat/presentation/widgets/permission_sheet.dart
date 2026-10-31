import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/aria_colors.dart';
import '../../../../core/theme/aria_tokens.dart';
import '../../../../core/theme/aria_type.dart';
import '../../../../core/widgets/aria_sheet.dart';
import '../../../../domain/decision/decision.dart';
import '../../../../l10n/app_localizations.dart';

/// Asks for permission and cannot be dismissed.
///
/// While this is open the agent is blocked on the answer, so there is no tap
/// outside, no close button and no system back: the only ways out are the
/// options the agent offered and an explicit cancel.
Future<void> showPermission(
  BuildContext context,
  Decision decision, {
  required ValueChanged<DecisionOption?> onAnswer,
  required int queued,
}) {
  void answer(DecisionOption? option) {
    Navigator.of(context, rootNavigator: true).pop();
    onAnswer(option);
  }

  return showAriaSheet<void>(
    context: context,
    dismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: _PermissionSheet(
        decision: decision,
        queued: queued,
        onAnswer: answer,
      ),
    ),
  );
}

class _PermissionSheet extends StatelessWidget {
  const _PermissionSheet({
    required this.decision,
    required this.queued,
    required this.onAnswer,
  });

  final Decision decision;
  final int queued;
  final ValueChanged<DecisionOption?> onAnswer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final primary = decision.primaryOption;

    return AriaSheet(
      title: decision.prompt,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (decision.detail != null &&
              decision.detail!.trim().isNotEmpty) ...<Widget>[
            Text(
              l10n.command,
              style: context.ariaType.caption.copyWith(
                color: colors.muted,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: AriaSpacing.xs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
              decoration: BoxDecoration(
                color: colors.panelDeep,
                borderRadius: AriaRadius.mdAll,
              ),
              child: SelectableText(
                decision.detail!,
                style: context.ariaType.code.copyWith(color: colors.ink),
              ),
            ),
            const SizedBox(height: AriaSpacing.md),
          ],
          if (decision.highImpact) ...<Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              decoration: BoxDecoration(
                color: colors.goldSoft,
                borderRadius: AriaRadius.mdAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.shield_outlined, size: 15, color: colors.gold),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      l10n.riskNote,
                      style: context.ariaType.caption.copyWith(
                        color: colors.gold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AriaSpacing.md),
          ],
          if (queued > 0) ...<Widget>[
            Text(
              l10n.moreWaiting(queued),
              style: context.ariaType.caption.copyWith(color: colors.muted),
            ),
            const SizedBox(height: AriaSpacing.sm),
          ],
          for (final option in decision.options) ...<Widget>[
            _OptionTile(
              option: option,
              primary: option == primary,
              onTap: () => onAnswer(option),
            ),
            const SizedBox(height: AriaSpacing.xs),
          ],
        ],
      ),
      foot: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => onAnswer(null),
          child: Text(l10n.cancelThis),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.primary,
    required this.onTap,
  });

  final DecisionOption option;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;
    final description = _description(l10n, option.kind);
    final foreground = primary ? colors.keyInk : colors.ink;
    final secondary = primary ? colors.keyMuted : colors.muted;

    return Material(
      color: primary ? colors.key : colors.panel,
      borderRadius: AriaRadius.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AriaRadius.lgAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  option.label,
                  style: type.label.copyWith(color: foreground),
                ),
                if (description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: type.caption.copyWith(color: secondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _description(AppLocalizations l10n, DecisionOptionKind kind) =>
      switch (kind) {
        DecisionOptionKind.allowOnce => l10n.optionAllowOnce,
        DecisionOptionKind.allowAlways => l10n.optionAllowAlways,
        DecisionOptionKind.rejectOnce => l10n.optionRejectOnce,
        DecisionOptionKind.rejectAlways => l10n.optionRejectAlways,
        DecisionOptionKind.other => '',
      };
}
