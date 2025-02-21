package com.tencent.qcloud.tuikit.tuicallkit

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.call.TUICallEngine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.interfaces.ITUINotification
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuicore.permission.PermissionRequester
import com.tencent.qcloud.tuicore.util.SPUtils
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.data.OfflinePushInfoConfig
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingBellFeature
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingVibratorFeature
import com.tencent.qcloud.tuikit.tuicallkit.extensions.NotificationFeature
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils
import com.tencent.qcloud.tuikit.tuicallkit.utils.Logger
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.utils.UserInfoUtils
import com.tencent.qcloud.tuikit.tuicallkit.view.CallKitActivity
import com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingview.IncomingFloatView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.incomingview.IncomingNotificationView

class TUICallKitImpl private constructor(context: Context) : TUICallKit(), ITUINotification {
    private val context: Context = context.applicationContext
    private var callingBellFeature: CallingBellFeature? = null
    private var callingVibratorFeature: CallingVibratorFeature? = null
    private val mainHandler: Handler = Handler(Looper.getMainLooper())

    init {
        registerCallingEvent()
    }

    companion object {
        private const val TAG = "TUICallKitImpl"
        private const val TAG_VIEW = "IncomingView"
        private var instance: TUICallKitImpl? = null
        fun createInstance(context: Context): TUICallKitImpl {
            if (null == instance) {
                synchronized(TUICallKitImpl::class.java) {
                    if (null == instance) {
                        instance = TUICallKitImpl(context)
                    }
                }
            }
            return instance!!
        }
    }

    override fun setSelfInfo(nickname: String?, avatar: String?, callback: TUICommonDefine.Callback?) {
        Logger.info(TAG, "setSelfInfo, nickname:$nickname, avatar:$avatar")
        TUICallEngine.createInstance(context).setSelfInfo(nickname, avatar, callback)
    }

    override fun call(userId: String, callMediaType: TUICallDefine.MediaType) {
        Logger.info(TAG, "call userId:$userId, callMediaType:$callMediaType")
        val params = TUICallDefine.CallParams()
        params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(context)
        params.timeout = Constants.SIGNALING_MAX_TIME
        call(userId, callMediaType, params, null)
    }

