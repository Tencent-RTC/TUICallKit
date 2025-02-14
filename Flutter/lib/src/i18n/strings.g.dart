
/*
 * Generated file. Do not edit.
 *
 * Locales: 3
 * Strings: 321 (107.0 per locale)
 *
 * Built on 2024-12-05 at 07:55 UTC
 */

import 'package:flutter/widgets.dart';

const AppLocale _baseLocale = AppLocale.en;
AppLocale _currLocale = _baseLocale;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale {
	en, // 'en' (base locale, fallback)
	ja, // 'ja'
	zhHans, // 'zh-Hans'
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
_StringsEn _t = _currLocale.translations;
_StringsEn get t => _t;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class Translations {
	Translations._(); // no constructor

	static _StringsEn of(BuildContext context) {
		final inheritedWidget = context.dependOnInheritedWidgetOfExactType<_InheritedLocaleData>();
		if (inheritedWidget == null) {
			throw 'Please wrap your app with "TranslationProvider".';
		}
		return inheritedWidget.translations;
	}
}

class LocaleSettings {
	LocaleSettings._(); // no constructor

	/// Uses locale of the device, fallbacks to base locale.
	/// Returns the locale which has been set.
	static AppLocale useDeviceLocale() {
		final locale = AppLocaleUtils.findDeviceLocale();
		return setLocale(locale);
	}

	/// Sets locale
	/// Returns the locale which has been set.
	static AppLocale setLocale(AppLocale locale) {
		_currLocale = locale;
		_t = _currLocale.translations;

		// force rebuild if TranslationProvider is used
		_translationProviderKey.currentState?.setLocale(_currLocale);

		return _currLocale;
	}

	/// Sets locale using string tag (e.g. en_US, de-DE, fr)
	/// Fallbacks to base locale.
	/// Returns the locale which has been set.
	static AppLocale setLocaleRaw(String rawLocale) {
		final locale = AppLocaleUtils.parse(rawLocale);
		return setLocale(locale);
	}

	/// Gets current locale.
	static AppLocale get currentLocale {
		return _currLocale;
	}

	/// Gets base locale.
	static AppLocale get baseLocale {
		return _baseLocale;
	}

	/// Gets supported locales in string format.
	static List<String> get supportedLocalesRaw {
		return AppLocale.values
			.map((locale) => locale.languageTag)
			.toList();
	}

	/// Gets supported locales (as Locale objects) with base locale sorted first.
	static List<Locale> get supportedLocales {
		return AppLocale.values
			.map((locale) => locale.flutterLocale)
			.toList();
	}
}

/// Provides utility functions without any side effects.
class AppLocaleUtils {
	AppLocaleUtils._(); // no constructor

	/// Returns the locale of the device as the enum type.
	/// Fallbacks to base locale.
	static AppLocale findDeviceLocale() {
		final String? deviceLocale = WidgetsBinding.instance.window.locale.toLanguageTag();
		if (deviceLocale != null) {
			final typedLocale = _selectLocale(deviceLocale);
			if (typedLocale != null) {
				return typedLocale;
			}
		}
		return _baseLocale;
	}

	/// Returns the enum type of the raw locale.
	/// Fallbacks to base locale.
	static AppLocale parse(String rawLocale) {
		return _selectLocale(rawLocale) ?? _baseLocale;
	}
}

// context enums

// interfaces generated as mixins

// translation instances

late _StringsEn _translationsEn = _StringsEn.build();
late _StringsJa _translationsJa = _StringsJa.build();
late _StringsZhHans _translationsZhHans = _StringsZhHans.build();

// extensions for AppLocale

extension AppLocaleExtensions on AppLocale {

	/// Gets the translation instance managed by this library.
	/// [TranslationProvider] is using this instance.
	/// The plural resolvers are set via [LocaleSettings].
	_StringsEn get translations {
		switch (this) {
			case AppLocale.en: return _translationsEn;
			case AppLocale.ja: return _translationsJa;
			case AppLocale.zhHans: return _translationsZhHans;
		}
	}

	/// Gets a new translation instance.
	/// [LocaleSettings] has no effect here.
	/// Suitable for dependency injection and unit tests.
	///
	/// Usage:
	/// final t = AppLocale.en.build(); // build
	/// String a = t.my.path; // access
	_StringsEn build() {
		switch (this) {
			case AppLocale.en: return _StringsEn.build();
			case AppLocale.ja: return _StringsJa.build();
			case AppLocale.zhHans: return _StringsZhHans.build();
		}
	}

	String get languageTag {
		switch (this) {
			case AppLocale.en: return 'en';
			case AppLocale.ja: return 'ja';
			case AppLocale.zhHans: return 'zh-Hans';
		}
	}

	Locale get flutterLocale {
		switch (this) {
			case AppLocale.en: return const Locale.fromSubtags(languageCode: 'en');
			case AppLocale.ja: return const Locale.fromSubtags(languageCode: 'ja');
			case AppLocale.zhHans: return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', );
		}
	}
}

extension StringAppLocaleExtensions on String {
	AppLocale? toAppLocale() {
		switch (this) {
			case 'en': return AppLocale.en;
			case 'ja': return AppLocale.ja;
			case 'zh-Hans': return AppLocale.zhHans;
			default: return null;
		}
	}
}

// wrappers

GlobalKey<_TranslationProviderState> _translationProviderKey = GlobalKey<_TranslationProviderState>();

class TranslationProvider extends StatefulWidget {
	TranslationProvider({required this.child}) : super(key: _translationProviderKey);

	final Widget child;

	@override
	_TranslationProviderState createState() => _TranslationProviderState();

	static _InheritedLocaleData of(BuildContext context) {
		final inheritedWidget = context.dependOnInheritedWidgetOfExactType<_InheritedLocaleData>();
		if (inheritedWidget == null) {
			throw 'Please wrap your app with "TranslationProvider".';
		}
		return inheritedWidget;
	}
}

class _TranslationProviderState extends State<TranslationProvider> {
	AppLocale locale = _currLocale;

	void setLocale(AppLocale newLocale) {
		setState(() {
			locale = newLocale;
		});
	}

	@override
	Widget build(BuildContext context) {
		return _InheritedLocaleData(
			locale: locale,
			child: widget.child,
		);
	}
}

class _InheritedLocaleData extends InheritedWidget {
	final AppLocale locale;
	Locale get flutterLocale => locale.flutterLocale; // shortcut
	final _StringsEn translations; // store translations to avoid switch call

	_InheritedLocaleData({required this.locale, required Widget child})
		: translations = locale.translations, super(child: child);

	@override
	bool updateShouldNotify(_InheritedLocaleData oldWidget) {
		return oldWidget.locale != locale;
	}
}

// pluralization feature not used

// helpers

final _localeRegex = RegExp(r'^([a-z]{2,8})?([_-]([A-Za-z]{4}))?([_-]?([A-Z]{2}|[0-9]{3}))?$');
AppLocale? _selectLocale(String localeRaw) {
	final match = _localeRegex.firstMatch(localeRaw);
	AppLocale? selected;
	if (match != null) {
		final language = match.group(1);
		final country = match.group(5);

		// match exactly
		selected = AppLocale.values
			.cast<AppLocale?>()
			.firstWhere((supported) => supported?.languageTag == localeRaw.replaceAll('_', '-'), orElse: () => null);

		if (selected == null && language != null) {
			// match language
			selected = AppLocale.values
				.cast<AppLocale?>()
				.firstWhere((supported) => supported?.languageTag.startsWith(language) == true, orElse: () => null);
		}

		if (selected == null && country != null) {
			// match country
			selected = AppLocale.values
				.cast<AppLocale?>()
				.firstWhere((supported) => supported?.languageTag.contains(country) == true, orElse: () => null);
		}
	}
	return selected;
}

// translations

// Path: <root>
class _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsEn.build();

	/// Access flat map
	dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	late final Map<String, dynamic> _flatMap = _buildFlatMap();

	late final _StringsEn _root = this; // ignore: unused_field

	// Translations
	String get k_0000001 => 'Waiting for the other party to accept the invitation';
	String get k_0000002 => 'Invited you to audio call';
	String get k_0000002_1 => 'Invited you to video call';
	String get k_0000003 => 'Invited you to a group call';
	String get k_0000004 => 'A new call is incoming, but cannot be answered due to insufficient permissions. Please make sure the camera/microphone permission is turned on.';
	String get k_0000005 => 'Invite members';
	String get k_0000006 => 'yourself';
	String get k_0000007 => 'microphone';
	String get k_0000008 => 'hang up';
	String get k_0000009 => 'speaker';
	String get k_0000010 => 'earpiece';
	String get k_0000011 => 'camera';
	String get k_0000012 => 'switch to voice call';
	String get k_0000013 => 'accept';
	String get k_0000014 => 'Exceeded the maximum number of people';
	String get k_0000015 => 'reject';
	String get k_0000016 => 'no response';
	String get k_0000017 => 'Busy';
	String get k_0000018 => 'Leave';
	String get k_0000019 => 'Tencent Real-Time Communication';
	String get k_0000020 => 'User ID';
	String get k_0000021 => 'Log in';
	String get k_0000022 => 'Quick access';
	String get k_0000023 => 'Package purchase';
	String get k_0000024 => 'Quick access';
	String get k_0000025 => 'API documentation';
	String get k_0000026 => 'Common problem';
	String get k_0000027 => 'Single call';
	String get k_0000028 => 'Group call';
	String get k_0000029 => 'Media type';
	String get k_0000030 => 'Video call';
	String get k_0000031 => 'Voice calls';
	String get k_0000032 => 'Call settings';
	String get k_0000033 => 'Initiate a call';
	String get k_0000034 => 'Group ID';
	String get k_0000035 => 'Join group call';
	String get k_0000036 => 'Digital room number';
	String get k_0000037 => 'String room number';
	String get k_0000038 => '1V1 call';
	String get k_0000039 => 'Avatar';
	String get k_0000040 => 'Nick name';
	String get k_0000041 => 'Silent mode';
	String get k_0000042 => 'Show floating enable button';
	String get k_0000043 => 'Call custom parameter settings';
	String get k_0000044 => 'Call times out often';
	String get k_0000045 => 'Extended Information';
	String get k_0000046 => 'Offline push message';
	String get k_0000047 => 'Video settings';
	String get k_0000048 => 'Resolution';
	String get k_0000049 => 'Resolution mode';
	String get k_0000050 => 'Horizontal screen';
	String get k_0000051 => 'Vertical screen';
	String get k_0000052 => 'Fill pattern';
	String get k_0000053 => 'Fill';
	String get k_0000054 => 'Fit';
	String get k_0000055 => 'Rotation Angle';
	String get k_0000056 => 'Beauty Level';
	String get k_0000057 => 'Not Set';
	String get k_0000058 => 'Go to settings';
	String get k_0000059 => 'Please enter';
	String get k_0000060 => 'Avatar settings';
	String get k_0000061 => 'Extended information settings';
	String get k_0000062 => 'Offline Push Message Settings';
	String get k_0000063 => 'Please enter the UserId you want to call';
	String get k_0000064 => 'Please enter GroupId';
	String get k_0000065 => 'User IDs are separated by commas';
	String get k_0000066 => 'Please enter RoomId';
	String get k_0000067 => 'Note: TUICallKit supports offline calls, and supports multiple platforms such as Android, iOS, Web, and Flutter';
	String get k_0000068 => 'Enter your username';
	String get k_0000069 => 'Login failed';
	String get k_0000070 => 'Continue';
	String get k_0000071 => 'Confirm';
	String get k_0000072 => 'Cancel';
	String get k_0000073 => 'Tencent Cloud';
	String get k_0000074 => 'Logout';
	String get k_0000075 => 'Please enter your UserId';
	String get k_0000076 => 'List of user ids';
	String get k_0000077 => 'Other party hung up, call ended';
	String get k_0000078 => 'Call rejected by other party';
	String get k_0000079 => 'The other party is busy';
	String get k_0000080 => 'The other party did not respond';
	String get k_0000081 => 'rejected call';
	String get k_0000082 => 'end the call';
	String get k_0000083 => 'Anonymity';
	String get k_0000084 => 'Apply for microphone permission';
	String get k_0000085 => 'Apply for microphone and camera permissions';
	String get k_0000086 => 'You need to access your microphone permission, which can be used for voice calls, multi-person voice calls, video calls, multi-person video calls and other functions after being turned on.';
	String get k_0000087 => 'You need to access your microphone and camera permissions, which can be used for voice calls, multi-person voice calls, video calls, multi-person video calls, etc.';
	String get k_0000088 => 'Waiting';
	String get k_0000089 => 'Display pop-up window while running in the background and Display pop-up Window permissions';
	String get k_0000090 => 'You have a new call';
	String get k_0000091 => 'Unmuted';
	String get k_0000092 => 'Muted';
	String get k_0000093 => 'Speaker';
	String get k_0000094 => 'Earpiece';
	String get k_0000095 => 'Camera On';
	String get k_0000096 => 'Camera Off';
	String get k_0000097 => 'Connected';
	String get k_0000098 => 'They are also there';
	String get k_0000099 => 'Join In';
	String get k_0000100 => ' person is on the call';
	String get k_0000101 => 'Switch Camera';
	String get k_0000102 => 'Blur Background';
	String get k_0000103 => 'Show blur background';
	String get k_0000104 => 'The other party\'s network connection is poor';
	String get k_0000105 => 'Your network connection is poor';
	String get k_0000106 => 'The identifier is in blacklist. Failed to send this message!';
}

