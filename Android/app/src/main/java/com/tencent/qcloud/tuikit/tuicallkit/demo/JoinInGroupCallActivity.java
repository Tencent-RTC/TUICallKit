package com.tencent.qcloud.tuikit.tuicallkit.demo;

import android.os.Bundle;
import android.text.TextUtils;
import android.widget.EditText;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;

public class JoinInGroupCallActivity extends BaseActivity {
    private EditText mEditCallId;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.app_activity_join_group_call);
        initView();
    }

    private void initView() {
        mEditCallId = findViewById(R.id.et_call_id);
        findViewById(R.id.iv_back).setOnClickListener(v -> onBackPressed());
        findViewById(R.id.btn_call).setOnClickListener(v -> joinInGroupCall());
    }

    private void joinInGroupCall() {
        String callId = mEditCallId.getText().toString();
        if (TextUtils.isEmpty(callId)) {
            ToastUtil.toastShortMessage(getString(R.string.app_please_input_group_id));
            return;
        }

        TUICallKit.createInstance(this).join(callId, null);
    }
}
