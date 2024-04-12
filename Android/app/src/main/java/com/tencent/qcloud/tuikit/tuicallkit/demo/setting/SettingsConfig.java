package com.tencent.qcloud.tuikit.tuicallkit.demo.setting;

import static com.tencent.qcloud.tuikit.TUICommonDefine.VideoEncoderParams.Resolution.Resolution_640_360;
import static com.tencent.qcloud.tuikit.TUICommonDefine.VideoEncoderParams.ResolutionMode.Portrait;
import static com.tencent.qcloud.tuikit.TUICommonDefine.VideoRenderParams.FillMode.Fill;
import static com.tencent.qcloud.tuikit.TUICommonDefine.VideoRenderParams.Rotation.Rotation_0;

import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingBellFeature;

public class SettingsConfig {

    public static String  userId               = "";
    public static String  userAvatar           = "";
    public static String  userName             = "";
    public static String  ringPath             =
            SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLKIT).getString(CallingBellFeature.PROFILE_CALL_BELL);
    public static boolean isMute               = false;
    public static boolean isShowFloatingWindow = false;
    public static boolean isShowBlurBackground = false;
    public static int     intRoomId            = 0;
    public static String  strRoomId            = "";
    public static int     callTimeOut          = 30;
    public static String  userData             = "";
    public static String  offlineParams        = "";
    public static int     resolution           = Resolution_640_360.ordinal();
    public static int     resolutionMode       = Portrait.ordinal();
    public static int     fillMode             = Fill.ordinal();
    public static int     rotation             = Rotation_0.ordinal();
    public static int     beautyLevel          = 6;
}
