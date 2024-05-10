package com.tencent.cloud.tuikit.flutter.tuicallkit.view.floatwindow;

import android.content.Context;
import android.content.Intent;
import android.view.MotionEvent;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.tencent.cloud.tuikit.flutter.tuicallkit.state.TUICallState;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.WindowManager;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;

import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

public class CallFloatView extends FrameLayout {

    private   Context   mContext;
    protected TextView  mTextStatus;
    protected Timer     mTimer = new Timer();
    protected TimerTask mTimerTask;

    public CallFloatView(Context context) {
        super(context);
        mContext = context;
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        return true;
    }

    public void destory() {
        stopTiming();
        Intent mStartIntent = new Intent(mContext, FloatWindowService.class);
        mContext.stopService(mStartIntent);

        if (TUICallState.getInstance().mSelfUser.callStatus != TUICallDefine.Status.None) {
            WindowManager.backCallingPageFromFloatWindow(mContext);
        }
    }

    protected void startTiming() {
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

    protected void stopTiming() {
        mTimer.cancel();
        mTimerTask = null;
    }
}
