package com.tencent.cloud.tuikit.flutter.tuicallkit;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.WakeLock;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Logger;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

/**
 * TUICallKitPlugin
 */
public class TUICallKitPlugin implements FlutterPlugin, ITUINotification, ActivityAware {
    public static final String TAG = "TUICallKitPlugin";

    private TUICallKitHandler    mCallKitManager;
    private TUICallEngineHandler mEngineManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Logger.info(TAG, "TUICallKitPlugin onAttachedToEngine");
        mEngineManager = new TUICallEngineHandler(flutterPluginBinding);
        mCallKitManager = new TUICallKitHandler(flutterPluginBinding);

        registerObserver();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mEngineManager.removeMethodCallHandler();
        mCallKitManager.removeMethodChannelHandler();
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

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> params) {
        if (!Constants.KEY_CALLKIT_PLUGIN.equals(key)) {
            return;
        }

        if (Constants.SUB_KEY_GOTO_CALLING_PAGE.equals(subKey)) {
            mCallKitManager.backCallingPageFromFloatWindow();
            return;
        }

        if (Constants.SUB_KEY_HANDLE_CALL_RECEIVED.equals(subKey)) {
            mCallKitManager.launchCallingPageFromIncomingBanner();
            return;
        }

        if (Constants.SUB_KEY_ENTER_FOREGROUND.equals(subKey)) {
            mCallKitManager.appEnterForeground();
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
