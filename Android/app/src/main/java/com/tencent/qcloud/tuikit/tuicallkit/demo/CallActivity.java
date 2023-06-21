package com.tencent.qcloud.tuikit.tuicallkit.demo;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import com.google.gson.Gson;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;
import com.tencent.qcloud.tuikit.tuicallkit.demo.setting.SettingsActivity;
import com.tencent.qcloud.tuikit.tuicallkit.demo.setting.SettingsConfig;

public class CallActivity extends BaseActivity {

    private EditText                mEditUserId;
    private TUICallDefine.MediaType mMediaType = TUICallDefine.MediaType.Audio;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.app_activity_call);
        initView();
    }

    private void initView() {
        mEditUserId = findViewById(R.id.et_userId);

        findViewById(R.id.iv_back).setOnClickListener(v -> finish());
        findViewById(R.id.btn_call).setOnClickListener(v -> {
            String userId = mEditUserId.getText().toString();
            if (SettingsConfig.userId.equals(userId)) {
                ToastUtil.toastShortMessage(getString(R.string.app_toast_not_call_myself));
                return;
            }
            startCall(userId);
        });
        findViewById(R.id.rb_video).setOnClickListener(v -> ((RadioButton) v).setChecked(true));
        findViewById(R.id.rb_video).setOnClickListener(v -> ((RadioButton) v).setChecked(true));
        ((RadioGroup) findViewById(R.id.rg_media_type)).setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == R.id.rb_video) {
                mMediaType = TUICallDefine.MediaType.Video;
            } else {
                mMediaType = TUICallDefine.MediaType.Audio;
            }
        });

        findViewById(R.id.ll_setting).setOnClickListener(v -> {
            Intent intent = new Intent(this, SettingsActivity.class);
            startActivity(intent);
        });
    }

    private void startCall(String userId) {
        TUICallDefine.CallParams callParams = createCallParams();
        if (callParams == null) {
            TUICallKit.createInstance(this).call(userId, mMediaType);
        } else {
            TUICallKit.createInstance(this).call(userId, mMediaType, callParams, null);
        }
    }

    private TUICallDefine.CallParams createCallParams() {
        try {
            if (SettingsConfig.callTimeOut != 30 || !TextUtils.isEmpty(SettingsConfig.userData) || !TextUtils.isEmpty(SettingsConfig.offlineParams)
                    || SettingsConfig.intRoomId != 0 || !TextUtils.isEmpty(SettingsConfig.strRoomId)) {
                TUICallDefine.CallParams callParams = new TUICallDefine.CallParams();
                callParams.timeout = SettingsConfig.callTimeOut;
                callParams.userData = SettingsConfig.userData;
                if (!TextUtils.isEmpty(SettingsConfig.offlineParams)) {
                    callParams.offlinePushInfo = new Gson().fromJson(SettingsConfig.offlineParams, TUICallDefine.OfflinePushInfo.class);
                }
                if (SettingsConfig.intRoomId != 0 || !TextUtils.isEmpty(SettingsConfig.strRoomId)) {
                    TUICommonDefine.RoomId roomId = new TUICommonDefine.RoomId();
                    roomId.intRoomId = SettingsConfig.intRoomId;
                    roomId.strRoomId = SettingsConfig.strRoomId;
                    callParams.roomId = roomId;
                }
                return callParams;
            }
        } catch (Exception e) {
        }
        return null;
    }

}
