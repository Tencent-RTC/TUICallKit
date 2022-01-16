package com.tencent.liteav.trtccalling.ui.floatwindow;

import java.util.ArrayList;
import java.util.List;

/**
 * 悬浮窗增加:数据传输Json字段
 */
public class FloatJsonData {
    private String       userId;
    private String       callType;
    private List<String> inviteeList;
    private boolean      isGroup;
    private boolean      isCameraOpen;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getCallType() {
        return callType;
    }

    public void setCallType(String callType) {
        this.callType = callType;
    }

    public List<String> getInviteeList() {
        if (null != inviteeList) {
            return inviteeList;
        } else {
            return new ArrayList<>();
        }
    }

    public void setInviteeList(List<String> inviteeList) {
        this.inviteeList = inviteeList;
    }

    public boolean isGroup() {
        return isGroup;
    }

    public void setGroup(boolean group) {
        isGroup = group;
    }

    public boolean isCameraOpen() {
        return isCameraOpen;
    }

    public void setCameraOpen(boolean cameraOpen) {
        isCameraOpen = cameraOpen;
    }
}
