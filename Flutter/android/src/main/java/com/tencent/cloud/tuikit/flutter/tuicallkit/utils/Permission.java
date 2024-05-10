package com.tencent.cloud.tuikit.flutter.tuicallkit.utils;

import android.app.AppOpsManager;
import android.app.NotificationManager;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.os.Build;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

public class Permission {
    public static boolean hasPermission(String premission) {
        return PermissionRequester.newInstance(premission).has();
    }

    public static void requestFloatPermission() {
        if (PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()) {
            return;
        }
        //In TUICallKit,Please open both OverlayWindows and Background pop-ups permission.
        PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION, PermissionRequester.BG_START_PERMISSION)
                .request();
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
