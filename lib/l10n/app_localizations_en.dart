// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Aria';

  @override
  String get composerHint => 'What should Aria do?';

  @override
  String get send => 'Send';

  @override
  String get stop => 'Stop';

  @override
  String get untitled => 'Untitled';

  @override
  String get back => 'Back';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String secondsShort(int count) {
    return '$count sec';
  }

  @override
  String get details => 'Details';

  @override
  String get stepInput => 'Input';

  @override
  String get stepOutput => 'Output';

  @override
  String moreWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more decisions are waiting',
      one: '1 more decision is waiting',
    );
    return '$_temp0';
  }

  @override
  String get toolCall => 'Tool call';

  @override
  String get reconnecting =>
      'Reconnecting. Your draft is kept and Stop still works.';

  @override
  String get settings => 'Settings';

  @override
  String get executorProfiles => 'Executors';

  @override
  String get addExecutor => 'Add executor';

  @override
  String get editExecutor => 'Edit executor';

  @override
  String get deleteExecutor => 'Delete executor';

  @override
  String deleteExecutorConfirm(String name) {
    return 'Delete “$name”? This cannot be undone.';
  }

  @override
  String get executorName => 'Name';

  @override
  String get executorUrl => 'Agent URL';

  @override
  String get executorToken => 'Access token (optional)';

  @override
  String get tokenUnchanged => 'Leave blank to keep the saved token.';

  @override
  String get executorCwd => 'Working directory';

  @override
  String get executorCwdHint => '/absolute/path/on/agent/host';

  @override
  String get executorUrlInvalid => 'Enter a ws:// or wss:// URL.';

  @override
  String get requiredField => 'Required';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get noExecutors => 'No executor yet';

  @override
  String get noExecutorsBody => 'Add an ACP endpoint to start.';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get errorNetwork =>
      'Cannot reach the agent. Check the URL and the connection.';

  @override
  String get errorAuth => 'The agent rejected the token.';

  @override
  String get errorProtocol => 'This endpoint is not speaking ACP v1.';

  @override
  String errorRemote(int code) {
    return 'The agent returned an error ($code).';
  }

  @override
  String get errorStorage =>
      'Aria could not save locally. Your work is still on screen.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get errorAgentStopped =>
      'The agent stopped before finishing. Try again.';

  @override
  String get errorRefused =>
      'The agent declined to continue. Rephrase the request or change the approach.';

  @override
  String get errorTruncated =>
      'The answer hit the model\'s token limit and was cut off.';

  @override
  String get retry => 'Retry';

  @override
  String get connectSubtitle => 'Pick an executor to connect to.';

  @override
  String get connect => 'Connect';

  @override
  String get connecting => 'Connecting…';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get reconnectingShort => 'Reconnecting';

  @override
  String get manageExecutors => 'Manage executors';

  @override
  String get newChat => 'New chat';

  @override
  String get sessions => 'Recent';

  @override
  String get noSessions => 'No sessions yet.';

  @override
  String get switchConnection => 'Switch connection';

  @override
  String get signOut => 'Sign out';

  @override
  String get refresh => 'Refresh';

  @override
  String get model => 'Model';

  @override
  String get mode => 'Mode';

  @override
  String get effort => 'Effort';

  @override
  String get processTitle => 'Work';

  @override
  String get processEmpty => 'Nothing was run.';

  @override
  String get thinkingProcess => 'Thinking';

  @override
  String processRunning(int index) {
    return 'Running · step $index';
  }

  @override
  String processDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }
}
