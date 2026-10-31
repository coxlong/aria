import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/aria_colors.dart';
import '../theme/aria_tokens.dart';
import '../theme/aria_type.dart';

/// The narrow strip that appears while the transport reconnects.
///
/// It never blocks the composer: a turn can still be stopped, and the draft is
/// kept until the connection returns.
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AriaSpacing.page,
        0,
        AriaSpacing.page,
        AriaSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: colors.goldSoft,
          borderRadius: AriaRadius.lgAll,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.gold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context).connectionLost,
                style: context.ariaType.caption.copyWith(color: colors.ink2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
