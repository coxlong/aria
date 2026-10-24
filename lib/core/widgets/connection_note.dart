import 'package:material_ui/material_ui.dart';

import '../theme/aria_colors.dart';
import '../theme/aria_tokens.dart';
import '../theme/aria_type.dart';

/// A single quiet line under the app bar. It never blocks input and never
/// reads as a failed turn.
class ConnectionNote extends StatelessWidget {
  const ConnectionNote({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return Container(
      width: double.infinity,
      color: colors.inset,
      padding: const EdgeInsets.symmetric(
        horizontal: AriaSpacing.md,
        vertical: AriaSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.warning,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AriaSpacing.xs),
          Flexible(
            child: Text(
              message,
              style: context.ariaType.ui.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
