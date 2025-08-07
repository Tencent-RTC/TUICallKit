package com.tencent.cloud.tuikit.flutter.tuicallkit.utils;

import com.tencent.cloud.tuikit.engine.call.TUICallDefine;
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.User;

import java.util.HashMap;
import java.util.Map;

public class ObjectParse {

    public static TUICallDefine.MediaType getMediaType(int index) {
        switch (index) {
            case 0:
                return TUICallDefine.MediaType.Unknown;
            case 1:
                return TUICallDefine.MediaType.Audio;
            case 2:
                return TUICallDefine.MediaType.Video;
            default:
                break;
        }
        return TUICallDefine.MediaType.Unknown;
    }

    public static TUICommonDefine.VideoEncoderParams.Resolution getResolutionType(int index) {
        switch (index) {
            case 0:
                return TUICommonDefine.VideoEncoderParams.Resolution.Resolution_640_360;
            case 1:
                return TUICommonDefine.VideoEncoderParams.Resolution.Resolution_960_540;
            case 2:
                return TUICommonDefine.VideoEncoderParams.Resolution.Resolution_1280_720;
            case 3:
                return TUICommonDefine.VideoEncoderParams.Resolution.Resolution_1920_1080;
            default:
                break;
        }
        return TUICommonDefine.VideoEncoderParams.Resolution.Resolution_640_360;
    }

    public static TUICommonDefine.VideoEncoderParams.ResolutionMode getResolutionModeType(int index) {
        switch (index) {
            case 0:
                return TUICommonDefine.VideoEncoderParams.ResolutionMode.Landscape;
            case 1:
                return TUICommonDefine.VideoEncoderParams.ResolutionMode.Portrait;
            default:
                break;
        }
        return TUICommonDefine.VideoEncoderParams.ResolutionMode.Portrait;
    }

    public static TUICommonDefine.VideoRenderParams.FillMode getFillModeType(int index) {
        switch (index) {
            case 0:
                return TUICommonDefine.VideoRenderParams.FillMode.Fill;
            case 1:
                return TUICommonDefine.VideoRenderParams.FillMode.Fit;
            default:
                break;
        }
        return TUICommonDefine.VideoRenderParams.FillMode.Fill;
    }

    public static TUICommonDefine.VideoRenderParams.Rotation getRotationType(int index) {
        switch (index) {
            case 0:
                return TUICommonDefine.VideoRenderParams.Rotation.Rotation_0;
            case 1:
                return TUICommonDefine.VideoRenderParams.Rotation.Rotation_90;
            case 2:
                return TUICommonDefine.VideoRenderParams.Rotation.Rotation_180;
            case 3:
                return TUICommonDefine.VideoRenderParams.Rotation.Rotation_270;
            default:
                break;
        }
        return TUICommonDefine.VideoRenderParams.Rotation.Rotation_0;
    }

    public static TUICallDefine.IOSOfflinePushType getIOSOfflinePushType(int index) {
        switch (index) {
            case 0:
                return TUICallDefine.IOSOfflinePushType.APNs;
            case 1:
                return TUICallDefine.IOSOfflinePushType.VoIP;
            default:
                break;
        }
        return TUICallDefine.IOSOfflinePushType.APNs;
    }

    public static TUICommonDefine.Camera getCameraType(int index) {
        switch (index) {
            case 0:
                return TUICommonDefine.Camera.Front;
            case 1:
                return TUICommonDefine.Camera.Back;
            default:
                break;
        }
        return TUICommonDefine.Camera.Front;
    }

    public static TUICommonDefine.AudioPlaybackDevice getAudioPlaybackDeviceType(int index) {
        switch (index) {
            case 0:
                return TUICommonDefine.AudioPlaybackDevice.Speakerphone;
            case 1:
                return TUICommonDefine.AudioPlaybackDevice.Earpiece;
            default:
                break;
        }
        return TUICommonDefine.AudioPlaybackDevice.Earpiece;
    }

