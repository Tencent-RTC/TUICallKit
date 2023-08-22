package com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.tencent.cloud.tuikit.flutter.tuicallkit.R;
import com.tencent.cloud.tuikit.flutter.tuicallkit.TUICallKitPlugin;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.TUICallState;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitAppUtils;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuikit.TUIVideoView;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;

import java.util.Date;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

public class FloatCallView extends RelativeLayout implements ITUINotification {

    public static String KEY_TUISTATE_CHANGE = "tuistate_change";
    public static String SUBKEY_REFRESH_VIEW = "tuistate_change_refresh_view";

    private final Context mContext;

    private TUIVideoView mTUIVideoView;
    private ImageView    mImageAvatar;
    private ImageView    mImageAudio;
    private TextView     mTextStatus;
    private Timer        mTimer        = new Timer();
    private TimerTask    mTimerTask;
    private boolean      mIsCameraOpen = false;

    public FloatCallView(Context context) {
        super(context);
        mContext = context;
        initView(context);
        updateView();
        registerObserver();
    }

    private void initView(Context context) {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_floatwindow_layout, this);
        mTUIVideoView = findViewById(R.id.tui_video_view);
        mImageAvatar = findViewById(R.id.iv_avatar);
        mImageAudio = findViewById(R.id.iv_audio_icon);
        mTextStatus = findViewById(R.id.tv_call_status);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        return true;
    }

    private void updateView() {
        if (TUICallState.getInstance().mMediaType == TUICallDefine.MediaType.Audio
                || TUICallState.getInstance().mScene == TUICallDefine.Scene.GROUP_CALL) {
            mImageAudio.setVisibility(VISIBLE);
            mTextStatus.setVisibility(VISIBLE);
            mTUIVideoView.setVisibility(GONE);
            mImageAvatar.setVisibility(GONE);
            if (TUICallState.getInstance().mSelfUser.callStatus == TUICallDefine.Status.Waiting) {
                mTextStatus.setText((String) TUICallState.getInstance().mResourceMap.get("k_0000088"));
            } else if (TUICallState.getInstance().mSelfUser.callStatus == TUICallDefine.Status.Accept) {
                startTiming();
            } else {
                destory();
            }
        } else if (TUICallState.getInstance().mMediaType == TUICallDefine.MediaType.Video) {
            mImageAudio.setVisibility(GONE);
            mTextStatus.setVisibility(GONE);
            if (TUICallState.getInstance().mSelfUser.callStatus == TUICallDefine.Status.Waiting) {
                mTUIVideoView.setVisibility(VISIBLE);
                mImageAvatar.setVisibility(GONE);
                if (!mIsCameraOpen) {
                    mIsCameraOpen = true;
                    TUICallEngine.createInstance(mContext).openCamera(TUICallState.getInstance().mCamera, mTUIVideoView, null);
                }
            } else if (TUICallState.getInstance().mSelfUser.callStatus == TUICallDefine.Status.Accept) {
                if (TUICallState.getInstance().mRemoteUser.videoAvailable) {
                    mTUIVideoView.setVisibility(VISIBLE);
                    mImageAvatar.setVisibility(GONE);
                    TUICallEngine.createInstance(mContext).startRemoteView(
                            TUICallState.getInstance().mRemoteUser.id,
                            mTUIVideoView,
                            null);
                } else {
                    mTUIVideoView.setVisibility(GONE);
                    mImageAvatar.setVisibility(VISIBLE);
                    if (TextUtils.isEmpty(TUICallState.getInstance().mRemoteUser.avatar)) {
                        mImageAvatar.setImageResource(R.drawable.tuicallkit_ic_avatar);
                    } else {
                        Glide.with(mContext).load(TUICallState.getInstance().mRemoteUser.avatar).error(R.drawable.tuicallkit_ic_avatar).into(mImageAvatar);
                    }
                }
            } else {
                destory();
            }
        } else {
            destory();
        }
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (KEY_TUISTATE_CHANGE.equals(key) && subKey.equals(SUBKEY_REFRESH_VIEW)) {
            updateView();
        }
    }

    private void registerObserver() {
        TUICore.registerEvent(KEY_TUISTATE_CHANGE, SUBKEY_REFRESH_VIEW, this);
    }

    private void unRegisterObserver() {
        TUICore.unRegisterEvent(this);
    }


    public void destory() {
        unRegisterObserver();
        stopTiming();
        FloatWindowService.stopFloatWindow(mContext);
        if (TUICallState.getInstance().mSelfUser.callStatus != TUICallDefine.Status.None) {
            if (KitAppUtils.isAppInForeground(mContext)) {
                TUICallKitPlugin.gotoCallingPage();
            } else {
                KitAppUtils.moveAppToForeground(mContext, KitAppUtils.EVENT_START_CALL_PAGE);
            }
        }
    }

    private void startTiming() {
        mTimerTask = new TimerTask() {
            @Override
            public void run() {
                mTextStatus.post(new Runnable() {
                    @Override
                    public void run() {
                        long timeCount = new Date().getTime() / 1000 - TUICallState.getInstance().mStartTime;
                        mTextStatus.setText(String.format("%02d:%02d", timeCount / 60, timeCount % 60));
                    }
                });
            }
        };
        mTimer.schedule(mTimerTask, 0, 1000);
    }

    private void stopTiming() {
        mTimer.cancel();
        mTimerTask = null;
    }
}

