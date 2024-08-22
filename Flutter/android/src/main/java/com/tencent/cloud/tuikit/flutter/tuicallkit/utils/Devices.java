package com.tencent.cloud.tuikit.flutter.tuicallkit.utils;

import android.app.KeyguardManager;
import android.content.Context;
import android.os.Build;
import com.tencent.qcloud.tuicore.util.TUIBuild;

public class Devices {

    static public boolean isScreenLocked(Context context) {
        KeyguardManager keyguardManager = (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);

        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            // >= Android 5.1
            return keyguardManager.isDeviceLocked();
        } else {
            // < Android 5.1
            return keyguardManager.inKeyguardRestrictedInputMode();
        }
    }

}