    public static TUICallDefine.CallRecords.Result getCallRecordsResultType(int index) {
        switch (index) {
            case 0:
                return TUICallDefine.CallRecords.Result.Unknown;
            case 1:
                return TUICallDefine.CallRecords.Result.Missed;
            case 2:
                return TUICallDefine.CallRecords.Result.Incoming;
            case 3:
                return TUICallDefine.CallRecords.Result.Outgoing;
            default:
                break;
        }
        return TUICallDefine.CallRecords.Result.Unknown;
    }

    public static TUICallDefine.Scene getSceneType(int index) {
        switch (index) {
            case 0:
                return TUICallDefine.Scene.SINGLE_CALL;
            case 1:
                return TUICallDefine.Scene.GROUP_CALL;
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
        if (map.get("remark") != null) {
            user.remark = (String) map.get("remark");
        }
        if (map.get("nickname") != null) {
            user.nickname = (String) map.get("nickname");
        }
        if (map.get("callRole") != null) {
            int callRoleIndex = (int) map.get("callRole");
            user.callRole = ObjectParse.getRoleType(callRoleIndex);
        }
        if (map.get("callStatus") != null) {
            int callStatusIndex = (int) map.get("callStatus");
            user.callStatus = ObjectParse.getStatusType(callStatusIndex);
        }
        if (map.get("audioAvailable") != null) {
            user.audioAvailable = (boolean) map.get("audioAvailable");
        }
        if (map.get("videoAvailable") != null) {
            user.videoAvailable = (boolean) map.get("videoAvailable");
        }
        if (map.get("playOutVolume") != null) {
            user.playoutVolume = (int) map.get("playOutVolume");
        }
        return user;
    }

    public static TUICallDefine.CallParams getTUICallParamsByMap(Map map) {
        if (map == null || map.size() <= 0) {
            return null;
        }
        TUICallDefine.CallParams params = new TUICallDefine.CallParams();
        if (map.get("offlinePushInfo") != null) {
            params.offlinePushInfo = getTUIOfflinePushInfoByMap((Map) map.get("offlinePushInfo"));
        }
        if (map.get("timeout") != null) {
            params.timeout = (int) map.get("timeout");
        }
        if (map.get("userData") != null) {
            params.userData = (String) map.get("userData");
        }
        if (map.get("roomId") != null) {
            Map roomIdMap = (Map) map.get("roomId");
            params.roomId = getRoomIdByMap(roomIdMap);
        }
        if (map.get("chatGroupId") != null) {
            params.chatGroupId = (String) map.get("chatGroupId");
        }
        return params;
    }

    public static TUICallDefine.OfflinePushInfo getTUIOfflinePushInfoByMap(Map map) {
        if (map == null || map.size() <= 0) {
            return null;
        }
        TUICallDefine.OfflinePushInfo offlinePushInfo = new TUICallDefine.OfflinePushInfo();
        if (map.get("title") != null) {
            offlinePushInfo.setTitle((String) map.get("title"));
        }
        if (map.get("desc") != null) {
            offlinePushInfo.setDesc((String) map.get("desc"));
        }
        if (map.get("ignoreIOSBadge") != null) {
            offlinePushInfo.setIgnoreIOSBadge((boolean) map.get("ignoreIOSBadge"));
        }
        if (map.get("iOSSound") != null) {
            offlinePushInfo.setIOSSound((String) map.get("iOSSound"));
        }
        if (map.get("androidSound") != null) {
            offlinePushInfo.setAndroidSound((String) map.get("androidSound"));
        }
        if (map.get("androidOPPOChannelID") != null) {
            offlinePushInfo.setAndroidOPPOChannelID((String) map.get("androidOPPOChannelID"));
        }
        if (map.get("androidVIVOClassification") != null) {
            offlinePushInfo.setAndroidVIVOClassification((int) map.get("androidVIVOClassification"));
        }
        if (map.get("androidXiaoMiChannelID") != null) {
            offlinePushInfo.setAndroidXiaoMiChannelID((String) map.get("androidXiaoMiChannelID"));
        }
        if (map.get("androidFCMChannelID") != null) {
            offlinePushInfo.setAndroidFCMChannelID((String) map.get("androidFCMChannelID"));
        }
        if (map.get("androidHuaWeiCategory") != null) {
            offlinePushInfo.setAndroidHuaWeiCategory((String) map.get("androidHuaWeiCategory"));
        }
        if (map.get("isDisablePush") != null) {
            offlinePushInfo.setDisablePush((boolean) map.get("isDisablePush"));
        }
        if (map.get("iOSPushType") != null) {
            int iOSPushTypeIndex = (int) map.get("iOSPushType");
            offlinePushInfo.setIOSPushType(ObjectParse.getIOSOfflinePushType(iOSPushTypeIndex));
        }
        return offlinePushInfo;
    }

    public static TUICommonDefine.RoomId getRoomIdByMap(Map map) {
        if (map == null) {
            return null;
        }
        TUICommonDefine.RoomId roomId = new TUICommonDefine.RoomId();
        if (map.containsKey("intRoomId")) {
            roomId.intRoomId = (int) map.get("intRoomId");
        }
        if (map.containsKey("strRoomId")) {
            roomId.strRoomId = (String) map.get("strRoomId");
        }
        return roomId;
    }


    public static TUICallDefine.RecentCallsFilter getRecentCallsFilterByMap(Map map) {
        if (map == null) {
            return null;
        }
        TUICallDefine.RecentCallsFilter filter = new TUICallDefine.RecentCallsFilter();
        if (map.containsKey("resultType")) {
            filter.result = ObjectParse.getCallRecordsResultType((int) map.get("resultType"));
        }
        return filter;
    }

    public static TUICommonDefine.VideoEncoderParams getVideoEncoderParamsByMap(Map map) {
        if (map == null) {
            return null;
        }

        TUICommonDefine.VideoEncoderParams encoderParams = new TUICommonDefine.VideoEncoderParams();
        if (map.containsKey("resolution")) {
            int resolutionIndex = (int) map.get("resolution");
            encoderParams.resolution = ObjectParse.getResolutionType(resolutionIndex);
        }
        if (map.containsKey("resolutionMode")) {
            int resolutionModeIndex = (int) map.get("resolutionMode");
            encoderParams.resolutionMode = ObjectParse.getResolutionModeType(resolutionModeIndex);

        }

        return encoderParams;
    }

    public static TUICommonDefine.VideoRenderParams getVideoRenderParamsByMap(Map map) {
        if (map == null) {
            return null;
        }

        TUICommonDefine.VideoRenderParams renderParams = new TUICommonDefine.VideoRenderParams();
        if (map.containsKey("fillMode")) {
            int fillModeIndex = (int) map.get("fillMode");
            renderParams.fillMode = ObjectParse.getFillModeType(fillModeIndex);
        }
        if (map.containsKey("rotation")) {
            int rotationIndex = (int) map.get("rotation");
            renderParams.rotation = ObjectParse.getRotationType(rotationIndex);
        }

        return renderParams;
    }

    public static Map getCallRecordsMap(TUICallDefine.CallRecords record) {
        Map<String, Object> map = new HashMap<>();
        if (record != null) {
            map.put("callId", record.callId);
            map.put("inviter", record.inviter);
            map.put("inviteList", record.inviteList);
            map.put("scene", record.scene.ordinal());
            map.put("mediaType", record.mediaType.ordinal());
            map.put("groupId", record.groupId);
            map.put("role", record.role.ordinal());
            map.put("result", record.result.ordinal());
            map.put("beginTime", record.beginTime);
            map.put("totalTime", record.totalTime);
        }
        return map;
    }

    public static Map<String, Object> getRoomIdMap(TUICommonDefine.RoomId roomId) {
        Map<String, Object> roomIdMap = new HashMap<>();
        roomIdMap.put("intRoomId", roomId.intRoomId);
        roomIdMap.put("strRoomId", roomId.strRoomId);
        return roomIdMap;
    }

    public static Map<String, Object> getCallObserverExtraInfoMap(TUICallDefine.CallObserverExtraInfo info) {
        Map<String, Object> map = new HashMap<>();
        if (info != null) {
            map.put("roomId", getRoomIdMap(info.roomId));
            map.put("role", info.role.getValue());
            map.put("userData", info.userData);
            map.put("chatGroupId", info.chatGroupId);
        }
        return map;
    }
}
