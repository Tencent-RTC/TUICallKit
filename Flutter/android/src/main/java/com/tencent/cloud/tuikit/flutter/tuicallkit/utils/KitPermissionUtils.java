package com.tencent.cloud.tuikit.flutter.tuicallkit.utils;

import android.app.AppOpsManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Binder;
import android.os.Build;
import android.provider.Settings;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.flutter.tuicallkit.R;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.TUICallState;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicallengine.utils.BrandUtils;

import java.lang.reflect.Method;

public class KitPermissionUtils {
    public static boolean hasPermission(Context context) {
        if (BrandUtils.isBrandXiaoMi()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                return Settings.canDrawOverlays(context);
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                return isXiaomiBgStartPermissionAllowed(context);
            }
            return true;
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                return Settings.canDrawOverlays(context);
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                return hasPermissionBelowMarshmallow(context);
            }
            return true;
        }
    }

    public static void requestFloatPermission(Context context) {
        if (KitPermissionUtils.hasPermission(context)) {
            return;
        }
        if (BrandUtils.isBrandXiaoMi()) {
            startXiaomiPermissionSettings(context);
        } else {
            startCommonSettings(context);
        }
    }

    private static boolean isXiaomiBgStartPermissionAllowed(Context context) {
        try {
            AppOpsManager appOpsManager = null;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
                appOpsManager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
            }
            if (appOpsManager == null) {
                return false;
            }
            int op = 10021;
            Method method = appOpsManager.getClass().getMethod("checkOpNoThrow",
                    new Class[]{int.class, int.class, String.class});
            method.setAccessible(true);
            int result = (int) method.invoke(appOpsManager, op, android.os.Process.myUid(), context.getPackageName());
            return AppOpsManager.MODE_ALLOWED == result;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private static boolean hasPermissionBelowMarshmallow(Context context) {
        try {
            AppOpsManager manager = null;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
                manager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
            }
            if (manager == null) {
                return false;
            }
            Method dispatchMethod = AppOpsManager.class.getMethod("checkOp", int.class, int.class, String.class);
            return AppOpsManager.MODE_ALLOWED == (Integer) dispatchMethod.invoke(
                    manager, 24, Binder.getCallingUid(), context.getApplicationContext().getPackageName());
        } catch (Exception e) {
            return false;
        }
    }

    private static void startXiaomiPermissionSettings(Context context) {
        if (!isMiuiOptimization()) {
            startCommonSettings(context);
            return;
        }

        try {
            Intent intent = new Intent("miui.intent.action.APP_PERM_EDITOR");
            intent.setClassName("com.miui.securitycenter",
                    "com.miui.permcenter.permissions.PermissionsEditorActivity");
            intent.putExtra("extra_pkgname", context.getPackageName());
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);

            ToastUtil.toastLongMessage((String) TUICallState.getInstance().mResourceMap.get("k_0000089"));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static boolean isMiuiOptimization() {
        String miuiOptimization = "";
        try {
            Class systemProperties = Class.forName("android.os.systemProperties");
            Method get = systemProperties.getDeclaredMethod("get", String.class, String.class);
            miuiOptimization = (String) get.invoke(systemProperties, "persist.sys.miuiOptimization", "");
            //The user has not adjusted the MIUI-optimization switch (default) | user open MIUI-optimization
            return TextUtils.isEmpty(miuiOptimization) | "true".equals(miuiOptimization);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return true;
    }


    private static void startCommonSettings(Context context) {
        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
                intent.setData(Uri.parse("package:" + context.getPackageName()));
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
