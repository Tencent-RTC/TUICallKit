package com.tencent.liteav.trtccalling.ui.floatwindow;

import android.animation.ValueAnimator;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Binder;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.gson.Gson;
import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.model.impl.base.CallModel;
import com.tencent.liteav.trtccalling.model.impl.base.TRTCLogger;
import com.tencent.rtmp.ui.TXCloudVideoView;

/**
 * TUICalling组件悬浮窗服务
 * 组件通过home键或者左上角按钮退到后台时,拉起悬浮窗;
 * 点击悬浮窗可重新进入界面,且悬浮窗消失,
 * 直接点击桌面icon,也可重新进入界面,悬浮窗消失
 */
public class FloatWindowService extends Service {
    private static final String TAG = "FloatWindowService";

    private static  Intent  startIntent;
    protected final Handler mMainHandler = new Handler(Looper.getMainLooper());

    private WindowManager              mWindowManager;
    private WindowManager.LayoutParams mWindowLayoutParams;
    private View                       mFloatingLayout;    //浮动布局
    private TXCloudVideoView           mTXCloudVideoView;  //userId对应的视频
    private ImageView                  mAudioView;         //语音图标
    private TextView                   mTextViewWaiting;
    private TextView                   mTextViewTimeCount;

    private String mCallType = CallModel.VALUE_CMD_VIDEO_CALL; //通话类型:VideoCall/AudioCall
    private String mRemoteUserId;      //保存被叫端的userId
    private int    mScreenWidth;       //屏幕宽度
    private int    mWidth;             //悬浮窗宽度

    public static void startFloatService(Context context, String data) {
        FloatJsonData jsonData = new Gson().fromJson(data, FloatJsonData.class);
        if (null == jsonData) {
            TRTCLogger.d(TAG, "startFloatService: jsonData is empty");
            return;
        }
        Log.d(TAG, "startFloatService");
        startIntent = new Intent(context, FloatWindowService.class);
        startIntent.putExtra(FloatConstants.USER_ID, jsonData.getUserId());
        startIntent.putExtra(FloatConstants.CALL_TYPE, jsonData.getCallType());
        startIntent.putExtra(FloatConstants.GROUP_CALL, jsonData.isGroup());
        context.startService(startIntent);
        FloatConstants.mServiceStart = true;
    }

    public static void stopService(Context context) {
        context.stopService(startIntent);
        clearFloatStatus();
    }

    private static void clearFloatStatus() {
        FloatConstants.mServiceStart = false;
        FloatConstants.mIsShowFloatWindow = false;
        FloatConstants.mBeginTime = 0;
        FloatConstants.mIsGroupCall = false;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        initWindow();
        initView();
        initListener();
    }

    @Override
    public void onStart(Intent intent, int startId) {
        super.onStart(intent, startId);
        updateFloating();  //悬浮框更新
    }

    @Override
    public IBinder onBind(Intent intent) {
        updateFloating();  //悬浮框更新
        return new FloatBinder();
    }

    public class FloatBinder extends Binder {
        public FloatWindowService getService() {
            return FloatWindowService.this;
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (null != mFloatingLayout) {
            // 移除悬浮窗口
            mWindowManager.removeView(mFloatingLayout);
            mFloatingLayout = null;
            clearFloatStatus();
        }
    }

    /**
     * 设置悬浮框基本参数（位置、宽高等）
     */
    private void initWindow() {
        mWindowManager = (WindowManager) getApplicationContext().getSystemService(Context.WINDOW_SERVICE);
        //设置好悬浮窗的参数
        mWindowLayoutParams = getParams();
        //得到容器，通过这个inflater来获得悬浮窗控件
        LayoutInflater inflater = LayoutInflater.from(getApplicationContext());
        // 获取浮动窗口视图所在布局
        mFloatingLayout = inflater.inflate(R.layout.trtccalling_floatwindow_layout, null);
        // 添加悬浮窗的视图
        mWindowManager.addView(mFloatingLayout, mWindowLayoutParams);
    }

    private WindowManager.LayoutParams getParams() {
        mWindowLayoutParams = new WindowManager.LayoutParams();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            mWindowLayoutParams.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            mWindowLayoutParams.type = WindowManager.LayoutParams.TYPE_PHONE;
        }
        mWindowLayoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                | WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS;

        // 悬浮窗默认显示以左上角为起始坐标
        mWindowLayoutParams.gravity = Gravity.LEFT | Gravity.TOP;
        //悬浮窗的开始位置，因为设置的是从左上角开始，所以屏幕左上角是x=0;y=0
        mWindowLayoutParams.x = 0;
        mWindowLayoutParams.y = 240;
        //设置悬浮窗口长宽数据
        mWindowLayoutParams.width = WindowManager.LayoutParams.WRAP_CONTENT;
        mWindowLayoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
        mWindowLayoutParams.format = PixelFormat.TRANSPARENT;
        //屏幕宽度
        mScreenWidth = mWindowManager.getDefaultDisplay().getWidth();
        return mWindowLayoutParams;
    }

