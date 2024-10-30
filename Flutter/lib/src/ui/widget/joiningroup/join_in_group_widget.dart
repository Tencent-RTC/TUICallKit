import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class JoinInGroupWidget extends StatefulWidget {
  final List<String> userIDs;
  final TUIRoomId roomId;
  final TUICallMediaType mediaType;
  final String groupId;

  const JoinInGroupWidget(
      {required this.userIDs,
      required this.roomId,
      required this.mediaType,
      required this.groupId,
      Key? key})
      : super(key: key);

  @override
  State<JoinInGroupWidget> createState() => _JoinInGroupWidgetState();
}

class _JoinInGroupWidgetState extends State<JoinInGroupWidget> {
  bool _isExpand = false;
  final List<String> _userAvatars = [];

  @override
  void initState() {
    super.initState();
    _updateUserAvatars();
  }

  @override
  Widget build(BuildContext context) {
    CallKitI18nUtils.setLanguage(Localizations.localeOf(context));
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: GestureDetector(
            onTap: () => _changeExpand(),
            child: Container(
                width: MediaQuery.of(context).size.width - 10,
                height: _isExpand ? 260 : 40,
                child: Column(
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    Row(
                      children: [
                        const Padding(padding: EdgeInsets.only(left: 15)),
                        Image.asset(
                          'assets/images/join_group_call.png',
                          package: 'tencent_calls_uikit',
                          width: 20,
                          height: 20,
                        ),
                        const Padding(padding: EdgeInsets.only(left: 15)),
                        Text(
                            '${widget.userIDs.length} ${CallKit_t("personIsOnTheCall")}',
                            textScaleFactor: 1.0,
                        ),
                        const Spacer(),
                        Image.asset(
                          _isExpand
                              ? 'assets/images/join_group_compress.png'
                              : 'assets/images/join_group_expand.png',
                          package: 'tencent_calls_uikit',
                        ),
                        const Padding(padding: EdgeInsets.only(left: 15)),
                      ],
                    ),
                    _isExpand ? const Padding(padding: EdgeInsets.only(top: 10)) : const SizedBox(),
                    _isExpand
                        ? Container(
                            width: MediaQuery.of(context).size.width - 30,
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(235, 235, 235, 1.0),
                              borderRadius: BorderRadius.circular(5), // Set the corner radius
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width - 40,
                                    height: 150,
                                    child: Center(
                                        child: ListView.builder(
                                      itemCount: _userAvatars.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 2.5, right: 2.5, top: 35, bottom: 35),
                                            child: Container(
                                              height: 80,
                                              width: 80,
                                              clipBehavior: Clip.hardEdge,
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                              ),
                                              child: Image(
                                                  image: NetworkImage(_userAvatars[index]),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (ctx, err, stackTrace) => ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: Image.asset(
                                                          'assets/images/user_icon.png',
                                                          package: 'tencent_calls_uikit',
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )),
                                            ));
                                      },
                                      padding: EdgeInsets.only(
                                          left: _computeEdge(MediaQuery.of(context).size.width - 40,
                                              85, _userAvatars.length),
                                          right: _computeEdge(
                                              MediaQuery.of(context).size.width - 40,
                                              85,
                                              _userAvatars.length)),
                                    ))),
                                Container(
                                  height: 1,
                                  decoration: const BoxDecoration(
                                    color: Colors.black12,
                                  ),
                                ),
                                InkWell(
                                    onTap: () => _joinInGroupCallAction(),
                                    child: Container(
                                      height: 49,
                                      alignment: Alignment.center,
                                      child: Text(
                                        CallKit_t('joinIn'),
                                        textScaleFactor: 1.0,
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                    ))
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ],
                )
            )
        )
    );
  }

  _computeEdge(double maxWidth, int imageWidth, int count) {
    int maxNeedCompute = maxWidth ~/ imageWidth;
    if (maxNeedCompute >= count) {
      return (maxWidth - imageWidth * count) / 2;
    } else {
      return 0.0;
    }
  }

  _changeExpand() {
    _isExpand = !_isExpand;
    setState(() {});
  }

  _joinInGroupCallAction() {
    CallManager.instance.joinInGroupCall(widget.roomId, widget.groupId, widget.mediaType);
  }

  _updateUserAvatars() async {
    final result = await TencentImSDKPlugin.v2TIMManager.getUsersInfo(userIDList: widget.userIDs);
    for (var userinfo in result.data!) {
      _userAvatars.add(userinfo.faceUrl!);
    }
    setState(() {});
  }
}
