package com.tencent.cloud.tuikit.flutter.tuicallkit.service;

import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Handler;
import android.os.HandlerThread;

public class CallingBellService {
    private MediaPlayer   mMediaPlayer;
    private Handler       mHandler;
    private HandlerThread mHandlerThread;
    private Runnable      mPlayRunnable;
    private String        mRingFilePath = "";


    public CallingBellService() {
        mMediaPlayer = new MediaPlayer();
    }

    public void startRing(String filePath) {
        mRingFilePath = filePath;
        startHandlerThread();
        mHandler.post(mPlayRunnable);
    }

    public void stopRing() {
        mRingFilePath = "";
        stopHandlerThread();
    }

    private void startHandlerThread() {
        if (null != mHandler) {
            return;
        }
        mHandlerThread = new HandlerThread("CallingBell");
        mHandlerThread.start();
        mHandler = new Handler(mHandlerThread.getLooper());
        mPlayRunnable = new Runnable() {
            @Override
            public void run() {
                if (mMediaPlayer.isPlaying()) {
                    mMediaPlayer.stop();
                }
                mMediaPlayer.reset();
                mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);

                try {
                    mMediaPlayer.setDataSource(mRingFilePath);
                    mMediaPlayer.setLooping(true);
                    mMediaPlayer.prepare();
                    mMediaPlayer.start();

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        };
    }

    private void stopHandlerThread() {
        if (null == mHandler) {
            return;
        }
        if (mMediaPlayer.isPlaying()) {
            mMediaPlayer.stop();
        }
        if (mHandler != null) {
            mHandler.removeCallbacks(mPlayRunnable);
            mHandler = null;
        }
        mPlayRunnable = null;
        if (mHandlerThread != null) {
            mHandlerThread.quitSafely();
            mHandlerThread = null;
        }
    }
}
