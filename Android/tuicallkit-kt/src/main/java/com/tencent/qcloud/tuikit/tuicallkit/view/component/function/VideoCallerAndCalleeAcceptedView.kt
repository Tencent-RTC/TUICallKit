package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.RelativeLayout
import androidx.constraintlayout.utils.widget.ImageFilterView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import androidx.transition.ChangeBounds
import androidx.transition.TransitionManager
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.AudioPlaybackDevice
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoFactory
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.livedata.Observer
import com.trtc.tuikit.common.util.ScreenUtil

class VideoCallerAndCalleeAcceptedView(context: Context) : RelativeLayout(context) {
    private lateinit var rootView: ConstraintLayout
    private lateinit var imageHangup: ImageFilterView
    private lateinit var imageSwitchCamera: ImageView
    private lateinit var imageExpandView: ImageView
    private lateinit var imageBlurBackground: ImageView

    private lateinit var buttonMicrophone: ControlButton
    private lateinit var buttonAudioDevice: ControlButton
    private lateinit var buttonCamera: ControlButton

    private var isBottomViewExpand: Boolean = true
    private var enableTransition: Boolean = false
    private val originalSet = ConstraintSet()
    private val rowSet = ConstraintSet()

    private var isCameraOpenObserver = Observer<Boolean> {
        buttonCamera.imageView.isActivated = it
        buttonCamera.textView.text = when {
            it -> context.getString(R.string.tuicallkit_toast_enable_camera)
            else -> context.getString(R.string.tuicallkit_toast_disable_camera)
        }

        showSwitchCamera(it)
        showBlurBackground(it)
    }

    private fun showSwitchCamera(show: Boolean) {
        if (GlobalState.instance.disableControlButtonSet.contains(Constants.ControlButton.SwitchCamera)
            || CallManager.instance.callState.scene.get() != TUICallDefine.Scene.SINGLE_CALL) {
            imageSwitchCamera.visibility = GONE
            return
        }
        imageSwitchCamera.visibility = if (show) VISIBLE else GONE
    }

    private fun showBlurBackground(show: Boolean) {
        if (!GlobalState.instance.enableVirtualBackground
            || CallManager.instance.callState.scene.get() != TUICallDefine.Scene.SINGLE_CALL) {
            imageBlurBackground.visibility = GONE
            return
        }
        imageBlurBackground.visibility = if (show) VISIBLE else GONE
    }

    private val isMicOpenObserver = Observer<Boolean> {
        val resId = if (it) {
            R.string.tuicallkit_toast_enable_mute
        } else {
            R.string.tuicallkit_toast_disable_mute
        }
        buttonMicrophone.textView.text = context.getString(resId)
        buttonMicrophone.imageView.isActivated = it
    }

    private val showLargeViewUserObserver = Observer<String> {
        startAnimation(it.isNullOrEmpty())
        enableTransition = true
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        this.layoutParams?.width = LayoutParams.MATCH_PARENT
        this.layoutParams?.height = LayoutParams.MATCH_PARENT
        enableTransition = false
        initView()
        registerObserver()
        initViewListener()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
    }

