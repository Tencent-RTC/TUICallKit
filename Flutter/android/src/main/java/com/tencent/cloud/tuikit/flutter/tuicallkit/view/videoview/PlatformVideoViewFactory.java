package com.tencent.cloud.tuikit.flutter.tuicallkit.view.videoview;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.flutter.tuicallkit.TUICallKitPlugin;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.videoview.PlatformVideoView;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Logger;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class PlatformVideoViewFactory extends PlatformViewFactory {
    public static final  String SIGN = "TUICallKitVideoView";

    private final BinaryMessenger                                                         mMessenger;
    public static Map<Integer, PlatformVideoView> mVideoViewMap;

    public PlatformVideoViewFactory(
            BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.mMessenger = messenger;
        mVideoViewMap = new HashMap<>();
    }


    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, @Nullable Object args) {
        Logger.info(TUICallKitPlugin.TAG, "create: viewId = " + viewId);
        PlatformView platformVideoView = mVideoViewMap.get(viewId);
        if (platformVideoView == null) {
            platformVideoView = new PlatformVideoView(context, viewId, mMessenger);
            mVideoViewMap.put(viewId, (PlatformVideoView) platformVideoView);
        }
        return platformVideoView;
    }
}
