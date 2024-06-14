package com.tencent.qcloud.tuikit.tuicallkit.demo;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.widget.EditText;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.debug.GenerateTestUserSig;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;
import com.tencent.qcloud.tuikit.tuicallkit.demo.setting.SettingsConfig;

import java.util.ArrayList;
import java.util.List;

public class LoginActivity extends BaseActivity {
    private static final String TAG = "LoginActivity";

    private EditText mEditUserId;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.app_activity_login);
        initView();
    }

    private void initView() {
        mEditUserId = findViewById(R.id.et_userId);

        findViewById(R.id.btn_login).setOnClickListener(v -> {
            String userId = mEditUserId.getText().toString().trim();
            login(userId);
        });
    }

    private void login(String userId) {
        if (TextUtils.isEmpty(userId)) {
            ToastUtil.toastShortMessage(getString(R.string.app_user_id_is_empty));
            return;
        }

        TUILogin.login(this, GenerateTestUserSig.SDKAPPID, userId, GenerateTestUserSig.genTestUserSig(userId),
                new TUICallback() {
                    @Override
                    public void onSuccess() {
                        Log.i(TAG, "login onSuccess");
                        SettingsConfig.userId = userId;
                        getUserInfo(userId);
                        TUICallKit.createInstance(getApplication()).enableFloatWindow(SettingsConfig.isShowFloatingWindow);
                        TUICallKit.createInstance(getApplication()).enableVirtualBackground(SettingsConfig.isShowBlurBackground);
                        TUICallKit.createInstance(getApplication()).enableIncomingBanner(SettingsConfig.isIncomingBanner);
                    }

                    @Override
                    public void onError(int errorCode, String errorMessage) {
                        ToastUtil.toastShortMessage(getString(R.string.app_toast_login_fail, errorCode, errorMessage));
                        Log.e(TAG, "login fail errorCode: " + errorCode + " errorMessage:" + errorMessage);
                    }
                });
    }

    private void getUserInfo(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        List<String> userList = new ArrayList<>();
        userList.add(userId);
        V2TIMManager.getInstance().getUsersInfo(userList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int errorCode, String errorMsg) {
                Log.e(TAG, "getUserInfo failed, code:" + errorCode + " msg: " + errorMsg);
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> userFullInfoList) {
                if (null == userFullInfoList || userFullInfoList.isEmpty()) {
                    Log.e(TAG, "getUserInfo result is empty");
                    return;
                }
                V2TIMUserFullInfo timUserFullInfo = userFullInfoList.get(0);
                String userName = timUserFullInfo.getNickName();
                String userAvatar = timUserFullInfo.getFaceUrl();
                Log.d(TAG, "getUserInfo success: userName = " + userName + " , userAvatar = " + userAvatar);
                if (TextUtils.isEmpty(userName) || TextUtils.isEmpty(userAvatar)) {
                    Intent intent = new Intent(LoginActivity.this, ProfileActivity.class);
                    startActivity(intent);
                    finish();
                } else {
                    SettingsConfig.userAvatar = userAvatar;
                    SettingsConfig.userName = userName;
                    Intent intent = new Intent(LoginActivity.this, MainActivity.class);
                    startActivity(intent);
                    finish();
                }
            }
        });
    }

    private void startWebPage(String url) {
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        startActivity(browserIntent);
    }
}