    private void initView() {
        mTXCloudVideoView = mFloatingLayout.findViewById(R.id.float_videoview);
        mTextViewWaiting = mFloatingLayout.findViewById(R.id.tv_waiting_reponse);
        mAudioView = mFloatingLayout.findViewById(R.id.float_audioview);
        mTextViewTimeCount = mFloatingLayout.findViewById(R.id.tv_time);
    }

    private void initListener() {
        //悬浮框触摸事件，设置悬浮框可拖动
        mTXCloudVideoView.setOnTouchListener(new FloatingListener());
        //悬浮框点击事件
        mTXCloudVideoView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //点击重新回到通话界面Activity
            }
        });
        mAudioView.setOnTouchListener(new FloatingListener());
        mAudioView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //点击重新回到通话界面Activity
            }
        });
    }

    //更新悬浮窗布局
    private void updateFloating() {
        //更新状态
        FloatConstants.mIsShowFloatWindow = true;
    }

    //未接通时调用,更新显示
    private void updateView(String userId) {
        //单人视频通话时需要显示自己的画面
        if (mCallType.equals(CallModel.VALUE_CMD_VIDEO_CALL)) {

        } else if (mCallType.equals(CallModel.VALUE_CMD_AUDIO_CALL)) {

        }
        //更新当前悬浮窗显示的userId
        FloatConstants.mCurFloatUserId = userId;
    }

    //=================================================================================================//
    //=========================================悬浮窗Touch和贴边事件======================================//
    //=================================================================================================//
    //开始触控的坐标，移动时的坐标（相对于屏幕左上角的坐标）
    private int mTouchStartX, mTouchStartY, mTouchCurrentX, mTouchCurrentY;
    //开始触控的坐标和结束时的坐标（相对于屏幕左上角的坐标）
    private int mStartX, mStartY, mStopX, mStopY;
    //判断悬浮窗口是否移动，这里做个标记，防止移动后松手触发了点击事件
    private boolean mIsMove;

    private class FloatingListener implements View.OnTouchListener {
        @Override
        public boolean onTouch(View v, MotionEvent event) {
            int action = event.getAction();
            switch (action) {
                case MotionEvent.ACTION_DOWN:
                    mIsMove = false;
                    mTouchStartX = (int) event.getRawX(); //触摸点相对屏幕显示器左上角的坐标
                    mTouchStartY = (int) event.getRawY();
                    //service起的悬浮窗不是全屏的,因此不能用getX()标记开始点,getX()是触摸点相对自身左上角的坐标
                    mStartX = (int) event.getRawX();
                    mStartY = (int) event.getRawY();
                    break;
                case MotionEvent.ACTION_MOVE:
                    mTouchCurrentX = (int) event.getRawX();
                    mTouchCurrentY = (int) event.getRawY();
                    mWindowLayoutParams.x += mTouchCurrentX - mTouchStartX;
                    mWindowLayoutParams.y += mTouchCurrentY - mTouchStartY;
                    mWindowManager.updateViewLayout(mFloatingLayout, mWindowLayoutParams);

                    mTouchStartX = mTouchCurrentX;
                    mTouchStartY = mTouchCurrentY;
                case MotionEvent.ACTION_UP:
                    mStopX = (int) event.getRawX();
                    mStopY = (int) event.getRawY();
                    if (Math.abs(mStartX - mStopX) >= 5 || Math.abs(mStartY - mStopY) >= 5) {
                        mIsMove = true;
                        mWidth = mFloatingLayout.getWidth();
                        //超所一半屏幕右移
                        if (mTouchCurrentX > (mScreenWidth / 2)) {
                            startScroll(mStopX, mScreenWidth - mWidth, false);
                        } else {
                            startScroll(mStopX, 0, true);
                        }
                    }
                    break;
                default:
                    break;
            }
            //如果是移动事件不触发OnClick事件，防止移动的时候一放手形成点击事件
            return mIsMove;
        }

    }

    //悬浮窗贴边动画
    private void startScroll(int start, int end, boolean isLeft) {
        mWidth = mFloatingLayout.getWidth();
        ValueAnimator valueAnimator = ValueAnimator.ofFloat(start, end).setDuration(300);
        valueAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                if (isLeft) {
                    mWindowLayoutParams.x = (int) (start * (1 - animation.getAnimatedFraction()));
                    mFloatingLayout.setBackgroundResource(R.drawable.trtccalling_bg_floatwindow_left);
                } else {
                    mWindowLayoutParams.x = (int) (start + (mScreenWidth - start - mWidth) * animation.getAnimatedFraction());
                    mFloatingLayout.setBackgroundResource(R.drawable.trtccalling_bg_floatwindow_right);
                }
                mWindowManager.updateViewLayout(mFloatingLayout, mWindowLayoutParams);
            }
        });
        valueAnimator.start();
    }
}
