package com.tencent.qcloud.tuikit.tuicallkit.internal

import android.content.Context
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.interfaces.ITUINotification
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit
import org.json.JSONException
import org.json.JSONObject

internal class TUICallKitService private constructor(context: Context) : ITUINotification {
    private var appContext: Context

    init {
        appContext = context
        TUICore.registerEvent(
            TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT, this
        )
    }

    override fun onNotifyEvent(key: String, subKey: String, param: Map<String, Any>?) {
        if (TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED == key
            && TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT == subKey
        ) {
            TUICallKit.createInstance(appContext)
            adaptiveComponentReport()
        }
    }

    private fun adaptiveComponentReport() {
        val service = TUICore.getService(TUIConstants.TUIChat.SERVICE_NAME)
        try {
            val params = JSONObject()
            params.put("framework", 1)
            if (service == null) {
                params.put("component", 14)
            } else {
                params.put("component", 15)
            }
            params.put("language", 2)

            val jsonObject = JSONObject()
            jsonObject.put("api", "setFramework")
            jsonObject.put("params", params)
            TUICallEngine.createInstance(appContext).callExperimentalAPI(jsonObject.toString())
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }

    companion object {
        private const val TAG = "TUICallKitService"

        fun sharedInstance(context: Context): TUICallKitService {
            return TUICallKitService(context)
        }
    }
}