// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_print,
// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:tencent_calls_uikit/src/i18n/strings.g.dart';

String CallKit_t(String value) {
  final CallKitI18nUtils ttBuild = CallKitI18nUtils();
  return ttBuild.imt_origin(value);
}

Function CallKit_t_para(String template, String value) {
  final CallKitI18nUtils ttBuild = CallKitI18nUtils();
  return ttBuild.imt_para_origin(template, value);
}

class CallKitI18nUtils {
  static CallKitI18nUtils? _instance;

  static setLanguage(Locale currentLocale) {
    switch (currentLocale.languageCode) {
      case 'zh':
        {
          CallKitI18nUtils(null, 'zh');
          break;
        }
      case 'en':
        {
          CallKitI18nUtils(null, 'en');
          break;
        }
      case 'ja':
        {
          CallKitI18nUtils(null, 'ja');
          break;
        }
    }
  }

  CallKitI18nUtils._internal([String? language]) {
    _init(language);
  }

  factory CallKitI18nUtils([BuildContext? context, String? language]) {
    if (language != null) {
      _instance = CallKitI18nUtils._internal(language);
    } else {
      _instance ??= CallKitI18nUtils._internal(language);
    }
    return _instance!;
  }

  Map<String, dynamic> zhMap = {};
  Map zhMapRevert = {};
  RegExp expForParameterOut = RegExp(r"{{[^]+}}");
  RegExp expForParameter = RegExp(r"(?:\{{)[^}]*(?=\}})");
  late final t;

  void _init([String? language]) {
    if (language != null) {
      t = findDeviceLocale(language).build();
    } else {
      try {
        t = findDeviceLocale().build();
      } catch (e) {
        t = AppLocale.en.build();
        debugPrint("errorInLanguage ${e.toString()}");
      }
    }
    zhMap = jsonDecode(zhJson);
    zhMapRevert = revertMap(zhMap);
  }

  // Usage update: using `TIM_t` directly instead of `ttBuild.imt`
  String imt_origin(String value) {
    String currentKey = zhMapRevert[value] ?? getKeyFromMap(zhMap, value) ?? "";
    String translatedValue = t[currentKey] ?? value;
    return translatedValue;
  }

  // Usage update: using `TIM_t_para` directly instead of `ttBuild.imt_para`
  Function imt_para_origin(String template, String value) {
    // Usage：TIM_t_para("selected:{{addType}}",'selected:$addType')(addType: addType)
    final originTemplate =
        template.replaceAllMapped(expForParameterOut, (Match m) => replaceParameterForTemplate(m));
    final originKey = zhMapRevert[originTemplate] ?? getKeyFromMap(zhMap, originTemplate) ?? "";
    final Function translatedValueFunction = t[originKey] ??
        ({
          Object? option1,
          Object? option2,
          Object? option3,
          Object? option4,
          Object? option5,
          Object? option6,
          Object? option7,
          Object? option8,
          Object? option9,
          Object? option10,
          Object? option11,
          Object? option12,
          Object? option13,
          Object? option14,
          Object? option15,
          Object? option16,
          Object? option17,
          Object? option18,
          Object? option19,
          Object? option20,
        }) {
          return value;
        };
    return translatedValueFunction;
  }

  String replaceParameterForTemplate(Match value) {
    final String? parameter = expForParameter.stringMatch(value[0] ?? "");
    return "\$$parameter".replaceAll("{", "");
  }

  static String getKeyFromMap(Map map, String key) {
    String currentKey = "";
    for (String tempKey in map.keys) {
      if (map[tempKey] == key) {
        currentKey = tempKey;
        break;
      }
    }
    return currentKey;
  }

  static Map revertMap(Map map) {
    final Map<String, String> newMap = {};
    for (String tempKey in map.keys) {
      newMap[map[tempKey]] = tempKey;
    }
    return newMap;
  }

