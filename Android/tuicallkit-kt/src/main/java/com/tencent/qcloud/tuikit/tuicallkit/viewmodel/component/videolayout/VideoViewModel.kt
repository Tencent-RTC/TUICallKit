package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.videolayout

import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.trtc.tuikit.common.livedata.LiveData

class VideoViewModel(user: User) {
    var user: User? = null
    var selfUser: User
    var scene: LiveData<TUICallDefine.Scene>? = null
    var isFrontCamera: LiveData<TUICommonDefine.Camera>
    var showLargeViewUserId: LiveData<String>

    init {
        this.user = user
        this.scene = TUICallState.instance.scene
        this.isFrontCamera = TUICallState.instance.isFrontCamera
        selfUser = TUICallState.instance.selfUser.get()
        showLargeViewUserId = TUICallState.instance.showLargeViewUserId
    }
}