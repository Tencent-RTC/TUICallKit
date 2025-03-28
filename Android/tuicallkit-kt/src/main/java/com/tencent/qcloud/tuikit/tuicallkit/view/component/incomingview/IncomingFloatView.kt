package com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingview

import android.content.Context
import android.content.Context.WINDOW_SERVICE
import android.content.res.Configuration
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.interfaces.ITUINotification
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuicore.util.ScreenUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.utils.Logger
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory
import com.trtc.tuikit.common.livedata.Observer

class IncomingFloatView(context: Context) : RelativeLayout(context) {
    companion object {
        private const val TAG = "IncomingViewFloat"
    }

    private var appContext: Context = context.applicationContext
    private var caller: User? = null

    private var windowManager: WindowManager? = null
    private var windowLayoutParams: WindowManager.LayoutParams? = null

    private lateinit var layoutView: View
    private var imageFloatAvatar: ImageView? = null
    private var textFloatTitle: TextView? = null
    private var textFloatDescription: TextView? = null
    private var imageReject: ImageView? = null
    private var imageAccept: ImageView? = null

    private val padding = 40

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.None || it == TUICallDefine.Status.Accept) {
            cancelIncomingView()
        }
    }

    private val notification = ITUINotification { key, subKey, param ->
        if (key == Constants.EVENT_VIEW_STATE_CHANGED &&
            (subKey == Constants.EVENT_SHOW_FULL_VIEW || subKey == Constants.EVENT_SHOW_FLOAT_VIEW)) {
            cancelIncomingView()
        }
    }

    fun showIncomingView(user: User) {
        Logger.info(TAG, "showIncomingView, user: $user")
        caller = user
        initWindow()
        addObserver()
    }

    fun cancelIncomingView() {
        Logger.info(TAG, "cancelIncomingView")
        if (layoutView.isAttachedToWindow) {
            windowManager?.removeView(layoutView)
        }
        removeObserver()
    }

    private fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe(callStatusObserver)
        TUICore.registerEvent(Constants.EVENT_VIEW_STATE_CHANGED, Constants.EVENT_SHOW_FULL_VIEW, notification)
        TUICore.registerEvent(Constants.EVENT_VIEW_STATE_CHANGED, Constants.EVENT_SHOW_FLOAT_VIEW, notification)
    }

    private fun removeObserver() {
        TUICallState.instance.selfUser.get().callStatus.removeObserver(callStatusObserver)
        TUICore.unRegisterEvent(notification)
    }

    private fun initWindow() {
        layoutView = LayoutInflater.from(context).inflate(R.layout.tuicallkit_incoming_float_view, this)
        imageFloatAvatar = layoutView.findViewById(R.id.img_float_avatar)
        textFloatTitle = layoutView.findViewById(R.id.tv_float_title)
        textFloatDescription = layoutView.findViewById(R.id.tv_float_desc)
        imageReject = layoutView.findViewById(R.id.btn_float_decline)
        imageAccept = layoutView.findViewById(R.id.btn_float_accept)

        ImageLoader.loadImage(appContext, imageFloatAvatar, caller?.avatar?.get(), R.drawable.tuicallkit_ic_avatar)
        textFloatTitle?.text = caller?.nickname?.get()

        textFloatDescription?.text = if (TUICallState.instance.mediaType.get() == TUICallDefine.MediaType.Video) {
            appContext.resources.getString(R.string.tuicallkit_invite_video_call)
        } else {
            appContext.resources.getString(R.string.tuicallkit_invite_audio_call)
        }

        imageReject?.setOnClickListener {
            EngineManager.instance.reject(null)
            cancelIncomingView()
        }

        layoutView.setOnClickListener {
            cancelIncomingView()
            TUICore.notifyEvent(Constants.EVENT_TUICALLKIT_CHANGED, Constants.EVENT_START_ACTIVITY, HashMap())
        }

        if (TUICallState.instance.mediaType.get() == TUICallDefine.MediaType.Video) {
            imageAccept?.setBackgroundResource(R.drawable.tuicallkit_ic_dialing_video)
        } else {
            imageAccept?.setBackgroundResource(R.drawable.tuicallkit_bg_dialing)
        }
        imageAccept?.setOnClickListener {
            if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
                Logger.warn(TAG, "current status is None, ignore")
                cancelIncomingView()
                return@setOnClickListener
            }

            PermissionRequest.requestPermissions(appContext, TUICallState.instance.mediaType.get(),
                object : PermissionCallback() {
                    override fun onGranted() {
                        if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
                            Logger.warn(TAG, "current status is None, ignore")
                            cancelIncomingView()
                            return
                        }
                        Logger.info(TAG, "accept the call")
                        TUICore.notifyEvent(
                            Constants.EVENT_TUICALLKIT_CHANGED, Constants.EVENT_START_ACTIVITY, HashMap()
                        )
                        EngineManager.instance.accept(null)
                        if (TUICallState.instance.mediaType.get() == TUICallDefine.MediaType.Video) {
                            val videoView = VideoViewFactory.instance.createVideoView(
                                TUICallState.instance.selfUser.get(), appContext
                            )

                            EngineManager.instance.openCamera(
                                TUICallState.instance.isFrontCamera.get(), videoView?.getVideoView(), null
                            )
                        }
                        cancelIncomingView()
                    }

                    override fun onDenied() {
                        super.onDenied()
                        EngineManager.instance.reject(null)
                        cancelIncomingView()
                    }
                })
        }

        windowManager = appContext.getSystemService(WINDOW_SERVICE) as WindowManager
        windowManager?.addView(layoutView, viewParams)
    }

    private val viewParams: WindowManager.LayoutParams
        get() {
            windowLayoutParams = WindowManager.LayoutParams()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                windowLayoutParams!!.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                windowLayoutParams!!.type = WindowManager.LayoutParams.TYPE_PHONE
            }
            windowLayoutParams!!.flags = (WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                    or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                    or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
            windowLayoutParams!!.gravity = Gravity.START or Gravity.TOP
            windowLayoutParams!!.x = padding
            windowLayoutParams!!.y = 0
            windowLayoutParams!!.width = ScreenUtil.getScreenWidth(appContext) - padding * 2
            windowLayoutParams!!.height = WindowManager.LayoutParams.WRAP_CONTENT
            windowLayoutParams!!.format = PixelFormat.TRANSPARENT
            return windowLayoutParams as WindowManager.LayoutParams
        }

    override fun onConfigurationChanged(newConfig: Configuration?) {
        super.onConfigurationChanged(newConfig)
        layoutView?.let { windowManager?.updateViewLayout(layoutView, viewParams) }
    }
}