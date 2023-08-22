import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tuicall_kit_example/src/settings/settings_config.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tuicall_kit_example/src/settings/settings_detail_widget.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  int _resolutionIndex = SettingsConfig.resolution.index;
  int _resolutionModeIndex = SettingsConfig.resolutionMode.index;
  int _fillModeIndex = SettingsConfig.fillMode.index;
  int _rotationIndex = SettingsConfig.rotation.index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(CallKit_t('通话设置')),
        leading: IconButton(
            onPressed: () => _goBack(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
        child: ListView(
          children: [
            _getBasicSettingsWidget(),
            _getCallParamsSettingsWidget(),
            _getVideoSettingsWidget()
          ],
        ),
      ),
    );
  }

  _getBasicSettingsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: Text(
            CallKit_t('通话设置'),
            style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                color: Colors.black54),
          ),
        ),

        SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              CallKit_t('头像'),
              style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
            InkWell(
                onTap: () => _goDetailSettings(SettingWidgetType.avatar),
                child: Row(children: [
                  SizedBox(
                      width: 200,
                      child: Text(
                        (SettingsConfig.avatar.isEmpty)
                            ? CallKit_t('未设置')
                            : SettingsConfig.avatar,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                        textAlign: TextAlign.right,
                      )),
                  const SizedBox(width: 10),
                  const Text('>')
                ]))
          ],
        )
        ),

        SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              CallKit_t('昵称'),
              style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: TextField(
                    autofocus: true,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: (SettingsConfig.nickname.isEmpty)
                          ? CallKit_t('未设置')
                          : SettingsConfig.nickname,
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      SettingsConfig.nickname = value;
                      TUICallKit.instance.setSelfInfo(
                          SettingsConfig.nickname,
                          SettingsConfig.avatar);
                    }))
          ],
        ),
        ),


        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('静音模式'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                Switch(
                    value: SettingsConfig.muteMode,
                    onChanged: (value) {
                      setState(() {
                        SettingsConfig.muteMode = value;
                        TUICallKit.instance
                            .enableMuteMode(SettingsConfig.muteMode);
                      });
                    })
              ],
            ),
        ),

        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('显示悬浮窗按钮'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                Switch(
                    value: SettingsConfig.enableFloatWindow,
                    onChanged: (value) {
                      setState(() {
                        SettingsConfig.enableFloatWindow = value;
                        TUICallKit.instance
                            .enableFloatWindow(SettingsConfig.enableFloatWindow);
                      });
                    })
              ],
            ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  _getCallParamsSettingsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: Text(
            CallKit_t('通话自定义参数设置'),
            style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                color: Colors.black54),
          ),
        ),

        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('数字房间号'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                        autofocus: true,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: '${SettingsConfig.intRoomId}',
                          border: InputBorder.none,
                        ),
                        onChanged: ((value) =>
                        SettingsConfig.intRoomId = int.parse(value))))
              ],
            ),
        ),

        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('字符串房间号'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                        autofocus: true,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: SettingsConfig.strRoomId,
                          border: InputBorder.none,
                        ),
                        onChanged: ((value) => SettingsConfig.strRoomId = value)))
              ],
            ),
        ),

        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('呼叫超时时常'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                        autofocus: true,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: '${SettingsConfig.timeout}',
                          border: InputBorder.none,
                        ),
                        onChanged: ((value) =>
                        SettingsConfig.timeout = int.parse(value))))
              ],
            ),
        ),

        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('扩展信息'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                InkWell(
                    onTap: () => _goDetailSettings(SettingWidgetType.extendInfo),
                    child: Row(children: [
                      Text(
                        SettingsConfig.extendInfo.isEmpty
                            ? CallKit_t('未设置')
                            : SettingsConfig.extendInfo,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(width: 10),
                      const Text('>')
                    ]))
              ],
            ),
        ),

        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('离线推送消息'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                InkWell(
                    onTap: () => _goDetailSettings(SettingWidgetType.offlinePush),
                    child: Row(children: [
                      Text(
                        SettingsConfig.offlinePushInfo == null ? CallKit_t('未设置') : CallKit_t('去设置'),
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(width: 10),
                      const Text('>')
                    ]))
              ],
            ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  _getVideoSettingsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            height: 40,
            child: Text(
              CallKit_t('视频设置'),
              style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54),
            ),
        ),


        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('分辨率'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                DropdownButton(
                  value: _resolutionIndex,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('640_360')),
                    DropdownMenuItem(value: 1, child: Text('640_480')),
                    DropdownMenuItem(value: 2, child: Text('960_540')),
                    DropdownMenuItem(value: 3, child: Text('960_720')),
                    DropdownMenuItem(value: 4, child: Text('1280_720')),
                    DropdownMenuItem(value: 5, child: Text('1920_1080')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _resolutionIndex = value!;
                      _setResolution();
                    });

                    VideoEncoderParams params = VideoEncoderParams(
                        resolution: SettingsConfig.resolution,
                        resolutionMode: SettingsConfig.resolutionMode);
                    TUICallEngine.instance.setVideoEncoderParams(params);
                  },
                  underline: Container(height: 0),
                ),
              ],
            ),
        ),


        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('横竖屏'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                DropdownButton(
                  value: _resolutionModeIndex,
                  items: [
                    DropdownMenuItem(value: 0, child: Text(CallKit_t('横屏'))),
                    DropdownMenuItem(value: 1, child: Text(CallKit_t('竖屏'))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _resolutionModeIndex = value!;
                      _setResolutionMode();
                    });

                    VideoEncoderParams params = VideoEncoderParams(
                        resolution: SettingsConfig.resolution,
                        resolutionMode: SettingsConfig.resolutionMode);
                    TUICallEngine.instance.setVideoEncoderParams(params);
                  },
                  underline: Container(height: 0),
                ),
              ],
            ),
        ),


        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('填充模式'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                DropdownButton(
                  value: _fillModeIndex,
                  items: [
                    DropdownMenuItem(value: 0, child: Text(CallKit_t('充满'))),
                    DropdownMenuItem(value: 1, child: Text(CallKit_t('自适应'))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _fillModeIndex = value!;
                      _setFillMode();
                    });
                    _setVideoRenderParams();
                  },
                  underline: Container(height: 0),
                ),
              ],
            ),
        ),


        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('旋转角度'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                DropdownButton(
                  value: _rotationIndex,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('0')),
                    DropdownMenuItem(value: 1, child: Text('90')),
                    DropdownMenuItem(value: 2, child: Text('180')),
                    DropdownMenuItem(value: 3, child: Text('270')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _rotationIndex = value!;
                      _setRotation();
                    });
                    _setVideoRenderParams();
                  },
                  underline: Container(height: 0),
                ),
              ],
            ),
        ),


        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('美颜等级'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                        autofocus: true,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: '${SettingsConfig.beautyLevel}',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          SettingsConfig.beautyLevel = double.parse(value);
                          TUICallEngine.instance
                              .setBeautyLevel(SettingsConfig.beautyLevel);
                        }))
              ],
            ),
        ),
      ],
    );
  }

  _goBack() {
    Navigator.of(context).pop();
  }

  _setResolution() {
    switch (_resolutionIndex) {
      case 0:
        SettingsConfig.resolution = Resolution.resolution_640_360;
        break;
      case 1:
        SettingsConfig.resolution = Resolution.resolution_640_480;
        break;
      case 2:
        SettingsConfig.resolution = Resolution.resolution_960_540;
        break;
      case 3:
        SettingsConfig.resolution = Resolution.resolution_960_720;
        break;
      case 4:
        SettingsConfig.resolution = Resolution.resolution_1280_720;
        break;
      case 5:
        SettingsConfig.resolution = Resolution.resolution_1920_1080;
        break;
    }
  }

  _setResolutionMode() {
    switch (_resolutionModeIndex) {
      case 0:
        SettingsConfig.resolutionMode = ResolutionMode.landscape;
        break;
      case 1:
        SettingsConfig.resolutionMode = ResolutionMode.portrait;
        break;
    }
  }

  _setFillMode() {
    switch (_fillModeIndex) {
      case 0:
        SettingsConfig.fillMode = FillMode.fill;
        break;
      case 1:
        SettingsConfig.fillMode = FillMode.fit;
        break;
    }
  }

  _setRotation() {
    switch (_rotationIndex) {
      case 0:
        SettingsConfig.rotation = Rotation.rotation_0;
        break;
      case 1:
        SettingsConfig.rotation = Rotation.rotation_90;
        break;
      case 2:
        SettingsConfig.rotation = Rotation.rotation_180;
        break;
      case 3:
        SettingsConfig.rotation = Rotation.rotation_270;
        break;
    }
  }

  _goDetailSettings(SettingWidgetType widgetType) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return SettingsDetailWidget(widgetType: widgetType);
      },
    ));
  }

  _setVideoRenderParams () {
    final params = VideoRenderParams(fillMode: SettingsConfig.fillMode, rotation: SettingsConfig.rotation);
    TUICallEngine.instance.setVideoRenderParams(CallState.instance.remoteUserList[0].id, params);
  }
}
