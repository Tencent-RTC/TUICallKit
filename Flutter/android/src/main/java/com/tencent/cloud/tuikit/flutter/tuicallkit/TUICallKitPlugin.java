package com.tencent.cloud.tuikit.flutter.tuicallkit;

import static com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow.FloatCallView.KEY_TUISTATE_CHANGE;
import static com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow.FloatCallView.SUBKEY_REFRESH_VIEW;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow.FloatWindowService;
import com.tencent.cloud.tuikit.flutter.tuicallkit.service.CallingBellService;
import com.tencent.cloud.tuikit.flutter.tuicallkit.service.ForegroundService;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.TUICallState;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.User;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitAppUtils;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitEnumUtils;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitObjectUtils;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitPermissionUtils;
import com.tencent.cloud.tuikit.tuicall_engine.utils.EnumUtils;
import com.tencent.cloud.tuikit.tuicall_engine.utils.Logger;
import com.tencent.cloud.tuikit.tuicall_engine.utils.MethodCallUtils;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * TUICallKitPlugin
 */
public class TUICallKitPlugin implements FlutterPlugin, MethodCallHandler {
    private static final String TAG = "TUICallKitPlugin";

    private static MethodChannel      mChannel;
    private        Context            mApplicationContext;
    private        CallingBellService mCallingBellService;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        mChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tuicall_kit");
        mChannel.setMethodCallHandler(this);

        mApplicationContext = flutterPluginBinding.getApplicationContext();
        mCallingBellService = new CallingBellService();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Logger.info(TAG, "onMethodCall -> method:" + call.method + ", arguments:" + call.arguments);
        try {
            Method method = TUICallKitPlugin.class.getDeclaredMethod(call.method, MethodCall.class, MethodChannel.Result.class);
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
        mCallingBellService.startRing(filePath);
        result.success(0);
    }

    public void stopRing(MethodCall call, MethodChannel.Result result) {
        mCallingBellService.stopRing();
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

        Map remoteUserMap = MethodCallUtils.getMethodParams(call, "remoteUser");
        User remoteUser = KitObjectUtils.getUserByMap(remoteUserMap);
        if (!TUICallState.getInstance().mRemoteUser.isSameUser(remoteUser)) {
            if (remoteUser.videoAvailable != TUICallState.getInstance().mRemoteUser.videoAvailable) {
                needRefreshView = true;
            }
            TUICallState.getInstance().mRemoteUser = remoteUser;
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

        if (needRefreshView) {
            TUICore.notifyEvent(KEY_TUISTATE_CHANGE, SUBKEY_REFRESH_VIEW, new HashMap<>());
        }
        Log.i(TAG, TUICallState.getInstance().toString());
        result.success(0);
    }

    public void startFloatWindow(MethodCall call, MethodChannel.Result result) {
        FloatWindowService.startFloatWindow(mApplicationContext);
        result.success(0);
    }

    public void stopFloatWindow(MethodCall call, MethodChannel.Result result) {
        FloatWindowService.stopFloatWindow(mApplicationContext);
        result.success(0);
    }

    public void hasFloatPermission(MethodCall call, MethodChannel.Result result) {
        if (KitPermissionUtils.hasPermission(mApplicationContext)) {
            result.success(true);
        } else {
            result.success(false);
        }
        KitPermissionUtils.requestFloatPermission(mApplicationContext);
    }

    public void isAppInForeground(MethodCall call, MethodChannel.Result result) {
        if (KitAppUtils.isAppInForeground(mApplicationContext)) {
            result.success(true);
        } else {
            result.success(false);
        }
    }

    public void moveAppToFront(MethodCall call, MethodChannel.Result result) {
        String event = MethodCallUtils.getMethodParams(call, KitAppUtils.EVENT_KEY);
        KitAppUtils.moveAppToForeground(mApplicationContext, event);
        result.success(0);
    }

    public void initResources(MethodCall call, MethodChannel.Result result) {
        Map resources = MethodCallUtils.getMethodParams(call, "resources");
        TUICallState.getInstance().mResourceMap.clear();
        TUICallState.getInstance().mResourceMap.putAll(resources);
        result.success(0);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mChannel.setMethodCallHandler(null);
    }

    public static void gotoCallingPage() {
        mChannel.invokeMethod("gotoCallingPage", new HashMap());
    }

    public static void handleCallReceived() {
        mChannel.invokeMethod("handleCallReceived", new HashMap());
    }

    public static void enableFloatWindow(boolean enable) {
        Map paramMap = new HashMap();
        paramMap.put("enable", enable);
        mChannel.invokeMethod("enableFloatWindow", paramMap);
    }

    public static void groupCall(String groupId, List<String> userIdList, TUICallDefine.MediaType mediaType) {
        Map paramMap = new HashMap();
        paramMap.put("groupId", groupId);
        paramMap.put("userIdList", userIdList);
        paramMap.put("mediaType", mediaType.ordinal());
        mChannel.invokeMethod("groupCall", paramMap);
    }

    public static void call(String userId, TUICallDefine.MediaType mediaType) {
        Map paramMap = new HashMap();
        paramMap.put("userId", userId);
        paramMap.put("mediaType", mediaType.ordinal());
        mChannel.invokeMethod("call", paramMap);
    }

    public static void handleLoginSuccess() {
        Map paramMap = new HashMap();
        paramMap.put("userId", TUILogin.getUserId());
        paramMap.put("sdkAppId", TUILogin.getSdkAppId());
        paramMap.put("userSig", TUILogin.getUserSig());
        mChannel.invokeMethod("handleLoginSuccess", paramMap);
    }

    public static void handleLogoutSuccess() {
        Map paramMap = new HashMap();
        mChannel.invokeMethod("handleLogoutSuccess", paramMap);
    }

}
