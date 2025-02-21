package com.tencent.cloud.tuikit.flutter.tuicallkit.utils;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Vibrator;

public class CallingVibrator {
    private final Context mContext;

    private Handler       mHandler;
    private HandlerThread mHandlerThread;
    private Vibrator      mVibrator;

    public CallingVibrator(Context context) {
        this.mContext = context.getApplicationContext();
        mVibrator = (Vibrator) mContext.getSystemService(Context.VIBRATOR_SERVICE);
    }

    public void startVibration() {
        mHandlerThread = new HandlerThread("CallingVibrator");
        mHandlerThread.start();
        mHandler = new Handler(mHandlerThread.getLooper());
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mVibrator.hasVibrator()) {
                    mVibrator.vibrate(500);
                    mHandler.postDelayed(this, 1500);
                }}
        });
    }

    public void stopVibration() {
        if (mHandlerThread != null) {
            mHandlerThread.quitSafely();
        }
        mVibrator.cancel();
    }
}
