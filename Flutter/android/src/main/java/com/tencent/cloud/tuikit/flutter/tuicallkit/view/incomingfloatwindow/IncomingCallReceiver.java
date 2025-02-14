package com.tencent.cloud.tuikit.flutter.tuicallkit.view.incomingfloatwindow;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.tencent.cloud.tuikit.engine.call.TUICallEngine;
import com.tencent.cloud.tuikit.flutter.tuicallkit.TUICallKitPlugin;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Logger;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Permission;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.WindowManager;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;

import java.util.Objects;

public class IncomingCallReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null) {
            Logger.warning(TUICallKitPlugin.TAG, "intent is invalid,ignore");
            return;
        }

        Logger.info(TUICallKitPlugin.TAG, "onReceive: action: " + intent.getAction());

        if (Objects.equals(intent.getAction(), Constants.SUB_KEY_HANDLE_CALL_RECEIVED)) {
            IncomingNotificationView.getInstance(context).cancelNotification();
            TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
        } else if (Objects.equals(intent.getAction(), Constants.ACCEPT_CALL_ACTION)) {
            TUICallEngine.createInstance(context).accept(null);
            IncomingNotificationView.getInstance(context).cancelNotification();
            TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
        } else if (Objects.equals(intent.getAction(), Constants.REJECT_CALL_ACTION)) {
            TUICallEngine.createInstance(context).reject(null);
            IncomingNotificationView.getInstance(context).cancelNotification();
        } else {
            Logger.warning(TUICallKitPlugin.TAG, "intent.action is invalid,ignore");
        }
    }
}
