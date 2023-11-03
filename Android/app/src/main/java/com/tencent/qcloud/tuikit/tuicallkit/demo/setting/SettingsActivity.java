package com.tencent.qcloud.tuikit.tuicallkit.demo.setting;

import static com.tencent.qcloud.tuikit.tuicallkit.demo.setting.SettingDetailActivity.ITEM_AVATAR;
import static com.tencent.qcloud.tuikit.tuicallkit.demo.setting.SettingDetailActivity.ITEM_KEY;
import static com.tencent.qcloud.tuikit.tuicallkit.demo.setting.SettingDetailActivity.ITEM_OFFLINE_MESSAGE;
import static com.tencent.qcloud.tuikit.tuicallkit.demo.setting.SettingDetailActivity.ITEM_RING_PATH;
import static com.tencent.qcloud.tuikit.tuicallkit.demo.setting.SettingDetailActivity.ITEM_USER_DATA;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.TextView;

import androidx.appcompat.widget.AppCompatSpinner;
import androidx.appcompat.widget.SwitchCompat;

import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;
import com.tencent.qcloud.tuikit.tuicallkit.demo.BaseActivity;
import com.tencent.qcloud.tuikit.tuicallkit.demo.R;

public class SettingsActivity extends BaseActivity {

    private TextView         mTextAvatar;
    private EditText         mEditNickname;
    private TextView         mTextRingPath;
    private SwitchCompat     mSwitchMute;
    private SwitchCompat     mSwitchFloating;
    private EditText         mEditDigitalRoomId;
    private EditText         mEditStringRoomId;
    private EditText         mEditTimeout;
    private TextView         mTextUserData;
    private TextView         mTextOfflineMessage;
    private AppCompatSpinner mSpinnerResolution;
    private AppCompatSpinner mSpinnerResolutionMode;
    private AppCompatSpinner mSpinnerRotation;
    private AppCompatSpinner mSpinnerFitMode;
    private EditText         mEditBeauty;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.app_activity_settings);
        initView();
    }

    @Override
    protected void onResume() {
        super.onResume();
        initData();
    }

    private void initView() {
        mTextAvatar = findViewById(R.id.tv_avatar);
        mEditNickname = findViewById(R.id.et_nickname);
        mTextRingPath = findViewById(R.id.tv_ring_path);
        mSwitchMute = findViewById(R.id.switch_mute);
        mSwitchFloating = findViewById(R.id.switch_floating);

        mEditDigitalRoomId = findViewById(R.id.et_room_id_num);
        mEditStringRoomId = findViewById(R.id.et_room_id_str);
        mEditTimeout = findViewById(R.id.et_timeout);
        mTextUserData = findViewById(R.id.tv_user_data);
        mTextOfflineMessage = findViewById(R.id.tv_offline_message);

        mSpinnerResolution = findViewById(R.id.spinner_resolution);
        mSpinnerResolutionMode = findViewById(R.id.spinner_resolution_mode);
        mSpinnerFitMode = findViewById(R.id.spinner_fit_mode);
        mSpinnerRotation = findViewById(R.id.spinner_rotation);
        mEditBeauty = findViewById(R.id.et_beauty);

        findViewById(R.id.iv_back).setOnClickListener(v -> onBackPressed());
        findViewById(R.id.rl_avatar).setOnClickListener(v -> {
            Intent intent = new Intent(SettingsActivity.this, SettingDetailActivity.class);
            intent.putExtra(ITEM_KEY, ITEM_AVATAR);
            startActivity(intent);
        });

        mEditNickname.setOnEditorActionListener((v, actionId, event) -> {
            if (EditorInfo.IME_ACTION_DONE == actionId) {
                setUserName();
            }
            return false;
        });

        findViewById(R.id.rl_ring_path).setOnClickListener(v -> {
            Intent intent = new Intent(SettingsActivity.this, SettingDetailActivity.class);
            intent.putExtra(ITEM_KEY, ITEM_RING_PATH);
            startActivity(intent);
        });

        mSwitchMute.setOnCheckedChangeListener((buttonView, isChecked) -> {
            SettingsConfig.isMute = isChecked;
            TUICallKit.createInstance(getApplicationContext()).enableMuteMode(isChecked);
        });

        mSwitchFloating.setOnCheckedChangeListener((buttonView, isChecked) -> {
            SettingsConfig.isShowFloatingWindow = isChecked;
            TUICallKit.createInstance(getApplicationContext()).enableFloatWindow(isChecked);
        });

        mEditDigitalRoomId.setOnEditorActionListener((v, actionId, event) -> {
            if (EditorInfo.IME_ACTION_DONE == actionId) {
                setDigitalRoomId();
            }
            return false;
        });

        mEditStringRoomId.setOnEditorActionListener((v, actionId, event) -> {
            if (EditorInfo.IME_ACTION_DONE == actionId) {
                setStringRoomId();
            }
            return false;
        });

        mEditTimeout.setOnEditorActionListener((v, actionId, event) -> {
            if (EditorInfo.IME_ACTION_DONE == actionId) {
                setCallTimeout();
            }
            return false;
        });

        findViewById(R.id.rl_user_data).setOnClickListener(v -> {
            Intent intent = new Intent(SettingsActivity.this, SettingDetailActivity.class);
            intent.putExtra(ITEM_KEY, ITEM_USER_DATA);
            startActivity(intent);
        });

        findViewById(R.id.rl_offline_message).setOnClickListener(v -> {
            Intent intent = new Intent(SettingsActivity.this, SettingDetailActivity.class);
            intent.putExtra(ITEM_KEY, ITEM_OFFLINE_MESSAGE);
            startActivity(intent);
        });

        mSpinnerResolution.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                SettingsConfig.resolution = position;
                setVideoEncoderParams();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        mSpinnerResolutionMode.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                SettingsConfig.resolutionMode = position;
                setVideoEncoderParams();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        mSpinnerRotation.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                SettingsConfig.rotation = position;
                setVideoRenderParams();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        mSpinnerFitMode.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                SettingsConfig.fillMode = position;
                setVideoRenderParams();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        mEditBeauty.setOnEditorActionListener((v, actionId, event) -> {
            if (EditorInfo.IME_ACTION_DONE == actionId) {
                setBeautyLeval();
            }
            return false;
        });
    }

    private void initData() {
        mEditNickname.setText(SettingsConfig.userName);
        mTextAvatar.setText(SettingsConfig.userAvatar);
        mTextRingPath.setText(SettingsConfig.ringPath);
        mSwitchMute.setChecked(SettingsConfig.isMute);
        mSwitchFloating.setChecked(SettingsConfig.isShowFloatingWindow);

        mEditDigitalRoomId.setText("" + SettingsConfig.intRoomId);
        mEditStringRoomId.setText("" + SettingsConfig.strRoomId);
        mEditTimeout.setText("" + SettingsConfig.callTimeOut);
        mTextUserData.setText(SettingsConfig.userData);
        mTextOfflineMessage.setText(SettingsConfig.offlineParams);

        mSpinnerResolution.setSelection(SettingsConfig.resolution, true);
        mSpinnerResolutionMode.setSelection(SettingsConfig.resolutionMode, true);
        mSpinnerRotation.setSelection(SettingsConfig.rotation, true);
        mSpinnerFitMode.setSelection(SettingsConfig.fillMode, true);
        mEditBeauty.setText("" + SettingsConfig.beautyLevel);
    }

    private void setUserName() {
        String nickname = mEditNickname.getText().toString();
        TUICallKit.createInstance(getApplicationContext()).setSelfInfo(nickname, SettingsConfig.userAvatar,
                new TUICommonDefine.Callback() {
                    @Override
                    public void onSuccess() {
                        SettingsConfig.userName = nickname;
                        ToastUtil.toastShortMessage(getString(R.string.app_set_success));
                    }

                    @Override
                    public void onError(int errCode, String errMsg) {
                        mEditNickname.setText(SettingsConfig.userName);
                        ToastUtil.toastShortMessage(getString(R.string.app_set_fail));
                    }
                });
    }

    private void setCallTimeout() {
        String text = mEditTimeout.getText().toString().trim();
        if (TextUtils.isEmpty(text)) {
            ToastUtil.toastShortMessage(getString(R.string.app_please_set_call_waiting_timeout));
            return;
        }
        try {
            int timeout = Integer.parseInt(text);
            SettingsConfig.callTimeOut = timeout;
            ToastUtil.toastShortMessage(getString(R.string.app_set_success));
        } catch (Exception e) {
        }
    }

    private void setBeautyLeval() {
        if (TextUtils.isEmpty(mEditBeauty.getText().toString())) {
            ToastUtil.toastShortMessage(getString(R.string.app_please_set_beauty_level));
            return;
        }
        int beauty = Integer.parseInt(mEditBeauty.getText().toString());
        SettingsConfig.beautyLevel = beauty;
        TUICallEngine.createInstance(getApplicationContext()).setBeautyLevel(beauty, new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                ToastUtil.toastShortMessage(getString(R.string.app_set_success));
            }

            @Override
            public void onError(int errCode, String errMsg) {
                ToastUtil.toastShortMessage(getString(R.string.app_set_fail) + "| errorCode:" + errCode + ", " +
                        "errMsg:" + errMsg);
            }
        });
    }

    public void setVideoEncoderParams() {
        TUICommonDefine.VideoEncoderParams videoEncoderParams = new TUICommonDefine.VideoEncoderParams();
        videoEncoderParams.resolutionMode =
                TUICommonDefine.VideoEncoderParams.ResolutionMode.values()[SettingsConfig.resolutionMode];
        videoEncoderParams.resolution =
                TUICommonDefine.VideoEncoderParams.Resolution.values()[SettingsConfig.resolution];
        TUICallEngine.createInstance(getApplicationContext()).setVideoEncoderParams(videoEncoderParams,
                new TUICommonDefine.Callback() {
                    @Override
                    public void onSuccess() {
                        ToastUtil.toastShortMessage(getString(R.string.app_set_success));
                    }

                    @Override
                    public void onError(int errCode, String errMsg) {
                        ToastUtil.toastShortMessage(getString(R.string.app_set_fail) + "| errorCode:" + errCode + ", " +
                                "errMsg:" + errMsg);
                    }
                });
    }

    public void setVideoRenderParams() {
        TUICommonDefine.VideoRenderParams videoRenderParams = new TUICommonDefine.VideoRenderParams();
        videoRenderParams.rotation = TUICommonDefine.VideoRenderParams.Rotation.values()[SettingsConfig.rotation];
        videoRenderParams.fillMode = TUICommonDefine.VideoRenderParams.FillMode.values()[SettingsConfig.fillMode];
        TUICallEngine.createInstance(getApplicationContext()).setVideoRenderParams(TUILogin.getLoginUser(), videoRenderParams,
                new TUICommonDefine.Callback() {
                    @Override
                    public void onSuccess() {
                        ToastUtil.toastShortMessage(getString(R.string.app_set_success));
                    }

                    @Override
                    public void onError(int errCode, String errMsg) {
                        ToastUtil.toastShortMessage(getString(R.string.app_set_fail) + "| errorCode:" + errCode + ", " +
                                "errMsg:" + errMsg);
                    }
                });
    }

    private void setDigitalRoomId() {
        String text = mEditDigitalRoomId.getText().toString().trim();
        if (!TextUtils.isEmpty(text)) {
            SettingsConfig.intRoomId = Integer.parseInt(text);
        } else {
            SettingsConfig.intRoomId = 0;
            mEditDigitalRoomId.setText("0");
        }
        ToastUtil.toastShortMessage(getString(R.string.app_set_success));
    }

    private void setStringRoomId() {
        SettingsConfig.strRoomId = mEditStringRoomId.getText().toString().trim();
        ToastUtil.toastShortMessage(getString(R.string.app_set_success));
    }
}
