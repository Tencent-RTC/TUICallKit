package com.tencent.cloud.tuikit.flutter.tuicallkit.state;

import androidx.annotation.NonNull;

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;

public class User {
    public String               id             = "";
    public String               avatar         = "";
    public String               nickname       = "";
    public TUICallDefine.Role   callRole       = TUICallDefine.Role.Caller;
    public TUICallDefine.Status callStatus     = TUICallDefine.Status.None;
    public boolean              audioAvailable = false;
    public boolean              videoAvailable = false;

    public boolean isSameUser(User user) {
        if (id != user.id
                || avatar != user.avatar
                || nickname != user.nickname
                || callRole != user.callRole
                || callStatus != user.callStatus
                || audioAvailable != user.audioAvailable
                || videoAvailable != user.videoAvailable) {
            return false;
        }
        return true;
    }

    @NonNull
    @Override
    public String toString() {
        return "User:{" +
                "id: " + id +
                ", avatar: " + avatar +
                ", nickname: " + nickname +
                ", callRole: " + callRole +
                ", callStatus: " + callStatus +
                ", audioAvailable: " + audioAvailable +
                ", videoAvailable: " + videoAvailable +
                "}";
    }
}
