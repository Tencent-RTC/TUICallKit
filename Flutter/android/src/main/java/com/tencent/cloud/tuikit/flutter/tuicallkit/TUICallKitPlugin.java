package com.tencent.cloud.tuikit.flutter.tuicallkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.tuicall_engine.utils.EnumUtils;
import com.tencent.cloud.tuikit.tuicall_engine.utils.Logger;
import com.tencent.cloud.tuikit.tuicall_engine.utils.MethodCallUtils;
import com.tencent.cloud.tuikit.tuicall_engine.utils.ObjectUtils;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Method;
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
    private static final String        TAG = "TUICallKitPlugin";
    private              MethodChannel channel;
    private              Context       mApplicationContext;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tuicall_kit");
        channel.setMethodCallHandler(this);

        mApplicationContext = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Logger.info(TAG, "onMethodCall -> method:" + call.method + ", arguments:" + call.arguments);
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

    public void login(MethodCall call, MethodChannel.Result result) {

        int sdkAppId = MethodCallUtils.getMethodRequiredParams(call, "sdkAppId", result);
        String userId = MethodCallUtils.getMethodRequiredParams(call, "userId", result);
        String userSig = MethodCallUtils.getMethodRequiredParams(call, "userSig", result);

        TUILogin.login(mApplicationContext, sdkAppId, userId, userSig,
                new TUICallback() {
                    @Override
                    public void onSuccess() {
                        result.success(0);
                        setFramework(mApplicationContext);
                    }

                    @Override
                    public void onError(int code, String message) {
                        Logger.error(TAG, "TUILogin Error:" + message);
                        result.error("" + code, message, "");
                    }
                });

    }

    public void logout(MethodCall call, MethodChannel.Result result) {
        TUILogin.logout(new TUICallback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                result.error("" + code, message, "");
            }
        });

    }

    public void setSelfInfo(MethodCall call, MethodChannel.Result result) {

        String nickname = MethodCallUtils.getMethodRequiredParams(call, "nickname", result);
        String avatar = MethodCallUtils.getMethodRequiredParams(call, "avatar", result);

        TUICallKit.createInstance(mApplicationContext).setSelfInfo(nickname, avatar, new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TAG, "setSelfInfo Error:" + message);
                result.error("" + code, message, "");
            }
        });
    }

    public void call(MethodCall call, MethodChannel.Result result) {
        String userId = MethodCallUtils.getMethodRequiredParams(call, "userId", result);
        int mediaTypeIndex = MethodCallUtils.getMethodRequiredParams(call, "callMediaType", result);
        Map paramsMap = MethodCallUtils.getMethodParams(call, "params");

        TUICallDefine.MediaType mediaType = EnumUtils.getMediaType(mediaTypeIndex);
        TUICallDefine.CallParams params = ObjectUtils.getTUICallParamsByMap(paramsMap);

        TUICallKit.createInstance(mApplicationContext).call(userId, mediaType, params, new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TAG, "call Error:" + message);
                result.error("" + code, message, "");
            }
        });

    }

    public void groupCall(MethodCall call, MethodChannel.Result result) {
        String groupId = MethodCallUtils.getMethodRequiredParams(call, "groupId", result);
        List userIdList = MethodCallUtils.getMethodRequiredParams(call, "userIdList", result);
        int mediaTypeIndex = MethodCallUtils.getMethodRequiredParams(call, "callMediaType", result);
        Map paramsMap = MethodCallUtils.getMethodParams(call, "params");

        TUICallDefine.MediaType mediaType = EnumUtils.getMediaType(mediaTypeIndex);
        TUICallDefine.CallParams params = ObjectUtils.getTUICallParamsByMap(paramsMap);

        TUICallKit.createInstance(mApplicationContext).groupCall(groupId, userIdList, mediaType, params,
                new TUICommonDefine.Callback() {
                    @Override
                    public void onSuccess() {
                        result.success(0);
                    }

                    @Override
                    public void onError(int code, String message) {
                        Logger.error(TAG, "groupCall Error:" + message);
                        result.error("" + code, message, "");
                    }
                });
    }


    public void joinInGroupCall(MethodCall call, MethodChannel.Result result) {
        int intRoomId = MethodCallUtils.getMethodRequiredParams(call, "roomId", result);
        String groupId = MethodCallUtils.getMethodRequiredParams(call, "groupId", result);
        int mediaTypeIndex = MethodCallUtils.getMethodRequiredParams(call, "callMediaType", result);

        TUICommonDefine.RoomId roomId = new TUICommonDefine.RoomId();
        roomId.intRoomId = intRoomId;
        TUICallDefine.MediaType mediaType = EnumUtils.getMediaType(mediaTypeIndex);

        TUICallKit.createInstance(mApplicationContext).joinInGroupCall(roomId, groupId, mediaType);
        result.success(0);
    }


    public void setCallingBell(MethodCall call, MethodChannel.Result result) {
        String filePath = MethodCallUtils.getMethodRequiredParams(call, "filePath", result);
        TUICallKit.createInstance(mApplicationContext).setCallingBell(filePath);
        result.success(0);
    }


    public void enableMuteMode(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodCallUtils.getMethodRequiredParams(call, "enable", result);
        TUICallKit.createInstance(mApplicationContext).enableMuteMode(enable);
        result.success(0);
    }

    public void enableFloatWindow(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodCallUtils.getMethodRequiredParams(call, "enable", result);
        TUICallKit.createInstance(mApplicationContext).enableFloatWindow(enable);
        result.success(0);
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }


    private void setFramework(Context context) {
        try {
            JSONObject params = new JSONObject();
            params.put("framework", 7);
            params.put("component", 14);

            JSONObject jsonObject = new JSONObject();
            jsonObject.put("api", "setFramework");
            jsonObject.put("params", params);
            TUICallEngine.createInstance(context).callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
