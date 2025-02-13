package com.tencent.qcloud.tuikit.tuicallkit.extensions

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuicore.util.TUIBuild
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.trtc.tuikit.common.livedata.Observer

class CallingVibratorFeature(context: Context) {
    private val context: Context = context.applicationContext
    private val vibrator: Vibrator

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        when (it) {
            TUICallDefine.Status.Waiting -> startVibrating()
            else -> stopVibrating()
        }
    }

    init {
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.S) {
            val vibratorManager = this.context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibrator = vibratorManager.defaultVibrator
        } else {
            vibrator = this.context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        addObserver()
    }

    fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe(callStatusObserver)
    }

    private fun startVibrating() {
        if (vibrator.hasVibrator()) {
            val pattern = longArrayOf(0, 500, 1500)
            if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.O) {
                val vibrationEffect = VibrationEffect.createWaveform(pattern, 1)
                vibrator.vibrate(vibrationEffect)
            } else {
                vibrator.vibrate(pattern, 1)
            }
        }
    }

    private fun stopVibrating() {
        vibrator.cancel()
        TUICallState.instance.selfUser.get().callStatus.removeObserver(callStatusObserver)
    }
}