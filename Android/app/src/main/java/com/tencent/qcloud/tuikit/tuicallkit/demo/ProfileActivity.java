package com.tencent.qcloud.tuikit.tuicallkit.demo;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicallkit.demo.setting.SettingsConfig;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;

import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ProfileActivity extends BaseActivity {
    private static final String TAG = "ProfileActivity";

    private ImageView mImageAvatar;
    private EditText  mEditUserName;
    private Button    mButtonRegister;
    private TextView  mTvInputTips;     //nickname constraints
    private String    mAvatarUrl;

    private static final String[] USER_AVATAR_ARRAY = {
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar2.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar3.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar4.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar5.png",
    };

    private static final int[] CUSTOM_NAME_ARRAY = {
            R.string.app_custom_name_1,
            R.string.app_custom_name_2,
            R.string.app_custom_name_3,
            R.string.app_custom_name_4,
            R.string.app_custom_name_5,
    };

    private void startMainActivity() {
        Intent intent = new Intent(ProfileActivity.this, MainActivity.class);
        startActivity(intent);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.app_activity_login_profile);
        initView();
    }

    private void initView() {
        mImageAvatar = findViewById(R.id.iv_user_avatar);
        mEditUserName = findViewById(R.id.et_user_name);
        mButtonRegister = findViewById(R.id.tv_register);
        mTvInputTips = findViewById(R.id.tv_tips_user_name);
        int index = new Random().nextInt(USER_AVATAR_ARRAY.length);
        mAvatarUrl = USER_AVATAR_ARRAY[index];
        ImageLoader.loadImage(this, mImageAvatar, mAvatarUrl, R.drawable.app_avatar);

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
                //Matches letters, digits, Chinese characters, underscores, and limits the input length to 2-20.
                Pattern p = Pattern.compile("^[a-z0-9A-Z\\u4e00-\\u9fa5\\_]{2,20}$");
                Matcher m = p.matcher(editable);
                if (!m.matches()) {
                    mTvInputTips.setTextColor(getResources().getColor(R.color.app_color_input_no_match));
                } else {
                    mTvInputTips.setTextColor(getResources().getColor(R.color.app_text_color_hint));
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
            ToastUtil.toastLongMessage(getString(R.string.app_hint_user_name));
            return;
        }
        String reg = "^[a-z0-9A-Z\\u4e00-\\u9fa5\\_]{2,20}$";
        if (!userName.matches(reg)) {
            mTvInputTips.setTextColor(getResources().getColor(R.color.app_color_input_no_match));
            return;
        }
        mTvInputTips.setTextColor(getResources().getColor(R.color.app_text_color_hint));
        V2TIMUserFullInfo v2TIMUserFullInfo = new V2TIMUserFullInfo();
        v2TIMUserFullInfo.setFaceUrl(mAvatarUrl);
        v2TIMUserFullInfo.setNickname(userName);
        V2TIMManager.getInstance().setSelfInfo(v2TIMUserFullInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                Log.e(TAG, "set profile failed errorCode : " + code + " errorMsg : " + desc);

                ToastUtil.toastLongMessage(getString(R.string.app_toast_failed_to_set, desc));
                startMainActivity();
                finish();
            }

            @Override
            public void onSuccess() {
                Log.i(TAG, "set profile success.");
                ToastUtil.toastLongMessage(getString(R.string.app_toast_register_success_and_logging_in));
                SettingsConfig.userName = userName;
                SettingsConfig.userAvatar = mAvatarUrl;
                startMainActivity();
                finish();
            }
        });
    }
}
