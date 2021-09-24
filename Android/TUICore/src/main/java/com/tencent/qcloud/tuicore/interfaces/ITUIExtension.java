package com.tencent.qcloud.tuicore.interfaces;

import android.os.Bundle;
import android.view.View;

import java.util.List;

public interface ITUIExtension {
    List<Bundle> onGetInfo(String key, Bundle param);
}
