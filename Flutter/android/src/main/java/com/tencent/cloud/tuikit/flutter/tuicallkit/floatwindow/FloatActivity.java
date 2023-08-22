package com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow;

import static com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitAppUtils.EVENT_KEY;

import android.app.Activity;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.flutter.tuicallkit.TUICallKitPlugin;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitAppUtils;

public class FloatActivity extends Activity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String event = getIntent().getStringExtra(EVENT_KEY);
        if (KitAppUtils.EVENT_START_CALL_PAGE.equals(event)) {
            TUICallKitPlugin.gotoCallingPage();
        } else if(KitAppUtils.EVENT_HANDLER_RECEIVE_CALL_REQUEST.equals(event)) {
            TUICallKitPlugin.handleCallReceived();
        }
        finish();
    }
}
