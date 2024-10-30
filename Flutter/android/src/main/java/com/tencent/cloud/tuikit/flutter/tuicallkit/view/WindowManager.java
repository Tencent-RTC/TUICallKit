package com.tencent.cloud.tuikit.flutter.tuicallkit.view;

import android.content.Context;
import android.content.Intent;

import com.tencent.cloud.tuikit.flutter.tuicallkit.TUICallKitPlugin;
import com.tencent.cloud.tuikit.flutter.tuicallkit.service.ServiceInitializer;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.TUICallState;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.User;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Devices;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Permission;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.floatwindow.FloatWindowService;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.incomingfloatwindow.IncomingFloatView;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.incomingfloatwindow.IncomingNotificationView;
import com.tencent.cloud.tuikit.tuicall_engine.utils.Logger;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;
import android.os.PowerManager;

public class WindowManager {

    public static boolean showFloatWindow(Context context) {
        if (Permission.hasPermission(PermissionRequester.FLOAT_PERMISSION)) {
            Intent mStartIntent = new Intent(context, FloatWindowService.class);
            context.startService(mStartIntent);
            return true;
        } else {
            Permission.requestFloatPermission();
            return false;
        }
    }

    public static void closeFloatWindow(Context context) {
        Intent mStartIntent = new Intent(context, FloatWindowService.class);
        context.stopService(mStartIntent);
    }

    public static void backCallingPageFromFloatWindow(Context context) {
        if (Permission.hasPermission(PermissionRequester.BG_START_PERMISSION)) {
            launchMainActivity(context);
        }
        TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_GOTO_CALLING_PAGE, null);
    }

    public static void showIncomingBanner(Context context) {
        Logger.info(TUICallKitPlugin.TAG, "Android Native: showIncomingBanner");
        User caller = TUICallState.getInstance().mRemoteUserList.get(0);
        if (caller == null) {
            return;
        }

        if (ServiceInitializer.isAppInForeground(context)) {
            incomingBannerInForeground(context, caller);
        } else {
            incomingBannerInBackground(context, caller);
        }
    }

    public static void openLockScreenApp(Context context) {
        Logger.info(TUICallKitPlugin.TAG, "Android Native: openLockScreenApp ");
        User caller = TUICallState.getInstance().mRemoteUserList.get(0);
        if (caller == null) {
            return;
        }
        turnOnScreen(context);

        if (Devices.isSamsungDevice() && Permission.hasPermission(PermissionRequester.BG_START_PERMISSION)) {
            Logger.info(TUICallKitPlugin.TAG, "Android Native: openLockScreenApp, try to launch MainActivity");
            launchMainActivity(context);
            TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
            return;
        }

        if (!ServiceInitializer.isAppInForeground(context) && isFCMDataNotification() && Permission.isNotificationEnabled()) {
            Logger.info(TUICallKitPlugin.TAG, "Android Native: openLockScreenApp, will open IncomingNotificationView");
            IncomingNotificationView.getInstance(context).showNotification(caller,
                    TUICallState.getInstance().mMediaType);
            return;
        }

        Logger.info(TUICallKitPlugin.TAG, "Android Native: openLockScreenApp, try to launch MainActivity");
        launchMainActivity(context);
        TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
    }

    public static void pullBackgroundApp(Context context) {
        Logger.info(TUICallKitPlugin.TAG, "Android Native: pullBackgroundApp ");
        User caller = TUICallState.getInstance().mRemoteUserList.get(0);
        if (caller == null) {
            return;
        }

        turnOnScreen(context);

        if (Devices.isSamsungDevice() && Permission.hasPermission(PermissionRequester.BG_START_PERMISSION)) {
            Logger.info(TUICallKitPlugin.TAG, "Android Native: pullBackgroundApp, try to launch MainActivity");
            launchMainActivity(context);
            TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
            return;
        }

        if (!ServiceInitializer.isAppInForeground(context) && isFCMDataNotification()) {
            if (Permission.hasPermission(PermissionRequester.FLOAT_PERMISSION)) {
                Logger.info(TUICallKitPlugin.TAG, "Android Native: pullBackgroundApp, will open IncomingFloatView");
                startIncomingFloatWindow(context, caller);
                return;
            } else if (Permission.isNotificationEnabled()) {
                Logger.info(TUICallKitPlugin.TAG, "Android Native: pullBackgroundApp, will open IncomingNotificationView");
                IncomingNotificationView.getInstance(context).showNotification(caller,
                        TUICallState.getInstance().mMediaType);
                return;
            }
        }

        Logger.info(TUICallKitPlugin.TAG, "Android Native: pullBackgroundApp, try to launch MainActivity");
        launchMainActivity(context);
        TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
    }

    private static void incomingBannerInForeground(Context context, User caller) {
        if (Permission.hasPermission(PermissionRequester.FLOAT_PERMISSION)) {
            startIncomingFloatWindow(context, caller);
        } else if (isFCMDataNotification() && Permission.isNotificationEnabled()) {
            IncomingNotificationView.getInstance(context).showNotification(caller,
                    TUICallState.getInstance().mMediaType);
        } else {
            TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
        }
    }

    private static void incomingBannerInBackground(Context context, User caller) {
        if (Permission.hasPermission(PermissionRequester.FLOAT_PERMISSION)) {
            Logger.info(TUICallKitPlugin.TAG, "App in background, will open IncomingFloatView");
            startIncomingFloatWindow(context, caller);
        } else if (Permission.isNotificationEnabled() && isFCMDataNotification()) {
            Logger.info(TUICallKitPlugin.TAG, "App in background, will open IncomingNotificationView");
            IncomingNotificationView.getInstance(context).showNotification(caller,
                    TUICallState.getInstance().mMediaType);
        } else {
            Logger.info(TUICallKitPlugin.TAG, "App in background, try to launch intent");
            launchMainActivity(context);
            TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
        }
    }

    public static void launchMainActivity(Context context) {
        Logger.info(TUICallKitPlugin.TAG, "Try to launch main activity");
        Intent intentLaunchMain = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
        if (intentLaunchMain != null) {
            intentLaunchMain.putExtra("show_in_foreground", true);
            intentLaunchMain.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intentLaunchMain);
        } else {
            Logger.error(TUICallKitPlugin.TAG, "Failed to get launch intent for package: " + context.getPackageName());
        }
    }

    private static void startIncomingFloatWindow(Context context, User caller) {
        IncomingFloatView floatView = new IncomingFloatView(context);
        TUICallState.getInstance().mIncomingFloatView = floatView;
        floatView.showIncomingView(caller, TUICallState.getInstance().mMediaType);
    }

    private static boolean isFCMDataNotification() {
        if (TUICore.getService(TUIConstants.TIMPush.SERVICE_NAME) == null) {
            return false;
        }

        int pushBrandId = (int) TUICore.callService(TUIConstants.TIMPush.SERVICE_NAME,
                TUIConstants.TIMPush.METHOD_GET_PUSH_BRAND_ID, null);

        return pushBrandId == TUIConstants.DeviceInfo.BRAND_GOOGLE_ELSE;
    }

    private static void turnOnScreen(Context context) {
        PowerManager powerManager = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
        PowerManager.WakeLock wakeLock = powerManager.newWakeLock(PowerManager.FULL_WAKE_LOCK | PowerManager.ACQUIRE_CAUSES_WAKEUP | PowerManager.ON_AFTER_RELEASE, "MyApp:MyWakeLockTag" );
        wakeLock.acquire();
        wakeLock.release();
    }
}
