package com.tencent.liteav.login.model;

import java.io.Serializable;

public class UserModel implements Serializable {
    public String phone;
    public String userId;
    public String userSig;
    public String userName;
    public String userAvatar;
    public UserType userType     = UserType.NONE;
    public enum   UserType{
        NONE,
        CHATSALONTYPE,   //语音沙龙
        VOICEROOMTYPE,   //语聊房
        LIVINGROOMTYPE;  //视频互动直播
    }

    @java.lang.Override
    public java.lang.String toString() {
        return "UserModel{" +
                "phone='" + phone + '\'' +
                ", userId='" + userId + '\'' +
                ", userSig='" + userSig + '\'' +
                ", userName='" + userName + '\'' +
                ", userAvatar='" + userAvatar + '\'' +
                '}';
    }
}
