package com.tencent.qcloud.tuicore;

import android.os.Bundle;
import android.text.TextUtils;

import com.tencent.qcloud.tuicore.interfaces.ITUIObject;

import java.util.HashMap;

/**
 * Object 创建
 */
class ObjectManager {
    private static final String TAG = ObjectManager.class.getSimpleName();

    private static class ObjectManagerHolder {
        private static final ObjectManager objectManager = new ObjectManager();
    }

    public static ObjectManager getInstance() {
        return ObjectManager.ObjectManagerHolder.objectManager;
    }

    private final HashMap<String, ITUIObject> objectHashMap = new HashMap<>();

    private ObjectManager() {
    }

    public ITUIObject createObject(String className, Bundle param) {
        if (TextUtils.isEmpty(className)) {
            return null;
        }
        ITUIObject object = objectHashMap.get(className);
        if (object != null) {
            object.onCreate(param);
        }
        return object;
    }
}
