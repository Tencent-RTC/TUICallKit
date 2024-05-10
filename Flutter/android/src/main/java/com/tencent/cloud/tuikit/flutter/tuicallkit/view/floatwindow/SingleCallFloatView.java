package com.tencent.cloud.tuikit.flutter.tuicallkit.view.floatwindow;

import static com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants.KEY_TUISTATE_CHANGE;
import static com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants.SUBKEY_REFRESH_VIEW;

import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.bumptech.glide.Glide;
import com.tencent.cloud.tuikit.flutter.tuicallkit.R;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.TUICallState;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.User;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.TUIVideoView;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;

import java.util.Map;

public class SingleCallFloatView extends CallFloatView implements ITUINotification {
    private final Context mContext;

    private RelativeLayout mRelativeLayout;
    private TUIVideoView   mTUIVideoView;
    private ImageView      mImageAvatar;
    private ImageView      mImageAudio;
    private boolean        mIsCameraOpen = false;
    public SingleCallFloatView(Context context) {
        super(context);
        mContext = context;
        initView(context);
        updateView();
        registerObserver();
    }

    private void initView(Context context) {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_floatwindow_singlecall_layout, this);
        mRelativeLayout = findViewById(R.id.ll_root);
        mTUIVideoView = findViewById(R.id.tui_video_view);
        mImageAvatar = findViewById(R.id.iv_avatar);
        mImageAudio = findViewById(R.id.iv_audio_icon);
        mTextStatus = findViewById(R.id.tv_call_status);
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
        if (TUICallState.getInstance().mMediaType == TUICallDefine.MediaType.Audio) {
            mImageAudio.setVisibility(VISIBLE);
            mTextStatus.setVisibility(VISIBLE);
            mTUIVideoView.setVisibility(GONE);
            mImageAvatar.setVisibility(GONE);

            RelativeLayout.LayoutParams textParams = new RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.WRAP_CONTENT,
                    RelativeLayout.LayoutParams.WRAP_CONTENT);
            textParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
            int topMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 48,
                    getResources().getDisplayMetrics());
            textParams.topMargin = topMargin;
            mTextStatus.setLayoutParams(textParams);
            mTextStatus.setTextColor(Color.argb(255, 41, 204, 133));

            FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) mRelativeLayout.getLayoutParams();
            layoutParams.width = ScreenUtil.dip2px(72);
            layoutParams.height = ScreenUtil.dip2px(72);
            mRelativeLayout.setLayoutParams(layoutParams);
            mRelativeLayout.setBackgroundColor(Color.argb(255, 255, 255, 255));

            if (TUICallState.getInstance().mSelfUser.callStatus == TUICallDefine.Status.Waiting) {
                mTextStatus.setText((String) TUICallState.getInstance().mResourceMap.get("k_0000088"));
            } else if (TUICallState.getInstance().mSelfUser.callStatus == TUICallDefine.Status.Accept) {
                startTiming();
            } else {
                destory();
            }
            return;
        }

        if (TUICallState.getInstance().mMediaType == TUICallDefine.MediaType.Video) {
            mImageAudio.setVisibility(GONE);

            FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) mRelativeLayout.getLayoutParams();
            layoutParams.width = ScreenUtil.dip2px(110);
            layoutParams.height = ScreenUtil.dip2px(196);
            mRelativeLayout.setLayoutParams(layoutParams);
            mRelativeLayout.setBackgroundColor(Color.argb(255, 60, 60, 60));

            RelativeLayout.LayoutParams textParams = new RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.WRAP_CONTENT,
                    RelativeLayout.LayoutParams.WRAP_CONTENT);
            textParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
            int topMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 140,
                    getResources().getDisplayMetrics());
            textParams.topMargin = topMargin;
            mTextStatus.setLayoutParams(textParams);
            mTextStatus.setTextColor(Color.argb(255, 214, 214, 214));

            if (TUICallState.getInstance().mSelfUser.callStatus == TUICallDefine.Status.Waiting) {
                mTUIVideoView.setVisibility(VISIBLE);
                mTextStatus.setVisibility(VISIBLE);
                mImageAvatar.setVisibility(GONE);
                mTextStatus.setText((String) TUICallState.getInstance().mResourceMap.get("k_0000088"));
                if (!mIsCameraOpen) {
                    mIsCameraOpen = true;
                    TUICallEngine.createInstance(mContext).openCamera(TUICallState.getInstance().mCamera,
                            mTUIVideoView, null);
                }
                return;
            }

            if (TUICallState.getInstance().mSelfUser.callStatus == TUICallDefine.Status.Accept) {
                mTextStatus.setVisibility(GONE);
                if (TUICallState.getInstance().mRemoteUserList.isEmpty()) {
                    destory();
                    return;
                }
                User remoteUser = TUICallState.getInstance().mRemoteUserList.get(0);

                if (remoteUser.videoAvailable) {
                    if (mTUIVideoView.getVisibility() == VISIBLE) {
                        return;
                    }
                    mTUIVideoView.setVisibility(VISIBLE);
                    mImageAvatar.setVisibility(GONE);
                    TUICallEngine.createInstance(mContext).startRemoteView(
                            remoteUser.id,
                            mTUIVideoView,
                            null);
                } else {
                    mTUIVideoView.setVisibility(GONE);
                    mImageAvatar.setVisibility(VISIBLE);
                    if (TextUtils.isEmpty(remoteUser.avatar)) {
                        mImageAvatar.setImageResource(R.drawable.tuicallkit_ic_avatar);
                    } else {
                        Glide.with(mContext).load(remoteUser.avatar).error(R.drawable.tuicallkit_ic_avatar).into(mImageAvatar);
                    }
                }
                return;
            }
        }
        destory();
    }
}

