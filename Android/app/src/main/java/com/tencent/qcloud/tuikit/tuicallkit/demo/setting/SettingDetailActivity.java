package com.tencent.qcloud.tuikit.tuicallkit.demo.setting;

import android.os.Bundle;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;
import com.tencent.qcloud.tuikit.tuicallkit.demo.BaseActivity;
import com.tencent.qcloud.tuikit.tuicallkit.demo.R;

public class SettingDetailActivity extends BaseActivity {

    public static final String ITEM_KEY             = "settingsItem";
    public static final String ITEM_AVATAR          = "avatar";
    public static final String ITEM_RING_PATH       = "ringPath";
    public static final String ITEM_USER_DATA       = "userData";
    public static final String ITEM_OFFLINE_MESSAGE = "offlineMessage";

    private EditText mEditContent;
    private String   mItemType = ITEM_USER_DATA;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.app_activity_settings_detail);
        initBundleData();
        initView();
    }

    private void initBundleData() {
        mItemType = getIntent().getStringExtra(ITEM_KEY);
    }

    private void initView() {
        mEditContent = findViewById(R.id.et_content);
        switch (mItemType) {
            case ITEM_USER_DATA:
                mEditContent.setText(SettingsConfig.userData);
                mEditContent.setHint(getString(R.string.app_invite_cmd_extra_info));
                break;
            case ITEM_OFFLINE_MESSAGE:
                mEditContent.setText(SettingsConfig.offlineParams);
                mEditContent.setHint(getString(R.string.app_offline_message_json_string));
                break;
            case ITEM_AVATAR:
                mEditContent.setText(SettingsConfig.userAvatar);
                mEditContent.setHint(getString(R.string.app_avatar));
                break;
            case ITEM_RING_PATH:
                mEditContent.setText(SettingsConfig.ringPath);
                mEditContent.setHint(getString(R.string.app_set_ring_path));
                break;
            default:
                break;
        }
        findViewById(R.id.iv_back).setOnClickListener(v -> finish());

        findViewById(R.id.btn_confirm).setOnClickListener(v -> {
            clickConfirm();
        });

        mEditContent.setOnEditorActionListener((v, actionId, event) -> {
            if (EditorInfo.IME_ACTION_DONE == actionId) {
                clickConfirm();
            }
            return false;
        });
    }

    private void clickConfirm() {
        switch (mItemType) {
            case ITEM_USER_DATA:
                SettingsConfig.userData = mEditContent.getText().toString().trim();
                break;
            case ITEM_OFFLINE_MESSAGE:
                SettingsConfig.offlineParams = mEditContent.getText().toString().trim();
                break;
            case ITEM_AVATAR:

                break;
            case ITEM_RING_PATH:
                String ringPath = mEditContent.getText().toString();
                SettingsConfig.ringPath = ringPath;
                TUICallKit.createInstance(getApplicationContext()).setCallingBell(ringPath);
                break;
            default:
                break;
        }
        ToastUtil.toastShortMessage(getString(R.string.app_set_success));
        finish();
    }

    private void setUserAvatar(String avatar) {
        TUICallKit.createInstance(getApplicationContext()).setSelfInfo(SettingsConfig.userName, avatar,
                new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                SettingsConfig.userAvatar = avatar;
                ToastUtil.toastShortMessage(getString(R.string.app_set_success));
                finish();
            }

            @Override
            public void onError(int errCode, String errMsg) {
                ToastUtil.toastShortMessage(getString(R.string.app_set_fail));
            }
        });
    }

}