// Path: <root>
class _StringsJa implements _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsJa.build();

	/// Access flat map
	@override dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	@override late final Map<String, dynamic> _flatMap = _buildFlatMap();

	@override late final _StringsJa _root = this; // ignore: unused_field

	// Translations
	@override String get k_0000001 => '相手が招待を承諾するのを待っています';
	@override String get k_0000002 => '音声通話に招待する';
	@override String get k_0000002_1 => 'ビデオ通話に招待する';
	@override String get k_0000003 => 'グループ通話に招待されました';
	@override String get k_0000004 => '新通話の呼入がありますが、権限不足により、接听できません。カメラ/マイクの権限が有効かどうか確認してください';
	@override String get k_0000005 => '邀请メンバーを翻訳します';
	@override String get k_0000006 => '自分';
	@override String get k_0000007 => 'マイク';
	@override String get k_0000008 => '通話終了';
	@override String get k_0000009 => 'スピーカー';
	@override String get k_0000010 => 'イヤホン';
	@override String get k_0000011 => 'カメラ';
	@override String get k_0000012 => '音声通話に切り替えます';
	@override String get k_0000013 => '応答';
	@override String get k_0000014 => '最大人数を超えました';
	@override String get k_0000015 => '通話拒否';
	@override String get k_0000016 => '呼び出しタイムアウト';
	@override String get k_0000017 => '相手が通話中です';
	@override String get k_0000018 => '通話を終了します';
	@override String get k_0000019 => 'TRTC';
	@override String get k_0000020 => 'ユーザーID';
	@override String get k_0000021 => 'ログイン';
	@override String get k_0000022 => 'クイックアクセス';
	@override String get k_0000023 => 'パッケージの購入';
	@override String get k_0000024 => 'クイックアクセス';
	@override String get k_0000025 => 'API ドキュメント';
	@override String get k_0000026 => 'よくある問題';
	@override String get k_0000027 => '1v1通話';
	@override String get k_0000028 => 'グループ通話';
	@override String get k_0000029 => 'メディアタイプ';
	@override String get k_0000030 => 'ビデオ通話';
	@override String get k_0000031 => '音声通話';
	@override String get k_0000032 => '通話設定';
	@override String get k_0000033 => '通話を開始';
	@override String get k_0000034 => 'グループID';
	@override String get k_0000035 => 'グループ通話に参加する';
	@override String get k_0000036 => 'ルームID（番号）';
	@override String get k_0000037 => 'ルームID（文字列）';
	@override String get k_0000038 => '1V1通话';
	@override String get k_0000039 => 'プロフィール画像';
	@override String get k_0000040 => 'ニックネーム';
	@override String get k_0000041 => 'ミュートモード';
	@override String get k_0000042 => 'フローティングウィンドウの表示';
	@override String get k_0000043 => '通話パラメータの設定';
	@override String get k_0000044 => 'コールウェイティングのタイムアウト時間を設定してください';
	@override String get k_0000045 => '拡張情報';
	@override String get k_0000046 => 'オフラインメッセージ';
	@override String get k_0000047 => 'ビデオ設定';
	@override String get k_0000048 => '解像度';
	@override String get k_0000049 => '縦横画面';
	@override String get k_0000050 => '横画面';
	@override String get k_0000051 => '縦画面';
	@override String get k_0000052 => '塗りつぶしパターン';
	@override String get k_0000053 => '塗りつぶし';
	@override String get k_0000054 => 'フィット';
	@override String get k_0000055 => '回転角度';
	@override String get k_0000056 => '美顔のレベル';
	@override String get k_0000057 => '未設定';
	@override String get k_0000058 => '設定に移動';
	@override String get k_0000059 => '入ってください';
	@override String get k_0000060 => 'プロフィール画像とユーザー名を入力してください';
	@override String get k_0000061 => '拡張情報';
	@override String get k_0000062 => 'オフライン メッセージ情報の json 文字列を入力してください';
	@override String get k_0000063 => '携帯電話番号/ユーザーIDを入力してください';
	@override String get k_0000064 => 'グループIDを入力してください';
	@override String get k_0000065 => 'ユーザー ID を区切るにはカンマを使用します';
	@override String get k_0000066 => 'ルームIDを入力してください';
	@override String get k_0000067 => '注: TUICallKit はオフライン通話をサポートし、Android、iOS、Web、Flutter などの複数のプラットフォームをサポートします。';
	@override String get k_0000068 => 'ニックネーム';
	@override String get k_0000069 => 'ログインに失敗しました。すべての機能が使用できません';
	@override String get k_0000070 => 'OK';
	@override String get k_0000071 => 'OK';
	@override String get k_0000072 => 'キャンセル';
	@override String get k_0000073 => 'TRTC';
	@override String get k_0000074 => 'ログアウト';
	@override String get k_0000075 => 'ユーザーIDを入力してください';
	@override String get k_0000076 => 'ユーザーID一覧';
	@override String get k_0000077 => '相手が切断、通話終了';
	@override String get k_0000078 => '相手による通話拒否';
	@override String get k_0000079 => '相手が通話中です';
	@override String get k_0000080 => '呼び出しタイムアウト';
	@override String get k_0000081 => 'は通話を拒否しました';
	@override String get k_0000082 => '通話終了';
	@override String get k_0000083 => '匿名';
	@override String get k_0000084 => 'マイクへのアクセス許可を申請します。';
	@override String get k_0000085 => 'マイクとカメラの許可を申請する';
	@override String get k_0000086 => 'マイクへのアクセス許可が必要で、音声/ビデオ通話、グループ音声/ビデオ通話などの機能に使用できます。マイクをオンにした場合のみ、録画した動画に音声が保存されます。';
	@override String get k_0000087 => 'カメラへのアクセス許可が必要で、ビデオ通話、グループビデオ通話などの機能に使用できます。美顔機能を使用する場合は、カメラで撮影された映像から顔の特徴点情報をリアルタイムで収集し、より自然な美しさを提供します。';
	@override String get k_0000088 => '応答を待っています';
	@override String get k_0000089 => 'バックグラウンドポップアップインターフェースを有効にし、同時にフローティングウィンドウ権限を表示してください。';
	@override String get k_0000090 => '新しい電話があります';
	@override String get k_0000091 => 'マイクオン';
	@override String get k_0000092 => 'マイクがオフ';
	@override String get k_0000093 => 'スピーカーオン';
	@override String get k_0000094 => 'スピーカーオフ';
	@override String get k_0000095 => 'カメラオン';
	@override String get k_0000096 => 'カメラオフ';
	@override String get k_0000097 => '接続済み';
	@override String get k_0000098 => '彼らもそこにいる';
	@override String get k_0000099 => '参加する';
	@override String get k_0000100 => '人が通話中です';
	@override String get k_0000101 => 'カメラの切り替え';
	@override String get k_0000102 => '背景をぼかす';
	@override String get k_0000103 => '背景をぼかす';
	@override String get k_0000104 => '相手のネットワーク接続が不安定です';
	@override String get k_0000105 => 'ネットワーク接続が不安定です';
	@override String get k_0000106 => 'ユーザーはブラックリストに登録され、通話が開始できませんでした。';
}

