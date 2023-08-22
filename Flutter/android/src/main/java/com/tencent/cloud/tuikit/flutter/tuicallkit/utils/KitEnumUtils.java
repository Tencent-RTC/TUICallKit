package com.tencent.cloud.tuikit.flutter.tuicallkit.utils;

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;

public class KitEnumUtils {
    public static TUICallDefine.Scene getSceneType(int index) {
        switch (index) {
            case 0:
                return TUICallDefine.Scene.GROUP_CALL;
            case 1:
                return TUICallDefine.Scene.MULTI_CALL;
            case 2:
                return TUICallDefine.Scene.SINGLE_CALL;
            default:
                break;
        }
        return TUICallDefine.Scene.SINGLE_CALL;
    }

    public static TUICallDefine.Role getRoleType(int index) {
        switch (index) {
            case 0:
                return TUICallDefine.Role.None;
            case 1:
                return TUICallDefine.Role.Caller;
            case 2:
                return TUICallDefine.Role.Called;
            default:
                break;
        }
        return TUICallDefine.Role.None;
    }

    public static TUICallDefine.Status getStatusType(int index) {
        switch (index) {
            case 0:
                return TUICallDefine.Status.None;
            case 1:
                return TUICallDefine.Status.Waiting;
            case 2:
                return TUICallDefine.Status.Accept;
            default:
                break;
        }
        return TUICallDefine.Status.None;
    }
}
