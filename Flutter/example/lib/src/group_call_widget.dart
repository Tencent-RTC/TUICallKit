import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tuicall_kit_example/src/join_group_call_widget.dart';
import 'package:tuicall_kit_example/src/settings/settings_config.dart';
import 'package:tuicall_kit_example/src/settings/settings_widget.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
class GroupCallWidget extends StatefulWidget {
  const GroupCallWidget({Key? key}) : super(key: key);

  @override
  State<GroupCallWidget> createState() => _GroupCallWidgetState();
}

class _GroupCallWidgetState extends State<GroupCallWidget> {
  String _groupId = '';
  String _userIDsStr = '';
  List<String> _userIDs = [];
  bool _isAudioCall = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(CallKit_t('群组通话')),
        leading: IconButton(
            onPressed: () => _goBack(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: Stack(
        children: [_getCallParamsWidget(), _getBtnWidget()],
      ),
    );
  }

  _getCallParamsWidget() {
    return Positioned(
        top: 20,
        left: 20,
        width: MediaQuery.of(context).size.width - 40,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('群组ID'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                SizedBox(
                    width: 200,
                    child: TextField(
                        autofocus: true,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: CallKit_t("请输入GroupId"),
                          border: InputBorder.none,
                        ),
                        onChanged: ((value) => _groupId = value)))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('用户ID列表'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                SizedBox(
                    width: 200,
                    child: TextField(
                        autofocus: true,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: CallKit_t('用户ID使用逗号隔开'),
                          border: InputBorder.none,
                        ),
                        onChanged: ((value) => _userIDsStr = value)))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CallKit_t('媒体类型'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                Row(children: [
                  Row(
                    children: [
                      Checkbox(
                        value: !_isAudioCall,
                        onChanged: (value) {
                          setState(() {
                            _isAudioCall = !value!;
                          });
                        },
                        shape: const CircleBorder(),
                      ),
                      Text(
                        CallKit_t('视频通话'),
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAudioCall,
                        onChanged: (value) {
                          setState(() {
                            _isAudioCall = value!;
                          });
                        },
                        shape: const CircleBorder(),
                      ),
                      Text(
                        CallKit_t('语音通话'),
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ])
              ],
            ),
            const SizedBox(height: 50),
            InkWell(
              onTap: () => _goSettings(),
              child: Text(
                '${CallKit_t('通话设置')} >',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff056DF6)),
              ),
            )
          ],
        ));
  }

  _getBtnWidget() {
    return Positioned(
        left: 0,
        bottom: 50,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => _joinGroupCall(),
              child: Text(
                CallKit_t('加入群组通话'),
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff056DF6)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 52,
              width: MediaQuery.of(context).size.width * 5 / 6,
              child: ElevatedButton(
                  onPressed: () => _call(),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xff056DF6)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.call),
                      const SizedBox(width: 10),
                      Text(
                        CallKit_t('发起通话'),
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  )),
            ),
          ],
        ));
  }

  _goBack() {
    Navigator.of(context).pop();
  }

  _call() {
    _userIDs = _userIDsStr.split(',');
    TUICallKit.instance.groupCall(
        _groupId,
        _userIDs,
        _isAudioCall ? TUICallMediaType.audio : TUICallMediaType.video,
        _createTUICallParams());
  }

  TUICallParams _createTUICallParams() {
    TUICallParams params = TUICallParams();
    if (SettingsConfig.intRoomId != 0) {
      params.roomId = TUIRoomId.intRoomId(intRoomId: SettingsConfig.intRoomId);
    } else if (SettingsConfig.strRoomId.isNotEmpty) {
      params.roomId = TUIRoomId.strRoomId(strRoomId: SettingsConfig.strRoomId);
    }
    params.timeout = SettingsConfig.timeout;
    params.offlinePushInfo = SettingsConfig.offlinePushInfo;
    params.userData = SettingsConfig.extendInfo;
    return params;
  }

  _goSettings() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const SettingsWidget();
      },
    ));
  }

  _joinGroupCall() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const JoinInGroupCallWidget();
      },
    ));
  }
}
