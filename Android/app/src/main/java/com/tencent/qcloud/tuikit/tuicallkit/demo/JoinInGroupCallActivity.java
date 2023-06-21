package com.tencent.qcloud.tuikit.tuicallkit.demo;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import androidx.appcompat.widget.AppCompatSpinner;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;

public class JoinInGroupCallActivity extends BaseActivity {

    private EditText                mEditGroupId;
    private EditText                mEditRoomId;
    private AppCompatSpinner        mSpinnerRoomId;
    private TUICallDefine.MediaType mMediaType   = TUICallDefine.MediaType.Audio;
    private boolean                 mIsStrRoomId = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.app_activity_join_group_call);
        initView();
    }

    private void initView() {
        mSpinnerRoomId = findViewById(R.id.spinner_room_id);
        mEditRoomId = findViewById(R.id.et_room_id);
        mEditGroupId = findViewById(R.id.et_group_id);

        findViewById(R.id.iv_back).setOnClickListener(v -> onBackPressed());
        findViewById(R.id.btn_call).setOnClickListener(v -> joinInGroupCall());
        findViewById(R.id.rb_video).setOnClickListener(v -> ((RadioButton) v).setChecked(true));
        findViewById(R.id.rb_video).setOnClickListener(v -> ((RadioButton) v).setChecked(true));
        ((RadioGroup) findViewById(R.id.rg_media_type)).setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == R.id.rb_video) {
                mMediaType = TUICallDefine.MediaType.Video;
            } else {
                mMediaType = TUICallDefine.MediaType.Audio;
            }
        });
        mSpinnerRoomId.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                mIsStrRoomId = (position == 1);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });
        mSpinnerRoomId.setSelection(mIsStrRoomId ? 1 : 0, true);
    }

    private void joinInGroupCall() {
        String groupId = mEditGroupId.getText().toString();
        if (TextUtils.isEmpty(groupId)) {
            ToastUtil.toastShortMessage(getString(R.string.app_please_input_group_id));
            return;
        }
        String roomId = mEditRoomId.getText().toString();
        if (TextUtils.isEmpty(roomId)) {
            ToastUtil.toastShortMessage(getString(R.string.app_please_input_room_id));
            return;
        }
        TUICommonDefine.RoomId room = new TUICommonDefine.RoomId();
        if (mIsStrRoomId) {
            room.strRoomId = roomId;
        } else {
            try {
                room.intRoomId = Integer.parseInt(roomId);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        TUICallKit.createInstance(this).joinInGroupCall(room, groupId, mMediaType);
    }
}
