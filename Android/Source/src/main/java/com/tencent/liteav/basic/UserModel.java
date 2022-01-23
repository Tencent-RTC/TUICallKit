package com.tencent.liteav.basic;

import java.io.Serializable;

public class UserModel implements Serializable {
    public String   phone;
    public String   userId;
    public String   userSig;
    public String   userName;
    public String   userAvatar;
    public UserType userType = UserType.NONE;

    public enum UserType {
        NONE,
        ROOM,       // 多人音视频房间
        CALLING,    // 语音/视频通话
        CHAT_SALON, // 语音沙龙
        VOICE_ROOM, // 语音聊天室
        LIVE_ROOM,  // 视频互动直播
        CHORUS,     // 合唱
        KARAOKE     // 卡拉OK
    }
}
