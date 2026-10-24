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
  /// **'简体中文'**
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
  /// **'Pick an executor to connect to.'**
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

  /// No description provided for @reconnectingShort.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting'**
  String get reconnectingShort;

  /// No description provided for @manageExecutors.
  ///
  /// In en, this message translates to:
  /// **'Manage executors'**
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

  /// No description provided for @processRunning.
  ///
  /// In en, this message translates to:
  /// **'Running · step {index}'**
  String processRunning(int index);

  /// No description provided for @processDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String processDone(int count);
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
