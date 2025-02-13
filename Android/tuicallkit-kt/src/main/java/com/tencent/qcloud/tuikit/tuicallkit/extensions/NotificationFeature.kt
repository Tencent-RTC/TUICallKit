package com.tencent.qcloud.tuikit.tuicallkit.extensions

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationChannelGroup
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import com.tencent.qcloud.tuikit.tuicallkit.R

class NotificationFeature {
    private val channelGroupId = "callKitChannelGroupId"

    fun createCallNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channelGroupName = context.getString(R.string.tuicallkit_notification_channel_group_id)
            val channelGroup = NotificationChannelGroup(channelGroupId, channelGroupName)
            nm.createNotificationChannelGroup(channelGroup)

            val channelName = context.getString(R.string.tuicallkit_notification_channel_id)
            val channel =
                NotificationChannel(CALL_CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_HIGH)
            channel.group = channelGroupId
            channel.enableLights(true)
            channel.enableVibration(true)
            channel.setShowBadge(true)
            channel.setSound(null, null)
            channel.setBypassDnd(true)
            channel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            nm.createNotificationChannel(channel)
        }
    }

    companion object {
        const val CALL_CHANNEL_ID = "CallKitChannelId"
    }
}