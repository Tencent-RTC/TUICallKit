package com.tencent.cloud.tuikit.flutter.tuicallkit.state;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.engine.call.TUICallDefine;
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.incomingfloatwindow.IncomingFloatView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUICallState {
    public User                    mSelfUser         = new User();
    public ArrayList<User>         mRemoteUserList = new ArrayList<User>();
    public TUICallDefine.Scene     mScene          = TUICallDefine.Scene.SINGLE_CALL;
    public TUICallDefine.MediaType mMediaType      = TUICallDefine.MediaType.Audio;
    public int                    mStartTime   = 0;
    public TUICommonDefine.Camera mCamera      = TUICommonDefine.Camera.Front;
    public Map                    mResourceMap = new HashMap();
    public Boolean                 mIsMicrophoneMute = false;
    public Boolean                 mIsCameraOpen     = false;
    public IncomingFloatView mIncomingFloatView;
    private TUICallState() {
    }

    public static TUICallState getInstance() {
        return TUICallStateHolder.instance;
    }

    @NonNull
    @Override
    public String toString() {
        return "TUICallState:{" +
                "mSelfUser: " + mSelfUser.toString() +
                ", mRemoteUser: " + mRemoteUserList +
                ", mScene: " + mScene +
                ", mMediaType: " + mMediaType +
                ", mStartTime: " + mStartTime +
                ", mCamera: " + mCamera +
                ", mIsMicrophoneMute" + mIsMicrophoneMute +
                ", mIsCameraOpen" + mIsCameraOpen +
                "}";
    }

    private static class TUICallStateHolder {
        private static TUICallState instance = new TUICallState();
    }
}
