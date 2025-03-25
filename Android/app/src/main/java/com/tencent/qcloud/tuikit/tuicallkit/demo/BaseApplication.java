package com.tencent.qcloud.tuikit.tuicallkit.demo;

import android.app.Application;
import android.os.Build;
import android.os.StrictMode;

import androidx.multidex.MultiDex;

import com.tencent.qcloud.tim.push.TIMPushManager;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Map;

public class BaseApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        MultiDex.install(this);

        StrictMode.VmPolicy.Builder builder = new StrictMode.VmPolicy.Builder();
        StrictMode.setVmPolicy(builder.build());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            builder.detectFileUriExposure();
        }


        // If your app uses FCM offline push messaging, please open this
        // registerFCMDataMessageNotifyEvent();
        // TIMPushManager.getInstance().forceUseFCMPushChannel(true);
    }

    private void registerFCMDataMessageNotifyEvent() {
        TUICore.registerEvent(TUIConstants.TIMPush.EVENT_IM_LOGIN_AFTER_APP_WAKEUP_KEY,
                TUIConstants.TIMPush.EVENT_IM_LOGIN_AFTER_APP_WAKEUP_SUB_KEY, new ITUINotification() {
                    @Override
                    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
                        if (TUIConstants.TIMPush.EVENT_IM_LOGIN_AFTER_APP_WAKEUP_KEY.equals(key)
                                && TUIConstants.TIMPush.EVENT_IM_LOGIN_AFTER_APP_WAKEUP_SUB_KEY.equals(subKey)) {
                            //you need to login again to launch call activity, please implement this method by yourself
                            //autoLogin();
                        }
                    }
                });
    }
}