package com.tencent.qcloud.tuikit.tuicallkit.data

object Constants {
    const val SIGNALING_MAX_TIME = 30
    const val MIN_AUDIO_VOLUME = 10
    const val MAX_USER = 9
    const val EVENT_TUICALLKIT_CHANGED = "eventTUICallKitChanged"
    const val EVENT_START_ACTIVITY = "eventStartActivity"
    const val EVENT_START_INCOMING_VIEW = "eventStartIncomingView"

    const val EVENT_VIEW_STATE_CHANGED = "eventViewStateChanged"
    const val EVENT_SHOW_FULL_VIEW = "eventShowFullView"
    const val EVENT_SHOW_FLOAT_VIEW = "eventShowFloatView"

    const val GROUP_ID = "groupId"
    const val SELECT_MEMBER_LIST = "selectMemberList"

    const val ACCEPT_CALL_ACTION = "accept_call_action"
    const val REJECT_CALL_ACTION = "reject_call_action"

    const val KEY_VIRTUAL_BACKGROUND = "enablevirtualbackground"

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