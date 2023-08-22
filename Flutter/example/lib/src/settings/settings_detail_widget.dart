import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tuicall_kit_example/src/settings/settings_config.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';

enum SettingWidgetType {
  avatar,
  extendInfo,
  offlinePush,
}

class SettingsDetailWidget extends StatefulWidget {
  final SettingWidgetType widgetType;

  const SettingsDetailWidget({Key? key, required this.widgetType}) : super(key: key);

  @override
  State<SettingsDetailWidget> createState() => _SettingsDetailWidgetState();
}

class _SettingsDetailWidgetState extends State<SettingsDetailWidget> {
  String _data = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_getTitle()),
          leading: IconButton(
              onPressed: _goBack,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.control_point_sharp),
              tooltip: 'Search',
              onPressed: () => _setData(),
            ),
          ],
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: TextField(
              autofocus: true,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintText: CallKit_t('请输入'),
                border: InputBorder.none,
              ),
              onChanged: (value) => _data = value),
        ));
  }

  _getTitle() {
    switch (widget.widgetType) {
      case SettingWidgetType.avatar:
        return CallKit_t('头像设置');
      case SettingWidgetType.extendInfo:
        return CallKit_t('扩展信息设置');
      case SettingWidgetType.offlinePush:
        return CallKit_t('离线推送消息设置');
    }
  }

  _setData() {
    switch (widget.widgetType) {
      case SettingWidgetType.avatar:
        SettingsConfig.avatar = _data;
        TUICallKit.instance.setSelfInfo(SettingsConfig.nickname, SettingsConfig.avatar);
        break;
      case SettingWidgetType.extendInfo:
        SettingsConfig.extendInfo = _data;
        break;
      case SettingWidgetType.offlinePush:
        _setOfflinePushInfo();
        break;
    }
  }

  _setOfflinePushInfo() {
    Map offlinePushMap = json.decode(_data);

    if (offlinePushMap['title'].isNull) {
      SettingsConfig.offlinePushInfo?.title = offlinePushMap['title'];
    }

    if (offlinePushMap['desc'].isNull) {
      SettingsConfig.offlinePushInfo?.desc = offlinePushMap['desc'];
    }

    if (offlinePushMap['ignoreIOSBadge'].isNull) {
      SettingsConfig.offlinePushInfo?.ignoreIOSBadge = offlinePushMap['ignoreIOSBadge'];
    }

    if (offlinePushMap['iOSSound'].isNull) {
      SettingsConfig.offlinePushInfo?.iOSSound = offlinePushMap['iOSSound'];
    }

    if (offlinePushMap['androidSound'].isNull) {
      SettingsConfig.offlinePushInfo?.androidSound = offlinePushMap['androidSound'];
    }

    if (offlinePushMap['androidOPPOChannelID'].isNull) {
      SettingsConfig.offlinePushInfo?.androidOPPOChannelID = offlinePushMap['androidOPPOChannelID'];
    }

    if (offlinePushMap['androidVIVOClassification'].isNull) {
      SettingsConfig.offlinePushInfo?.androidVIVOClassification = offlinePushMap['androidVIVOClassification'];
    }

    if (offlinePushMap['androidXiaoMiChannelID'].isNull) {
      SettingsConfig.offlinePushInfo?.androidXiaoMiChannelID = offlinePushMap['androidXiaoMiChannelID'];
    }

    if (offlinePushMap['androidFCMChannelID'].isNull) {
      SettingsConfig.offlinePushInfo?.androidXiaoMiChannelID = offlinePushMap['androidFCMChannelID'];
    }

    if (offlinePushMap['androidHuaWeiCategory'].isNull) {
      SettingsConfig.offlinePushInfo?.androidXiaoMiChannelID = offlinePushMap['androidHuaWeiCategory'];
    }

    if (offlinePushMap['isDisablePush'].isNull) {
      SettingsConfig.offlinePushInfo?.isDisablePush = offlinePushMap['isDisablePush'];
    }

    if (offlinePushMap['iOSPushType'].isNull) {
      int index = offlinePushMap['iOSPushType'];
      SettingsConfig.offlinePushInfo?.iOSPushType =
          index == 0 ? TUICallIOSOfflinePushType.APNs : TUICallIOSOfflinePushType.VoIP;
    }
  }

  _goBack() {
    Navigator.of(context).pop();
  }
}
