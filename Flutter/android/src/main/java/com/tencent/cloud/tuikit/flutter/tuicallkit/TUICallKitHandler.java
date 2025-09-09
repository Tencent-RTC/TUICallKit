package com.tencent.cloud.tuikit.flutter.tuicallkit;

import static com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants.KEY_TUISTATE_CHANGE;
import static com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants.SUBKEY_REFRESH_VIEW;

import android.Manifest;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.engine.call.TUICallDefine;
import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.flutter.tuicallkit.service.ServiceInitializer;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.TUICallState;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.User;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.CallingBellPlayer;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.CallingVibrator;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Devices;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.ObjectParse;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Logger;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.MethodCallUtils;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Permission;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.WakeLock;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.WindowManager;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.incomingfloatwindow.IncomingNotificationView;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.videoview.PlatformVideoViewFactory;
import com.tencent.cloud.uikit.core.utils.MethodUtils;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;
import com.trtc.tuikit.common.foregroundservice.AudioForegroundService;
import com.trtc.tuikit.common.foregroundservice.VideoForegroundService;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class TUICallKitHandler {
    public static String CHANNEL_NAME = "tuicall_kit";

    private MethodChannel mChannel;
    private Context           mApplicationContext;
    private CallingBellPlayer mCallingBellPlayer;
    private CallingVibrator   mCallingVibrator;

    public TUICallKitHandler(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        Logger.info(TUICallKitPlugin.TAG, "TUICallKitManager init");

        this.mChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_NAME);
        mApplicationContext = flutterPluginBinding.getApplicationContext();
        mCallingBellPlayer = new CallingBellPlayer(mApplicationContext);
        mCallingVibrator = new CallingVibrator(mApplicationContext);

        this.mChannel.setMethodCallHandler((call, result) -> {
            try {
                Method method = TUICallKitHandler.class.getDeclaredMethod(call.method, MethodCall.class,
                        MethodChannel.Result.class);
                method.invoke(this, call, result);
            } catch (NoSuchMethodException e) {
                Logger.error(TUICallKitPlugin.TAG, "onMethodCall |method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                Logger.error(TUICallKitPlugin.TAG, "onMethodCall |method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
                e.printStackTrace();
            } catch (Exception e) {
                Logger.error(TUICallKitPlugin.TAG, "onMethodCall |method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
                e.printStackTrace();
            }
        });
    }

    public void removeMethodChannelHandler() {
        mChannel.setMethodCallHandler(null);
    }


    public void startForegroundService(MethodCall call, MethodChannel.Result result) {
        boolean isVideo = MethodCallUtils.getMethodParams(call, "isVideo");
        if (isVideo) {
            VideoForegroundService.start(mApplicationContext, "", "", 0);
        } else {
            AudioForegroundService.start(mApplicationContext, "", "", 0);
        }
        result.success(0);
    }

    public void stopForegroundService(MethodCall call, MethodChannel.Result result) {
        VideoForegroundService.stop(mApplicationContext);
        AudioForegroundService.stop(mApplicationContext);
        result.success(0);
    }

    public void startRing(MethodCall call, MethodChannel.Result result) {
        String filePath = MethodCallUtils.getMethodRequiredParams(call, "filePath", result);
        mCallingBellPlayer.startRing(filePath);
        if (TUICallState.getInstance().mSelfUser.callRole == TUICallDefine.Role.Called) {
            mCallingVibrator.startVibration();
        }
        result.success(0);
    }

    public void stopRing(MethodCall call, MethodChannel.Result result) {
        mCallingBellPlayer.stopRing();
        if (TUICallState.getInstance().mSelfUser.callRole == TUICallDefine.Role.Called) {
            mCallingVibrator.stopVibration();
        }
        IncomingNotificationView.getInstance(mApplicationContext).cancelNotification();
        if (TUICallState.getInstance().mIncomingFloatView != null) {
            TUICallState.getInstance().mIncomingFloatView.cancelIncomingView();
        }
        result.success(0);
    }

    public void updateCallStateToNative(MethodCall call, MethodChannel.Result result) {
        boolean needRefreshView = false;
        Map selfUserMap = MethodCallUtils.getMethodParams(call, "selfUser");
        User selfUser = ObjectParse.getUserByMap(selfUserMap);
        if (!TUICallState.getInstance().mSelfUser.isSameUser(selfUser)) {
            if (selfUser.callStatus != TUICallState.getInstance().mSelfUser.callStatus) {
                needRefreshView = true;
            }
            TUICallState.getInstance().mSelfUser = selfUser;
        }

        List<Map> remoteUserMapList = MethodCallUtils.getMethodParams(call, "remoteUserList");
        TUICallState.getInstance().mRemoteUserList.clear();
        for (Map remoteUserMap : remoteUserMapList) {
            User remoteUser = ObjectParse.getUserByMap(remoteUserMap);
            TUICallState.getInstance().mRemoteUserList.add(remoteUser);
            needRefreshView = true;
        }

        int sceneIndex = MethodCallUtils.getMethodParams(call, "scene");
        TUICallState.getInstance().mScene = ObjectParse.getSceneType(sceneIndex);

        int mediaTypeIndex = MethodCallUtils.getMethodParams(call, "mediaType");
        if (TUICallState.getInstance().mMediaType != ObjectParse.getMediaType(mediaTypeIndex)) {
            needRefreshView = true;
            TUICallState.getInstance().mMediaType = ObjectParse.getMediaType(mediaTypeIndex);
        }

        TUICallState.getInstance().mStartTime = MethodCallUtils.getMethodParams(call, "startTime");

        int cameraIndex = MethodCallUtils.getMethodParams(call, "camera");
        TUICallState.getInstance().mCamera = ObjectParse.getCameraType(cameraIndex);

        TUICallState.getInstance().mIsCameraOpen = MethodCallUtils.getMethodParams(call, "isCameraOpen");

        TUICallState.getInstance().mIsMicrophoneMute = MethodCallUtils.getMethodParams(call, "isMicrophoneMute");

        if (needRefreshView) {
            TUICore.notifyEvent(KEY_TUISTATE_CHANGE, SUBKEY_REFRESH_VIEW, new HashMap<>());
        }
        result.success(0);
    }

    public void startFloatWindow(MethodCall call, MethodChannel.Result result) {
        if (WindowManager.showFloatWindow(mApplicationContext)) {
            result.success(0);
        } else {
            result.error("-1", "No Permission", null);
        }
    }

    public void stopFloatWindow(MethodCall call, MethodChannel.Result result) {
        WindowManager.closeFloatWindow(mApplicationContext);
        result.success(0);
    }

    public void hasFloatPermission(MethodCall call, MethodChannel.Result result) {
        if (Permission.hasPermission(PermissionRequester.FLOAT_PERMISSION)) {
            result.success(true);
        } else {
            result.success(false);
        }
        Permission.requestFloatPermission();
    }

    public void isAppInForeground(MethodCall call, MethodChannel.Result result) {
        if (ServiceInitializer.isAppInForeground(mApplicationContext)) {
            result.success(true);
        } else {
            result.success(false);
        }
    }

    public void showIncomingBanner(MethodCall call, MethodChannel.Result result) {
        WindowManager.showIncomingBanner(mApplicationContext);
        result.success(0);
    }

    public void initResources(MethodCall call, MethodChannel.Result result) {
        Map resources = MethodCallUtils.getMethodParams(call, "resources");
        TUICallState.getInstance().mResourceMap.clear();
        TUICallState.getInstance().mResourceMap.putAll(resources);
        result.success(0);
    }

    public void apiLog(MethodCall call, MethodChannel.Result result) {
        String logString = MethodCallUtils.getMethodRequiredParams(call, "logString", result);
        int level = MethodCallUtils.getMethodRequiredParams(call, "level", result);

        switch (level) {
            case 1:
                Logger.warning(TUICallKitPlugin.TAG, logString);
                break;
            case 2:
                Logger.error(TUICallKitPlugin.TAG, logString);
                break;
            default:
                Logger.info(TUICallKitPlugin.TAG, logString);
                break;
        }
        result.success(0);
    }

    public void hasPermissions(MethodCall call, MethodChannel.Result result) {
        List<Integer> permissionsList = MethodUtils.getMethodParam(call, "permission");
        String[] strings = new String[permissionsList.size()];
        for (int i = 0; i < permissionsList.size(); i++) {
            strings[i] = getPermissionsByIndex(permissionsList.get(i));
        }
        boolean isGranted = com.tencent.qcloud.tuicore.util.PermissionRequester.isGranted(strings);
        result.success(isGranted);
    }

    public void requestPermissions(MethodCall call, MethodChannel.Result result) {
        List<Integer> permissionsList = MethodUtils.getMethodParam(call, "permission");
        String[] permissions = new String[permissionsList.size()];
        for (int i = 0; i < permissionsList.size(); i++) {
            permissions[i] = getPermissionsByIndex(permissionsList.get(i));
        }
        String title = MethodUtils.getMethodParam(call, "title");
        String description = MethodUtils.getMethodParam(call, "description");
        String settingsTip = MethodUtils.getMethodParam(call, "settingsTip");
        PermissionCallback callback = new PermissionCallback() {
            @Override
            public void onGranted() {
                result.success(PermissionRequester.Result.Granted.ordinal());
            }

            @Override
            public void onDenied() {
                result.success(PermissionRequester.Result.Denied.ordinal());
            }

            @Override
            public void onRequesting() {
                result.success(PermissionRequester.Result.Requesting.ordinal());
            }
        };

        PermissionRequester.newInstance(permissions)
                .title(title)
                .description(description)
                .settingsTip(settingsTip)
                .callback(callback)
                .request();
    }

    public void pullBackgroundApp(MethodCall call, MethodChannel.Result result) {
        WindowManager.pullBackgroundApp(mApplicationContext);
        result.success(0);
    }

    public void openLockScreenApp(MethodCall call, MethodChannel.Result result) {
        WindowManager.openLockScreenApp(mApplicationContext);
        result.success(0);
    }

    public void enableWakeLock(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodCallUtils.getMethodParams(call, "enable");
        if (enable) {
            WakeLock.getInstance().enable();
        } else {
            WakeLock.getInstance().disable();
        }
        result.success(0);
    }

    public void isScreenLocked(MethodCall call, MethodChannel.Result result) {
        if (Devices.isScreenLocked(mApplicationContext)) {
            result.success(true);
        } else {
            result.success(false);
        }
    }

    public void imSDKInitSuccessEvent(MethodCall call, MethodChannel.Result result) {
        TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT, null);
        result.success(0);
    }

    public void loginSuccessEvent(MethodCall call, MethodChannel.Result result) {
        TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, null);
        result.success(0);
    }

    public void logoutSuccessEvent(MethodCall call, MethodChannel.Result result) {
        TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS, null);
        result.success(0);
    }

    public void checkUsbCameraService(MethodCall call, MethodChannel.Result result) {
        if (TUICore.getService(TUIConstants.USBCamera.SERVICE_NAME) != null) {
            result.success(true);
        } else {
            result.success(false);
        }
    }

    public void openUsbCamera(MethodCall call, MethodChannel.Result result) {
        int viewId = MethodCallUtils.getMethodParams(call, "viewId");
        TUIVideoView videoView = (TUIVideoView) PlatformVideoViewFactory.mVideoViewMap.get(viewId).getView();
        Map map = new HashMap();
        map.put(TUIConstants.USBCamera.PARAM_TX_CLOUD_VIEW, videoView);
        TUICore.notifyEvent(TUIConstants.USBCamera.KEY_USB_CAMERA, TUIConstants.USBCamera.SUB_KEY_OPEN_CAMERA, map);
        result.success(0);
    }

    public void closeUsbCamera(MethodCall call, MethodChannel.Result result) {
        TUICore.notifyEvent(TUIConstants.USBCamera.KEY_USB_CAMERA, TUIConstants.USBCamera.SUB_KEY_CLOSE_CAMERA, null);
        result.success(0);
    }

    public void isSamsungDevice(MethodCall call, MethodChannel.Result result) {
        if (Devices.isSamsungDevice()) {
            result.success(true);
        } else {
            result.success(false);
        }
    }

    private String getPermissionsByIndex(int index) {
        switch (index) {
            case 0:
                return Manifest.permission.CAMERA;
            case 1:
                return Manifest.permission.RECORD_AUDIO;
            case 2:
                return Manifest.permission.BLUETOOTH_CONNECT;
            default:
                return "";
        }
    }

    public void backCallingPageFromFloatWindow() {
        mChannel.invokeMethod("backCallingPageFromFloatWindow", new HashMap(), new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object result) {
            }

            @Override
            public void error(@NonNull String code, @Nullable String message, @Nullable Object details) {
                Logger.error(TUICallKitPlugin.TAG, "backCallingPageFromFloatWindow error code: " + code + " message:" + message +
                        "details:"
                        + details);
            }

            @Override
            public void notImplemented() {
                Logger.error(TUICallKitPlugin.TAG, "backCallingPageFromFloatWindow notImplemented");
            }
        });
    }

    public void launchCallingPageFromIncomingBanner() {
        mChannel.invokeMethod("launchCallingPageFromIncomingBanner", new HashMap(), new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object result) {
            }

            @Override
            public void error(@NonNull String code, @Nullable String message, @Nullable Object details) {
            }

            @Override
            public void notImplemented() {
                Logger.error(TUICallKitPlugin.TAG, "launchCallingPageFromIncomingBanner notImplemented");
            }
        });
    }

    public void appEnterForeground() {
        mChannel.invokeMethod("appEnterForeground", new HashMap(), new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object result) {
                Logger.info(TUICallKitPlugin.TAG, "appEnterForeground success");
            }

            @Override
            public void error(@NonNull String code, @Nullable String message, @Nullable Object details) {
                Logger.error(TUICallKitPlugin.TAG, "appEnterForeground error code: " + code + " message:" + message + "details:"
                        + details);
            }

            @Override
            public void notImplemented() {
                Logger.error(TUICallKitPlugin.TAG, "appEnterForeground notImplemented");
            }
        });
    }
}
