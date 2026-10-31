import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Aria'**
  String get appName;

  /// No description provided for @composerHint.
  ///
  /// In en, this message translates to:
  /// **'What should Aria do?'**
  String get composerHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} sec'**
  String secondsShort(int count);

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @stepInput.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get stepInput;

  /// No description provided for @stepOutput.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get stepOutput;

  /// No description provided for @moreWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more decision is waiting} other{{count} more decisions are waiting}}'**
  String moreWaiting(int count);

  /// No description provided for @toolCall.
  ///
  /// In en, this message translates to:
  /// **'Tool call'**
  String get toolCall;

  /// No description provided for @reconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting. Your draft is kept and Stop still works.'**
  String get reconnecting;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @executorProfiles.
  ///
  /// In en, this message translates to:
  /// **'Executors'**
  String get executorProfiles;

  /// No description provided for @addExecutor.
  ///
  /// In en, this message translates to:
  /// **'Add executor'**
  String get addExecutor;

  /// No description provided for @editExecutor.
  ///
  /// In en, this message translates to:
  /// **'Edit executor'**
  String get editExecutor;

  /// No description provided for @deleteExecutor.
  ///
  /// In en, this message translates to:
  /// **'Delete executor'**
  String get deleteExecutor;

  /// No description provided for @deleteExecutorConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? This cannot be undone.'**
  String deleteExecutorConfirm(String name);

  /// No description provided for @executorName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get executorName;

  /// No description provided for @executorUrl.
  ///
  /// In en, this message translates to:
  /// **'Agent URL'**
  String get executorUrl;

  /// No description provided for @executorToken.
  ///
  /// In en, this message translates to:
  /// **'Access token (optional)'**
  String get executorToken;

  /// No description provided for @tokenUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep the saved token.'**
  String get tokenUnchanged;

  /// No description provided for @executorCwd.
  ///
  /// In en, this message translates to:
  /// **'Working directory'**
  String get executorCwd;

  /// No description provided for @executorCwdHint.
  ///
  /// In en, this message translates to:
  /// **'/absolute/path/on/agent/host'**
  String get executorCwdHint;

  /// No description provided for @executorUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a ws:// or wss:// URL.'**
  String get executorUrlInvalid;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noExecutors.
  ///
  /// In en, this message translates to:
  /// **'No executor yet'**
  String get noExecutors;

  /// No description provided for @noExecutorsBody.
  ///
  /// In en, this message translates to:
  /// **'Add an ACP endpoint to start.'**
  String get noExecutorsBody;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the agent. Check the URL and the connection.'**
  String get errorNetwork;

  /// No description provided for @errorAuth.
  ///
  /// In en, this message translates to:
  /// **'The agent rejected the token.'**
  String get errorAuth;

  /// No description provided for @errorProtocol.
  ///
  /// In en, this message translates to:
  /// **'This endpoint is not speaking ACP v1.'**
  String get errorProtocol;

  /// No description provided for @errorRemote.
  ///
  /// In en, this message translates to:
  /// **'The agent returned an error ({code}).'**
  String errorRemote(int code);

  /// No description provided for @errorStorage.
  ///
  /// In en, this message translates to:
  /// **'Aria could not save locally. Your work is still on screen.'**
  String get errorStorage;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnknown;

  /// No description provided for @errorAgentStopped.
  ///
  /// In en, this message translates to:
  /// **'The agent stopped before finishing. Try again.'**
  String get errorAgentStopped;

  /// No description provided for @errorRefused.
  ///
  /// In en, this message translates to:
  /// **'The agent declined to continue. Rephrase the request or change the approach.'**
  String get errorRefused;

  /// No description provided for @errorTruncated.
  ///
  /// In en, this message translates to:
  /// **'The answer hit the model\'s token limit and was cut off.'**
  String get errorTruncated;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @connectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick an agent to connect to.'**
  String get connectSubtitle;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @connectFirstAgent.
  ///
  /// In en, this message translates to:
  /// **'Add an agent first'**
  String get connectFirstAgent;

  /// No description provided for @connectFirstAgentBody.
  ///
  /// In en, this message translates to:
  /// **'Add an endpoint, then Aria can start.'**
  String get connectFirstAgentBody;

  /// No description provided for @connectAria.
  ///
  /// In en, this message translates to:
  /// **'Connect Aria'**
  String get connectAria;

  /// No description provided for @connectingAria.
  ///
  /// In en, this message translates to:
  /// **'Connecting Aria'**
  String get connectingAria;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get connectionFailed;

  /// No description provided for @changeAgent.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeAgent;

  /// No description provided for @chooseAgent.
  ///
  /// In en, this message translates to:
  /// **'Choose an agent'**
  String get chooseAgent;

  /// No description provided for @reconnectingShort.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting'**
  String get reconnectingShort;

  /// No description provided for @manageExecutors.
  ///
  /// In en, this message translates to:
  /// **'Manage agents'**
  String get manageExecutors;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get sessions;

  /// No description provided for @noSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet.'**
  String get noSessions;

  /// No description provided for @switchConnection.
  ///
  /// In en, this message translates to:
  /// **'Switch connection'**
  String get switchConnection;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @effort.
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get effort;

  /// No description provided for @processTitle.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get processTitle;

  /// No description provided for @processEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing was run.'**
  String get processEmpty;

  /// No description provided for @thinkingProcess.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinkingProcess;

  /// No description provided for @processThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get processThinking;

  /// No description provided for @processAnswering.
  ///
  /// In en, this message translates to:
  /// **'Writing the reply'**
  String get processAnswering;

  /// No description provided for @processDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String processDone(int count);

  /// No description provided for @heroQuestion.
  ///
  /// In en, this message translates to:
  /// **'What can Aria do for you?'**
  String get heroQuestion;

  /// No description provided for @homeComposeHint.
  ///
  /// In en, this message translates to:
  /// **'Describe a task to start'**
  String get homeComposeHint;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get startConversation;

  /// No description provided for @recentConversations.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentConversations;

  /// No description provided for @takesThis.
  ///
  /// In en, this message translates to:
  /// **'{name} takes this'**
  String takesThis(String name);

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet. Start with one specific task.'**
  String get noConversations;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations'**
  String get searchConversations;

  /// No description provided for @findConversation.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get findConversation;

  /// No description provided for @searchKicker.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get searchKicker;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Type a keyword'**
  String get searchHint;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No match for “{query}”. Try another word.'**
  String noSearchResults(String query);

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @youPrefix.
  ///
  /// In en, this message translates to:
  /// **'You: '**
  String get youPrefix;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get newConversation;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hr ago'**
  String hoursAgo(int count);

  /// No description provided for @settingsKicker.
  ///
  /// In en, this message translates to:
  /// **'ARIA'**
  String get settingsKicker;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @agents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get agents;

  /// No description provided for @agent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get agent;

  /// No description provided for @addAgent.
  ///
  /// In en, this message translates to:
  /// **'Add an agent'**
  String get addAgent;

  /// No description provided for @agentName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get agentName;

  /// No description provided for @agentNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Translate'**
  String get agentNameHint;

  /// No description provided for @agentNameTaken.
  ///
  /// In en, this message translates to:
  /// **'That name is taken'**
  String get agentNameTaken;

  /// No description provided for @tokenOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank if none'**
  String get tokenOptionalHint;

  /// No description provided for @agentDesc.
  ///
  /// In en, this message translates to:
  /// **'What it handles'**
  String get agentDesc;

  /// No description provided for @agentDescHint.
  ///
  /// In en, this message translates to:
  /// **'One line is enough'**
  String get agentDescHint;

  /// No description provided for @agentDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get agentDefault;

  /// No description provided for @makeDefault.
  ///
  /// In en, this message translates to:
  /// **'Make default'**
  String get makeDefault;

  /// No description provided for @connectThisAgent.
  ///
  /// In en, this message translates to:
  /// **'Connect this agent'**
  String get connectThisAgent;

  /// No description provided for @defaultSet.
  ///
  /// In en, this message translates to:
  /// **'{name} is now the default'**
  String defaultSet(String name);

  /// No description provided for @defaultCannotDelete.
  ///
  /// In en, this message translates to:
  /// **'The default cannot be deleted. Set another as default first.'**
  String get defaultCannotDelete;

  /// No description provided for @disconnectToDelete.
  ///
  /// In en, this message translates to:
  /// **'Disconnect before deleting this agent.'**
  String get disconnectToDelete;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @agentAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String agentAdded(String name);

  /// No description provided for @agentDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String agentDeleted(String name);

  /// No description provided for @agentSaved.
  ///
  /// In en, this message translates to:
  /// **'Configuration saved'**
  String get agentSaved;

  /// No description provided for @agentLocked.
  ///
  /// In en, this message translates to:
  /// **'The address, token and directory are locked while connected. Disconnect to change them.'**
  String get agentLocked;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @disconnectedKept.
  ///
  /// In en, this message translates to:
  /// **'Disconnected · conversations kept'**
  String get disconnectedKept;

  /// No description provided for @disconnectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Disconnect from {name}?'**
  String disconnectConfirm(String name);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @backToSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get backToSettings;

  /// No description provided for @connectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect an agent'**
  String get connectTitle;

  /// No description provided for @noAgents.
  ///
  /// In en, this message translates to:
  /// **'No agents yet.'**
  String get noAgents;

  /// No description provided for @currentAgent.
  ///
  /// In en, this message translates to:
  /// **'Current agent'**
  String get currentAgent;

  /// No description provided for @workingNote.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get workingNote;

  /// No description provided for @liveStep.
  ///
  /// In en, this message translates to:
  /// **'Running {name}…'**
  String liveStep(String name);

  /// No description provided for @thinkingNow.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get thinkingNow;

  /// No description provided for @replyingNow.
  ///
  /// In en, this message translates to:
  /// **'Replying…'**
  String get replyingNow;

  /// No description provided for @needsApproval.
  ///
  /// In en, this message translates to:
  /// **'Needs approval'**
  String get needsApproval;

  /// No description provided for @needsApprovalWith.
  ///
  /// In en, this message translates to:
  /// **'Needs approval: {prompt}'**
  String needsApprovalWith(String prompt);

  /// No description provided for @waitingForYou.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get waitingForYou;

  /// No description provided for @stoppedNotice.
  ///
  /// In en, this message translates to:
  /// **'Stopped · what was produced is kept.'**
  String get stoppedNotice;

  /// No description provided for @jumpLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get jumpLatest;

  /// No description provided for @composerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add more detail…'**
  String get composerPlaceholder;

  /// No description provided for @composerLabel.
  ///
  /// In en, this message translates to:
  /// **'Message Aria'**
  String get composerLabel;

  /// No description provided for @stopToast.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get stopToast;

  /// No description provided for @turnRunningToast.
  ///
  /// In en, this message translates to:
  /// **'This turn is still running. Stop it or wait.'**
  String get turnRunningToast;

  /// No description provided for @workLog.
  ///
  /// In en, this message translates to:
  /// **'Work log'**
  String get workLog;

  /// No description provided for @thought.
  ///
  /// In en, this message translates to:
  /// **'Thought'**
  String get thought;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get statusRunning;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get statusStopped;

  /// No description provided for @statusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get statusSkipped;

  /// No description provided for @toolsUsed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tool} other{{count} tools}}'**
  String toolsUsed(int count);

  /// No description provided for @thoughtsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thought} other{{count} thoughts}}'**
  String thoughtsCount(int count);

  /// No description provided for @thoughtsCountSuffix.
  ///
  /// In en, this message translates to:
  /// **', {count, plural, =1{1 thought} other{{count} thoughts}}'**
  String thoughtsCountSuffix(int count);

  /// No description provided for @failedCountSuffix.
  ///
  /// In en, this message translates to:
  /// **' · {count} failed'**
  String failedCountSuffix(int count);

  /// No description provided for @failedSuffix.
  ///
  /// In en, this message translates to:
  /// **' · Failed'**
  String get failedSuffix;

  /// No description provided for @stepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String stepsCount(int count);

  /// No description provided for @andMoreSteps.
  ///
  /// In en, this message translates to:
  /// **' · {count, plural, =1{1 step} other{{count} steps}}'**
  String andMoreSteps(int count);

  /// No description provided for @andMore.
  ///
  /// In en, this message translates to:
  /// **'…'**
  String get andMore;

  /// No description provided for @listSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// No description provided for @stepError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get stepError;

  /// No description provided for @backToWorkLog.
  ///
  /// In en, this message translates to:
  /// **'Back to work log'**
  String get backToWorkLog;

  /// No description provided for @workLogGone.
  ///
  /// In en, this message translates to:
  /// **'This work log is gone'**
  String get workLogGone;

  /// No description provided for @stepGone.
  ///
  /// In en, this message translates to:
  /// **'This step is gone'**
  String get stepGone;

  /// No description provided for @thoughtGone.
  ///
  /// In en, this message translates to:
  /// **'This thought is gone'**
  String get thoughtGone;

  /// No description provided for @modelEffortMode.
  ///
  /// In en, this message translates to:
  /// **'Model and execution'**
  String get modelEffortMode;

  /// No description provided for @thisTurn.
  ///
  /// In en, this message translates to:
  /// **'THIS TURN'**
  String get thisTurn;

  /// No description provided for @reasoningEffort.
  ///
  /// In en, this message translates to:
  /// **'Reasoning effort'**
  String get reasoningEffort;

  /// No description provided for @appliesNextTurn.
  ///
  /// In en, this message translates to:
  /// **'Applies to the next turn.'**
  String get appliesNextTurn;

  /// No description provided for @noModels.
  ///
  /// In en, this message translates to:
  /// **'This endpoint offers no model choice.'**
  String get noModels;

  /// No description provided for @noEfforts.
  ///
  /// In en, this message translates to:
  /// **'This endpoint offers no effort setting.'**
  String get noEfforts;

  /// No description provided for @noModes.
  ///
  /// In en, this message translates to:
  /// **'This endpoint offers no modes.'**
  String get noModes;

  /// No description provided for @modelChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Model {model}, reasoning effort {effort}, mode {mode}'**
  String modelChipLabel(String model, String effort, String mode);

  /// No description provided for @approvalKicker.
  ///
  /// In en, this message translates to:
  /// **'APPROVAL'**
  String get approvalKicker;

  /// No description provided for @command.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get command;

  /// No description provided for @approvalDetail.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get approvalDetail;

  /// No description provided for @riskNote.
  ///
  /// In en, this message translates to:
  /// **'This touches outside the workspace and cannot be undone.'**
  String get riskNote;

  /// No description provided for @cancelThis.
  ///
  /// In en, this message translates to:
  /// **'Cancel this'**
  String get cancelThis;

  /// No description provided for @optionAllowOnce.
  ///
  /// In en, this message translates to:
  /// **'This run only'**
  String get optionAllowOnce;

  /// No description provided for @optionAllowAlways.
  ///
  /// In en, this message translates to:
  /// **'Stop asking for this kind'**
  String get optionAllowAlways;

  /// No description provided for @optionRejectOnce.
  ///
  /// In en, this message translates to:
  /// **'Do not run this time'**
  String get optionRejectOnce;

  /// No description provided for @optionRejectAlways.
  ///
  /// In en, this message translates to:
  /// **'Refuse this kind from now on'**
  String get optionRejectAlways;

  /// No description provided for @requestClosed.
  ///
  /// In en, this message translates to:
  /// **'This request is closed'**
  String get requestClosed;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost · reconnecting; queued work replays automatically.'**
  String get connectionLost;

  /// No description provided for @connectionOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get connectionOffline;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @onWatch.
  ///
  /// In en, this message translates to:
  /// **'On watch'**
  String get onWatch;

  /// No description provided for @connectToStart.
  ///
  /// In en, this message translates to:
  /// **'Connect an agent to start.'**
  String get connectToStart;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteAgentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? This cannot be undone.'**
  String deleteAgentConfirm(String name);

  /// No description provided for @relink.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get relink;

  /// No description provided for @sessionRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing…'**
  String get sessionRefreshing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
