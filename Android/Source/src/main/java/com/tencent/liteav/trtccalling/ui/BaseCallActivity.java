package com.tencent.liteav.trtccalling.ui;

import androidx.appcompat.app.AppCompatActivity;
import android.widget.Toast;

import com.tencent.liteav.trtccalling.R;
import com.tencent.trtc.TRTCCloudDef;

import java.io.Serializable;
import java.util.List;

public class BaseCallActivity extends AppCompatActivity {
    private static final int MIN_DURATION_SHOW_LOW_QUALITY = 5000; //显示网络不佳最小间隔时间

    private long mSelfLowQualityTime;
    private long mOtherPartyLowQualityTime;

    //localQuality 己方网络状态， remoteQualityList对方网络状态列表，取第一个为1v1通话的网络状态
    protected void updateNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, List<TRTCCloudDef.TRTCQuality> remoteQualityList) {
        //如果己方网络和对方网络都很差，优先显示己方网络差
        boolean isLocalLowQuality = isLowQuality(localQuality);
        if (isLocalLowQuality) {
            updateLowQualityTip(true);
        } else {
            if (!remoteQualityList.isEmpty()) {
                TRTCCloudDef.TRTCQuality remoteQuality = remoteQualityList.get(0);
                if (isLowQuality(remoteQuality)) {
                    updateLowQualityTip(false);
                }
            }
        }
    }

    private boolean isLowQuality(TRTCCloudDef.TRTCQuality qualityInfo) {
        if (qualityInfo == null) {
            return false;
        }
        int quality = qualityInfo.quality;
        boolean lowQuality;
        switch (quality) {
            case TRTCCloudDef.TRTC_QUALITY_Vbad:
            case TRTCCloudDef.TRTC_QUALITY_Down:
                lowQuality = true;
                break;
            default:
                lowQuality = false;
        }
        return lowQuality;
    }

    private void updateLowQualityTip(boolean isSelf) {
        long currentTime = System.currentTimeMillis();
        if (isSelf) {
            if (currentTime - mSelfLowQualityTime > MIN_DURATION_SHOW_LOW_QUALITY) {
                Toast.makeText(this, R.string.trtccalling_self_network_low_quality, Toast.LENGTH_SHORT).show();
                mSelfLowQualityTime = currentTime;
            }
        } else {
            if (currentTime - mOtherPartyLowQualityTime > MIN_DURATION_SHOW_LOW_QUALITY) {
                Toast.makeText(this, R.string.trtccalling_other_party_network_low_quality, Toast.LENGTH_SHORT).show();
                mOtherPartyLowQualityTime = currentTime;
            }
        }
    }

    public static class UserInfo implements Serializable {
        public String userId;
        public String userAvatar;
        public String userName;
    }
}
