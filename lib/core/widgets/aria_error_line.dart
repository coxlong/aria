import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../error/app_error.dart';
import '../error/error_text.dart';
import '../theme/aria_colors.dart';
import '../theme/aria_tokens.dart';
import '../theme/aria_type.dart';

/// One sentence, one action, and the technical detail behind a tap.
class AriaErrorLine extends StatefulWidget {
  const AriaErrorLine({super.key, required this.error, this.onRetry});

  final AppError error;
  final VoidCallback? onRetry;

  @override
  State<AriaErrorLine> createState() => _AriaErrorLineState();
}

class _AriaErrorLineState extends State<AriaErrorLine> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;

    return Container(
      decoration: BoxDecoration(
        color: colors.errorSoft,
        borderRadius: AriaRadius.mdAll,
      ),
      padding: const EdgeInsets.all(AriaSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            describeError(l10n, widget.error),
            style: type.ui.copyWith(color: colors.error),
          ),
          const SizedBox(height: AriaSpacing.xxs),
          Row(
            children: <Widget>[
              _QuietAction(
                label: l10n.details,
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
              if (widget.onRetry != null)
                _QuietAction(label: l10n.retry, onPressed: widget.onRetry),
            ],
          ),
          if (_expanded) ...<Widget>[
            const SizedBox(height: AriaSpacing.xs),
            SelectableText(
              widget.error.technicalDetail,
              style: type.code.copyWith(color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuietAction extends StatelessWidget {
  const _QuietAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colors.error,
        minimumSize: const Size(ariaMinTarget, ariaMinTarget),
        padding: const EdgeInsets.symmetric(horizontal: AriaSpacing.xs),
        textStyle: context.ariaType.label,
      ),
      child: Text(label),
    );
  }
}