    override fun call(
        userId: String, callMediaType: TUICallDefine.MediaType,
        params: TUICallDefine.CallParams?, callback: TUICommonDefine.Callback?
    ) {
        Logger.info(TAG, "call, userId:$userId, callMediaType:$callMediaType, params:${params?.toString()}")
        EngineManager.instance.call(userId, callMediaType, params, object :
            TUICommonDefine.Callback {
            override fun onSuccess() {
                callingBellFeature = CallingBellFeature(context)
                val intent = Intent(context, CallKitActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(intent)
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String?) {
                callback?.onError(errCode, errMsg)
            }
        })
    }

    override fun groupCall(groupId: String, userIdList: List<String?>?, callMediaType: TUICallDefine.MediaType) {
        Logger.info(TAG, "groupCall, groupId:$groupId, userIdList:$userIdList, callMediaType:$callMediaType")
        val params = TUICallDefine.CallParams()
        params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(context)
        params.timeout = Constants.SIGNALING_MAX_TIME
        groupCall(groupId, userIdList, callMediaType, params, null)
    }

    override fun groupCall(
        groupId: String, userIdList: List<String?>?, mediaType: TUICallDefine.MediaType,
        params: TUICallDefine.CallParams?, callback: TUICommonDefine.Callback?
    ) {
        Logger.info(TAG, "groupCall, groupId:$groupId, userIdList:$userIdList, mediaType: $mediaType, params:$params")
        EngineManager.instance.groupCall(groupId, userIdList, mediaType, params, object : TUICommonDefine.Callback {
            override fun onSuccess() {
                callingBellFeature = CallingBellFeature(context)
                val intent = Intent(context, CallKitActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(intent)
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String?) {
                callback?.onError(errCode, errMsg)
            }
        })
    }

    override fun calls(
        userIdList: List<String?>?, mediaType: TUICallDefine.MediaType?, params: TUICallDefine.CallParams?,
        callback: TUICommonDefine.Callback?
    ) {
        EngineManager.instance.calls(userIdList, mediaType, params, object : TUICommonDefine.Callback {
            override fun onSuccess() {
                callingBellFeature = CallingBellFeature(context)
                val intent = Intent(context, CallKitActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(intent)
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String?) {
                callback?.onError(errCode, errMsg)
            }
        })
    }

    override fun join(callId: String?, callback: TUICommonDefine.Callback?) {
        EngineManager.instance.join(callId, callback)
    }

    override fun joinInGroupCall(
        roomId: TUICommonDefine.RoomId?,
        groupId: String?,
        mediaType: TUICallDefine.MediaType?
    ) {
        Logger.info(TAG, "joinInGroupCall, roomId:$roomId, groupId:$groupId, mediaType:$mediaType")
        EngineManager.instance.joinInGroupCall(roomId, groupId, mediaType)
    }

    override fun setCallingBell(filePath: String?) {
        Logger.info(TAG, "setCallingBell, filePath:$filePath")
        SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLKIT)
            .put(CallingBellFeature.PROFILE_CALL_BELL, filePath)
    }

    override fun enableMuteMode(enable: Boolean) {
        Logger.info(TAG, "enableMuteMode, enable:$enable")
        EngineManager.instance.enableMuteMode(enable)
    }

    override fun enableFloatWindow(enable: Boolean) {
        Logger.info(TAG, "enableFloatWindow, enable:$enable")
        EngineManager.instance.enableFloatWindow(enable)
    }

    override fun enableVirtualBackground(enable: Boolean) {
        Logger.info(TAG, "enableVirtualBackground, enable:$enable")
        TUICallState.instance.showVirtualBackgroundButton = enable

        val data = HashMap<String, Any>()
        data[Constants.KEY_VIRTUAL_BACKGROUND] = enable
        EngineManager.instance.reportOnlineLog(data)
    }

    override fun enableIncomingBanner(enable: Boolean) {
        Logger.info(TAG, "enableIncomingBanner, enable:$enable")
        TUICallState.instance.enableIncomingBanner = enable
    }

    override fun setScreenOrientation(orientation: Int) {
        Logger.info(TAG, "setScreenOrientation, orientation:$orientation")
        if (orientation in 0..2) {
            TUICallState.instance.orientation = Constants.Orientation.values()[orientation]
        }

        if (orientation == Constants.Orientation.LandScape.ordinal) {
            val videoEncoderParams = TUICommonDefine.VideoEncoderParams()
            videoEncoderParams.resolutionMode = TUICommonDefine.VideoEncoderParams.ResolutionMode.Landscape
            TUICallEngine.createInstance(context).setVideoEncoderParams(videoEncoderParams, null)
        }
    }

    fun queryOfflineCall() {
        Logger.info(TAG, "queryOfflineCall start")
        if (TUICallDefine.Status.Accept != TUICallState.instance.selfUser.get().callStatus.get()) {
            val role: TUICallDefine.Role = TUICallState.instance.selfUser.get().callRole.get()
            val mediaType: TUICallDefine.MediaType = TUICallState.instance.mediaType.get()
            if (TUICallDefine.Role.None == role || TUICallDefine.MediaType.Unknown == mediaType) {
                return
            }

            //The received call has been processed in #onCallReceived
            if (TUICallDefine.Role.Called == role && PermissionRequester.newInstance(PermissionRequester.BG_START_PERMISSION)
                    .has()
            ) {
                return
            }
            PermissionRequest.requestPermissions(context, mediaType, object : PermissionCallback() {
                override fun onGranted() {
                    Logger.info(TAG, "queryOfflineCall requestPermissions onGranted")
                    if (TUICallDefine.Status.None != TUICallState.instance.selfUser.get().callStatus.get()) {
                        var intent = Intent(context, CallKitActivity::class.java)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        context.startActivity(intent)
                    } else {
                        TUICallState.instance.clear()
                    }
                }

                override fun onDenied() {
                    if (TUICallDefine.Role.Called == role) {
                        TUICallEngine.createInstance(context).reject(null)
                    }
                }
            })
        }
    }

    private fun registerCallingEvent() {
        TUICore.registerEvent(
            TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this
        )
        TUICore.registerEvent(
            TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS, this
        )

        TUICore.registerEvent(Constants.EVENT_TUICALLKIT_CHANGED, Constants.EVENT_START_ACTIVITY, this)
        TUICore.registerEvent(Constants.EVENT_TUICALLKIT_CHANGED, Constants.EVENT_START_INCOMING_VIEW, this)
    }

    override fun onNotifyEvent(key: String, subKey: String, param: Map<String?, Any>?) {
        if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED == key) {
            if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS == subKey) {
                TUICallEngine.createInstance(context).hangup(null)
                TUICallEngine.destroyInstance()
                TUICallState.instance.clear()
            } else if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS == subKey) {
                TUICallEngine.createInstance(context).addObserver(TUICallState.instance.mTUICallObserver)
                initCallEngine()
            }
        }

