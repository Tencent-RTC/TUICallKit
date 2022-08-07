package com.tencent.qcloud.tim.tuiofflinepush.utils;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.tencent.qcloud.tim.tuiofflinepush.TUIOfflinePushService;
import com.tencent.qcloud.tuicore.util.TUIBuild;

public class BrandUtil {

    public static boolean isBrandXiaoMi() {
        return "xiaomi".equalsIgnoreCase(getBuildBrand())
                || "xiaomi".equalsIgnoreCase(getBuildManufacturer());
    }

    public static boolean isBrandHuawei() {
        return "huawei".equalsIgnoreCase(getBuildBrand()) ||
                "huawei".equalsIgnoreCase(getBuildManufacturer()) ||
                "honor".equalsIgnoreCase(getBuildBrand()) ||
                "honor".equalsIgnoreCase(getBuildManufacturer());
    }

    public static boolean isBrandMeizu() {
        return "meizu".equalsIgnoreCase(getBuildBrand())
                || "meizu".equalsIgnoreCase(getBuildManufacturer())
                || "22c4185e".equalsIgnoreCase(getBuildBrand());
    }

    public static boolean isBrandOppo() {
        return "oppo".equalsIgnoreCase(getBuildBrand()) ||
                "realme".equalsIgnoreCase(getBuildBrand()) ||
                "oneplus".equalsIgnoreCase(getBuildBrand()) ||
                "oppo".equalsIgnoreCase(getBuildManufacturer()) ||
                "realme".equalsIgnoreCase(getBuildManufacturer()) ||
                "oneplus".equalsIgnoreCase(getBuildManufacturer());
    }

    public static boolean isBrandVivo() {
        return "vivo".equalsIgnoreCase(getBuildBrand())
                || "vivo".equalsIgnoreCase(getBuildManufacturer());
    }

    public static boolean isGoogleServiceSupport() {
        GoogleApiAvailability googleApiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = googleApiAvailability.isGooglePlayServicesAvailable(TUIOfflinePushService.appContext);
        return resultCode == ConnectionResult.SUCCESS;
    }

    public static String getBuildBrand() {
        return TUIBuild.getBrand();
    }

    public static String getBuildManufacturer() {
        return TUIBuild.getManufacturer();
    }

    public static String getBuildModel() {
        return TUIBuild.getModel();
    }

    public static String getBuildVersionRelease() {
        return TUIBuild.getVersion();
    }

    public static int getBuildVersionSDKInt() {
        return TUIBuild.getVersionInt();
    }
}
