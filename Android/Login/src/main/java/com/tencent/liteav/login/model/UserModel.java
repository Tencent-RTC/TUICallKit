package com.tencent.liteav.login.model;

import java.io.Serializable;

public class UserModel implements Serializable {
    public String phone;
    public String userId;
    public String userSig;
    public String userName;
    public String userAvatar;
    public UserType userType = UserType.NONE;

    public enum UserType {
        NONE,
        MEETING,    // 视频会议
        CALLING,    // 语音/视频通话
        CHAT_SALON, // 语音沙龙
        VOICE_ROOM, // 语音聊天室
        LIVE_ROOM   // 视频互动直播
    }

    @Override
    public String toString() {
        return "UserModel{" +
                "phone='" + phone + '\'' +
                ", userId='" + userId + '\'' +
                ", userSig='" + userSig + '\'' +
                ", userName='" + userName + '\'' +
                ", userAvatar='" + userAvatar + '\'' +
                '}';
    }
}
