import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_member_filter_enum.dart';

class InviteUserWidget extends StatefulWidget {
  const InviteUserWidget({Key? key}) : super(key: key);

  @override
  State<InviteUserWidget> createState() => _InviteUserWidgetState();
}

class _InviteUserWidgetState extends State<InviteUserWidget> {
  final List<GroupMemberInfo> _groupMemberList = [];
  final List<String> _defaultSelectList = [];

  @override
  void initState() {
    super.initState();
    _getGroupMember();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(CallKit_t('inviteMembers')),
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
              onPressed: () => _inviteUser(),
            ),
          ],
        ),
        body: ListView.builder(
            itemCount: _groupMemberList.length,
            itemExtent: 60,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  _selectUser(index);
                },
                child: Row(
                  children: [
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10)),
                    Image.asset(
                      _groupMemberList[index].isSelected
                          ? 'assets/images/check_box_group_selected.png'
                          : 'assets/images/check_box_group_unselected.png',
                      package: 'tencent_calls_uikit',
                      width: 18,
                      height: 18,
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10)),
                    Container(
                      width: 40,
                      height: 40,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Image(
                        image: NetworkImage(_groupMemberList[index].avatar),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stackTrace) => Image.asset(
                          'assets/images/user_icon.png',
                          package: 'tencent_calls_uikit',
                        ),
                      ),
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5)),
                    Text(
                      _getMemberDisPlayName(_groupMemberList[index]),
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    )
                  ],
                ),
              );
            }));
  }

  _getGroupMember() async {
    final imuserInfoBack = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .getGroupMemberList(
            groupID: CallState.instance.groupId,
            filter: GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL,
            nextSeq: '0');
    _groupMemberList.clear();
    if (imuserInfoBack.data == null ||
        imuserInfoBack.data!.memberInfoList == null) {
      return;
    }
    _defaultSelectList.add(CallState.instance.selfUser.id);
    for (User user in CallState.instance.remoteUserList) {
      _defaultSelectList.add(user.id);
    }

    var memberInfo = GroupMemberInfo();
    memberInfo.userId = CallState.instance.selfUser.id;
    memberInfo.userName =
        '${StringStream.makeNull(CallState.instance.selfUser.nickname, CallState.instance.selfUser.id)} (${CallKit_t("yourself")})';
    memberInfo.avatar =
        StringStream.makeNull(CallState.instance.selfUser.avatar, Constants.defaultAvatar);
    memberInfo.isSelected = true;
    _groupMemberList.add(memberInfo);

    for (var imUser in imuserInfoBack.data!.memberInfoList!) {
      if (imUser == null || imUser.userID == CallState.instance.selfUser.id) {
        continue;
      }
      var memberInfo = GroupMemberInfo();
      memberInfo.userId = imUser.userID;
      memberInfo.userName = StringStream.makeNull(imUser.nickName, '');
      memberInfo.remark = StringStream.makeNull(imUser.friendRemark, '');
      memberInfo.avatar = StringStream.makeNull(imUser.faceUrl, Constants.defaultAvatar);
      memberInfo.isSelected = _defaultSelectList.contains(imUser.userID);
      _groupMemberList.add(memberInfo);
    }
    if (mounted) {
      setState(() {});
    }
  }

  _selectUser(int index) {
    if (index == 0) return;
    _groupMemberList[index].isSelected = !_groupMemberList[index].isSelected;
    if (mounted) {
      setState(() {});
    }
  }

  _inviteUser() {
    List<String> userIdList = [];
    for (GroupMemberInfo info in _groupMemberList) {
      if (info.isSelected) {
        userIdList.add(info.userId);
      }
    }
    CallManager.instance.inviteUser(userIdList);
    _goBack();
  }

  _goBack() {
    TUICallKitNavigatorObserver.getInstance().exitInviteUserPage();
  }

  _getMemberDisPlayName(GroupMemberInfo member) {
    if (member.remark.isNotEmpty) {
      return member.remark;
    }
    if (member.userName.isNotEmpty) {
      return member.userName;
    }
    return member.userId;
  }
}

class GroupMemberInfo {
  String userId = "";
  String userName = "";
  String avatar = "";
  String remark = "";
  bool isSelected = false;
}
