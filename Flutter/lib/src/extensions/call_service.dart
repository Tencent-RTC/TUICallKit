import 'package:tencent_calls_uikit/src/impl/call_state.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

import 'package:tencent_calls_uikit/src/data/offline_push_info.dart';

class CallService extends AbstractTUIService {
  static final CallService _instance = CallService();

  static CallService get instance => _instance;

  @override
  onCall(String serviceName, String method, Map<String, dynamic> param) {
    if (serviceName != TUICALLKIT_SERVICE_NAME) {
      return;
    }

    if (method == METHOD_NAME_ENABLE_FLOAT_WINDOW) {
      final enableFloatWindow = param[PARAM_NAME_ENABLE_FLOAT_WINDOW] as bool;
      TUICallKit.instance.enableFloatWindow(enableFloatWindow);
    } else if (method == METHOD_NAME_CALL) {
      final userIDs = param[PARAM_NAME_USERIDS] as List<String>;
      final groupId = param[PARAM_NAME_GROUPID] as String;

      final mediaTypeString = param[PARAM_NAME_TYPE] as String;
      var mediaType = TUICallMediaType.none;
      if (mediaTypeString == TYPE_AUDIO) {
        mediaType = TUICallMediaType.audio;
      } else if (mediaTypeString == TYPE_VIDEO) {
        mediaType = TUICallMediaType.video;
      }

      if (CallState.instance.forceUseV2API) {
        if (groupId.isEmpty) {
          TUICallKit.instance.call(userIDs.first, mediaType);
        } else {
          TUICallKit.instance.groupCall(groupId, userIDs, mediaType);
        }
      } else {
        var param = TUICallParams();
        param.chatGroupId = groupId;
        param.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo();
        TUICallKit.instance.calls(userIDs, mediaType, param);
      }
    }
  }
}
