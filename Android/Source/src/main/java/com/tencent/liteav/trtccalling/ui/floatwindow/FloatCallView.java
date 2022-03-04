package com.tencent.liteav.trtccalling.ui.floatwindow;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.liteav.renderer.TXCGLSurfaceView;
import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.TUICalling;
import com.tencent.liteav.trtccalling.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtccalling.model.util.TUICallingConstants;
import com.tencent.liteav.trtccalling.ui.base.BaseCallActivity;
import com.tencent.liteav.trtccalling.ui.base.BaseTUICallView;
import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCVideoLayout;
import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCVideoLayoutManager;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.rtmp.ui.TXCloudVideoView;

public class FloatCallView extends BaseTUICallView {
    private static final String TAG = "FloatCallView";

    private TXCloudVideoView mTXCloudVideoView;  //userId对应的视频画面
    private ImageView        mAudioView;         //语音图标
    private TextView         mTextViewWaiting;
    private TextView         mTextViewTimeCount;
    private String           mRemoteUserId;      //对端用户,主叫保存第一个被叫;被叫保存主叫
    private TUICalling.Type  mCallType;          //通话类型
    private TXCloudVideoView mVideoView;
    private String           mNewUser;           //新进房的用户
    private int              mCount;

    private static final int UPDATE_COUNT    = 3;   //视频加载最大次数
    private static final int UPDATE_INTERVAL = 300; //视频重加载间隔(单位:ms)

    public FloatCallView(Context context, TUICalling.Role role, TUICalling.Type type,
                         String[] userIDs, String sponsorID, String groupID, boolean isFromGroup) {
        super(context, role, userIDs, sponsorID, groupID, isFromGroup);
        mCallType = type;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        initData();
        initListener();
        showFloatWindow();
    }

    private void initData() {
        if (TUICalling.Role.CALL == mRole) {
            for (String userId : mUserIDs) {
                mRemoteUserId = userId;
                return;
            }
        } else if (TUICalling.Role.CALLED == mRole) {
            mRemoteUserId = mSponsorID;
        } else {
            TRTCLogger.i(TAG, "initData mRole: " + mRole);
        }
    }

