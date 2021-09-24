package com.tencent.qcloud.tuicore.interfaces;

import android.os.Bundle;

public interface ITUINotification {
    void onNotifyEvent(String key, String subKey, Bundle param);
}
