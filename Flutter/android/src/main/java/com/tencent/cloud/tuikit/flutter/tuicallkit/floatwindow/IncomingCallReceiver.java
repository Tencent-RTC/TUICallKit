package com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitPermissionUtils;
import com.tencent.cloud.tuikit.tuicall_engine.utils.Logger;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;

public class IncomingCallReceiver extends BroadcastReceiver {
    private static String TAG = "IncomingCallReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null) {
            TUILog.w(TAG, "intent is invalid,ignore");
        }

        TUILog.i(TAG, "onReceive: action: "+ intent.getAction());

        if (intent.getAction().equals(Constants.SUB_KEY_HANDLE_CALL_RECEIVED)) {
            if (KitPermissionUtils.hasPermission(PermissionRequester.BG_START_PERMISSION)) {
                Intent intentLaunchMain = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
                if (intentLaunchMain != null) {
                    intentLaunchMain.putExtra("show_in_foreground", true);
                    intentLaunchMain.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(intentLaunchMain);
                    TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
                } else {
                    Logger.error(TAG, "Failed to get launch intent for package: " + context.getPackageName());
                }
            } else {
                TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
            }
        } else if (intent.getAction().equals(Constants.ACCEPT_CALL_ACTION)) {
            TUICallEngine.createInstance(context).accept(null);
            if (KitPermissionUtils.hasPermission(PermissionRequester.BG_START_PERMISSION)) {
                Intent intentLaunchMain = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
                if (intentLaunchMain != null) {
                    intentLaunchMain.putExtra("show_in_foreground", true);
                    intentLaunchMain.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(intentLaunchMain);
                    TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
                } else {
                    Logger.error(TAG, "Failed to get launch intent for package: " + context.getPackageName());
                }
            } else {
                TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
            }
        } else if (intent.getAction().equals(Constants.REJECT_CALL_ACTION)) {
            TUICallEngine.createInstance(context).reject(null);
        } else {
            TUILog.w(TAG, "intent.action is invalid,ignore");
        }
    }
}