    @Override
    protected void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.trtccalling_floatwindow_layout, this);
        mTXCloudVideoView = findViewById(R.id.float_videoView);
        mTextViewWaiting = findViewById(R.id.tv_waiting_response);
        mAudioView = findViewById(R.id.float_audioView);
        mTextViewTimeCount = findViewById(R.id.tv_time);
    }

    private void showFloatWindow() {
        TRTCLogger.i(TAG, "showFloatWindow: CallStatus = " + FloatWindowStatus.mCallStatus
                + " , mRemoteUser = " + mRemoteUserId);
        if (FloatWindowStatus.CALL_STATUS.NONE == FloatWindowStatus.mCallStatus) {
            return;
        }
        if (FloatWindowStatus.mCallStatus == FloatWindowStatus.CALL_STATUS.ACCEPT) {
            mTextViewWaiting.setVisibility(View.GONE);
            mTextViewTimeCount.setVisibility(View.VISIBLE);
            showTimeCount(mTextViewTimeCount);
            updateView(mRemoteUserId);
        } else {
            mTextViewWaiting.setVisibility(View.VISIBLE);
            mTextViewTimeCount.setVisibility(View.GONE);
            updateView(TUILogin.getUserId());
        }
    }

    //更新显示
    private void updateView(String userId) {
        if (TUICalling.Type.VIDEO.equals(mCallType)) {
            if (isGroupCall()) {
                mTXCloudVideoView.setVisibility(GONE);
                mAudioView.setVisibility(View.VISIBLE);
            } else {
                mAudioView.setVisibility(View.GONE);
                mTextViewWaiting.setVisibility(View.GONE);
                mTextViewTimeCount.setVisibility(View.GONE);
                mTXCloudVideoView.setVisibility(VISIBLE);
                updateVideoFloatWindow(userId);
            }
        } else if (TUICalling.Type.AUDIO.equals(mCallType)) {
            mTXCloudVideoView.setVisibility(GONE);
            mAudioView.setVisibility(View.VISIBLE);
        }
        //更新当前悬浮窗状态
        FloatWindowStatus.mCurFloatUserId = userId;
        FloatWindowStatus.mIsShowFloatWindow = true;
    }

    //更新视频通话界面
    //视频通话未接通时,悬浮窗显示自己的画面,
    //视频通话已接听,悬浮窗显示对端画面.
    private void updateVideoFloatWindow(String userId) {
        if (TextUtils.isEmpty(userId)) {
            TRTCLogger.d(TAG, "userId is empty");
            return;
        }
        TRTCVideoLayoutManager videoLayoutManager = FloatWindowStatus.mVideoLayoutManager;
        if (null == videoLayoutManager) {
            TRTCLogger.d(TAG, "videoLayoutManager is empty");
            return;
        }

        mTXCloudVideoView.removeAllViews();
        TRTCVideoLayout videoLayout = videoLayoutManager.findCloudView(userId);
        if (null == videoLayout) {
            videoLayout = videoLayoutManager.allocCloudVideoView(userId);
        }
        TRTCLogger.i(TAG, "updateVideoFloatWindow: userId = " + userId + " ,videoLayout: " + videoLayout);
        TXCloudVideoView renderView = videoLayout.getVideoView();
        if (null == renderView) {
            TRTCLogger.d(TAG, "video renderView is empty");
            return;
        }
        if (userId.equals(TUILogin.getLoginUser())) {
            TXCGLSurfaceView mTXCGLSurfaceView = renderView.getGLSurfaceView();
            if (mTXCGLSurfaceView != null && mTXCGLSurfaceView.getParent() != null) {
                ((ViewGroup) mTXCGLSurfaceView.getParent()).removeView(mTXCGLSurfaceView);
                mTXCloudVideoView.addVideoView(mTXCGLSurfaceView);
            }
        } else {
            TextureView mTextureView = renderView.getVideoView();
            TRTCLogger.i(TAG, "updateVideoFloatWindow: mTextureView = " + mTextureView);
            if (null != mTextureView) {
                if (null != mTextureView.getParent()) {
                    ((ViewGroup) mTextureView.getParent()).removeView(mTextureView);
                }
                mTXCloudVideoView.addVideoView(mTextureView);
            }
        }
    }

    private void initListener() {
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(mContext, BaseCallActivity.class);
                intent.putExtra(TUICallingConstants.PARAM_NAME_TYPE, mCallType);
                intent.putExtra(TUICallingConstants.PARAM_NAME_ROLE, mRole);
                if (TUICalling.Role.CALLED == mRole) {
                    intent.putExtra(TUICallingConstants.PARAM_NAME_SPONSORID, mSponsorID);
                    intent.putExtra(TUICallingConstants.PARAM_NAME_ISFROMGROUP, mIsFromGroup);
                }
                intent.putExtra(TUICallingConstants.PARAM_NAME_USERIDS, mUserIDs);
                intent.putExtra(TUICallingConstants.PARAM_NAME_GROUPID, mGroupID);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                mContext.startActivity(intent);
            }
        });
    }

    @Override
    public void onUserEnter(String userId) {
        super.onUserEnter(userId);
        if (!FloatWindowStatus.mIsShowFloatWindow) {
            return;
        }
        //语音通话和群聊,用户进房后更新悬浮窗状态
        if (TUICalling.Type.AUDIO == mCallType || isGroupCall()) {
            mTextViewWaiting.setVisibility(GONE);
            mTextViewTimeCount.setVisibility(VISIBLE);
            showTimeCount(mTextViewTimeCount);
        }
    }

    @Override
    public void onUserVideoAvailable(String userId, boolean isVideoAvailable) {
        if (!FloatWindowStatus.mIsShowFloatWindow) {
            return;
        }
        //单聊有用户的视频开启了,摄像头开关状态改变
        FloatWindowStatus.mCallStateChanged = true;
        TRTCVideoLayoutManager videoLayoutManager = FloatWindowStatus.mVideoLayoutManager;
        if (null == videoLayoutManager) {
            TRTCLogger.d(TAG, "videoLayoutManager is empty,ignore");
            return;
        }
        TRTCVideoLayout layout = videoLayoutManager.findCloudView(userId);
        if (null == layout) {
            return;
        }
        layout.setVideoAvailable(isVideoAvailable);
        if (isVideoAvailable) {
            mVideoView = layout.getVideoView();
            mNewUser = userId;
            //TextureView绘制会慢一点,等view准备好了,再去更新悬浮窗显示
            if (null == mVideoView.getVideoView()) {
                mVideoViewHandler.sendEmptyMessageDelayed(0, UPDATE_INTERVAL);
            } else {
                mTRTCCalling.startRemoteView(mNewUser, mVideoView);
                updateView(mNewUser);
            }
        } else {
            mTRTCCalling.stopRemoteView(userId);
        }
    }

    @Override
    public void onCallEnd() {
        super.onCallEnd();
        //通话结束,停止悬浮窗显示
        if (FloatWindowStatus.mIsShowFloatWindow) {
            FloatWindowService.stopService(mContext);
            finish();
        }
    }

    private final Handler mVideoViewHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            if (null == mVideoView.getVideoView() && mCount <= UPDATE_COUNT) {
                sendEmptyMessageDelayed(0, UPDATE_INTERVAL);
                mCount++;
            } else {
                mTRTCCalling.startRemoteView(mNewUser, mVideoView);
                updateView(mNewUser);
            }
        }
    };

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        //悬浮窗这里拦截掉,否则不能响应onTouch事件
        return true;
    }

    @Override
    protected void onDetachedFromWindow() {
        TRTCLogger.i(TAG, "onDetachedFromWindow");
        mVideoViewHandler.removeCallbacksAndMessages(null);
        super.onDetachedFromWindow();
    }
}
