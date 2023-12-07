package com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow;

import static com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitAppUtils.EVENT_KEY;

import android.app.Activity;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.flutter.tuicallkit.TUICallKitPlugin;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitAppUtils;
import com.tencent.qcloud.tuicore.TUICore;

public class FloatActivity extends Activity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String event = getIntent().getStringExtra(EVENT_KEY);
        if (KitAppUtils.EVENT_START_CALL_PAGE.equals(event)) {
            TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_GOTO_CALLING_PAGE, null);
        } else if(KitAppUtils.EVENT_HANDLER_RECEIVE_CALL_REQUEST.equals(event)) {
            TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
        }
        finish();
    }
}
