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
  String get connectTitle => 'Connect to an agent';

  @override
  String get connectSubtitle =>
      'Your duet with AI starts with a working connection.';

  @override
  String get connect => 'Connect';

  @override
  String get addServer => 'Add server';

  @override
  String get editServer => 'Edit server';

  @override
  String get deleteServer => 'Delete server';

  @override
  String deleteServerConfirm(String name) {
    return 'Delete “$name”? This cannot be undone.';
  }

  @override
  String get serverName => 'Name';

  @override
  String get serverUrl => 'Agent URL';

  @override
  String get serverToken => 'Access token (optional)';

  @override
  String get serverCwd => 'Working directory';

  @override
  String get serverCwdHint => '/absolute/path/on/agent/host';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get noServersTitle => 'No agents yet';

  @override
  String get noServersBody => 'Add an ACP server to start a session.';

  @override
  String get newChat => 'New chat';

  @override
  String get recentSessions => 'Recent';

  @override
  String get noSessions => 'No sessions yet';

  @override
  String get currentConnection => 'Current connection';

  @override
  String get switchServer => 'Switch server';

  @override
  String get composerHint => 'Message the agent…';

  @override
  String get send => 'Send';

  @override
  String get stop => 'Stop';

  @override
  String processRunning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'step $count',
      one: 'step 1',
      zero: 'starting',
    );
    return 'Running · $_temp0';
  }

  @override
  String processCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return 'Completed · $_temp0';
  }

  @override
  String get thinking => 'Thinking';

  @override
  String get stepDetails => 'Step details';

  @override
  String get permissionTitle => 'Approve tool call';

  @override
  String get permissionHint => 'The agent is waiting for your decision.';

  @override
  String get allowOnce => 'Allow once';

  @override
  String get allowAlways => 'Always allow';

  @override
  String get rejectOnce => 'Reject';

  @override
  String get rejectAlways => 'Always reject';

  @override
  String get permissionCancel => 'Cancel';

  @override
  String get model => 'Model';

  @override
  String get mode => 'Mode';

  @override
  String get effort => 'Reasoning effort';

  @override
  String get errorNetwork =>
      'Cannot reach the agent. Check the URL, network and bridge.';

  @override
  String get errorAuth =>
      'The agent rejected the token. Check the access token.';

  @override
  String get errorProtocol => 'The connection is not speaking ACP v1.';

  @override
  String get errorTimeout => 'The agent did not respond in time.';

  @override
  String get errorSessionLost =>
      'The session is no longer available on the agent.';

  @override
  String errorAgent(int code) {
    return 'The agent returned an error ($code).';
  }

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get reconnecting => 'Reconnecting…';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get emptyChatBody => 'Send a message to start the duet.';

  @override
  String get sessionUntitled => 'Untitled session';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get settings => 'Settings';

  @override
  String get requiredField => 'Required';

  @override
  String get serverUrlInvalid => 'Enter a ws:// or wss:// URL.';

  @override
  String get refresh => 'Refresh';

  @override
  String get status => 'Status';

  @override
  String get toolInput => 'Input';

  @override
  String get toolOutput => 'Output';

  @override
  String get deleteSession => 'Delete conversation';
}
