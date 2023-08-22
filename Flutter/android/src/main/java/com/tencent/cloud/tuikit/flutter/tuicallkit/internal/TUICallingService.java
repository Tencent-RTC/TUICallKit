package com.tencent.cloud.tuikit.flutter.tuicallkit.internal;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.flutter.tuicallkit.TUICallKitPlugin;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * `TUICore` call (if the `TUICore` module is not imported, use `TUICallKitImpl` instead)
 */
final class TUICallingService implements ITUINotification, ITUIService {
    private static final String TAG = "TUICallingService";

    private static final TUICallingService INSTANCE = new TUICallingService();

    private Context appContext;

    static TUICallingService sharedInstance() {
        return INSTANCE;
    }

    private TUICallingService() {}

    public void init(Context context) {
        appContext = context;

        TUICore.registerEvent(
                TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this
        );
        TUICore.registerEvent(
                TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS, this
        );
    }

    @Override
    public Object onCall(String method, Map<String, Object> param) {
        Log.i(TAG, "onCall, method: " + method + " ,param: " + param);

        if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_ENABLE_FLOAT_WINDOW, method)) {
            boolean enableFloatWindow = (boolean) param.get(TUIConstants.TUICalling.PARAM_NAME_ENABLE_FLOAT_WINDOW);
            Log.i(TAG, "onCall, enableFloatWindow: " + enableFloatWindow);
            TUICallKitPlugin.enableFloatWindow(enableFloatWindow);
            return null;
        }

        if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_ENABLE_MULTI_DEVICE, method)) {
            boolean enable = (boolean) param.get(TUIConstants.TUICalling.PARAM_NAME_ENABLE_MULTI_DEVICE);
            Log.i(TAG, "onCall, enableMultiDevice: " + enable);
            TUICallEngine.createInstance(appContext).enableMultiDeviceAbility(enable, new TUICommonDefine.Callback() {
                @Override
                public void onSuccess() {
                }

                @Override
                public void onError(int errCode, String errMsg) {
                }
            });
            return null;
        }

        if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_CALL, method)) {
            String[] userIDs = (String[]) param.get(TUIConstants.TUICalling.PARAM_NAME_USERIDS);
            String typeString = (String) param.get(TUIConstants.TUICalling.PARAM_NAME_TYPE);
            String groupID = (String) param.get(TUIConstants.TUICalling.PARAM_NAME_GROUPID);

            List<String> userIdList = new ArrayList<>(Arrays.asList(userIDs));
            TUICallDefine.MediaType mediaType = TUICallDefine.MediaType.Unknown;
            if (TUIConstants.TUICalling.TYPE_AUDIO.equals(typeString)) {
                mediaType = TUICallDefine.MediaType.Audio;
            } else if (TUIConstants.TUICalling.TYPE_VIDEO.equals(typeString)) {
                mediaType = TUICallDefine.MediaType.Video;
            }
            if (!TextUtils.isEmpty(groupID)) {
                TUICallKitPlugin.groupCall(groupID, userIdList, mediaType);
            } else if (userIdList.size() == 1) {
                TUICallKitPlugin.call(userIdList.get(0), mediaType);
            } else {
                Log.e(TAG, "onCall ignored, groupId is empty and userList is not 1, cannot start call or groupCall");
            }
        }
        return null;
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED.equals(key)
                && TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS.equals(subKey)) {
            TUICallKitPlugin.handleLogoutSuccess();
        } else if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS == subKey) {
            TUICallKitPlugin.handleLoginSuccess();
        }
    }
}