// Path: <root>
class _StringsZhHans implements _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsZhHans.build();

	/// Access flat map
	@override dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	@override late final Map<String, dynamic> _flatMap = _buildFlatMap();

	@override late final _StringsZhHans _root = this; // ignore: unused_field

	// Translations
	@override String get k_0000001 => '等待对方接受邀请';
	@override String get k_0000002 => '邀请你进行语音通话';
	@override String get k_0000002_1 => '邀请你进行视频通话';
	@override String get k_0000003 => '邀请你进行多人通话';
	@override String get k_0000004 => '新通话呼入，但因权限不足，无法接听。请确认摄像头/麦克风权限已开启。';
	@override String get k_0000005 => '邀请成员';
	@override String get k_0000006 => '你';
	@override String get k_0000007 => '麦克风';
	@override String get k_0000008 => '挂断';
	@override String get k_0000009 => '扬声器';
	@override String get k_0000010 => '听筒';
	@override String get k_0000011 => '摄像头';
	@override String get k_0000012 => '切到语音通话';
	@override String get k_0000013 => '接听';
	@override String get k_0000014 => '超过最大人数限制';
	@override String get k_0000015 => '拒绝通话';
	@override String get k_0000016 => '未响应';
	@override String get k_0000017 => '忙线';
	@override String get k_0000018 => '离开通话';
	@override String get k_0000019 => '腾讯云音视频';
	@override String get k_0000020 => '用户ID';
	@override String get k_0000021 => '登录';
	@override String get k_0000022 => '快速访问';
	@override String get k_0000023 => '套餐购买';
	@override String get k_0000024 => '快速接入';
	@override String get k_0000025 => 'API文档';
	@override String get k_0000026 => '常见问题';
	@override String get k_0000027 => '单人通话';
	@override String get k_0000028 => '群组通话';
	@override String get k_0000029 => '媒体类型';
	@override String get k_0000030 => '视频通话';
	@override String get k_0000031 => '语音通话';
	@override String get k_0000032 => '通话设置';
	@override String get k_0000033 => '发起通话';
	@override String get k_0000034 => '群组ID';
	@override String get k_0000035 => '加入群组通话';
	@override String get k_0000036 => '数字房间号';
	@override String get k_0000037 => '字符串房间号';
	@override String get k_0000038 => '1V1通话';
	@override String get k_0000039 => '头像';
	@override String get k_0000040 => '昵称';
	@override String get k_0000041 => '静音模式';
	@override String get k_0000042 => '显示悬浮窗按钮';
	@override String get k_0000043 => '通话自定义参数设置';
	@override String get k_0000044 => '呼叫超时时常';
	@override String get k_0000045 => '扩展信息';
	@override String get k_0000046 => '离线推送消息';
	@override String get k_0000047 => '视频设置';
	@override String get k_0000048 => '分辨率';
	@override String get k_0000049 => '横竖屏';
	@override String get k_0000050 => '横屏';
	@override String get k_0000051 => '竖屏';
	@override String get k_0000052 => '填充模式';
	@override String get k_0000053 => '充满';
	@override String get k_0000054 => '自适应';
	@override String get k_0000055 => '旋转角度';
	@override String get k_0000056 => '美颜等级';
	@override String get k_0000057 => '未设置';
	@override String get k_0000058 => '去设置';
	@override String get k_0000059 => '请输入';
	@override String get k_0000060 => '头像设置';
	@override String get k_0000061 => '扩展信息设置';
	@override String get k_0000062 => '离线推送消息设置';
	@override String get k_0000063 => '请输入您要呼叫的UserId';
	@override String get k_0000064 => '请输入GroupId';
	@override String get k_0000065 => '用户ID使用逗号隔开';
	@override String get k_0000066 => '请输入RoomId';
	@override String get k_0000067 => '注意：TUICallKit支持离线调用，支持Android、iOS、Web、Flutter等多平台';
	@override String get k_0000068 => '输入你的用户昵称';
	@override String get k_0000069 => '登录失败';
	@override String get k_0000070 => '继续';
	@override String get k_0000071 => '确定';
	@override String get k_0000072 => '取消';
	@override String get k_0000073 => '腾讯云';
	@override String get k_0000074 => '退出登录';
	@override String get k_0000075 => '请输入您的UserId';
	@override String get k_0000076 => '用户ID列表';
	@override String get k_0000077 => '对方已挂断，通话结束';
	@override String get k_0000078 => '对方拒绝了通话请求';
	@override String get k_0000079 => '对方忙线';
	@override String get k_0000080 => '对方未响应';
	@override String get k_0000081 => '拒绝了通话请求';
	@override String get k_0000082 => '结束了通话';
	@override String get k_0000083 => '匿名';
	@override String get k_0000084 => '申请麦克风权限';
	@override String get k_0000085 => '申请麦克风、摄像头权限';
	@override String get k_0000086 => '需要访问您的麦克风权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。';
	@override String get k_0000087 => '需要访问您的麦克风和摄像头权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。';
	@override String get k_0000088 => '等待接听';
	@override String get k_0000089 => '请同时打开后台弹出界面和显示悬浮窗权限';
	@override String get k_0000090 => '您有一个新的通话';
	@override String get k_0000091 => '麦克风已开启';
	@override String get k_0000092 => '麦克风已关闭';
	@override String get k_0000093 => '扬声器已开启';
	@override String get k_0000094 => '扬声器已关闭';
	@override String get k_0000095 => '摄像头已开启';
	@override String get k_0000096 => '摄像头已关闭';
	@override String get k_0000097 => '已接通';
	@override String get k_0000098 => '他们也在';
	@override String get k_0000099 => '加入';
	@override String get k_0000100 => '人正在通话';
	@override String get k_0000101 => '翻转';
	@override String get k_0000102 => '模糊背景';
	@override String get k_0000103 => '显示模糊背景按钮';
	@override String get k_0000104 => '当前通话对方网络不佳';
	@override String get k_0000105 => '当前通话你的网络不佳';
	@override String get k_0000106 => '发起通话失败，用户在黑名单中，禁止发起！';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
	Map<String, dynamic> _buildFlatMap() {
		return <String, dynamic>{
			'k_0000001': 'Waiting for the other party to accept the invitation',
			'k_0000002': 'Invited you to audio call',
			'k_0000002_1': 'Invited you to video call',
			'k_0000003': 'Invited you to a group call',
			'k_0000004': 'A new call is incoming, but cannot be answered due to insufficient permissions. Please make sure the camera/microphone permission is turned on.',
			'k_0000005': 'Invite members',
			'k_0000006': 'yourself',
			'k_0000007': 'microphone',
			'k_0000008': 'hang up',
			'k_0000009': 'speaker',
			'k_0000010': 'earpiece',
			'k_0000011': 'camera',
			'k_0000012': 'switch to voice call',
			'k_0000013': 'accept',
			'k_0000014': 'Exceeded the maximum number of people',
			'k_0000015': 'reject',
			'k_0000016': 'no response',
			'k_0000017': 'Busy',
			'k_0000018': 'Leave',
			'k_0000019': 'Tencent Real-Time Communication',
			'k_0000020': 'User ID',
			'k_0000021': 'Log in',
			'k_0000022': 'Quick access',
			'k_0000023': 'Package purchase',
			'k_0000024': 'Quick access',
			'k_0000025': 'API documentation',
			'k_0000026': 'Common problem',
			'k_0000027': 'Single call',
			'k_0000028': 'Group call',
			'k_0000029': 'Media type',
			'k_0000030': 'Video call',
			'k_0000031': 'Voice calls',
			'k_0000032': 'Call settings',
			'k_0000033': 'Initiate a call',
			'k_0000034': 'Group ID',
			'k_0000035': 'Join group call',
			'k_0000036': 'Digital room number',
			'k_0000037': 'String room number',
			'k_0000038': '1V1 call',
			'k_0000039': 'Avatar',
			'k_0000040': 'Nick name',
			'k_0000041': 'Silent mode',
			'k_0000042': 'Show floating enable button',
			'k_0000043': 'Call custom parameter settings',
			'k_0000044': 'Call times out often',
			'k_0000045': 'Extended Information',
			'k_0000046': 'Offline push message',
			'k_0000047': 'Video settings',
			'k_0000048': 'Resolution',
			'k_0000049': 'Resolution mode',
			'k_0000050': 'Horizontal screen',
			'k_0000051': 'Vertical screen',
			'k_0000052': 'Fill pattern',
			'k_0000053': 'Fill',
			'k_0000054': 'Fit',
			'k_0000055': 'Rotation Angle',
			'k_0000056': 'Beauty Level',
			'k_0000057': 'Not Set',
			'k_0000058': 'Go to settings',
			'k_0000059': 'Please enter',
			'k_0000060': 'Avatar settings',
			'k_0000061': 'Extended information settings',
			'k_0000062': 'Offline Push Message Settings',
			'k_0000063': 'Please enter the UserId you want to call',
			'k_0000064': 'Please enter GroupId',
			'k_0000065': 'User IDs are separated by commas',
			'k_0000066': 'Please enter RoomId',
			'k_0000067': 'Note: TUICallKit supports offline calls, and supports multiple platforms such as Android, iOS, Web, and Flutter',
			'k_0000068': 'Enter your username',
			'k_0000069': 'Login failed',
			'k_0000070': 'Continue',
			'k_0000071': 'Confirm',
			'k_0000072': 'Cancel',
			'k_0000073': 'Tencent Cloud',
			'k_0000074': 'Logout',
			'k_0000075': 'Please enter your UserId',
			'k_0000076': 'List of user ids',
			'k_0000077': 'Other party hung up, call ended',
			'k_0000078': 'Call rejected by other party',
			'k_0000079': 'The other party is busy',
			'k_0000080': 'The other party did not respond',
			'k_0000081': 'rejected call',
			'k_0000082': 'end the call',
			'k_0000083': 'Anonymity',
			'k_0000084': 'Apply for microphone permission',
			'k_0000085': 'Apply for microphone and camera permissions',
			'k_0000086': 'You need to access your microphone permission, which can be used for voice calls, multi-person voice calls, video calls, multi-person video calls and other functions after being turned on.',
			'k_0000087': 'You need to access your microphone and camera permissions, which can be used for voice calls, multi-person voice calls, video calls, multi-person video calls, etc.',
			'k_0000088': 'Waiting',
			'k_0000089': 'Display pop-up window while running in the background and Display pop-up Window permissions',
			'k_0000090': 'You have a new call',
			'k_0000091': 'Unmuted',
			'k_0000092': 'Muted',
			'k_0000093': 'Speaker',
			'k_0000094': 'Earpiece',
			'k_0000095': 'Camera On',
			'k_0000096': 'Camera Off',
			'k_0000097': 'Connected',
			'k_0000098': 'They are also there',
			'k_0000099': 'Join In',
			'k_0000100': ' person is on the call',
			'k_0000101': 'Switch Camera',
			'k_0000102': 'Blur Background',
			'k_0000103': 'Show blur background',
			'k_0000104': 'The other party\'s network connection is poor',
			'k_0000105': 'Your network connection is poor',
			'k_0000106': 'The identifier is in blacklist. Failed to send this message!',
		};
	}
}

