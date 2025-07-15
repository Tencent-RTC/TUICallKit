package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.AudioPlaybackDevice
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.livedata.Observer

class AudioCallerWaitingAndAcceptedView(context: Context) : RelativeLayout(context) {
    private lateinit var buttonMicrophone: ControlButton
    private lateinit var buttonAudioDevice: ControlButton
    private lateinit var buttonHangup: ControlButton

    private var isMicMuteObserver = Observer<Boolean> {
        buttonMicrophone.imageView.isActivated = it
        buttonMicrophone.textView.text = getMicText()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        this.layoutParams?.width = LayoutParams.MATCH_PARENT
        this.layoutParams?.height = LayoutParams.MATCH_PARENT
        initView()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
    }

    private fun registerObserver() {
        CallManager.instance.mediaState.isMicrophoneMuted.observe(isMicMuteObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.mediaState.isMicrophoneMuted.removeObserver(isMicMuteObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_audio, this)
        buttonMicrophone = findViewById(R.id.cb_mic)
        buttonHangup = findViewById(R.id.cb_hangup)
        buttonAudioDevice = findViewById(R.id.cb_audio_device)

        val buttonSet = GlobalState.instance.disableControlButtonSet
        buttonMicrophone.visibility = if (buttonSet.contains(Constants.ControlButton.Microphone)) GONE else VISIBLE
        buttonAudioDevice.visibility =
            if (buttonSet.contains(Constants.ControlButton.AudioPlaybackDevice)) GONE else VISIBLE

        buttonMicrophone.imageView.isActivated = CallManager.instance.mediaState.isMicrophoneMuted.get()
        buttonAudioDevice.imageView.isActivated =
            CallManager.instance.mediaState.audioPlayoutDevice.get() == AudioPlaybackDevice.Speakerphone
        buttonMicrophone.textView.text = getMicText()
        buttonAudioDevice.textView.text = getAudioDeviceText()

        initViewListener()
    }

    private fun initViewListener() {
        buttonMicrophone.setOnClickListener {
            if (!buttonMicrophone.isEnabled) {
                return@setOnClickListener
            }
            if (CallManager.instance.mediaState.isMicrophoneMuted.get()) {
                CallManager.instance.openMicrophone(null)
            } else {
                CallManager.instance.closeMicrophone()
            }
        }
        buttonHangup.setOnClickListener {
            buttonHangup.imageView.roundPercent = 1.0f
            buttonHangup.imageView.setBackgroundColor(ContextCompat.getColor(context, R.color.tuicallkit_button_bg_red))
            ImageLoader.loadGif(context, buttonHangup.imageView, R.drawable.tuicallkit_hangup_loading)
            disableButton(buttonMicrophone)
            disableButton(buttonAudioDevice)

            CallManager.instance.hangup(null)
        }
        buttonAudioDevice.setOnClickListener {
            if (!buttonAudioDevice.isEnabled) {
                return@setOnClickListener
            }
            val isSpeaker = CallManager.instance.mediaState.audioPlayoutDevice.get() == AudioPlaybackDevice.Speakerphone
            val device = if (isSpeaker) AudioPlaybackDevice.Earpiece else AudioPlaybackDevice.Speakerphone
            CallManager.instance.selectAudioPlaybackDevice(device)
            buttonAudioDevice.textView.text = getAudioDeviceText()
            buttonAudioDevice.imageView.isActivated = !isSpeaker
        }
    }

    private fun disableButton(button: ControlButton) {
        button.isEnabled = false
        button.alpha = 0.8f
    }

    private fun getMicText(): String {
        return if (CallManager.instance.mediaState.isMicrophoneMuted.get()) {
            context.getString(R.string.tuicallkit_toast_enable_mute)
        } else {
            context.getString(R.string.tuicallkit_toast_disable_mute)
        }
    }

    private fun getAudioDeviceText(): String {
        return if (CallManager.instance.mediaState.audioPlayoutDevice.get() == AudioPlaybackDevice.Speakerphone) {
            context.getString(R.string.tuicallkit_toast_speaker)
        } else {
            context.getString(R.string.tuicallkit_toast_use_earpiece)
        }
    }
}