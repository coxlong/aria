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
  String get languageChinese => '中文';

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
  String get connectSubtitle => 'Pick an agent to connect to.';

  @override
  String get connect => 'Connect';

  @override
  String get connecting => 'Connecting…';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get connectFirstAgent => 'Add an agent first';

  @override
  String get connectFirstAgentBody => 'Add an endpoint, then Aria can start.';

  @override
  String get connectAria => 'Connect Aria';

  @override
  String get connectingAria => 'Connecting Aria';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get changeAgent => 'Change';

  @override
  String get chooseAgent => 'Choose an agent';

  @override
  String get reconnectingShort => 'Reconnecting';

  @override
  String get manageExecutors => 'Manage agents';

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
  String get processThinking => 'Thinking';

  @override
  String get processAnswering => 'Writing the reply';

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

  @override
  String get heroQuestion => 'What can Aria do for you?';

  @override
  String get homeComposeHint => 'Describe a task to start';

  @override
  String get startConversation => 'Start a conversation';

  @override
  String get recentConversations => 'Recent';

  @override
  String takesThis(String name) {
    return '$name takes this';
  }

  @override
  String get noConversations =>
      'No conversations yet. Start with one specific task.';

  @override
  String get searchConversations => 'Search conversations';

  @override
  String get findConversation => 'Search';

  @override
  String get searchKicker => 'SEARCH';

  @override
  String get searchHint => 'Type a keyword';

  @override
  String noSearchResults(String query) {
    return 'No match for “$query”. Try another word.';
  }

  @override
  String get conversations => 'Conversations';

  @override
  String get youPrefix => 'You: ';

  @override
  String get newConversation => 'New conversation';

  @override
  String get now => 'now';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hr ago';
  }

  @override
  String get settingsKicker => 'ARIA';

  @override
  String get theme => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get agents => 'Agents';

  @override
  String get agent => 'Agent';

  @override
  String get addAgent => 'Add an agent';

  @override
  String get agentName => 'Name';

  @override
  String get agentNameHint => 'e.g. Translate';

  @override
  String get agentNameTaken => 'That name is taken';

  @override
  String get tokenOptionalHint => 'Leave blank if none';

  @override
  String get agentDesc => 'What it handles';

  @override
  String get agentDescHint => 'One line is enough';

  @override
  String get agentDefault => 'Default';

  @override
  String get makeDefault => 'Make default';

  @override
  String get connectThisAgent => 'Connect this agent';

  @override
  String defaultSet(String name) {
    return '$name is now the default';
  }

  @override
  String get defaultCannotDelete =>
      'The default cannot be deleted. Set another as default first.';

  @override
  String get disconnectToDelete => 'Disconnect before deleting this agent.';

  @override
  String get add => 'Add';

  @override
  String agentAdded(String name) {
    return '$name added';
  }

  @override
  String agentDeleted(String name) {
    return '$name deleted';
  }

  @override
  String get agentSaved => 'Configuration saved';

  @override
  String get agentLocked =>
      'The address, token and directory are locked while connected. Disconnect to change them.';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get disconnectedKept => 'Disconnected · conversations kept';

  @override
  String disconnectConfirm(String name) {
    return 'Disconnect from $name?';
  }

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get backToSettings => 'Settings';

  @override
  String get connectTitle => 'Connect an agent';

  @override
  String get noAgents => 'No agents yet.';

  @override
  String get currentAgent => 'Current agent';

  @override
  String get workingNote => 'Working…';

  @override
  String liveStep(String name) {
    return 'Running $name…';
  }

  @override
  String get thinkingNow => 'Thinking…';

  @override
  String get replyingNow => 'Replying…';

  @override
  String get needsApproval => 'Needs approval';

  @override
  String needsApprovalWith(String prompt) {
    return 'Needs approval: $prompt';
  }

  @override
  String get waitingForYou => 'Waiting for you';

  @override
  String get stoppedNotice => 'Stopped · what was produced is kept.';

  @override
  String get jumpLatest => 'Latest';

  @override
  String get composerPlaceholder => 'Add more detail…';

  @override
  String get composerLabel => 'Message Aria';

  @override
  String get stopToast => 'Stopped';

  @override
  String get turnRunningToast => 'This turn is still running. Stop it or wait.';

  @override
  String get workLog => 'Work log';

  @override
  String get thought => 'Thought';

  @override
  String get statusDone => 'Done';

  @override
  String get statusRunning => 'Running';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusStopped => 'Stopped';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String toolsUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tools',
      one: '1 tool',
    );
    return '$_temp0';
  }

  @override
  String thoughtsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thoughts',
      one: '1 thought',
    );
    return '$_temp0';
  }

  @override
  String thoughtsCountSuffix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thoughts',
      one: '1 thought',
    );
    return ', $_temp0';
  }

  @override
  String failedCountSuffix(int count) {
    return ' · $count failed';
  }

  @override
  String get failedSuffix => ' · Failed';

  @override
  String stepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String andMoreSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return ' · $_temp0';
  }

  @override
  String get andMore => '…';

  @override
  String get listSeparator => ', ';

  @override
  String get stepError => 'Error';

  @override
  String get backToWorkLog => 'Back to work log';

  @override
  String get workLogGone => 'This work log is gone';

  @override
  String get stepGone => 'This step is gone';

  @override
  String get thoughtGone => 'This thought is gone';

  @override
  String get modelEffortMode => 'Model and execution';

  @override
  String get thisTurn => 'THIS TURN';

  @override
  String get reasoningEffort => 'Reasoning effort';

  @override
  String get appliesNextTurn => 'Applies to the next turn.';

  @override
  String get noModels => 'This endpoint offers no model choice.';

  @override
  String get noEfforts => 'This endpoint offers no effort setting.';

  @override
  String get noModes => 'This endpoint offers no modes.';

  @override
  String modelChipLabel(String model, String effort, String mode) {
    return 'Model $model, reasoning effort $effort, mode $mode';
  }

  @override
  String get approvalKicker => 'APPROVAL';

  @override
  String get command => 'Command';

  @override
  String get approvalDetail => 'Details';

  @override
  String get riskNote =>
      'This touches outside the workspace and cannot be undone.';

  @override
  String get cancelThis => 'Cancel this';

  @override
  String get optionAllowOnce => 'This run only';

  @override
  String get optionAllowAlways => 'Stop asking for this kind';

  @override
  String get optionRejectOnce => 'Do not run this time';

  @override
  String get optionRejectAlways => 'Refuse this kind from now on';

  @override
  String get requestClosed => 'This request is closed';

  @override
  String get connectionLost =>
      'Connection lost · reconnecting; queued work replays automatically.';

  @override
  String get connectionOffline => 'Offline';

  @override
  String get notConnected => 'Not connected';

  @override
  String get onWatch => 'On watch';

  @override
  String get connectToStart => 'Connect an agent to start.';

  @override
  String get edit => 'Edit';

  @override
  String deleteAgentConfirm(String name) {
    return 'Delete “$name”? This cannot be undone.';
  }

  @override
  String get relink => 'Reconnect';

  @override
  String get sessionRefreshing => 'Refreshing…';
}
