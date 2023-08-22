package com.tencent.cloud.tuikit.flutter.tuicallkit.utils;

import com.tencent.cloud.tuikit.flutter.tuicallkit.state.User;

import java.util.Map;

public class KitObjectUtils {
    public static User getUserByMap(Map map) {
        if (map == null || map.size() <= 0) {
            return null;
        }
        User user = new User();
        if (map.get("id") != null) {
            user.id = (String) map.get("id");
        }
        if (map.get("avatar") != null) {
            user.avatar = (String) map.get("avatar");
        }
        if (map.get("nickname") != null) {
            user.nickname = (String) map.get("nickname");
        }
        if (map.get("callRole") != null) {
            int callRoleIndex = (int) map.get("callRole");
            user.callRole = KitEnumUtils.getRoleType(callRoleIndex);
        }
        if (map.get("callStatus") != null) {
            int callStatusIndex = (int) map.get("callStatus");
            user.callStatus = KitEnumUtils.getStatusType(callStatusIndex);
        }
        if (map.get("audioAvailable") != null) {
            user.audioAvailable = (boolean) map.get("audioAvailable");
        }
        if (map.get("videoAvailable") != null) {
            user.videoAvailable = (boolean) map.get("videoAvailable");
        }
        return user;
    }
}
