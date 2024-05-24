package com.tencent.cloud.tuikit.flutter.tuicallkit.utils;

import android.app.Activity;
import android.view.WindowManager;

public class WakeLock {
    private static WakeLock mInstance;
    private Activity mActivity;
    private boolean mIsEnabled = false;
    private boolean mIsKeepScreenOn = false;
    private boolean mIsTurnScreenOn = false;
    private boolean mIsDismissKeyguard = false;
    private boolean mIsShowWhenLocked = false;
    private WakeLock() { }
    public static synchronized WakeLock getInstance() {
        if (mInstance == null) {
            mInstance = new WakeLock();
        }
        return mInstance;
    }

    public void setActivity(Activity activity) {
        this.mActivity = activity;
    }

    public void enable() {
        if (mActivity == null || mIsEnabled) {
            return;
        }
        mIsEnabled = true;
        mIsKeepScreenOn = (mActivity.getWindow().getAttributes().flags & WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON) != 0;
        mIsTurnScreenOn = (mActivity.getWindow().getAttributes().flags & WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON) != 0;
        mIsDismissKeyguard = (mActivity.getWindow().getAttributes().flags & WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD) != 0;
        mIsShowWhenLocked = (mActivity.getWindow().getAttributes().flags & WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED) != 0;

        if (!mIsKeepScreenOn) {
            mActivity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
        if (!mIsTurnScreenOn) {
            mActivity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
        }
        if (!mIsDismissKeyguard) {
            mActivity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD);
        }
        if (!mIsShowWhenLocked) {
            mActivity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED);
        }
    }

    public void disable() {
        if (mActivity == null || !mIsEnabled) {
            return;
        }
        mIsEnabled = false;

        if (!mIsKeepScreenOn) {
            mActivity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
        if (!mIsTurnScreenOn) {
            mActivity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
        }
        if (!mIsDismissKeyguard) {
            mActivity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD);
        }
        if (!mIsShowWhenLocked) {
            mActivity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED);
        }
    }
}
