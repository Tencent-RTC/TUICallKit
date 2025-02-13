package com.tencent.qcloud.tuikit.tuicallkit.demo;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.EditText;
import android.widget.RadioGroup;

import com.google.gson.Gson;
import com.tencent.cloud.tuikit.engine.call.TUICallDefine;
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;
import com.tencent.qcloud.tuikit.tuicallkit.demo.setting.SettingsActivity;
import com.tencent.qcloud.tuikit.tuicallkit.demo.setting.SettingsConfig;

import java.util.ArrayList;
import java.util.List;

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
            startCall();
        });

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

    private void startCall() {
        String userId = mEditUserId.getText().toString();
        if (TextUtils.isEmpty(userId)) {
            ToastUtil.toastShortMessage(getString(R.string.app_please_input_user_id_list));
            return;
        }
        if (SettingsConfig.userId.equals(userId)) {
            ToastUtil.toastShortMessage(getString(R.string.app_toast_not_call_myself));
            return;
        }
        TUICallDefine.CallParams callParams = createCallParams();
        List<String> list = new ArrayList<>();
        list.add(userId);
        TUICallKit.createInstance(this).calls(list, mMediaType, callParams, null);
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
