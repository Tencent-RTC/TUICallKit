package com.tencent.cloud.tuikit.flutter.tuicallkit.utils;

import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;

import com.tencent.cloud.tuikit.flutter.tuicallkit.TUICallKitPlugin;
import com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow.FloatActivity;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;

import java.util.List;

public class KitAppUtils {
    public static String EVENT_KEY                          = "event";
    public static String EVENT_START_CALL_PAGE              = "event_start_call_page";
    public static String EVENT_HANDLER_RECEIVE_CALL_REQUEST = "event_handle_receive_call";

    public static boolean isAppInForeground(Context context) {
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningAppProcessInfo> runningAppProcessInfos = activityManager.getRunningAppProcesses();
        if (runningAppProcessInfos == null) {
            return false;
        }
        String packageName = context.getPackageName();
        for (ActivityManager.RunningAppProcessInfo appProcessInfo : runningAppProcessInfos) {
            if (appProcessInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
                    && appProcessInfo.processName.equals(packageName)) {
                return true;
            }
        }
        return false;
    }

    public static void moveAppToForeground(Context context, String event) {
        if (KitPermissionUtils.hasPermission(PermissionRequester.BG_START_PERMISSION)) {
            Intent intent = new Intent(context, FloatActivity.class);
            intent.putExtra(KitAppUtils.EVENT_KEY, event);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
        } else {
            if (KitAppUtils.EVENT_START_CALL_PAGE.equals(event)) {
                TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_GOTO_CALLING_PAGE, null);
            } else if(KitAppUtils.EVENT_HANDLER_RECEIVE_CALL_REQUEST.equals(event)) {
                TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
            }
        }
    }
}
