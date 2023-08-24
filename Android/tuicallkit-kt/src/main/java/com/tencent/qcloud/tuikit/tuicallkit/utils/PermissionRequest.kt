package com.tencent.qcloud.tuikit.tuicallkit.utils

import android.Manifest
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuicore.permission.PermissionRequester
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.utils.BrandUtils
import com.tencent.qcloud.tuikit.tuicallengine.utils.PermissionUtils
import com.tencent.qcloud.tuikit.tuicallkit.R

object PermissionRequest {
    fun requestPermissions(context: Context, type: TUICallDefine.MediaType, callback: PermissionCallback?) {
        val title = StringBuilder().append(context.getString(R.string.tuicalling_permission_microphone))
        val reason = StringBuilder()
        var microphonePermissionsDescription = TUICore.createObject(
            TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
            TUIConstants.Privacy.PermissionsFactory.PermissionsName.MICROPHONE_PERMISSIONS, null
        ) as String?
        if (!TextUtils.isEmpty(microphonePermissionsDescription)) {
            reason.append(microphonePermissionsDescription)
        } else {
            reason.append(context.getString(R.string.tuicalling_permission_mic_reason))
        }
        val permissionList: MutableList<String> = ArrayList()
        permissionList.add(Manifest.permission.RECORD_AUDIO)
        if (TUICallDefine.MediaType.Video == type) {
            title.append(context.getString(R.string.tuicalling_permission_separator))
            title.append(context.getString(R.string.tuicalling_permission_camera))
            val cameraPermissionsDescription = TUICore.createObject(
                TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
                TUIConstants.Privacy.PermissionsFactory.PermissionsName.CAMERA_PERMISSIONS, null
            ) as String?
            if (!TextUtils.isEmpty(cameraPermissionsDescription)) {
                reason.append(cameraPermissionsDescription)
            } else {
                reason.append(context.getString(R.string.tuicalling_permission_camera_reason))
            }
            permissionList.add(Manifest.permission.CAMERA)
        }
        val permissionCallback: PermissionCallback = object : PermissionCallback() {
            override fun onGranted() {
                requestBluetoothPermission(context, object : PermissionCallback() {
                    override fun onGranted() {
                        callback?.onGranted()
                    }
                })
            }

            override fun onDenied() {
                super.onDenied()
                callback?.onDenied()
            }
        }
        val applicationInfo = context.applicationInfo
        val appName = context.packageManager.getApplicationLabel(applicationInfo).toString()
        val permissions = permissionList.toTypedArray()
        PermissionRequester.newInstance(*permissions)
            .title(context.getString(R.string.tuicalling_permission_title, appName, title))
            .description(reason.toString())
            .settingsTip(
                """
    ${context.getString(R.string.tuicalling_permission_tips, title)}
    $reason
    """.trimIndent()
            )
            .callback(permissionCallback)
            .request()
    }

    /**
     * Android S(31) need apply for Nearby devices(Bluetooth) permission to support bluetooth headsets.
     * Please refer to: https://developer.android.com/guide/topics/connectivity/bluetooth/permissions
     */
    private fun requestBluetoothPermission(context: Context, callback: PermissionCallback) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            callback.onGranted()
            return
        }
        val title = context.getString(R.string.tuicalling_permission_bluetooth)
        val reason = context.getString(R.string.tuicalling_permission_bluetooth_reason)
        val applicationInfo = context.applicationInfo
        val appName = context.packageManager.getApplicationLabel(applicationInfo).toString()
        PermissionRequester.newInstance(Manifest.permission.BLUETOOTH_CONNECT)
            .title(context.getString(R.string.tuicalling_permission_title, appName, title))
            .description(reason)
            .settingsTip(reason)
            .callback(object : PermissionCallback() {
                override fun onGranted() {
                    callback.onGranted()
                }

                override fun onDenied() {
                    super.onDenied()
                    //bluetooth is unnecessary permission, return permission granted
                    callback.onGranted()
                }
            })
            .request()
    }

    fun requestFloatPermission(context: Context) {
        if (PermissionUtils.hasPermission(context)) {
            return
        }
        if (BrandUtils.isBrandVivo()) {
            requestVivoFloatPermission(context)
        } else {
            startCommonSettings(context)
        }
    }

    private fun startCommonSettings(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            intent.data = Uri.parse("package:" + context.packageName)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
        }
    }

    private fun requestVivoFloatPermission(context: Context) {
        val vivoIntent = Intent()
        val model = BrandUtils.getModel()
        var isVivoY85 = false
        if (!TextUtils.isEmpty(model)) {
            isVivoY85 = model.contains("Y85") && !model.contains("Y85A")
        }
        if (!TextUtils.isEmpty(model) && (isVivoY85 || model.contains("vivo Y53L"))) {
            vivoIntent.setClassName(
                "com.vivo.permissionmanager",
                "com.vivo.permissionmanager.activity.PurviewTabActivity"
            )
            vivoIntent.putExtra("tabId", "1")
        } else {
            vivoIntent.setClassName(
                "com.vivo.permissionmanager",
                "com.vivo.permissionmanager.activity.SoftPermissionDetailActivity"
            )
            vivoIntent.action = "secure.intent.action.softPermissionDetail"
        }
        vivoIntent.putExtra("packagename", context.packageName)
        vivoIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(vivoIntent)
    }
}