package com.tencent.cloud.tuikit.flutter.tuicallkit.utils;

import android.content.Context;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Handler;
import android.os.HandlerThread;

import com.tencent.cloud.tuikit.engine.call.TUICallDefine;
import com.tencent.cloud.tuikit.engine.call.TUICallEngine;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.TUICallState;
import com.tencent.liteav.audio.TXAudioEffectManager;

public class CallingBellPlayer {
    private final Context mContext;

    private MediaPlayer   mMediaPlayer;
    private Handler       mHandler;
    private HandlerThread mHandlerThread;
    private Runnable      mPlayRunnable;
    private String        mRingFilePath = "";
    private int           AUDIO_DIAL_ID = 48;

    public CallingBellPlayer(Context mContext) {
        this.mContext = mContext;
        mMediaPlayer = new MediaPlayer();
    }

    public void startRing(String filePath) {
        mRingFilePath = filePath;
        if (TUICallState.getInstance().mSelfUser.callRole == TUICallDefine.Role.Caller) {
            startPlayAudioByTRTC(mRingFilePath, AUDIO_DIAL_ID);
        } else if (TUICallState.getInstance().mSelfUser.callRole == TUICallDefine.Role.Called) {
            startHandlerThread();
            mHandler.post(mPlayRunnable);
        }
    }

    public void stopRing() {
        mRingFilePath = "";
        if (TUICallState.getInstance().mSelfUser.callRole == TUICallDefine.Role.Caller) {
            stopPlayAudioByTRTC(AUDIO_DIAL_ID);
        } else if (TUICallState.getInstance().mSelfUser.callRole == TUICallDefine.Role.Called) {
            stopHandlerThread();
        }
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
                mMediaPlayer.setAudioStreamType(AudioManager.STREAM_RING);

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

    private void startPlayAudioByTRTC(String filepath, int id) {
        TXAudioEffectManager.AudioMusicParam param = new TXAudioEffectManager.AudioMusicParam(id, filepath);
        TUICallEngine.createInstance(mContext).getTRTCCloudInstance().getAudioEffectManager().startPlayMusic(param);
        TUICallEngine.createInstance(mContext).getTRTCCloudInstance().getAudioEffectManager().setMusicPlayoutVolume(id, 100);
    }

    private void stopPlayAudioByTRTC(int id) {
        TUICallEngine.createInstance(mContext).getTRTCCloudInstance().getAudioEffectManager().stopPlayMusic(id);
    }
}
