import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
class JoinInGroupCallWidget extends StatefulWidget {
  const JoinInGroupCallWidget({Key? key}) : super(key: key);

  @override
  State<JoinInGroupCallWidget> createState() => _JoinInGroupCallWidgetState();
}

class _JoinInGroupCallWidgetState extends State<JoinInGroupCallWidget> {
  String _groupId = '';
  String _roomId = '';
  int _roomIdType = 0;
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
                DropdownButton(
                  value: _roomIdType,
                  items: [
                    DropdownMenuItem(value: 0, child: Text(CallKit_t('数字房间号'))),
                    DropdownMenuItem(value: 1, child: Text(CallKit_t('字符串房间号'))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _roomIdType = value!;
                    });
                  },
                  underline: Container(height: 0),
                ),
                SizedBox(
                    width: 200,
                    child: TextField(
                        autofocus: true,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: CallKit_t('请输入RoomId'),
                          border: InputBorder.none,
                        ),
                        onChanged: ((value) => _roomId = value)))
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
                      Text(
                        CallKit_t('加入群组通话'),
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
    TUIRoomId roomId = _roomIdType == 0
        ? TUIRoomId.intRoomId(intRoomId: int.parse(_roomId))
        : TUIRoomId.strRoomId(strRoomId: _roomId);

    TUICallKit.instance.joinInGroupCall(roomId, _groupId,
        _isAudioCall ? TUICallMediaType.audio : TUICallMediaType.video);
  }
}
