// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_print

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
    // Usage：TIM_t_para("已选：{{addType}}",'已选：$addType')(addType: addType)
    final originTemplate = template.replaceAllMapped(
        expForParameterOut, (Match m) => replaceParameterForTemplate(m));
    final originKey = zhMapRevert[originTemplate] ??
        getKeyFromMap(zhMap, originTemplate) ??
        "";
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
    final String deviceLocale =
        locale ?? WidgetsBinding.instance.window.locale.toLanguageTag();

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
          (supported) =>
              supported?.languageTag == localeRaw.replaceAll('_', '-'),
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
  "k_0000001": "正在等待对方接受邀请……",
  "k_0000002": "邀请您进行通话……",
  "k_0000003": "邀请您进行多人通话……",
  "k_0000004": "新通话呼入，但因权限不足，无法接听。请确认摄像头/麦克风权限已开启。",
  "k_0000005": "邀请成员",
  "k_0000006": "你",
  "k_0000007": "麦克风",
  "k_0000008": "挂断",
  "k_0000009": "扬声器",
  "k_0000010": "听筒",
  "k_0000011": "摄像头",
  "k_0000012": "切到语音通话",
  "k_0000013": "接听",
  "k_0000014": "超过最大人数限制",
  "k_0000015": "拒绝通话",
  "k_0000016": "未响应",
  "k_0000017": "忙线",
  "k_0000018": "离开通话",
  "k_0000019": "腾讯云音视频",
  "k_0000020": "用户ID",
  "k_0000021": "登录",
  "k_0000022": "快速访问",
  "k_0000023": "套餐购买",
  "k_0000024": "快速接入",
  "k_0000025": "API文档",
  "k_0000026": "常见问题",
  "k_0000027": "单人通话",
  "k_0000028": "群组通话",
  "k_0000029": "媒体类型",
  "k_0000030": "视频通话",
  "k_0000031": "语音通话",
  "k_0000032": "通话设置",
  "k_0000033": "发起通话",
  "k_0000034": "群组ID",
  "k_0000035": "加入群组通话",
  "k_0000036": "数字房间号",
  "k_0000037": "字符串房间号",
  "k_0000038": "1V1通话",
  "k_0000039": "头像",
  "k_0000040": "昵称",
  "k_0000041": "静音模式",
  "k_0000042": "显示悬浮窗按钮",
  "k_0000043": "通话自定义参数设置",
  "k_0000044": "呼叫超时时常",
  "k_0000045": "扩展信息",
  "k_0000046": "离线推送消息",
  "k_0000047": "视频设置",
  "k_0000048": "分辨率",
  "k_0000049": "横竖屏",
  "k_0000050": "横屏",
  "k_0000051": "竖屏",
  "k_0000052": "填充模式",
  "k_0000053": "充满",
  "k_0000054": "自适应",
  "k_0000055": "旋转角度",
  "k_0000056": "美颜等级",
  "k_0000057": "未设置",
  "k_0000058": "去设置",
  "k_0000059": "请输入",
  "k_0000060": "头像设置",
  "k_0000061": "扩展信息设置",
  "k_0000062": "离线推送消息设置",
  "k_0000063": "请输入您要呼叫的UserId",
  "k_0000064": "请输入GroupId",
  "k_0000065": "用户ID使用逗号隔开",
  "k_0000066": "请输入RoomId",
  "k_0000067": "注意：TUICallKit支持离线调用，支持Android、iOS、Web、Flutter等多平台",
  "k_0000068": "输入你的用户昵称",
  "k_0000069": "登录失败",
  "k_0000070": "继续",
  "k_0000071": "确定",
  "k_0000072": "取消",
  "k_0000073": "腾讯云",
  "k_0000074": "退出登录",
  "k_0000075": "请输入您的UserId",
  "k_0000076": "用户ID列表",
  "k_0000077": "对方已挂断，通话结束",
  "k_0000078": "对方拒绝了通话请求",
  "k_0000079": "对方忙线",
  "k_0000080": "对方未响应",
  "k_0000081": "拒绝了通话请求",
  "k_0000082": "结束了通话",
  "k_0000083": "匿名",
  "k_0000084": "申请麦克风权限",
  "k_0000085": "申请麦克风、摄像头权限",
  "k_0000086": "需要访问您的麦克风权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。",
  "k_0000087": "需要访问您的麦克风和摄像头权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。",
  "k_0000088": "等待接听",
  "k_0000089": "请同时打开后台弹出界面和显示悬浮窗权限",
  "k_0000090": "您有一个新的通话"
  }''';
}
