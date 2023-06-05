// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:tuicall_kit_example/i18n/strings.g.dart';

String TIM_t(String value){
  final I18nUtils ttBuild = I18nUtils();
  return ttBuild.imt_origin(value);
}

Function TIM_t_para(String template, String value){
  final I18nUtils ttBuild = I18nUtils();
  return ttBuild.imt_para_origin(template, value);
}

class I18nUtils {
  static I18nUtils? _instance;

  I18nUtils._internal([String? language]) {
    _init(language);
  }

  factory I18nUtils([BuildContext? context, String? language]) {
    if (language != null) {
      _instance = I18nUtils._internal(language);
    } else {
      _instance ??= I18nUtils._internal(language);
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
        print("errorInLanguage ${e.toString()}");
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
    return Localizations
        .localeOf(context)
        .languageCode;
  }

  static AppLocale findDeviceLocale([String? locale]) {
    final String? deviceLocale =
        locale ?? WidgetsBinding.instance?.window.locale.toLanguageTag();
    if (deviceLocale != null) {
      final typedLocale = _selectLocale(deviceLocale);
      if (typedLocale != null) {
        return typedLocale;
      }
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
                (supported) =>
            supported?.languageTag.startsWith(language) == true,
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
  final zhJson ='''{
  "k_1fdhj9g": "TUICallKit 示例工程",
  "k_06pujtm": "TUICallKit是腾讯云推出的音视频通话UI组件。",
  "k_05nspni": "集成这个组件，写几行代码就可以使用视频通话功能。",
  "k_03fchyy": "注意：TUICallKit支持离线调用，支持Android、iOS、Web、Flutter等多平台",
  "k_03i9mfe": "输入User ID",
  "k_03agq58": "登录失败",
  "k_039xqny": "继续",
  "k_003tr0a": "登录",
  "k_002wddw": "腾讯云",
  "k_0got6f7": "设置昵称",
  "k_1uaqed6": "输入你的用户昵称",
  "k_0z2z7rx": "确定",
  "k_0y39ngu": "昵称",
  "k_0y1a2my": "输入用户ID",
  "k_0z4fib8": "语音通话",
  "k_0y24mcg": "视频通话",
  "k_0pewpd1": "群组通话",
  "k_13s8d9p": "输入群组ID",
  "k_003qkx2": "输入用户ID"}''';
}
