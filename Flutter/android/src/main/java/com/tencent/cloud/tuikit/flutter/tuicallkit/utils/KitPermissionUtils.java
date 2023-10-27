package com.tencent.cloud.tuikit.flutter.tuicallkit.utils;

import android.content.Context;

import com.tencent.qcloud.tuicore.permission.PermissionRequester;

public class KitPermissionUtils {
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
}
