import 'package:flutter/material.dart';
import 'package:tuicall_kit_example/generate/app_localizations.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';

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
        title: Text(AppLocalizations.of(context)!.multi_call),
        leading: IconButton(
            onPressed: () => _goBack(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
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
                  AppLocalizations.of(context)!.group_id,
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
                          hintText: AppLocalizations.of(context)!.enter_group_id,
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
                    DropdownMenuItem(
                        value: 0, child: Text(AppLocalizations.of(context)!.digital_room)),
                    DropdownMenuItem(
                        value: 1, child: Text(AppLocalizations.of(context)!.string_room)),
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
                          hintText: AppLocalizations.of(context)!.enter_room_id,
                          border: InputBorder.none,
                        ),
                        onChanged: ((value) => _roomId = value)))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.media_type,
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
                        AppLocalizations.of(context)!.video_call,
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
                        AppLocalizations.of(context)!.voice_call,
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
                    backgroundColor: MaterialStateProperty.all(const Color(0xff056DF6)),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.join_multi_call,
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

    TUICallKit.instance.joinInGroupCall(
        roomId, _groupId, _isAudioCall ? TUICallMediaType.audio : TUICallMediaType.video);
  }
}
