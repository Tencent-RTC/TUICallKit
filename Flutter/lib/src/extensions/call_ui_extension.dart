import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:tencent_calls_uikit/src/call_define.dart';
import 'package:tencent_calls_uikit/src/ui/widget/joiningroup/join_in_group_widget.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class CallUIExtension extends AbstractTUIExtension {
  static final CallUIExtension _instance = CallUIExtension();

  static CallUIExtension get instance => _instance;

  @override
  Future<Widget> onRaiseExtension(TUIExtensionID extensionID, Map<String, dynamic> param) {
    if (extensionID == TUIExtensionID.joinInGroup) {
      return _getGroupAttributes(param).catchError((error, stackTrace) {
        print("onRaiseExtension error: $error");
      });
    }

    return Future<Widget>.value(const SizedBox());
  }

  Future<Widget> _getGroupAttributes(Map<String, dynamic> param) async {
    String groupId = param[GROUP_ID];
    if (groupId.isEmpty) {
      return Future<Widget>.value(const SizedBox());
    }

    final resultMap = await TencentImSDKPlugin.v2TIMManager.v2TIMGroupManager
        .getGroupAttributes(groupID: groupId);

    if (resultMap.data == null || !resultMap.data!.containsKey('inner_attr_kit_info')) {
      return Future<Widget>.value(const SizedBox());
    }

    final groupAttAryString = resultMap.data!['inner_attr_kit_info'];
    final groupAttAryMap = jsonDecode(groupAttAryString!);

    String? callId = groupAttAryMap['call_id'];
    final businessType = groupAttAryMap['business_type'];
    final roomIDValue = groupAttAryMap['room_id'];
    final roomIDType = groupAttAryMap['room_id_type'];
    final mediaTypeString = groupAttAryMap['call_media_type'];
    final userListMap = List<Map<String, dynamic>>.from(groupAttAryMap['user_list']);

    TUIRoomId? roomId;
    if (roomIDType != null && roomIDValue != null) {
      if (roomIDType == 1 || roomIDType == 0) {
        roomId = TUIRoomId.intRoomId(intRoomId: int.parse(roomIDValue));
      } else {
        roomId = TUIRoomId.strRoomId(strRoomId: roomIDValue);
      }
    }

    TUICallMediaType mediaType;
    if (mediaTypeString == 'audio') {
      mediaType = TUICallMediaType.audio;
    } else {
      mediaType = TUICallMediaType.video;
    }

    List<String> userIds = [];
    for (var user in userListMap) {
      userIds.add(user['userid'] as String);
    }

    if (businessType != 'callkit' ||
        userIds.length <= 1 ||
        mediaTypeString.isEmpty) {
      return Future<Widget>.value(const SizedBox());
    }

    return JoinInGroupWidget(
        userIDs: userIds, roomId: roomId, mediaType: mediaType, groupId: groupId, callId: callId,);
  }
}