extension on _StringsJa {
	Map<String, dynamic> _buildFlatMap() {
		return <String, dynamic>{
			'k_0000001': '相手が招待を承諾するのを待っています',
			'k_0000002': '音声通話に招待する',
			'k_0000002_1': 'ビデオ通話に招待する',
			'k_0000003': 'グループ通話に招待されました',
			'k_0000004': '新通話の呼入がありますが、権限不足により、接听できません。カメラ/マイクの権限が有効かどうか確認してください',
			'k_0000005': '邀请メンバーを翻訳します',
			'k_0000006': '自分',
			'k_0000007': 'マイク',
			'k_0000008': '通話終了',
			'k_0000009': 'スピーカー',
			'k_0000010': 'イヤホン',
			'k_0000011': 'カメラ',
			'k_0000012': '音声通話に切り替えます',
			'k_0000013': '応答',
			'k_0000014': '最大人数を超えました',
			'k_0000015': '通話拒否',
			'k_0000016': '呼び出しタイムアウト',
			'k_0000017': '相手が通話中です',
			'k_0000018': '通話を終了します',
			'k_0000019': 'TRTC',
			'k_0000020': 'ユーザーID',
			'k_0000021': 'ログイン',
			'k_0000022': 'クイックアクセス',
			'k_0000023': 'パッケージの購入',
			'k_0000024': 'クイックアクセス',
			'k_0000025': 'API ドキュメント',
			'k_0000026': 'よくある問題',
			'k_0000027': '1v1通話',
			'k_0000028': 'グループ通話',
			'k_0000029': 'メディアタイプ',
			'k_0000030': 'ビデオ通話',
			'k_0000031': '音声通話',
			'k_0000032': '通話設定',
			'k_0000033': '通話を開始',
			'k_0000034': 'グループID',
			'k_0000035': 'グループ通話に参加する',
			'k_0000036': 'ルームID（番号）',
			'k_0000037': 'ルームID（文字列）',
			'k_0000038': '1V1通话',
			'k_0000039': 'プロフィール画像',
			'k_0000040': 'ニックネーム',
			'k_0000041': 'ミュートモード',
			'k_0000042': 'フローティングウィンドウの表示',
			'k_0000043': '通話パラメータの設定',
			'k_0000044': 'コールウェイティングのタイムアウト時間を設定してください',
			'k_0000045': '拡張情報',
			'k_0000046': 'オフラインメッセージ',
			'k_0000047': 'ビデオ設定',
			'k_0000048': '解像度',
			'k_0000049': '縦横画面',
			'k_0000050': '横画面',
			'k_0000051': '縦画面',
			'k_0000052': '塗りつぶしパターン',
			'k_0000053': '塗りつぶし',
			'k_0000054': 'フィット',
			'k_0000055': '回転角度',
			'k_0000056': '美顔のレベル',
			'k_0000057': '未設定',
			'k_0000058': '設定に移動',
			'k_0000059': '入ってください',
			'k_0000060': 'プロフィール画像とユーザー名を入力してください',
			'k_0000061': '拡張情報',
			'k_0000062': 'オフライン メッセージ情報の json 文字列を入力してください',
			'k_0000063': '携帯電話番号/ユーザーIDを入力してください',
			'k_0000064': 'グループIDを入力してください',
			'k_0000065': 'ユーザー ID を区切るにはカンマを使用します',
			'k_0000066': 'ルームIDを入力してください',
			'k_0000067': '注: TUICallKit はオフライン通話をサポートし、Android、iOS、Web、Flutter などの複数のプラットフォームをサポートします。',
			'k_0000068': 'ニックネーム',
			'k_0000069': 'ログインに失敗しました。すべての機能が使用できません',
			'k_0000070': 'OK',
			'k_0000071': 'OK',
			'k_0000072': 'キャンセル',
			'k_0000073': 'TRTC',
			'k_0000074': 'ログアウト',
			'k_0000075': 'ユーザーIDを入力してください',
			'k_0000076': 'ユーザーID一覧',
			'k_0000077': '相手が切断、通話終了',
			'k_0000078': '相手による通話拒否',
			'k_0000079': '相手が通話中です',
			'k_0000080': '呼び出しタイムアウト',
			'k_0000081': 'は通話を拒否しました',
			'k_0000082': '通話終了',
			'k_0000083': '匿名',
			'k_0000084': 'マイクへのアクセス許可を申請します。',
			'k_0000085': 'マイクとカメラの許可を申請する',
			'k_0000086': 'マイクへのアクセス許可が必要で、音声/ビデオ通話、グループ音声/ビデオ通話などの機能に使用できます。マイクをオンにした場合のみ、録画した動画に音声が保存されます。',
			'k_0000087': 'カメラへのアクセス許可が必要で、ビデオ通話、グループビデオ通話などの機能に使用できます。美顔機能を使用する場合は、カメラで撮影された映像から顔の特徴点情報をリアルタイムで収集し、より自然な美しさを提供します。',
			'k_0000088': '応答を待っています',
			'k_0000089': 'バックグラウンドポップアップインターフェースを有効にし、同時にフローティングウィンドウ権限を表示してください。',
			'k_0000090': '新しい電話があります',
			'k_0000091': 'マイクオン',
			'k_0000092': 'マイクがオフ',
			'k_0000093': 'スピーカーオン',
			'k_0000094': 'スピーカーオフ',
			'k_0000095': 'カメラオン',
			'k_0000096': 'カメラオフ',
			'k_0000097': '接続済み',
			'k_0000098': '彼らもそこにいる',
			'k_0000099': '参加する',
			'k_0000100': '人が通話中です',
			'k_0000101': 'カメラの切り替え',
			'k_0000102': '背景をぼかす',
			'k_0000103': '背景をぼかす',
			'k_0000104': '相手のネットワーク接続が不安定です',
			'k_0000105': 'ネットワーク接続が不安定です',
			'k_0000106': 'ユーザーはブラックリストに登録され、通話が開始できませんでした。',
		};
	}
}

