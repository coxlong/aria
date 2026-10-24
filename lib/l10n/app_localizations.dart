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

  /// No description provided for @connectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to an agent'**
  String get connectTitle;

  /// No description provided for @connectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your duet with AI starts with a working connection.'**
  String get connectSubtitle;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @addServer.
  ///
  /// In en, this message translates to:
  /// **'Add server'**
  String get addServer;

  /// No description provided for @editServer.
  ///
  /// In en, this message translates to:
  /// **'Edit server'**
  String get editServer;

  /// No description provided for @deleteServer.
  ///
  /// In en, this message translates to:
  /// **'Delete server'**
  String get deleteServer;

  /// No description provided for @deleteServerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? This cannot be undone.'**
  String deleteServerConfirm(String name);

  /// No description provided for @serverName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get serverName;

  /// No description provided for @serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Agent URL'**
  String get serverUrl;

  /// No description provided for @serverToken.
  ///
  /// In en, this message translates to:
  /// **'Access token (optional)'**
  String get serverToken;

  /// No description provided for @serverCwd.
  ///
  /// In en, this message translates to:
  /// **'Working directory'**
  String get serverCwd;

  /// No description provided for @serverCwdHint.
  ///
  /// In en, this message translates to:
  /// **'/absolute/path/on/agent/host'**
  String get serverCwdHint;

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

  /// No description provided for @noServersTitle.
  ///
  /// In en, this message translates to:
  /// **'No agents yet'**
  String get noServersTitle;

  /// No description provided for @noServersBody.
  ///
  /// In en, this message translates to:
  /// **'Add an ACP server to start a session.'**
  String get noServersBody;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentSessions;

  /// No description provided for @noSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get noSessions;

  /// No description provided for @currentConnection.
  ///
  /// In en, this message translates to:
  /// **'Current connection'**
  String get currentConnection;

  /// No description provided for @switchServer.
  ///
  /// In en, this message translates to:
  /// **'Switch server'**
  String get switchServer;

  /// No description provided for @composerHint.
  ///
  /// In en, this message translates to:
  /// **'Message the agent…'**
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

  /// No description provided for @processRunning.
  ///
  /// In en, this message translates to:
  /// **'Running · {count, plural, =0{starting} =1{step 1} other{step {count}}}'**
  String processRunning(int count);

  /// No description provided for @processCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed · {count, plural, =1{1 step} other{{count} steps}}'**
  String processCompleted(int count);

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinking;

  /// No description provided for @stepDetails.
  ///
  /// In en, this message translates to:
  /// **'Step details'**
  String get stepDetails;

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve tool call'**
  String get permissionTitle;

  /// No description provided for @permissionHint.
  ///
  /// In en, this message translates to:
  /// **'The agent is waiting for your decision.'**
  String get permissionHint;

  /// No description provided for @allowOnce.
  ///
  /// In en, this message translates to:
  /// **'Allow once'**
  String get allowOnce;

  /// No description provided for @allowAlways.
  ///
  /// In en, this message translates to:
  /// **'Always allow'**
  String get allowAlways;

  /// No description provided for @rejectOnce.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectOnce;

  /// No description provided for @rejectAlways.
  ///
  /// In en, this message translates to:
  /// **'Always reject'**
  String get rejectAlways;

  /// No description provided for @permissionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get permissionCancel;

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
  /// **'Reasoning effort'**
  String get effort;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the agent. Check the URL, network and bridge.'**
  String get errorNetwork;

  /// No description provided for @errorAuth.
  ///
  /// In en, this message translates to:
  /// **'The agent rejected the token. Check the access token.'**
  String get errorAuth;

  /// No description provided for @errorProtocol.
  ///
  /// In en, this message translates to:
  /// **'The connection is not speaking ACP v1.'**
  String get errorProtocol;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The agent did not respond in time.'**
  String get errorTimeout;

  /// No description provided for @errorSessionLost.
  ///
  /// In en, this message translates to:
  /// **'The session is no longer available on the agent.'**
  String get errorSessionLost;

  /// No description provided for @errorAgent.
  ///
  /// In en, this message translates to:
  /// **'The agent returned an error ({code}).'**
  String errorAgent(int code);

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// No description provided for @reconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get reconnecting;

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

  /// No description provided for @emptyChatBody.
  ///
  /// In en, this message translates to:
  /// **'Send a message to start the duet.'**
  String get emptyChatBody;

  /// No description provided for @sessionUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled session'**
  String get sessionUntitled;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @serverUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a ws:// or wss:// URL.'**
  String get serverUrlInvalid;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @toolInput.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get toolInput;

  /// No description provided for @toolOutput.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get toolOutput;

  /// No description provided for @deleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get deleteSession;
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
