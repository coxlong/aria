import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../error/app_error.dart';
import '../error/error_text.dart';
import '../theme/aria_colors.dart';
import '../theme/aria_tokens.dart';
import '../theme/aria_type.dart';

/// One sentence, one action, and the technical detail behind a tap.
///
/// A failure is a line, not a card: the design keeps the conversation free of
/// status blocks unless the person asks for the detail.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(
                Icons.error_outline_rounded,
                size: 14,
                color: colors.danger,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                describeError(l10n, widget.error),
                style: type.caption.copyWith(color: colors.danger),
              ),
            ),
            if (widget.onRetry != null)
              TextButton(
                onPressed: widget.onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: colors.danger,
                  textStyle: type.caption.copyWith(fontWeight: FontWeight.w600),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(44, 32),
                ),
                child: Text(l10n.retry),
              ),
            TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              style: TextButton.styleFrom(
                foregroundColor: colors.muted,
                textStyle: type.caption,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(44, 32),
              ),
              child: Text(l10n.details),
            ),
          ],
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 4),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: colors.panelDeep,
                borderRadius: AriaRadius.smAll,
              ),
              child: SelectableText(
                widget.error.technicalDetail,
                style: type.code.copyWith(color: colors.ink2),
              ),
            ),
          ),
      ],
    );
  }
}
