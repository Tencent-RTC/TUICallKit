package com.tencent.cloud.tuikit.flutter.tuicallkit;

import static com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants.KEY_TUISTATE_CHANGE;
import static com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants.SUBKEY_REFRESH_VIEW;

import android.Manifest;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.flutter.tuicallkit.service.ServiceInitializer;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.CallingBellPlayer;
import com.tencent.cloud.tuikit.flutter.tuicallkit.service.ForegroundService;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.TUICallState;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.User;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitEnumUtils;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitObjectUtils;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Permission;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.WakeLock;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.WindowManager;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.incomingfloatwindow.IncomingNotificationView;
import com.tencent.cloud.tuikit.tuicall_engine.utils.EnumUtils;
import com.tencent.cloud.tuikit.tuicall_engine.utils.Logger;
import com.tencent.cloud.tuikit.tuicall_engine.utils.MethodCallUtils;
import com.tencent.cloud.uikit.core.utils.MethodUtils;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * TUICallKitPlugin
 */
public class TUICallKitPlugin implements FlutterPlugin, MethodCallHandler, ITUINotification, ActivityAware {
    public static final String TAG = "TUICallKitPlugin";

    private MethodChannel     mChannel;
    private Context           mApplicationContext;
    private CallingBellPlayer mCallingBellPlayer;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Logger.info(TAG, "TUICallKitPlugin onAttachedToEngine");
        mChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tuicall_kit");
        mChannel.setMethodCallHandler(this);

        mApplicationContext = flutterPluginBinding.getApplicationContext();
        mCallingBellPlayer = new CallingBellPlayer(mApplicationContext);

