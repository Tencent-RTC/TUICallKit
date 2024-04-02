package com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.tencent.cloud.tuikit.flutter.tuicallkit.R;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.TUICallState;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.User;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuikit.TUIVideoView;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;

import java.util.Map;

public class GroupCallFloatView extends CallFloatView implements ITUINotification {

    public static String KEY_TUISTATE_CHANGE = "tuistate_change";
    public static String SUBKEY_REFRESH_VIEW = "tuistate_change_refresh_view";

    private final Context mContext;

    private ImageView    mMicStatus;
    private ImageView    mCameraStatus;
    private TUIVideoView mTUIVideoView;
    private ImageView    mImageAvatar;
    private ImageView    mImageAudio;
    private TextView     mTextUserName;

    public GroupCallFloatView(Context context) {
        super(context);
        mContext = context;
        initView(context);
        updateView();
        registerObserver();
    }

    private void initView(Context context) {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_floatwindow_groupcall_layout, this);
        mTUIVideoView = findViewById(R.id.tui_video_view);
        mImageAvatar = findViewById(R.id.iv_avatar);
        mImageAudio = findViewById(R.id.iv_audio_icon);
        mTextStatus = findViewById(R.id.tv_call_status);
        mMicStatus = findViewById(R.id.iv_float_video_mark);
        mCameraStatus = findViewById(R.id.iv_float_audio_mark);
        mTextUserName = findViewById(R.id.tv_call_userName);

        mImageAvatar.setScaleType(ImageView.ScaleType.CENTER_CROP);
    }

    private void registerObserver() {
        TUICore.registerEvent(KEY_TUISTATE_CHANGE, SUBKEY_REFRESH_VIEW, this);
    }

    private void unRegisterObserver() {
        TUICore.unRegisterEvent(this);
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (KEY_TUISTATE_CHANGE.equals(key) && subKey.equals(SUBKEY_REFRESH_VIEW)) {
            updateView();
        }
    }

    @Override
    public void destory() {
        super.destory();
        unRegisterObserver();
    }

    private void updateView() {
        mMicStatus.setImageResource(TUICallState.getInstance().mIsMicrophoneMute &&
                TUICallState.getInstance().mSelfUser.callStatus == TUICallDefine.Status.Accept ?
                R.drawable.tuicallkit_ic_float_audio_off : R.drawable.tuicallkit_ic_float_audio_on);
        mCameraStatus.setImageResource(TUICallState.getInstance().mIsCameraOpen &&
                TUICallState.getInstance().mSelfUser.callStatus == TUICallDefine.Status.Accept ?
                R.drawable.tuicallkit_ic_float_video_on : R.drawable.tuicallkit_ic_float_video_off);

        if (TUICallState.getInstance().mSelfUser.callStatus == TUICallDefine.Status.Waiting) {
            mImageAudio.setVisibility(VISIBLE);
            mTextStatus.setVisibility(VISIBLE);
            mTUIVideoView.setVisibility(GONE);
            mImageAvatar.setVisibility(GONE);
            mTextUserName.setVisibility(GONE);

            mTextStatus.setText((String) TUICallState.getInstance().mResourceMap.get("k_0000088"));
            return;
        }

        if (TUICallState.getInstance().mSelfUser.callStatus == TUICallDefine.Status.Accept) {

            User speakingUser = getSpeakingUser();

            if (speakingUser == null) {
                mImageAudio.setVisibility(VISIBLE);
                mTextStatus.setVisibility(VISIBLE);
                mTUIVideoView.setVisibility(GONE);
                mImageAvatar.setVisibility(GONE);
                mTextUserName.setVisibility(GONE);
                startTiming();
                return;
            }

            mTextUserName.setVisibility(VISIBLE);
            mTextUserName.setText(speakingUser.nickname);
            if (speakingUser.videoAvailable ||
                    (speakingUser.id == TUICallState.getInstance().mSelfUser.id &&
                            TUICallState.getInstance().mIsCameraOpen)) {
                mImageAudio.setVisibility(GONE);
                mTextStatus.setVisibility(GONE);
                mTUIVideoView.setVisibility(VISIBLE);
                mImageAvatar.setVisibility(GONE);

                if (speakingUser.id == TUICallState.getInstance().mSelfUser.id) {
                    TUICallEngine.createInstance(mContext).openCamera(TUICallState.getInstance().mCamera,
                            mTUIVideoView,
                            null);
                } else {
                    TUICallEngine.createInstance(mContext).startRemoteView(
                            speakingUser.id,
                            mTUIVideoView,
                            null);
                }
                return;
            }

            mImageAudio.setVisibility(GONE);
            mTextStatus.setVisibility(GONE);
            mTUIVideoView.setVisibility(GONE);
            mImageAvatar.setVisibility(VISIBLE);
            if (TextUtils.isEmpty(speakingUser.avatar)) {
                mImageAvatar.setImageResource(R.drawable.tuicallkit_ic_avatar);
            } else {
                Glide.with(mContext).load(speakingUser.avatar).error(R.drawable.tuicallkit_ic_avatar).into(mImageAvatar);
            }
            return;
        }
        destory();
    }

    private User getSpeakingUser() {
        User user = null;
        for (User remoterUser : TUICallState.getInstance().mRemoteUserList) {
            if (remoterUser.playoutVolume > 30 &&
                    !(user != null && user.playoutVolume > remoterUser.playoutVolume)) {
                user = remoterUser;
            }
        }

        if (TUICallState.getInstance().mSelfUser.playoutVolume > 30 &&
                !(user != null && user.playoutVolume > TUICallState.getInstance().mSelfUser.playoutVolume)) {
            user = TUICallState.getInstance().mSelfUser;
        }
        return user;
    }
}

