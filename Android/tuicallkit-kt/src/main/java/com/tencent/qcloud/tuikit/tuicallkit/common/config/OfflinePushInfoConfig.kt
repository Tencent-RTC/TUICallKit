package com.tencent.qcloud.tuikit.tuicallkit.common.config

import android.content.Context
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.OfflinePushInfo
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuikit.tuicallkit.R

object OfflinePushInfoConfig {
    fun createOfflinePushInfo(context: Context): OfflinePushInfo {
        val pushInfo = OfflinePushInfo()
        pushInfo.title = if (TUILogin.getNickName().isNullOrEmpty()) TUILogin.getLoginUser() else TUILogin.getNickName()
        pushInfo.desc = context.getString(R.string.tuicallkit_have_a_new_call)
        //OPPO must set a ChannelID to receive push messages. If you set it on the console, you don't need set here.
        //pushInfo.androidOPPOChannelID = "tuikit"
        pushInfo.isIgnoreIOSBadge = false
        pushInfo.iosSound = "phone_ringing.mp3"
        pushInfo.androidSound = "phone_ringing"
        //FCM channel ID, If you set it on the console, you don't need set here.
        //pushInfo.androidFCMChannelID = "fcm_push_channel"
        //HuaWei message type: https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/message-classification-0000001149358835
        pushInfo.androidHuaWeiCategory = "IM"
        //IOS push type, if you want use VoIP, please modify type to TUICallDefine.IOSOfflinePushType.VoIP
        pushInfo.iosPushType = TUICallDefine.IOSOfflinePushType.APNs
        return pushInfo
    }
}