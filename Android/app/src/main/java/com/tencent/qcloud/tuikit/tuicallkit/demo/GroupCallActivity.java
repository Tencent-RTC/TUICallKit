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

import java.util.Arrays;
import java.util.List;

public class GroupCallActivity extends BaseActivity {

    private EditText                mEditGroupId;
    private EditText                mEditUserList;
    private TUICallDefine.MediaType mMediaType = TUICallDefine.MediaType.Audio;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.app_activity_group_call);
        initView();
    }

    private void initView() {
        mEditUserList = findViewById(R.id.et_user_id_list);
        mEditGroupId = findViewById(R.id.et_group_id);

        findViewById(R.id.iv_back).setOnClickListener(v -> onBackPressed());
        findViewById(R.id.btn_call).setOnClickListener(v -> startGroupCall());
        findViewById(R.id.rb_video).setOnClickListener(v -> ((RadioButton) v).setChecked(true));
        findViewById(R.id.rb_video).setOnClickListener(v -> ((RadioButton) v).setChecked(true));
        findViewById(R.id.tv_join_group_call).setOnClickListener(v -> {
            Intent intent = new Intent(this, JoinInGroupCallActivity.class);
            startActivity(intent);
        });
        findViewById(R.id.ll_setting).setOnClickListener(v -> {
            Intent intent = new Intent(this, SettingsActivity.class);
            startActivity(intent);
        });
        ((RadioGroup) findViewById(R.id.rg_media_type)).setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == R.id.rb_video) {
                mMediaType = TUICallDefine.MediaType.Video;
            } else {
                mMediaType = TUICallDefine.MediaType.Audio;
            }
        });
    }

    private void startGroupCall() {
        String groupId = mEditGroupId.getText().toString();
        String userList = mEditUserList.getText().toString();

        if (TextUtils.isEmpty(groupId)) {
            ToastUtil.toastShortMessage(getString(R.string.app_please_input_group_id));
            return;
        }
        if (TextUtils.isEmpty(userList)) {
            ToastUtil.toastShortMessage(getString(R.string.app_please_input_user_id_list));
            return;
        }
        List<String> userIdList = null;
        if (userList.contains(",")) {
            userIdList = Arrays.asList(userList.split(","));
        } else if (userList.contains("，")) {
            userIdList = Arrays.asList(userList.split("，"));
        } else {
            userIdList = Arrays.asList(userList);
        }
        TUICallDefine.CallParams callParams = createCallParams();
        if (callParams == null) {
            TUICallKit.createInstance(this).groupCall(groupId, userIdList, mMediaType);
        } else {
            TUICallKit.createInstance(this).groupCall(groupId, userIdList, mMediaType, callParams, null);
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
