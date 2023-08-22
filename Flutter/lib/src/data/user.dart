import 'package:flutter/cupertino.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';

class User {
  String id = '';
  String avatar = '';
  String nickname = '';
  TUICallRole callRole = TUICallRole.none;
  TUICallStatus callStatus = TUICallStatus.none;
  bool audioAvailable = false;
  bool videoAvailable = false;
  int playOutVolume = 0;
  int viewID = 0;
  var key = GlobalKey();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['avatar'] = avatar;
    data['nickname'] = nickname;
    data['callRole'] = callRole.index;
    data['callStatus'] = callStatus.index;
    data['audioAvailable'] = audioAvailable;
    data['videoAvailable'] = videoAvailable;
    data['playOutVolume'] = playOutVolume;
    data['viewID'] = viewID;
    return data;
  }
}
