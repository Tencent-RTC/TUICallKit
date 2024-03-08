package com.tencent.cloud.tuikit.flutter.tuicallkit.utils;

import android.app.ActivityManager;
import android.app.AppOpsManager;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.os.Build;
import android.util.Log;

import com.tencent.cloud.tuikit.flutter.tuicallkit.TUICallKitPlugin;
import com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow.FloatActivity;
import com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow.FloatWindowService;
import com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow.IncomingFloatView;
import com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow.IncomingNotificationView;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.TUICallState;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.User;
import com.tencent.cloud.tuikit.tuicall_engine.utils.Logger;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
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
        if (KitAppUtils.EVENT_START_CALL_PAGE.equals(event)) {
            if (KitPermissionUtils.hasPermission(PermissionRequester.BG_START_PERMISSION)) {
                Intent intent = new Intent(context, FloatActivity.class);
                intent.putExtra(KitAppUtils.EVENT_KEY, event);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
            } else {
                TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_GOTO_CALLING_PAGE, null);
            }
        } else if (KitAppUtils.EVENT_HANDLER_RECEIVE_CALL_REQUEST.equals(event)) {
            User caller = TUICallState.getInstance().mRemoteUserList.get(0);
            if (caller == null) {
                return;
            }
            if (KitPermissionUtils.hasPermission(PermissionRequester.FLOAT_PERMISSION)) {
                Logger.info(TUICallKitPlugin.TAG, "App in background, will open IncomingFloatView");

                IncomingFloatView floatView = new IncomingFloatView(context);
                TUICallState.getInstance().mIncomingFloatView = floatView;
                floatView.showIncomingView(caller, TUICallState.getInstance().mMediaType);
            } else if (isNotificationEnabled()) {
                Logger.info(TUICallKitPlugin.TAG, "App in background, will open IncomingNotificationView");

                IncomingNotificationView.getInstance(context).showNotification(caller, TUICallState.getInstance().mMediaType);
            } else if (KitPermissionUtils.hasPermission(PermissionRequester.BG_START_PERMISSION)) {
                Logger.info(TUICallKitPlugin.TAG, "App in background, try to launch intent");

                Intent intentLaunchMain = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
                if (intentLaunchMain != null) {
                    intentLaunchMain.putExtra("show_in_foreground", true);
                    intentLaunchMain.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(intentLaunchMain);
                    TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
                } else {
                    Logger.error(TUICallKitPlugin.TAG, "Failed to get launch intent for package: " + context.getPackageName());
                }
            } else {
                Logger.info(TUICallKitPlugin.TAG, "App in background, no permissions");
                TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
            }
        }
    }

    public static boolean isNotificationEnabled() {
        Context context = TUIConfig.getAppContext();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // For Android Oreo and above
            NotificationManager manager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            return manager.areNotificationsEnabled();
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            // For versions prior to Android Oreo
            AppOpsManager appOps = null;
            appOps = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
            ApplicationInfo appInfo = context.getApplicationInfo();
            String packageName = context.getApplicationContext().getPackageName();
            int uid = appInfo.uid;
            try {
                Class<?> appOpsClass = null;
                appOpsClass = Class.forName(AppOpsManager.class.getName());
                Method checkOpNoThrowMethod = appOpsClass.getMethod(
                        "checkOpNoThrow", Integer.TYPE, Integer.TYPE, String.class
                );
                Field opPostNotificationValue = appOpsClass.getDeclaredField("OP_POST_NOTIFICATION");
                int value = (int) opPostNotificationValue.get(Integer.class);
                return (int) checkOpNoThrowMethod.invoke(appOps, value, uid, packageName) == AppOpsManager.MODE_ALLOWED;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return false;
    }
}
