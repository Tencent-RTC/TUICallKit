package com.tencent.cloud.tuikit.flutter.tuicallkit.view.videoview;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.flutter.tuicallkit.TUICallKitPlugin;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Logger;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class PlatformVideoView implements PlatformView, MethodChannel.MethodCallHandler {
    private TUIVideoView mTUIVideoView;
    private Context      mContext;
    private int             mViewId;
    private MethodChannel   mChannel;
    private BinaryMessenger mMessenger;

    public PlatformVideoView(Context context, int id, BinaryMessenger messenger) {
        super();
        mContext = context;
        mViewId = id;
        mMessenger = messenger;
        mTUIVideoView = new TUIVideoView(context);
        mChannel = new MethodChannel(mMessenger, "tuicall_kit/video_view_" + mViewId);
        mChannel.setMethodCallHandler(this);
    }

    @Nullable
    @Override
    public View getView() {
        return mTUIVideoView;
    }

    @Override
    public void dispose() {

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Logger.info(TUICallKitPlugin.TAG, "PlatformVideoView( " + mViewId + ")onMethodCall -> method:"
                + call.method + ", arguments:" + call.arguments);
        String method = call.method;
        switch (method) {
            case "destroyVideoView":
                destroyVideoView();
                break;
            default:
                break;
        }
    }

    private void destroyVideoView() {
        Logger.info(TUICallKitPlugin.TAG, "V2LiveRenderView destroy viewId:" + mViewId);
        if (PlatformVideoViewFactory.mVideoViewMap.containsKey(mViewId)) {
            PlatformVideoViewFactory.mVideoViewMap.remove(mViewId);
        }
    }
}
