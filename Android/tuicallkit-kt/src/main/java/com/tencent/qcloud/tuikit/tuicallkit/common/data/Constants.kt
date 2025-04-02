package com.tencent.qcloud.tuikit.tuicallkit.common.data

object Constants {
    const val CALL_WAITING_MAX_TIME = 30 //unit:s
    const val MAX_USER = 9
    const val MIN_AUDIO_VOLUME = 10

    const val REJECT_CALL_ACTION = "reject_call_action"
    const val ACCEPT_CALL_ACTION = "accept_call_action"

    const val KEY_TUI_CALLKIT = "keyTUICallKit"
    const val SUB_KEY_SHOW_FLOAT_WINDOW = "subKeyShowFloatWindow"

    enum class NetworkQualityHint {
        None,
        Local,
        Remote
    }

    enum class Orientation {
        Portrait,
        LandScape,
        Auto
    }
}