  String getCurrentLanguage(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  static AppLocale findDeviceLocale([String? locale]) {
    final String deviceLocale = locale ?? WidgetsBinding.instance.window.locale.toLanguageTag();

    final typedLocale = _selectLocale(deviceLocale);
    if (typedLocale != null) {
      return typedLocale;
    }

    return AppLocale.en;
  }

  static final _localeRegex =
      RegExp(r'^([a-z]{2,8})?([_-]([A-Za-z]{4}))?([_-]?([A-Z]{2}|[0-9]{3}))?$');

  static AppLocale? _selectLocale(String localeRaw) {
    final match = _localeRegex.firstMatch(localeRaw);
    AppLocale? selected;
    if (match != null) {
      final language = match.group(1);
      final country = match.group(5);
      final script = match.group(3);
      // match exactly
      selected = AppLocale.values.cast<AppLocale?>().firstWhere(
          (supported) => supported?.languageTag == localeRaw.replaceAll('_', '-'),
          orElse: () => null);

      if (selected == null && script != null) {
        // match script
        selected = AppLocale.values.cast<AppLocale?>().firstWhere(
            (supported) => supported?.languageTag.contains(script) == true,
            orElse: () => null);
      }

      if (selected == null && language != null) {
        // match language
        selected = AppLocale.values.cast<AppLocale?>().firstWhere(
            (supported) => supported?.languageTag.startsWith(language) == true,
            orElse: () => null);
      }

      if (selected == null && country != null) {
        // match country
        selected = AppLocale.values.cast<AppLocale?>().firstWhere(
            (supported) => supported?.languageTag.contains(country) == true,
            orElse: () => null);
      }
    }
    return selected;
  }

  // Please do not modify here manually, it will be generated by `scan.js`. Refer to: https://docs.qq.com/doc/DSVN4aHVpZm1CSEhv?u=c927b5c7e9874f77b40b7549f3fffa57
  final zhJson = '''{
    "k_0000001": "waitingForInvitationAcceptance",
    "k_0000002": "invitedToAudioCall",
    "k_0000002_1": "invitedToVideoCall",
    "k_0000003": "invitedToGroupCall",
    "k_0000004": "insufficientPermissions",
    "k_0000005": "inviteMembers",
    "k_0000006": "yourself",
    "k_0000007": "microphone",
    "k_0000008": "hangUp",
    "k_0000009": "speaker",
    "k_0000010": "earpiece",
    "k_0000011": "camera",
    "k_0000012": "switchToVoiceCall",
    "k_0000013": "accept",
    "k_0000014": "exceededMaximumNumber",
    "k_0000015": "reject",
    "k_0000016": "noResponse",
    "k_0000017": "busy",
    "k_0000018": "leave",
    "k_0000019": "realTimeCommunication",
    "k_0000020": "userId",
    "k_0000021": "logIn",
    "k_0000022": "quickAccess",
    "k_0000023": "packagePurchase",
    "k_0000024": "quickAccess",
    "k_0000025": "apiDocumentation",
    "k_0000026": "commonProblem",
    "k_0000027": "singleCall",
    "k_0000028": "groupCall",
    "k_0000029": "mediaType",
    "k_0000030": "videoCall",
    "k_0000031": "voiceCalls",
    "k_0000032": "callSettings",
    "k_0000033": "initiateCall",
    "k_0000034": "groupId",
    "k_0000035": "joinGroupCall",
    "k_0000036": "digitalRoomNumber",
    "k_0000037": "stringRoomNumber",
    "k_0000038": "oneToOneCall",
    "k_0000039": "avatar",
    "k_0000040": "nickName",
    "k_0000041": "silentMode",
    "k_0000042": "showFloatingButton",
    "k_0000043": "callCustomParameterSettings",
    "k_0000044": "callTimeOutOften",
    "k_0000045": "extendedInformation",
    "k_0000046": "offlinePushMessage",
    "k_0000047": "videoSettings",
    "k_0000048": "resolution",
    "k_0000049": "resolutionMode",
    "k_0000050": "horizontalScreen",
    "k_0000051": "verticalScreen",
    "k_0000052": "fillPattern",
    "k_0000053": "fill",
    "k_0000054": "fit",
    "k_0000055": "rotationAngle",
    "k_0000056": "beautyLevel",
    "k_0000057": "notSet",
    "k_0000058": "goToSettings",
    "k_0000059": "pleaseEnter",
    "k_0000060": "avatarSettings",
    "k_0000061": "extendedInformationSettings",
    "k_0000062": "offlinePushMessageSettings",
    "k_0000063": "pleaseEnterUserIdToCall",
    "k_0000064": "pleaseEnterGroupId",
    "k_0000065": "userIdsSeparatedByCommas",
    "k_0000066": "pleaseEnterRoomId",
    "k_0000067": "noteTUICallKitSupportsOfflineCalls",
    "k_0000068": "enterYourUsername",
    "k_0000069": "loginFailed",
    "k_0000070": "continue",
    "k_0000071": "confirm",
    "k_0000072": "cancel",
    "k_0000073": "tencentCloud",
    "k_0000074": "logout",
    "k_0000075": "pleaseEnterYourUserId",
    "k_0000076": "listOfUserIds",
    "k_0000077": "otherPartyHungUp",
    "k_0000078": "otherPartyDeclinedCallRequest",
    "k_0000079": "otherPartyBusy",
    "k_0000080": "otherPartyNoResponse",
    "k_0000081": "callRequestDeclined",
    "k_0000082": "endedTheCall",
    "k_0000083": "anonymity",
    "k_0000084": "applyForMicrophonePermission",
    "k_0000085": "applyForMicrophoneAndCameraPermissions",
    "k_0000086": "needToAccessMicrophonePermission",
    "k_0000087": "needToAccessMicrophoneAndCameraPermissions",
    "k_0000088": "waiting",
    "k_0000089": "displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions",
    "k_0000090": "youHaveANewCall",
    "k_0000091": "microphoneIsOn",
    "k_0000092": "microphoneIsOff",
    "k_0000093": "speakerIsOn",
    "k_0000094": "speakerIsOff",
    "k_0000095": "cameraIsOn",
    "k_0000096": "cameraIsOff",
    "k_0000097": "connected",
    "k_0000098": "theyAreAlsoThere",
    "k_0000099": "joinIn",
    "k_0000100": "personIsOnTheCall",
    "k_0000101": "switchCamera",
    "k_0000102": "blurBackground",
    "k_0000103": "showBlurBackground",
    "k_0000104": "otherPartyNetworkLowQuality",
    "k_0000105": "selfNetworkLowQuality"
  }''';
}