        if (Constants.EVENT_TUICALLKIT_CHANGED == key) {
            if (Constants.EVENT_START_ACTIVITY == subKey) {
                startFullScreenView()
            } else if (Constants.EVENT_START_INCOMING_VIEW == subKey) {
                handleNewCall()
            }
        }
    }

    private fun handleNewCall() {
        mainHandler.post {
            if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
                Logger.warn(TAG_VIEW, "handleNewCall, current status: None, ignore")
                return@post
            }
            callingBellFeature = CallingBellFeature(context)
            callingVibratorFeature = CallingVibratorFeature(context)

            val hasFloatPermission = PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()
            val isAppInBackground: Boolean = !DeviceUtils.isAppRunningForeground(context)
            val hasBgPermission = PermissionRequester.newInstance(PermissionRequester.BG_START_PERMISSION).has()
            val hasNotificationPermission = PermissionRequest.isNotificationEnabled()

            val isFCMData = isFCMDataNotification()

            Logger.info(
                TAG_VIEW, "handleNewCall, isAppInBackground: $isAppInBackground, " +
                        "floatPermission: $hasFloatPermission, " +
                        "backgroundStartPermission: $hasBgPermission, " +
                        "notificationPermission: $hasNotificationPermission , " +
                        "isFCMDataNotification: $isFCMData, " +
                        "enableIncomingBanner:${TUICallState.instance.enableIncomingBanner}"
            )

            if (DeviceUtils.isScreenLocked(context)) {
                Logger.info(TAG_VIEW, "handleNewCall, screen is locked, try to pop up call full screen view")
                if (isAppInBackground && isFCMData && hasNotificationPermission) {
                    startSmallScreenView(IncomingNotificationView(context))
                } else {
                    startFullScreenView()
                }
                return@post
            }

            if (!TUICallState.instance.enableIncomingBanner) {
                if (isAppInBackground) {
                    when {
                        isFCMData && hasFloatPermission -> startSmallScreenView(IncomingFloatView(context))
                        isFCMData && hasNotificationPermission -> startSmallScreenView(IncomingNotificationView(context))
                        hasBgPermission -> startFullScreenView()
                        else -> {
                            Logger.warn(TAG_VIEW, "App is in background with no permission")
                        }
                    }
                } else {
                    startFullScreenView()
                }

                return@post
            }

            if (isAppInBackground) {
                when {
                    hasFloatPermission -> startSmallScreenView(IncomingFloatView(context))
                    isFCMData && hasNotificationPermission -> startSmallScreenView(IncomingNotificationView(context))
                    hasBgPermission -> startFullScreenView()
                    else -> {
                        Logger.warn(TAG_VIEW, "App is in background with no permission")
                    }
                }
                return@post
            }

            when {
                hasFloatPermission -> startSmallScreenView(IncomingFloatView(context))
                hasNotificationPermission -> startSmallScreenView(IncomingNotificationView(context))
                else -> startFullScreenView()
            }
        }
    }

    private fun isFCMDataNotification(): Boolean {
        return TUICore.getService(TUIConstants.TIMPush.SERVICE_NAME) != null
                && TUIConfig.getCustomData("pushChannelId") == TUIConstants.DeviceInfo.BRAND_GOOGLE_ELSE
    }

    private fun startFullScreenView() {
        Logger.info(TAG_VIEW, "startFullScreenView")
        mainHandler.post {
            if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
                Logger.warn(TAG_VIEW, "startFullScreenView, current status: None, ignore")
                return@post
            }
            PermissionRequest.requestPermissions(context, TUICallState.instance.mediaType.get(), object :
                PermissionCallback() {
                override fun onGranted() {
                    if (TUICallDefine.Status.None != TUICallState.instance.selfUser.get().callStatus.get()) {
                        Logger.info(TAG_VIEW, "startFullScreenView requestPermissions onGranted")
                        val intent = Intent(context, CallKitActivity::class.java)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        context.startActivity(intent)
                    } else {
                        TUICallState.instance.clear()
                    }
                }

                override fun onDenied() {
                    if (TUICallState.instance.selfUser.get().callRole.get() == TUICallDefine.Role.Called) {
                        TUICallEngine.createInstance(context).reject(null)
                    }
                    TUICallState.instance.clear()
                }
            })
        }
    }

    private fun startSmallScreenView(view: Any) {
        var caller: User = TUICallState.instance.selfUser.get()
        for (user in TUICallState.instance.remoteUserList.get()) {
            if (user.callRole.get() == TUICallDefine.Role.Caller) {
                caller = user
                break
            }
        }

        val list = ArrayList<String>()
        caller.id?.let { list.add(it) }

        UserInfoUtils.getUserListInfo(list, object : TUICommonDefine.ValueCallback<List<User>?> {
            override fun onSuccess(data: List<User>?) {
                if (data.isNullOrEmpty()) {
                    return
                }
                if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
                    Logger.warn(TAG_VIEW, "startSmallScreenView, current status: None, ignore")
                    return
                }
                caller.avatar.set(data[0].avatar.get())
                caller.nickname.set(data[0].nickname.get())

                if (view is IncomingFloatView) {
                    view.showIncomingView(caller)
                } else if (view is IncomingNotificationView) {
                    view.showNotification(caller)
                }
            }

            override fun onError(errCode: Int, errMsg: String?) {
                if (view is IncomingFloatView) {
                    view.showIncomingView(caller)
                } else if (view is IncomingNotificationView) {
                    view.showNotification(caller)
                }
            }
        })
    }

    private fun initCallEngine() {
        TUICallEngine.createInstance(context).init(
            TUILogin.getSdkAppId(), TUILogin.getLoginUser(), TUILogin.getUserSig(), object : TUICommonDefine.Callback {
                override fun onSuccess() {
                    TUICallEngine.createInstance(context).addObserver(TUICallState.instance.mTUICallObserver)

                    val notificationFeature = NotificationFeature()
                    notificationFeature.createCallNotificationChannel(context)
                }

                override fun onError(errCode: Int, errMsg: String) {}
            })
    }
}