package com.tencent.qcloud.tuicore.interfaces;

import android.os.Bundle;

public interface ITUIService {
    Object onCall(String method, Bundle param);
}
