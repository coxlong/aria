import '../l10n/app_localizations.dart';
import 'error_mapping.dart';

/// Localized, actionable text for a mapped error.
///
/// The technical message stays out of the main UI; screens may show it behind
/// a "technical details" disclosure.
String localizeError(AppLocalizations l10n, AriaError error) {
  return switch (error.kind) {
    AriaErrorKind.network => l10n.errorNetwork,
    AriaErrorKind.auth => l10n.errorAuth,
    AriaErrorKind.protocol => l10n.errorProtocol,
    AriaErrorKind.timeout => l10n.errorTimeout,
    AriaErrorKind.sessionLost => l10n.errorSessionLost,
    AriaErrorKind.agent =>
      error.code == null ? l10n.errorGeneric : l10n.errorAgent(error.code!),
    AriaErrorKind.unknown => l10n.errorGeneric,
  };
}
