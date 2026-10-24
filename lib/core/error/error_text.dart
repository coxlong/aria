import '../../l10n/app_localizations.dart';
import 'app_error.dart';

/// One sentence the person can act on. Technical detail stays behind the
/// caller's "Details" disclosure.
String describeError(AppLocalizations l10n, AppError error) => switch (error) {
  NetworkUnavailable() => l10n.errorNetwork,
  AuthenticationFailed() => l10n.errorAuth,
  ProtocolMismatch() => l10n.errorProtocol,
  RemoteRejected(:final code) => l10n.errorRemote(code),
  ExecutionStopped(:final reason) => switch (reason) {
    'refusal' => l10n.errorRefused,
    'max_tokens' => l10n.errorTruncated,
    _ => l10n.errorAgentStopped,
  },
  StorageFailure() => l10n.errorStorage,
  UnknownFailure() => l10n.errorUnknown,
};
