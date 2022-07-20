package com.tencent.liteav.demo;

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
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.liteav.basic.UserModel;
import com.tencent.liteav.basic.UserModelManager;
import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;

import java.util.ArrayList;
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
        initButtonLogin();
    }

    private void initButtonLogin() {
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
            Toast.makeText(this, R.string.user_id_is_empty, Toast.LENGTH_SHORT).show();
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
                Log.d(TAG, "login onSuccess");
                getUserInfo();
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                ToastUtils.showLong(R.string.app_toast_login_fail, errorCode, errorMessage);
                Log.d(TAG, "login fail errorCode: " + errorCode + " msg:" + errorMessage);
            }
        });
    }

    private void getUserInfo() {
        final UserModelManager manager = UserModelManager.getInstance();
        final UserModel userModel = manager.getUserModel();
        //先查询用户是否存在
        List<String> userIdList = new ArrayList<>();
        userIdList.add(userModel.userId);
        Log.d(TAG, "setUserInfo: userIdList = " + userIdList);
        V2TIMManager.getInstance().getUsersInfo(userIdList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {

            @Override
            public void onError(int code, String msg) {
                Log.e(TAG, "get group info list fail, code:" + code + " msg: " + msg);
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> resultList) {
                if (resultList == null || resultList.isEmpty()) {
                    return;
                }
                V2TIMUserFullInfo result = resultList.get(0);
                String userName = result.getNickName();
                String userAvatar = result.getFaceUrl();
                Log.d(TAG, "onSuccess: userName = " + userName + " , userAvatar = " + userAvatar);
                //如果用户名和头像为空,则跳转设置界面进行设置
                if (TextUtils.isEmpty(userName) || TextUtils.isEmpty(userAvatar)) {
                    Intent intent = new Intent(LoginActivity.this, ProfileActivity.class);
                    startActivity(intent);
                    finish();
                } else {
                    userModel.userAvatar = userAvatar;
                    userModel.userName = userName;
                    manager.setUserModel(userModel);
                    //如果用户信息不为空,则直接进入主界面
                    Intent intent = new Intent(LoginActivity.this, MainActivity.class);
                    startActivity(intent);
                    finish();
                }
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
