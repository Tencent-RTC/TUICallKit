package com.tencent.qcloud.tuikit.tuicallkit.utils

import android.text.TextUtils
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.ValueCallback
import com.tencent.imsdk.v2.V2TIMFriendInfoResult
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMValueCallback
import com.tencent.qcloud.tuikit.tuicallkit.data.User

object UserInfoUtils {

    private const val TAG = "UserInfoUtils"

    fun updateUserInfo(user: User) {
        if (TextUtils.isEmpty(user.id)) {
            Logger.error(TAG, "getUsersInfo, user.userId isEmpty")
            return
        }
        if (!TextUtils.isEmpty(user.nickname.get()) && !TextUtils.isEmpty(user.avatar.get())) {
            Logger.info(TAG, "getUsersInfo, user.userName = ${user.nickname}, avatar = ${user.avatar}")
            return
        }
        val userList: MutableList<String> = ArrayList()
        userList.add(user.id!!)

        getFriendsInfo(userList, object : ValueCallback<List<UserInfo?>?> {
            override fun onSuccess(data: List<UserInfo?>?) {
                if (data.isNullOrEmpty() || data[0] == null) {
                    Logger.error(TAG, "getUserInfo result is empty")
                    return
                }
                var userInfo = data[0]
                Logger.info(
                    TAG, "getUsersInfo -> userId:${user.id} onSuccess: " +
                            "nickname:${userInfo?.nickname}, avatar:${userInfo?.avatar}" +
                            ", friendRemark:${userInfo?.remark}"
                )
                if (!TextUtils.isEmpty(userInfo?.remark)) {
                    user.nickname.set(userInfo?.remark)
                } else if (!TextUtils.isEmpty(userInfo?.nickname)) {
                    user.nickname.set(userInfo?.nickname)
                } else {
                    user.nickname.set(userInfo?.id)
                }
                user.avatar.set(userInfo?.avatar)
            }

            override fun onError(errCode: Int, errMsg: String?) {
                Logger.error(TAG, "getUsersInfo,userId:${user.id} error, errCode: $errCode , errMsg: $errMsg")
            }

        })
    }

    fun getUserListInfo(userList: List<String>, callback: ValueCallback<List<User>?>) {
        getFriendsInfo(userList, object : ValueCallback<List<UserInfo?>?> {
            override fun onSuccess(data: List<UserInfo?>?) {
                if (data.isNullOrEmpty()) {
                    Logger.error(TAG, "getUserInfo result is empty")
                    return
                }

                var userList: MutableList<User> = ArrayList()
                for (i in data.indices) {
                    var userInfo = data[i]

                    var user = User()
                    user.id = userInfo?.id
                    if (!TextUtils.isEmpty(userInfo?.remark)) {
                        user.nickname.set(userInfo?.remark)
                    } else if (!TextUtils.isEmpty(userInfo?.nickname)) {
                        user.nickname.set(userInfo?.nickname)
                    } else {
                        user.nickname.set(userInfo?.id)
                    }
                    user.avatar.set(userInfo?.avatar)
                    userList.add(user)
                }
                callback.onSuccess(userList)
            }

            override fun onError(errCode: Int, errMsg: String?) {
                Logger.error(TAG, "getUsersInfo, userId:${userList} error, errCode: $errCode , errMsg: $errMsg")
                callback.onError(errCode, errMsg)
            }

        })
    }

    private fun getFriendsInfo(
        userList: List<String?>?,
        callback: ValueCallback<List<UserInfo?>?>?
    ) {
        V2TIMManager.getFriendshipManager()
            .getFriendsInfo(userList, object : V2TIMValueCallback<List<V2TIMFriendInfoResult?>?> {
                override fun onSuccess(list: List<V2TIMFriendInfoResult?>?) {
                    if (list.isNullOrEmpty()) {
                        Logger.error(TAG, "getUserInfo result is empty")
                        return
                    }

                    var userList: MutableList<UserInfo> = ArrayList()
                    for (i in list.indices) {
                        var friendInfo = list[i]?.friendInfo

                        var userInfo = UserInfo()
                        userInfo.id = friendInfo?.userID ?: ""
                        userInfo.remark = friendInfo?.friendRemark ?: ""
                        userInfo.nickname = friendInfo?.userProfile?.nickName ?: ""
                        userInfo.avatar = friendInfo?.userProfile?.faceUrl ?: ""
                        userList.add(userInfo)
                    }
                    callback?.onSuccess(userList)
                }

                override fun onError(code: Int, desc: String?) {
                    callback?.onError(code, desc)
                }
            })
    }

    class UserInfo {
        var id: String = ""
        var avatar: String = ""
        var nickname: String = ""
        var remark: String = ""
    }
}