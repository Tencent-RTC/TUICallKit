package com.tencent.liteav.demo;

import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.liteav.basic.AvatarConstant;
import com.tencent.liteav.basic.ImageLoader;
import com.tencent.liteav.basic.UserModel;
import com.tencent.liteav.basic.UserModelManager;

import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ProfileActivity extends AppCompatActivity {
    private static final String    TAG               = "ProfileActivity";
    private              ImageView mImageAvatar;
    private              EditText  mEditUserName;
    private              Button    mButtonRegister;
    private              TextView  mTvInputTips;     //昵称限制提示
    private              String    mAvatarUrl;       //用户头像
    //自定义随机登录名
    private static final int[]     CUSTOM_NAME_ARRAY = {
            R.string.app_custom_name_1,
            R.string.app_custom_name_2,
            R.string.app_custom_name_3,
            R.string.app_custom_name_4,
            R.string.app_custom_name_5,
            R.string.app_custom_name_6,
            R.string.app_custom_name_7,
            R.string.app_custom_name_8,
            R.string.app_custom_name_9,
            R.string.app_custom_name_10,
            R.string.app_custom_name_11,
            R.string.app_custom_name_12,
    };

    private void startMainActivity() {
        Intent intent = new Intent();
        intent.addCategory("android.intent.category.DEFAULT");
        intent.setAction("com.tencent.liteav.action.portal");
        startActivity(intent);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login_profile);
        initStatusBar();
        initView();
    }

    private void initView() {
        mImageAvatar = (ImageView) findViewById(R.id.iv_user_avatar);
        mEditUserName = (EditText) findViewById(R.id.et_user_name);
        mButtonRegister = (Button) findViewById(R.id.tv_register);
        mTvInputTips = (TextView) findViewById(R.id.tv_tips_user_name);
        String[] avatarArr = AvatarConstant.USER_AVATAR_ARRAY;
        int index = new Random().nextInt(avatarArr.length);
        mAvatarUrl = avatarArr[index];
        ImageLoader.loadImage(this, mImageAvatar, mAvatarUrl, R.drawable.ic_avatar);

        mButtonRegister.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setProfile();
            }
        });
        int customNameIndex = new Random().nextInt(CUSTOM_NAME_ARRAY.length);
        mEditUserName.setText(getString(CUSTOM_NAME_ARRAY[customNameIndex]));
        String text = mEditUserName.getText().toString();
        if (!TextUtils.isEmpty(text)) {
            mEditUserName.setSelection(text.length());
        }
        mEditUserName.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence text, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence text, int start, int before, int count) {
                mButtonRegister.setEnabled(text.length() != 0);
                String editable = mEditUserName.getText().toString();
                //匹配字母,数字,中文,下划线,以及限制输入长度为2-20.
                Pattern p = Pattern.compile("^[a-z0-9A-Z\\u4e00-\\u9fa5\\_]{2,20}$");
                Matcher m = p.matcher(editable);
                if (!m.matches()) {
                    mTvInputTips.setTextColor(getResources().getColor(R.color.color_input_no_match));
                } else {
                    mTvInputTips.setTextColor(getResources().getColor(R.color.text_color_hint));
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });
    }

    private void setProfile() {
        final String userName = mEditUserName.getText().toString().trim();
        if (TextUtils.isEmpty(userName)) {
            ToastUtils.showLong(getString(R.string.app_hint_user_name));
            return;
        }
        String reg = "^[a-z0-9A-Z\\u4e00-\\u9fa5\\_]{2,20}$";
        if (!userName.matches(reg)) {
            mTvInputTips.setTextColor(getResources().getColor(R.color.color_input_no_match));
            return;
        }
        mTvInputTips.setTextColor(getResources().getColor(R.color.text_color_hint));
        V2TIMUserFullInfo v2TIMUserFullInfo = new V2TIMUserFullInfo();
        v2TIMUserFullInfo.setFaceUrl(mAvatarUrl);
        v2TIMUserFullInfo.setNickname(userName);
        V2TIMManager.getInstance().setSelfInfo(v2TIMUserFullInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                Log.e(TAG, "set profile failed errorCode : " + code + " errorMsg : " + desc);
                //头像和昵称设置失败,也可以进入到主界面(头像和昵称都用默认值),不影响功能
                ToastUtils.showLong(getString(R.string.app_toast_failed_to_set, desc));
                startMainActivity();
                finish();
            }

            @Override
            public void onSuccess() {
                Log.i(TAG, "set profile success.");
                ToastUtils.showLong(getString(R.string.app_toast_register_success_and_logging_in));
                //成功后保存用户数据
                UserModel userModel = UserModelManager.getInstance().getUserModel();
                userModel.userName = userName;
                userModel.userAvatar = mAvatarUrl;
                UserModelManager.getInstance().setUserModel(userModel);
                startMainActivity();
                finish();
            }
        });
    }

    private void initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }
}