        registerObserver();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            Method method = TUICallKitPlugin.class.getDeclaredMethod(call.method, MethodCall.class,
                    MethodChannel.Result.class);
            method.invoke(this, call, result);
        } catch (NoSuchMethodException e) {
            Logger.error(TAG, "onMethodCall |method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            Logger.error(TAG, "onMethodCall |method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
            e.printStackTrace();
        } catch (Exception e) {
            Logger.error(TAG, "onMethodCall |method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
            e.printStackTrace();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mChannel.setMethodCallHandler(null);
        unRegisterObserver();
    }

    private void registerObserver() {
        TUICore.registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_GOTO_CALLING_PAGE, this);
        TUICore.registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, this);
        TUICore.registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_ENABLE_FLOAT_WINDOW, this);
        TUICore.registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_CALL, this);
        TUICore.registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_GROUP_CALL, this);
        TUICore.registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_LOGIN_SUCCESS, this);
        TUICore.registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_LOGOUT_SUCCESS, this);
        TUICore.registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_ENTER_FOREGROUND, this);
    }

    private void unRegisterObserver() {
        TUICore.unRegisterEvent(this);
    }

    public void startForegroundService(MethodCall call, MethodChannel.Result result) {
        ForegroundService.start(mApplicationContext);
        result.success(0);
    }

    public void stopForegroundService(MethodCall call, MethodChannel.Result result) {
        ForegroundService.stop(mApplicationContext);
        result.success(0);
    }

    public void startRing(MethodCall call, MethodChannel.Result result) {
        String filePath = MethodCallUtils.getMethodRequiredParams(call, "filePath", result);
        mCallingBellPlayer.startRing(filePath);
        result.success(0);
    }

    public void stopRing(MethodCall call, MethodChannel.Result result) {
        mCallingBellPlayer.stopRing();
        IncomingNotificationView.getInstance(mApplicationContext).cancelNotification();
        if (TUICallState.getInstance().mIncomingFloatView != null) {
            TUICallState.getInstance().mIncomingFloatView.cancelIncomingView();
        }
        result.success(0);
    }

    public void updateCallStateToNative(MethodCall call, Result result) {
        boolean needRefreshView = false;
        Map selfUserMap = MethodCallUtils.getMethodParams(call, "selfUser");
        User selfUser = KitObjectUtils.getUserByMap(selfUserMap);
        if (!TUICallState.getInstance().mSelfUser.isSameUser(selfUser)) {
            if (selfUser.callStatus != TUICallState.getInstance().mSelfUser.callStatus) {
                needRefreshView = true;
            }
            TUICallState.getInstance().mSelfUser = selfUser;
        }

        List<Map> remoteUserMapList = MethodCallUtils.getMethodParams(call, "remoteUserList");
        TUICallState.getInstance().mRemoteUserList.clear();
        for (Map remoteUserMap : remoteUserMapList) {
            User remoteUser = KitObjectUtils.getUserByMap(remoteUserMap);
            TUICallState.getInstance().mRemoteUserList.add(remoteUser);
            needRefreshView = true;
        }

        int sceneIndex = MethodCallUtils.getMethodParams(call, "scene");
        TUICallState.getInstance().mScene = KitEnumUtils.getSceneType(sceneIndex);

        int mediaTypeIndex = MethodCallUtils.getMethodParams(call, "mediaType");
        if (TUICallState.getInstance().mMediaType != EnumUtils.getMediaType(mediaTypeIndex)) {
            needRefreshView = true;
            TUICallState.getInstance().mMediaType = EnumUtils.getMediaType(mediaTypeIndex);
        }

        TUICallState.getInstance().mStartTime = MethodCallUtils.getMethodParams(call, "startTime");

        int cameraIndex = MethodCallUtils.getMethodParams(call, "camera");
        TUICallState.getInstance().mCamera = EnumUtils.getCameraType(cameraIndex);

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
        WindowManager.showIncomingBanner(mApplicationContext);
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
                Logger.warning(TAG, logString);
                break;
            case 2:
                Logger.error(TAG, logString);
                break;
            default:
                Logger.info(TAG, logString);
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

    public void enableWakeLock(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodCallUtils.getMethodParams(call, "enable");
        if (enable) {
            WakeLock.getInstance().enable();
        } else {
            WakeLock.getInstance().disable();
        }
        result.success(0);
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
        mChannel.invokeMethod("backCallingPageFromFloatWindow", new HashMap(), new Result() {
            @Override
            public void success(@Nullable Object result) {
            }

            @Override
            public void error(@NonNull String code, @Nullable String message, @Nullable Object details) {
                Logger.error(TAG, "backCallingPageFromFloatWindow error code: " + code + " message:" + message +
                        "details:"
                        + details);
            }

            @Override
            public void notImplemented() {
                Logger.error(TAG, "backCallingPageFromFloatWindow notImplemented");
            }
        });
    }

    public void launchCallingPageFromIncomingBanner() {
        mChannel.invokeMethod("launchCallingPageFromIncomingBanner", new HashMap(), new Result() {
            @Override
            public void success(@Nullable Object result) {
            }

            @Override
            public void error(@NonNull String code, @Nullable String message, @Nullable Object details) {
            }

            @Override
            public void notImplemented() {
                Logger.error(TAG, "launchCallingPageFromIncomingBanner notImplemented");
            }
        });
    }

    public void appEnterForeground() {
        mChannel.invokeMethod("appEnterForeground", new HashMap(), new Result() {
            @Override
            public void success(@Nullable Object result) {
                Logger.info(TAG, "appEnterForeground success");
            }

            @Override
            public void error(@NonNull String code, @Nullable String message, @Nullable Object details) {
                Logger.error(TAG, "appEnterForeground error code: " + code + " message:" + message + "details:"
                        + details);
            }

            @Override
            public void notImplemented() {
                Logger.error(TAG, "appEnterForeground notImplemented");
            }
        });
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> params) {
        if (!Constants.KEY_CALLKIT_PLUGIN.equals(key)) {
            return;
        }

        if (Constants.SUB_KEY_GOTO_CALLING_PAGE.equals(subKey)) {
            backCallingPageFromFloatWindow();
            return;
        }

        if (Constants.SUB_KEY_HANDLE_CALL_RECEIVED.equals(subKey)) {
            launchCallingPageFromIncomingBanner();
            return;
        }

        if (Constants.SUB_KEY_ENTER_FOREGROUND.equals(subKey)) {
            appEnterForeground();
        }
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        WakeLock.getInstance().setActivity(binding.getActivity());
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        WakeLock.getInstance().setActivity(null);
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        WakeLock.getInstance().setActivity(binding.getActivity());
    }

    @Override
    public void onDetachedFromActivity() {
        WakeLock.getInstance().setActivity(null);
    }
}
