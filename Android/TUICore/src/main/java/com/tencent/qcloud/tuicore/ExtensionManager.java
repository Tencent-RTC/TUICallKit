package com.tencent.qcloud.tuicore;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

/**
 * 页面扩展注册和获取
 */
class ExtensionManager {
    private static final String TAG = ExtensionManager.class.getSimpleName();

    private static class ExtensionManagerHolder {
        private static final ExtensionManager extensionManager = new ExtensionManager();
    }

    public static ExtensionManager getInstance() {
        return ExtensionManagerHolder.extensionManager;
    }

    private final HashMap<String, List<ITUIExtension>>  extensionHashMap = new HashMap<>();

    private ExtensionManager() {}

    public void registerExtension(String key, ITUIExtension extension) {
        Log.i(TAG, "registerExtension key : " + key + ", extension : " + extension);
        if (TextUtils.isEmpty(key) || extension == null) {
            return;
        }
        List<ITUIExtension> list = extensionHashMap.get(key);
        if (list == null) {
            list = new ArrayList<>();
            extensionHashMap.put(key, list);
        }
        if (!list.contains(extension)) {
            list.add(extension);
        }
    }

    public void removeExtension(String key, ITUIExtension extension) {
        Log.i(TAG, "removeExtension key : " + key + ", extension : " + extension);
        if (TextUtils.isEmpty(key) || extension == null) {
            return;
        }
        List<ITUIExtension> list = extensionHashMap.get(key);
        if (list == null) {
            return;
        }
        list.remove(extension);
    }

    public List<Bundle> getExtensionObjects(String key, Bundle param) {
        Log.i(TAG, "getExtensionObjects key : " + key );
        if (TextUtils.isEmpty(key)) {
            return new ArrayList<>();
        }
        List<ITUIExtension> list = extensionHashMap.get(key);
        if (list == null) {
            return new ArrayList<>();
        }
        List<Bundle> bundleList = new ArrayList<>();
        for(ITUIExtension extension : list) {
            List<Bundle> bundles = extension.onGetInfo(key, param);
            if (bundles != null) {
                bundleList.addAll(bundles);
            }
        }
        return bundleList;
    }
}
