package com.tencent.liteav.trtccalling.model.impl;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.model.TUICalling;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.ArrayList;
import java.util.List;

/**
 * TUICore来调用（如果未引入TUICore模块，请使用TUICallingManager）
 */
final class TUICallingService implements ITUIService, ITUIExtension, ITUINotification, TUICallingManager.CallingManagerListener {

    private static final String TAG = "TUICallingService";

    private static final TUICallingService INSTANCE = new TUICallingService();

    private final TUICallingManager mCallingManager = TUICallingManager.sharedInstance();

    static final TUICallingService sharedInstance() {
        return INSTANCE;
    }

    private TUICallingService() {

    }

    public void init(Context context) {
        mCallingManager.setCallingManagerListener(this);
        TUICore.registerService(TUIConstants.TUICalling.SERVICE_NAME, this);
        TUICore.registerExtension(TUIConstants.TUIChat.EXTENSION_INPUT_MORE, this);
        TUICore.registerEvent(TUIConstants.TUIChat.EVENT_KEY_INPUT_MORE, TUIConstants.TUIChat.EVENT_SUB_KEY_ON_CLICK, this);
//        TUICore.registerEvent(TUIConstants.TUICalling.EVENT_KEY_CALLING, TUIConstants.TUICalling.EVENT_KEY_CALLING, this);
    }

    @Override
    public Object onCall(String method, Bundle param) {
        if (param == null) {
            return null;
        }
        Log.d(TAG, String.format("onCall, method=%s, param=%s", method, param.toString()));
        if (TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_CALL, method)) {
            String[] userIDs = param.getStringArray(TUIConstants.TUICalling.PARAM_NAME_USERIDS);
            String typeString = param.getString(TUIConstants.TUICalling.PARAM_NAME_TYPE);
            String groupID = param.getString(TUIConstants.TUICalling.PARAM_NAME_GROUPID);
            if (TUIConstants.TUICalling.TYPE_AUDIO.equals(typeString)) {
                mCallingManager.internalCall(userIDs, groupID, TUICalling.Type.AUDIO, TUICalling.Role.CALL);
            } else if (TUIConstants.TUICalling.TYPE_VIDEO.equals(typeString)) {
                mCallingManager.internalCall(userIDs, groupID, TUICalling.Type.VIDEO, TUICalling.Role.CALL);
            }
        } else if (TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_RECEIVEAPNSCALLED, method)) {
            String[] userIDs = param.getStringArray(TUIConstants.TUICalling.PARAM_NAME_USERIDS);
            String typeString = param.getString(TUIConstants.TUICalling.PARAM_NAME_TYPE);
            String groupID = param.getString(TUIConstants.TUICalling.PARAM_NAME_GROUPID);
            if (TUIConstants.TUICalling.TYPE_AUDIO.equals(typeString)) {
                mCallingManager.internalCall(userIDs, groupID, TUICalling.Type.AUDIO, TUICalling.Role.CALLED);
            } else if (TUIConstants.TUICalling.TYPE_VIDEO.equals(typeString)) {
                mCallingManager.internalCall(userIDs, groupID, TUICalling.Type.VIDEO, TUICalling.Role.CALLED);
            }
        }
        return null;
    }

    @Override
    public List<Bundle> onGetInfo(String key, Bundle param) {
        Log.d(TAG, String.format("onGetInfo, key=%s, param=%s", key, null == param ? "" : param.toString()));
        List<Bundle> bundleList = new ArrayList<>();
        Bundle bundle = new Bundle();
        bundle.putInt(TUIConstants.TUIChat.INPUT_MORE_ICON, R.drawable.trtccalling_ic_audio_call);
        bundle.putInt(TUIConstants.TUIChat.INPUT_MORE_TITLE, R.string.trtccalling_audio_call);
        bundle.putInt(TUIConstants.TUIChat.INPUT_MORE_ACTION_ID, TUIConstants.TUICalling.ACTION_ID_AUDIO_CALL);
        bundleList.add(bundle);

        bundle = new Bundle();
        bundle.putInt(TUIConstants.TUIChat.INPUT_MORE_ICON, R.drawable.trtccalling_ic_video_call);
        bundle.putInt(TUIConstants.TUIChat.INPUT_MORE_TITLE, R.string.trtccalling_video_call);
        bundle.putInt(TUIConstants.TUIChat.INPUT_MORE_ACTION_ID, TUIConstants.TUICalling.ACTION_ID_VIDEO_CALL);
        bundleList.add(bundle);
        return bundleList;
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Bundle param) {
        Log.d(TAG, String.format("onNotifyEvent, key=%s, subKey=%s, param=%s", key, subKey, null == param ? "" : param.toString()));
        if (TextUtils.equals(TUIConstants.TUIChat.EVENT_KEY_INPUT_MORE, key) && TextUtils.equals(TUIConstants.TUIChat.EVENT_SUB_KEY_ON_CLICK, subKey) && null != param) {
            final int actionId = param.getInt(TUIConstants.TUIChat.INPUT_MORE_ACTION_ID, -1);
            if (TUIConstants.TUICalling.ACTION_ID_AUDIO_CALL == actionId || TUIConstants.TUICalling.ACTION_ID_VIDEO_CALL == actionId) {
                onCall(TUIConstants.TUICalling.METHOD_NAME_CALL, param);
            }
        }
    }

    @Override
    public void onEvent(String key, Bundle bundle) {
        bundle.putString(TUIConstants.TUICalling.EVENT_KEY_NAME, key);
        TUICore.notifyEvent(TUIConstants.TUICalling.EVENT_KEY_CALLING, TUIConstants.TUICalling.EVENT_KEY_CALLING, bundle);
    }
}
