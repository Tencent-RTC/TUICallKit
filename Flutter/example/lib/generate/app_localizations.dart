import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generate/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @trtc.
  ///
  /// In en, this message translates to:
  /// **'Tencent RTC'**
  String get trtc;

  /// No description provided for @user_id.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get user_id;

  /// No description provided for @enter_user_id.
  ///
  /// In en, this message translates to:
  /// **'Please enter your UserID'**
  String get enter_user_id;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @enter_nickname.
  ///
  /// In en, this message translates to:
  /// **'Enter your user nickname'**
  String get enter_nickname;

  /// No description provided for @tencent_cloud.
  ///
  /// In en, this message translates to:
  /// **'Tencent Cloud'**
  String get tencent_cloud;

  /// No description provided for @login_fail.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get login_fail;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get next;

  /// No description provided for @quick_access.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get quick_access;

  /// No description provided for @package_purchase.
  ///
  /// In en, this message translates to:
  /// **'Package purchase'**
  String get package_purchase;

  /// No description provided for @integration.
  ///
  /// In en, this message translates to:
  /// **'Quick integration'**
  String get integration;

  /// No description provided for @api_docs.
  ///
  /// In en, this message translates to:
  /// **'API documentation'**
  String get api_docs;

  /// No description provided for @common_problems.
  ///
  /// In en, this message translates to:
  /// **'Common issues'**
  String get common_problems;

  /// No description provided for @single_call.
  ///
  /// In en, this message translates to:
  /// **'Single call'**
  String get single_call;

  /// No description provided for @group_call.
  ///
  /// In en, this message translates to:
  /// **'Group call'**
  String get group_call;

  /// No description provided for @multi_call.
  ///
  /// In en, this message translates to:
  /// **'Multi-person call'**
  String get multi_call;

  /// No description provided for @enter_callee_id.
  ///
  /// In en, this message translates to:
  /// **'Please enter the UserId you want to call'**
  String get enter_callee_id;

  /// No description provided for @media_type.
  ///
  /// In en, this message translates to:
  /// **'Media type'**
  String get media_type;

  /// No description provided for @video_call.
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get video_call;

  /// No description provided for @voice_call.
  ///
  /// In en, this message translates to:
  /// **'Voice call'**
  String get voice_call;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Call settings'**
  String get settings;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Initiate a call'**
  String get call;

  /// No description provided for @group_id.
  ///
  /// In en, this message translates to:
  /// **'Group ID'**
  String get group_id;

  /// No description provided for @enter_group_id.
  ///
  /// In en, this message translates to:
  /// **'Please enter GroupId'**
  String get enter_group_id;

  /// No description provided for @callee_id_list.
  ///
  /// In en, this message translates to:
  /// **'User ID list'**
  String get callee_id_list;

  /// No description provided for @separated.
  ///
  /// In en, this message translates to:
  /// **'IDs are separated by commas'**
  String get separated;

  /// No description provided for @join_group_call.
  ///
  /// In en, this message translates to:
  /// **'Join group call'**
  String get join_group_call;

  /// No description provided for @join_multi_call.
  ///
  /// In en, this message translates to:
  /// **'Join a multi-person call'**
  String get join_multi_call;

  /// No description provided for @digital_room.
  ///
  /// In en, this message translates to:
  /// **'Digital room number'**
  String get digital_room;

  /// No description provided for @string_room.
  ///
  /// In en, this message translates to:
  /// **'String room number'**
  String get string_room;

  /// No description provided for @enter_room_id.
  ///
  /// In en, this message translates to:
  /// **'Please enter RoomId'**
  String get enter_room_id;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @not_set.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get not_set;

  /// No description provided for @nick_name.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nick_name;

  /// No description provided for @silent_mode.
  ///
  /// In en, this message translates to:
  /// **'Silent mode'**
  String get silent_mode;

  /// No description provided for @enable_floating.
  ///
  /// In en, this message translates to:
  /// **'Show floating window button'**
  String get enable_floating;

  /// No description provided for @call_custom_setiings.
  ///
  /// In en, this message translates to:
  /// **'Custom call parameter settings'**
  String get call_custom_setiings;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Call timeout duration'**
  String get timeout;

  /// No description provided for @extended_info.
  ///
  /// In en, this message translates to:
  /// **'Extended information'**
  String get extended_info;

  /// No description provided for @offline_push_info.
  ///
  /// In en, this message translates to:
  /// **'Offline push message'**
  String get offline_push_info;

  /// No description provided for @go_set.
  ///
  /// In en, this message translates to:
  /// **'Go to settings'**
  String get go_set;

  /// No description provided for @video_settings.
  ///
  /// In en, this message translates to:
  /// **'Video settings'**
  String get video_settings;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @resolution_mode.
  ///
  /// In en, this message translates to:
  /// **'Portrait/landscape'**
  String get resolution_mode;

  /// No description provided for @horizontal.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get horizontal;

  /// No description provided for @vertical.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get vertical;

  /// No description provided for @fill_pattern.
  ///
  /// In en, this message translates to:
  /// **'Fill pattern'**
  String get fill_pattern;

  /// No description provided for @fill.
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get fill;

  /// No description provided for @fit.
  ///
  /// In en, this message translates to:
  /// **'Fit'**
  String get fit;

  /// No description provided for @rotation.
  ///
  /// In en, this message translates to:
  /// **'Rotation angle'**
  String get rotation;

  /// No description provided for @beauty_level.
  ///
  /// In en, this message translates to:
  /// **'Beauty level'**
  String get beauty_level;

  /// No description provided for @avatar_settings.
  ///
  /// In en, this message translates to:
  /// **'Avatar settings'**
  String get avatar_settings;

  /// No description provided for @extended_info_settings.
  ///
  /// In en, this message translates to:
  /// **'Extended information settings'**
  String get extended_info_settings;

  /// No description provided for @offline_push_info_settings.
  ///
  /// In en, this message translates to:
  /// **'Offline push message settings'**
  String get offline_push_info_settings;

  /// No description provided for @please_enter.
  ///
  /// In en, this message translates to:
  /// **'Please enter'**
  String get please_enter;

  /// No description provided for @show_blur_background_button.
  ///
  /// In en, this message translates to:
  /// **'Show blur background'**
  String get show_blur_background_button;

  /// No description provided for @show_incoming_banner.
  ///
  /// In en, this message translates to:
  /// **'Show incoming banner'**
  String get show_incoming_banner;

  /// No description provided for @optional_parameters.
  ///
  /// In en, this message translates to:
  /// **'Optional parameters'**
  String get optional_parameters;
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
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
