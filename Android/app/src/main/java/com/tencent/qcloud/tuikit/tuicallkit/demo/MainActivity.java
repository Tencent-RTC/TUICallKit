package com.tencent.qcloud.tuikit.tuicallkit.demo;

import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUILoginListener;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicallkit.demo.setting.SettingsConfig;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends BaseActivity {
    private static final String TAG = "MainActivity";

    private TextView  mTextUserId;
    private TextView  mTextNickname;
    private ImageView mImageAvatar;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.app_activity_main);
        initView();

        if (!isTaskRoot()
                && getIntent().hasCategory(Intent.CATEGORY_LAUNCHER)
                && getIntent().getAction() != null
                && getIntent().getAction().equals(Intent.ACTION_MAIN)) {

            finish();
            return;
        }

        if (!TUILogin.isUserLogined()) {
            Intent intent = new Intent(MainActivity.this, LoginActivity.class);
            startActivity(intent);
            finish();
            return;
        }
        TUILogin.addLoginListener(mLoginListener);
    }

    @Override
    protected void onResume() {
        super.onResume();
        getUserInfo();
    }

    private void initView() {
        mTextUserId = findViewById(R.id.tv_user_id);
        mTextNickname = findViewById(R.id.tv_nickname);
        mImageAvatar = findViewById(R.id.iv_avatar);

        findViewById(R.id.btn_call).setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, CallActivity.class);
            startActivity(intent);
        });

        findViewById(R.id.btn_group_call).setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, GroupCallActivity.class);
            startActivity(intent);
        });

        mImageAvatar.setOnClickListener(v -> {
            showLogoutDialog();
        });
    }

    private void getUserInfo() {
        if (TextUtils.isEmpty(SettingsConfig.userId)) {
            Intent intent = new Intent(MainActivity.this, LoginActivity.class);
            startActivity(intent);
            finish();
            return;
        }
        List<String> userList = new ArrayList<>();
        userList.add(SettingsConfig.userId);
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
                SettingsConfig.userName = timUserFullInfo.getNickName();
                SettingsConfig.userAvatar = timUserFullInfo.getFaceUrl();
                mTextUserId.setText(SettingsConfig.userId);
                mTextNickname.setText(SettingsConfig.userName);
                ImageLoader.loadImage(getApplicationContext(), mImageAvatar, SettingsConfig.userAvatar, R.drawable.app_avatar);
            }
        });
    }

    private void showLogoutDialog() {
        final Dialog dialog = new Dialog(this, R.style.LogoutDialogStyle);
        dialog.setContentView(R.layout.app_dialog_logout);
        Button btnPositive = (Button) dialog.findViewById(R.id.btn_positive);
        Button btnNegative = (Button) dialog.findViewById(R.id.btn_negative);
        btnPositive.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                logout();
            }
        });
        btnNegative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
            }
        });
        dialog.show();
    }

    private void logout() {
        TUILogin.logout(new TUICallback() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "logout success");
                SettingsConfig.userId = "";
                SettingsConfig.userName = "";
                SettingsConfig.userAvatar = "";
                TUILogin.removeLoginListener(mLoginListener);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                Log.e(TAG, "logout failed, errorCode: " + errorCode + " , errorMessage: " + errorMessage);
            }
        });
        startLoginActivity();
    }

    private void startLoginActivity() {
        Intent intent = new Intent(this, LoginActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();
    }

    private final TUILoginListener mLoginListener = new TUILoginListener() {
        @Override
        public void onKickedOffline() {
            super.onKickedOffline();
            Log.i(TAG, "You have been kicked off the line. Please login again!");
            ToastUtil.toastLongMessage(getString(R.string.app_user_kicked_offline));
            logout();
        }

        @Override
        public void onUserSigExpired() {
            super.onUserSigExpired();
            Log.i(TAG, "Your user signature information has expired");
            ToastUtil.toastLongMessage(getString(R.string.app_user_sig_expired));
            logout();
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();
        TUILogin.removeLoginListener(mLoginListener);
    }
}

