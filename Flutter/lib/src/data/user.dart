import 'package:flutter/cupertino.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';

class User {
  String id = '';
  String avatar = '';
  String nickname = '';
  String remark = '';
  TUICallRole callRole = TUICallRole.none;
  TUICallStatus callStatus = TUICallStatus.none;
  bool audioAvailable = false;
  bool videoAvailable = false;
  int playOutVolume = 0;
  int viewID = 0;
  bool networkQualityReminder = false;
  var key = GlobalKey();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['avatar'] = avatar;
    data['nickname'] = nickname;
    data['remark'] = remark;
    data['callRole'] = callRole.index;
    data['callStatus'] = callStatus.index;
    data['audioAvailable'] = audioAvailable;
    data['videoAvailable'] = videoAvailable;
    data['playOutVolume'] = playOutVolume;
    data['viewID'] = viewID;
    data['networkQualityReminder'] = networkQualityReminder;
    return data;
  }

  static String getUserDisplayName(User user) {
    if (user.remark.isNotEmpty) {
      return user.remark;
    }
    if (user.nickname.isNotEmpty) {
      return user.nickname;
    }
    return user.id;
  }
}
