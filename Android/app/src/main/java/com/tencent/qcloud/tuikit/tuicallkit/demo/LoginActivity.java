package com.tencent.qcloud.tuikit.tuicallkit.demo;

import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.debug.GenerateTestUserSig;
import com.tencent.qcloud.tuikit.tuicallkit.demo.basic.UserModel;
import com.tencent.qcloud.tuikit.tuicallkit.demo.basic.UserModelManager;
import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;
import com.tencent.qcloud.tuikit.tuicallkit.utils.UserInfoUtils;

import java.util.List;

public class LoginActivity extends AppCompatActivity {
    private static final String TAG = "LoginActivity";

    private EditText mEditUserId;
    private Button   mButtonLogin;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        initStatusBar();
        initView();
    }

    private void initView() {
        mEditUserId = (EditText) findViewById(R.id.et_userId);
        mButtonLogin = (Button) findViewById(R.id.tv_login);
        mButtonLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                login();
            }
        });
    }

    private void login() {
        String userId = mEditUserId.getText().toString().trim();
        if (TextUtils.isEmpty(userId)) {
            ToastUtil.toastShortMessage(getString(R.string.user_id_is_empty));
            return;
        }

        final UserModelManager manager = UserModelManager.getInstance();
        final UserModel userModel = manager.getUserModel();
        userModel.phone = userId;
        userModel.userId = userId;
        userModel.userSig = GenerateTestUserSig.genTestUserSig(userId);
        manager.setUserModel(userModel);

        TUILogin.login(this, GenerateTestUserSig.SDKAPPID, userModel.userId, userModel.userSig, new TUICallback() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "login onSuccess");
                getUserInfo();
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                ToastUtil.toastShortMessage(getString(R.string.app_toast_login_fail, errorCode, errorMessage));
                Log.e(TAG, "login fail errorCode: " + errorCode + " errorMessage:" + errorMessage);
            }
        });
    }

    private void getUserInfo() {
        final UserModelManager manager = UserModelManager.getInstance();
        final UserModel userModel = manager.getUserModel();

        if (TextUtils.isEmpty(userModel.userId)) {
            return;
        }

        UserInfoUtils userInfoUtils = new UserInfoUtils();
        userInfoUtils.getUserInfo(userModel.userId, new UserInfoUtils.UserCallback() {
            @Override
            public void onSuccess(List<CallingUserModel> list) {
                if (list == null || list.isEmpty()) {
                    Log.e(TAG, "getUserInfo failed, list is empty");
                    return;
                }
                CallingUserModel callingUserModel = list.get(0);
                String userName = callingUserModel.userName;
                String userAvatar = callingUserModel.userAvatar;
                Log.d(TAG, "getUserInfo success: userName = " + userName + " , userAvatar = " + userAvatar);

                if (TextUtils.isEmpty(userName) || TextUtils.isEmpty(userAvatar)) {
                    Intent intent = new Intent(LoginActivity.this, ProfileActivity.class);
                    startActivity(intent);
                    finish();
                } else {
                    userModel.userAvatar = userAvatar;
                    userModel.userName = userName;
                    manager.setUserModel(userModel);

                    Intent intent = new Intent(LoginActivity.this, MainActivity.class);
                    startActivity(intent);
                    finish();
                }
            }

            @Override
            public void onFailed(int errorCode, String errorMsg) {
                Log.e(TAG, "getUserInfo failed, code:" + errorCode + " msg: " + errorMsg);
            }
        });
    }

    private void initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }
}
