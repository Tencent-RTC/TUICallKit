import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';

class OfflinePushInfoConfig {
  static TUIOfflinePushInfo createOfflinePushInfo() {
    TUIOfflinePushInfo pushInfo = TUIOfflinePushInfo();
    pushInfo.title = CallState.instance.selfUser.nickname.isEmpty
        ? CallState.instance.selfUser.id
        : CallState.instance.selfUser.nickname;
    pushInfo.desc = CallKit_t("您有一个新的通话");
    // OPPO必须设置ChannelID才可以收到推送消息，如果在控制台已经配置,代码中无需调用
    // OPPO must set a ChannelID to receive push messages. If you set it on the console, you don't need set here.
    // pushInfo.setAndroidOPPOChannelID("tuikit");
    pushInfo.ignoreIOSBadge = false;
    pushInfo.iOSSound = "phone_ringing.mp3";
    pushInfo.androidSound = "phone_ringing";
    //VIVO message type: 0-push message, 1-System message(have a higher delivery rate)
    pushInfo.androidVIVOClassification = 1;
    //FCM channel ID, you need change PrivateConstants.java and set "fcmPushChannelId",
    //If you set it on the console, you don't need set here.
    //pushInfo.setAndroidFCMChannelID("fcm_push_channel");
    //HuaWei message type: https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/message-classification-0000001149358835
    pushInfo.androidHuaWeiCategory = "IM";
    //IOS push type: if you want user VoIP, please modify type to TUICallDefine.IOSOfflinePushType.VoIP
    pushInfo.iOSPushType = TUICallIOSOfflinePushType.APNs;
    return pushInfo;
  }
}
