package com.tencent.qcloud.tuikit.tuicallkit.view.component

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import android.text.TextUtils
import android.view.ViewGroup
import android.widget.ImageView
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.Logger
import com.trtc.tuikit.common.livedata.Observer

@SuppressLint("AppCompatCustomView")
class InviteUserButton(context: Context) : ImageView(context) {

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (TUICallDefine.Status.Accept == it) {
            this.visibility = VISIBLE
        }
    }

    init {
        initView()
        addObserver()
    }

    fun clear() {
        removeObserver()
    }

    private fun initView() {
        setBackgroundResource(R.drawable.tuicallkit_ic_add_user_black)
        val lp = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        layoutParams = lp

        val isCaller = TUICallDefine.Role.Caller == TUICallState.instance.selfUser.get().callRole.get()
        val isAccept = TUICallDefine.Status.Accept == TUICallState.instance.selfUser.get().callStatus.get()
        visibility = when {
            isCaller || isAccept -> VISIBLE
            else -> GONE
        }
        setOnClickListener {
            inviteUser()
        }
    }

    private fun inviteUser() {
        val groupId = TUICallState.instance.groupId.get()
        if (TextUtils.isEmpty(groupId)) {
            ToastUtil.toastShortMessage(
                ServiceInitializer.getAppContext().getString(R.string.tuicallkit_group_id_is_empty)
            )
            return
        }
        val status: TUICallDefine.Status = TUICallState.instance.selfUser.get().callStatus.get()
        if (TUICallDefine.Role.Called == TUICallState.instance.selfUser.get().callRole?.get()
            && TUICallDefine.Status.Accept != status
        ) {
            Logger.info(TAG, "This feature can only be used after the callee accepted the call.")
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
        Logger.info(TAG, "inviteUserButtonClicked, groupId: $groupId ,list: $list")
        val bundle = Bundle()
        bundle.putString(Constants.GROUP_ID, groupId)
        bundle.putStringArrayList(Constants.SELECT_MEMBER_LIST, list)
        TUICore.startActivity("SelectGroupMemberActivity", bundle)
    }

    private fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe(callStatusObserver)
    }

    private fun removeObserver() {
        TUICallState.instance.selfUser.get().callStatus.removeObserver(callStatusObserver)
    }

    companion object {
        private const val TAG = "InviteUserButton"
    }
}