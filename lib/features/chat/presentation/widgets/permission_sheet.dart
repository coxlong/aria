import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/aria_colors.dart';
import '../../../../core/theme/aria_tokens.dart';
import '../../../../core/theme/aria_type.dart';
import '../../../../domain/decision/decision.dart';
import '../../../../l10n/app_localizations.dart';

/// Asks for permission and cannot be dismissed.
///
/// While this is open the agent is blocked on the answer, so there is no tap
/// outside, no close button, no drag-to-dismiss, and no system back: the only
/// ways out are the options the agent offered and an explicit cancel. Wide
/// screens get a dialog, compact ones a sheet, but the content and the rules
/// are identical.
///
/// `barrierDismissible` and `enableDrag` only cover taps and drags. The back
/// gesture pops the route through `Navigator.maybePop`, which is why each
/// branch is wrapped in [PopScope] — without it Android's back button silently
/// removed the sheet and left the agent waiting forever.
Future<void> showPermission(
  BuildContext context,
  Decision decision, {
  required ValueChanged<DecisionOption?> onAnswer,
  required int queued,
}) {
  final compact = MediaQuery.sizeOf(context).width <= 600;

  void answer(DecisionOption? option) {
    Navigator.of(context, rootNavigator: true).pop();
    onAnswer(option);
  }

  if (compact) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      showDragHandle: true,
      builder: (context) => PopScope(
        canPop: false,
        child: _PermissionBody(
          decision: decision,
          queued: queued,
          onAnswer: answer,
        ),
      ),
    );
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0x80000000),
    builder: (context) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _PermissionBody(
            decision: decision,
            queued: queued,
            onAnswer: answer,
            dialog: true,
          ),
        ),
      ),
    ),
  );
}

class _PermissionBody extends StatelessWidget {
  const _PermissionBody({
    required this.decision,
    required this.queued,
    required this.onAnswer,
    this.dialog = false,
  });

  final Decision decision;
  final int queued;
  final ValueChanged<DecisionOption?> onAnswer;
  final bool dialog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;
    final highImpact = decision.highImpact;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(decision.prompt, style: type.title.copyWith(color: colors.text)),
        if (decision.detail != null) ...<Widget>[
          const SizedBox(height: AriaSpacing.xxs),
          Text(
            decision.detail!,
            style: type.ui.copyWith(color: colors.textSecondary),
          ),
        ],
        if (queued > 0) ...<Widget>[
          const SizedBox(height: AriaSpacing.xxs),
          Text(
            l10n.moreWaiting(queued),
            style: type.caption.copyWith(color: colors.textMuted),
          ),
        ],
        const SizedBox(height: AriaSpacing.md),
        for (final option in decision.options) ...<Widget>[
          if (option.kind == DecisionOptionKind.allowOnce)
            FilledButton(
              onPressed: () => onAnswer(option),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              child: Text(option.label),
            )
          else
            OutlinedButton(
              onPressed: () => onAnswer(option),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              child: Text(option.label),
            ),
          const SizedBox(height: AriaSpacing.xs),
        ],
        TextButton(
          onPressed: () => onAnswer(null),
          style: TextButton.styleFrom(
            foregroundColor: colors.textMuted,
            minimumSize: const Size.fromHeight(44),
          ),
          child: Text(l10n.cancel),
        ),
      ],
    );

    if (!dialog) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AriaSpacing.lg,
            0,
            AriaSpacing.lg,
            AriaSpacing.lg,
          ),
          child: content,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AriaSpacing.lg),
      decoration: BoxDecoration(
        color: highImpact ? colors.attentionSoft : colors.surface,
        borderRadius: AriaRadius.xlAll,
        border: Border.all(color: colors.border),
      ),
      child: content,
    );
  }
}