extension on _StringsZhHans {
	Map<String, dynamic> _buildFlatMap() {
		return <String, dynamic>{
			'k_0000001': '等待对方接受邀请',
			'k_0000002': '邀请你进行语音通话',
			'k_0000002_1': '邀请你进行视频通话',
			'k_0000003': '邀请你进行多人通话',
			'k_0000004': '新通话呼入，但因权限不足，无法接听。请确认摄像头/麦克风权限已开启。',
			'k_0000005': '邀请成员',
			'k_0000006': '你',
			'k_0000007': '麦克风',
			'k_0000008': '挂断',
			'k_0000009': '扬声器',
			'k_0000010': '听筒',
			'k_0000011': '摄像头',
			'k_0000012': '切到语音通话',
			'k_0000013': '接听',
			'k_0000014': '超过最大人数限制',
			'k_0000015': '拒绝通话',
			'k_0000016': '未响应',
			'k_0000017': '忙线',
			'k_0000018': '离开通话',
			'k_0000019': '腾讯云音视频',
			'k_0000020': '用户ID',
			'k_0000021': '登录',
			'k_0000022': '快速访问',
			'k_0000023': '套餐购买',
			'k_0000024': '快速接入',
			'k_0000025': 'API文档',
			'k_0000026': '常见问题',
			'k_0000027': '单人通话',
			'k_0000028': '群组通话',
			'k_0000029': '媒体类型',
			'k_0000030': '视频通话',
			'k_0000031': '语音通话',
			'k_0000032': '通话设置',
			'k_0000033': '发起通话',
			'k_0000034': '群组ID',
			'k_0000035': '加入群组通话',
			'k_0000036': '数字房间号',
			'k_0000037': '字符串房间号',
			'k_0000038': '1V1通话',
			'k_0000039': '头像',
			'k_0000040': '昵称',
			'k_0000041': '静音模式',
			'k_0000042': '显示悬浮窗按钮',
			'k_0000043': '通话自定义参数设置',
			'k_0000044': '呼叫超时时常',
			'k_0000045': '扩展信息',
			'k_0000046': '离线推送消息',
			'k_0000047': '视频设置',
			'k_0000048': '分辨率',
			'k_0000049': '横竖屏',
			'k_0000050': '横屏',
			'k_0000051': '竖屏',
			'k_0000052': '填充模式',
			'k_0000053': '充满',
			'k_0000054': '自适应',
			'k_0000055': '旋转角度',
			'k_0000056': '美颜等级',
			'k_0000057': '未设置',
			'k_0000058': '去设置',
			'k_0000059': '请输入',
			'k_0000060': '头像设置',
			'k_0000061': '扩展信息设置',
			'k_0000062': '离线推送消息设置',
			'k_0000063': '请输入您要呼叫的UserId',
			'k_0000064': '请输入GroupId',
			'k_0000065': '用户ID使用逗号隔开',
			'k_0000066': '请输入RoomId',
			'k_0000067': '注意：TUICallKit支持离线调用，支持Android、iOS、Web、Flutter等多平台',
			'k_0000068': '输入你的用户昵称',
			'k_0000069': '登录失败',
			'k_0000070': '继续',
			'k_0000071': '确定',
			'k_0000072': '取消',
			'k_0000073': '腾讯云',
			'k_0000074': '退出登录',
			'k_0000075': '请输入您的UserId',
			'k_0000076': '用户ID列表',
			'k_0000077': '对方已挂断，通话结束',
			'k_0000078': '对方拒绝了通话请求',
			'k_0000079': '对方忙线',
			'k_0000080': '对方未响应',
			'k_0000081': '拒绝了通话请求',
			'k_0000082': '结束了通话',
			'k_0000083': '匿名',
			'k_0000084': '申请麦克风权限',
			'k_0000085': '申请麦克风、摄像头权限',
			'k_0000086': '需要访问您的麦克风权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。',
			'k_0000087': '需要访问您的麦克风和摄像头权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。',
			'k_0000088': '等待接听',
			'k_0000089': '请同时打开后台弹出界面和显示悬浮窗权限',
			'k_0000090': '您有一个新的通话',
			'k_0000091': '麦克风已开启',
			'k_0000092': '麦克风已关闭',
			'k_0000093': '扬声器已开启',
			'k_0000094': '扬声器已关闭',
			'k_0000095': '摄像头已开启',
			'k_0000096': '摄像头已关闭',
			'k_0000097': '已接通',
			'k_0000098': '他们也在',
			'k_0000099': '加入',
			'k_0000100': '人正在通话',
			'k_0000101': '翻转',
			'k_0000102': '模糊背景',
			'k_0000103': '显示模糊背景按钮',
			'k_0000104': '当前通话对方网络不佳',
			'k_0000105': '当前通话你的网络不佳',
			'k_0000106': '发起通话失败，用户在黑名单中，禁止发起！',
		};
	}
}
