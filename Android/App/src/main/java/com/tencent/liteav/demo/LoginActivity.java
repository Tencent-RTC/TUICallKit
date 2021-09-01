package com.tencent.liteav.demo;

import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;

import com.tencent.liteav.basic.AvatarConstant;
import com.tencent.liteav.basic.UserModel;
import com.tencent.liteav.basic.UserModelManager;
import com.tencent.liteav.debug.GenerateTestUserSig;

import java.util.Random;

public class LoginActivity extends AppCompatActivity {
    private static final String TAG = LoginActivity.class.getName();

    private EditText          mEditUserId;
    private Button            mButtonLogin;

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
        final UserModel userModel = new UserModel();
        userModel.phone = userId;
        userModel.userId = userId;
        userModel.userName = userId;
        int index = new Random().nextInt(AvatarConstant.USER_AVATAR_ARRAY.length);
        String coverUrl = AvatarConstant.USER_AVATAR_ARRAY[index];
        userModel.userAvatar = coverUrl;
        userModel.userSig = GenerateTestUserSig.genTestUserSig(userId);
        final UserModelManager manager = UserModelManager.getInstance();
        manager.setUserModel(userModel);
        Intent intent = new Intent(LoginActivity.this, MainActivity.class);
        startActivity(intent);
        finish();
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
