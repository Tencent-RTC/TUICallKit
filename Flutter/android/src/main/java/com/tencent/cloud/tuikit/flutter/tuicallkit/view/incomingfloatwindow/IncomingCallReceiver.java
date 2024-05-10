package com.tencent.cloud.tuikit.flutter.tuicallkit.view.incomingfloatwindow;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Permission;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.WindowManager;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;

import java.util.Objects;

public class IncomingCallReceiver extends BroadcastReceiver {
    private static String TAG = "IncomingCallReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null) {
            TUILog.w(TAG, "intent is invalid,ignore");
            return;
        }

        TUILog.i(TAG, "onReceive: action: "+ intent.getAction());

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
            TUILog.w(TAG, "intent.action is invalid,ignore");
        }
    }
}
