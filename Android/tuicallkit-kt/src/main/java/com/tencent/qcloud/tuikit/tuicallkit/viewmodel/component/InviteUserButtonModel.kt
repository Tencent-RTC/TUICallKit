package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component

import android.os.Bundle
import android.text.TextUtils
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class InviteUserButtonModel  {
    public var role: LiveData<TUICallDefine.Role>? = null
    public var mediaType = LiveData<TUICallDefine.MediaType>()

    init {
        role = TUICallState.instance.selfUser.get().callRole
        mediaType = TUICallState.instance.mediaType
    }

    fun inviteUser() {
        val groupId = TUICallState.instance.groupId.get()
        if (TextUtils.isEmpty(groupId)) {
            ToastUtil.toastShortMessage(ServiceInitializer.getAppContext().getString(R.string.tuicalling_groupid_is_empty))
            return
        }
        val status: TUICallDefine.Status = TUICallState.instance.selfUser.get().callStatus.get()
        if (TUICallDefine.Role.Called == role?.get() && TUICallDefine.Status.Accept != status) {
            ToastUtil.toastShortMessage(ServiceInitializer.getAppContext().getString(R.string.tuicalling_status_is_not_accept))
            return
        }
        val list = ArrayList<String?>()
        for (model in TUICallState.instance.remoteUserList.get()) {
            if (model != null && !TextUtils.isEmpty(model.id) && !list.contains(model.id)) {
                list.add(model.id)
            }
        }
        if (!list.contains(TUILogin.getLoginUser())) {
            list.add(TUILogin.getLoginUser())
        }
        TUILog.i(TAG, "initInviteUserFunction, groupId: $groupId ,list: $list")
        val bundle = Bundle()
        bundle.putString(TUIConstants.TUIGroup.GROUP_ID, groupId)
        bundle.putString(TUIConstants.TUIGroup.USER_DATA, Constants.TUICALLKIT)
        bundle.putStringArrayList(TUIConstants.TUIGroup.SELECTED_LIST, list)
        TUICore.startActivity("GroupMemberActivity", bundle)
    }

    companion object {
        private const val TAG = "InviteUserButtonModel"
    }
}