    private fun registerObserver() {
        CallManager.instance.mediaState.isCameraOpened.observe(isCameraOpenObserver)
        CallManager.instance.mediaState.isMicrophoneMuted.observe(isMicOpenObserver)
        CallManager.instance.viewState.showLargeViewUserId.observe(showLargeViewUserObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.mediaState.isCameraOpened.removeObserver(isCameraOpenObserver)
        CallManager.instance.mediaState.isMicrophoneMuted.removeObserver(isMicOpenObserver)
        CallManager.instance.viewState.showLargeViewUserId.removeObserver(showLargeViewUserObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_video, this)
        rootView = findViewById(R.id.cl_view_video)
        buttonMicrophone = findViewById(R.id.cb_microphone)
        buttonAudioDevice = findViewById(R.id.cb_speaker)
        buttonCamera = findViewById(R.id.cb_open_camera)

        imageHangup = findViewById(R.id.iv_hang_up)
        imageSwitchCamera = findViewById(R.id.iv_function_switch_camera)
        imageBlurBackground = findViewById(R.id.img_blur_background)
        imageExpandView = findViewById(R.id.iv_expanded)

        val isMute = CallManager.instance.mediaState.isMicrophoneMuted.get()
        buttonMicrophone.imageView.isActivated = isMute
        val micResId = if (isMute) R.string.tuicallkit_toast_disable_mute else R.string.tuicallkit_toast_enable_mute
        buttonMicrophone.textView.text = context.getString(micResId)

        val isSpeaker = CallManager.instance.mediaState.audioPlayoutDevice.get() == AudioPlaybackDevice.Speakerphone
        val speakerResId = if (isSpeaker) R.string.tuicallkit_toast_speaker else R.string.tuicallkit_toast_use_earpiece
        buttonAudioDevice.imageView.isActivated = isSpeaker
        buttonAudioDevice.textView.text = context.getString(speakerResId)

        val buttonSet = GlobalState.instance.disableControlButtonSet
        buttonMicrophone.visibility = if (buttonSet.contains(Constants.ControlButton.Microphone)) GONE else VISIBLE
        buttonAudioDevice.visibility =
            if (buttonSet.contains(Constants.ControlButton.AudioPlaybackDevice)) GONE else VISIBLE
        buttonCamera.visibility = if (buttonSet.contains(Constants.ControlButton.Camera)) GONE else VISIBLE

        val isCameraOpened = CallManager.instance.mediaState.isCameraOpened.get()
        showSwitchCamera(isCameraOpened)
        showBlurBackground(isCameraOpened)

        imageExpandView.visibility = if (enableTransition) View.VISIBLE else View.GONE

        originalSet.clone(rootView)
        rowSet.clone(rootView)
        buildRowConstraint(rowSet)

        if (!CallManager.instance.viewState.showLargeViewUserId.get().isNullOrEmpty()) {
            startAnimation(false)
        }
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
        buttonAudioDevice.setOnClickListener {
            if (!buttonAudioDevice.isEnabled) {
                return@setOnClickListener
            }
            val device =
                if (CallManager.instance.mediaState.audioPlayoutDevice.get() == AudioPlaybackDevice.Speakerphone) {
                    AudioPlaybackDevice.Earpiece
                } else {
                    AudioPlaybackDevice.Speakerphone
                }
            val resId = if (device == AudioPlaybackDevice.Speakerphone) {
                R.string.tuicallkit_toast_speaker
            } else {
                R.string.tuicallkit_toast_use_earpiece
            }

            CallManager.instance.selectAudioPlaybackDevice(device)
            buttonAudioDevice.textView.text = context.getString(resId)
            buttonAudioDevice.imageView.isActivated = device == AudioPlaybackDevice.Speakerphone
        }
        buttonCamera.setOnClickListener {
            if (!buttonCamera.isEnabled) {
                return@setOnClickListener
            }
            if (CallManager.instance.mediaState.isCameraOpened.get()) {
                CallManager.instance.closeCamera()
            } else {
                val selfUser = CallManager.instance.userState.selfUser.get()
                val camera: TUICommonDefine.Camera = CallManager.instance.mediaState.isFrontCamera.get()
                val videoView = VideoFactory.instance.findVideoView(selfUser.id)

                CallManager.instance.openCamera(camera, videoView, null)
                if (CallManager.instance.callState.scene.get() != TUICallDefine.Scene.SINGLE_CALL) {
                    if (CallManager.instance.viewState.showLargeViewUserId.get() != selfUser.id) {
                        CallManager.instance.viewState.showLargeViewUserId.set(selfUser.id)
                    }
                }
            }
        }

        imageHangup.setOnClickListener {
            imageHangup.roundPercent = 1.0f
            imageHangup.setBackgroundColor(ContextCompat.getColor(context, R.color.tuicallkit_button_bg_red))
            ImageLoader.loadGif(context, imageHangup, R.drawable.tuicallkit_hangup_loading)

            disableButton(buttonMicrophone)
            disableButton(buttonAudioDevice)
            disableButton(buttonCamera)
            disableButton(imageSwitchCamera)
            disableButton(imageBlurBackground)

            CallManager.instance.hangup(null)
        }

        imageExpandView.setOnClickListener() {
            startAnimation(!isBottomViewExpand)
        }

        imageBlurBackground.setOnClickListener {
            if (!imageBlurBackground.isEnabled) {
                return@setOnClickListener
            }
            CallManager.instance.setBlurBackground(!CallManager.instance.viewState.isVirtualBackgroundOpened.get())
        }

        imageSwitchCamera.setOnClickListener() {
            if (!imageSwitchCamera.isEnabled) {
                return@setOnClickListener
            }
            var camera = TUICommonDefine.Camera.Back
            if (CallManager.instance.mediaState.isFrontCamera.get() == TUICommonDefine.Camera.Back) {
                camera = TUICommonDefine.Camera.Front
            }
            CallManager.instance.switchCamera(camera)
        }
    }

    private fun disableButton(button: View) {
        button.isEnabled = false
        button.alpha = 0.8f
    }

    private fun startAnimation(isExpand: Boolean) {
        if (CallManager.instance.callState.scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            return
        }
        rootView.background = ContextCompat.getDrawable(context, R.drawable.tuicallkit_bg_group_call_bottom)
        if (!enableTransition) {
            return
        }
        if (isExpand == isBottomViewExpand) {
            return
        }
        isBottomViewExpand = isExpand

        val transition = ChangeBounds().apply { duration = 300 }
        TransitionManager.beginDelayedTransition(rootView, transition)
        if (isExpand) {
            originalSet.applyTo(rootView)
        } else {
            rowSet.applyTo(rootView)
            imageExpandView.rotation = 180f
        }
        imageExpandView.visibility = if (enableTransition) View.VISIBLE else View.GONE
        setControlButtonTextVisible(isExpand)
    }

    private fun setControlButtonTextVisible(visible: Boolean) {
        val buttonSet = GlobalState.instance.disableControlButtonSet
        buttonMicrophone.textView.visibility =
            if (visible && !buttonSet.contains(Constants.ControlButton.Microphone)) View.VISIBLE else View.GONE
        buttonAudioDevice.textView.visibility =
            if (visible && !buttonSet.contains(Constants.ControlButton.AudioPlaybackDevice)) View.VISIBLE else View.GONE
        buttonCamera.textView.visibility =
            if (visible && !buttonSet.contains(Constants.ControlButton.Camera)) View.VISIBLE else View.GONE
    }

    private fun buildRowConstraint(set: ConstraintSet) {
        val disableButtonSet = GlobalState.instance.disableControlButtonSet

        val buttonIds = mutableListOf(imageExpandView.id).apply {
            if (!disableButtonSet.contains(Constants.ControlButton.Microphone)) {
                add(buttonMicrophone.id)
            }
            if (!disableButtonSet.contains(Constants.ControlButton.AudioPlaybackDevice)) {
                add(buttonAudioDevice.id)
            }
            if (!disableButtonSet.contains(Constants.ControlButton.Camera)) {
                add(buttonCamera.id)
            }
            add(imageHangup.id)
        }

        buttonIds.forEach {
            set.clear(it)
            set.setVisibility(it, View.VISIBLE)
            set.constrainWidth(it, ConstraintSet.WRAP_CONTENT)
            set.constrainHeight(it, ConstraintSet.WRAP_CONTENT)
        }
        set.createHorizontalChainRtl(
            ConstraintSet.PARENT_ID, ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.END,
            buttonIds.toIntArray(), null, ConstraintSet.CHAIN_SPREAD
        )
        val margin = ScreenUtil.dip2px(20f)
        buttonIds.forEach {
            set.connect(it, ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP, margin)
            set.connect(it, ConstraintSet.BOTTOM, ConstraintSet.PARENT_ID, ConstraintSet.BOTTOM, margin)
        }
        set.setMargin(imageExpandView.id, ConstraintSet.START, margin)
        set.setMargin(imageHangup.id, ConstraintSet.END, margin)
    }
}