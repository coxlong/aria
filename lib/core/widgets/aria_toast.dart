import 'package:material_ui/material_ui.dart';

import '../theme/aria_tokens.dart';

/// The messenger the app's one-line confirmations appear on.
///
/// Sheets and routes come and go, so the messenger is owned by the app rather
/// than by whichever page happened to trigger the message.
final GlobalKey<ScaffoldMessengerState> ariaMessenger =
    GlobalKey<ScaffoldMessengerState>();

/// A quiet confirmation: one line, above the composer, gone in a moment.
void showAriaToast(String text) {
  final messenger = ariaMessenger.currentState;
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 2200),
        margin: const EdgeInsets.fromLTRB(
          AriaSpacing.page,
          0,
          AriaSpacing.page,
          AriaSpacing.md,
        ),
      ),
    );
}
