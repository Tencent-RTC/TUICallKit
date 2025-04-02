package com.tencent.qcloud.tuikit.tuicallkit.demo.setting;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.VideoEncoderParams;
import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.VideoRenderParams;

import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.tuicallkit.manager.feature.CallingBellFeature;

public class SettingsConfig {

    public static String  userId               = "";
    public static String  userAvatar           = "";
    public static String  userName             = "";
    public static String  ringPath             =
            SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLKIT).getString(CallingBellFeature.PROFILE_CALL_BELL);
    public static boolean isMute               = false;
    public static boolean isShowFloatingWindow = true;
    public static boolean isShowBlurBackground = true;
    public static boolean isIncomingBanner     = true;
    public static int     intRoomId            = 0;
    public static String  strRoomId            = "";
    public static int     callTimeOut          = 30;
    public static String  userData             = "";
    public static String  offlineParams        = "";
    public static int     resolution           = VideoEncoderParams.Resolution.Resolution_640_360.ordinal();
    public static int     resolutionMode       = VideoEncoderParams.ResolutionMode.Portrait.ordinal();
    public static int     fillMode             = VideoRenderParams.FillMode.Fill.ordinal();
    public static int     rotation             = VideoRenderParams.Rotation.Rotation_0.ordinal();
    public static int     beautyLevel          = 6;
}
