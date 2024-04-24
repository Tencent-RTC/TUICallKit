package com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow;

import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Build;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.tencent.cloud.tuikit.flutter.tuicallkit.R;
import com.tencent.cloud.tuikit.flutter.tuicallkit.TUICallKitPlugin;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.TUICallState;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.User;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitPermissionUtils;
import com.tencent.cloud.tuikit.tuicall_engine.utils.Logger;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;
public class IncomingFloatView {
    private static final String                     TAG = "IncomingFloatView";
    private              WindowManager              mWindowManager;
    private              WindowManager.LayoutParams mWindowLayoutParams;

    private View      layoutView;
    private ImageView imageFloatAvatar;
    private TextView  textFloatTitle;
    private TextView  textFloatDescription;
    private ImageView imageReject;
    private ImageView imageAccept;

    private  User user;
    private TUICallDefine.MediaType mediaType;

    private Context context;

    private int padding = 20;

    public IncomingFloatView(Context context) {
        this.context = context;
    }

    public void showIncomingView( User caller, TUICallDefine.MediaType mediaType) {
        Logger.info(TUICallKitPlugin.TAG, "IncomingFloatView  showIncomingView | UserId:" + caller.id);

        this.context = context;
        this.user = caller;
        this.mediaType = mediaType;
        initWindow();
    }

    private void initWindow() {
        Logger.info(TUICallKitPlugin.TAG, "IncomingFloatView  initWindow");

        layoutView = LayoutInflater.from(context).inflate(R.layout.tuicallkit_incoming_float_view, null);
        imageFloatAvatar = layoutView.findViewById(R.id.img_float_avatar);
        textFloatTitle = layoutView.findViewById(R.id.tv_float_title);
        textFloatDescription = layoutView.findViewById(R.id.tv_float_desc);
        imageReject = layoutView.findViewById(R.id.btn_float_decline);
        imageAccept = layoutView.findViewById(R.id.btn_float_accept);

        Uri avatarUri = Uri.parse(user.avatar);
        if (avatarUri == null) {
            if (imageFloatAvatar != null && R.drawable.tuicallkit_ic_avatar != 0) {
                imageFloatAvatar.setImageResource(R.drawable.tuicallkit_ic_avatar);
            }
        } else {
            Glide.with(context).load(avatarUri).error(R.drawable.tuicallkit_ic_avatar).into(imageFloatAvatar);
        }

        textFloatTitle.setText(user.nickname);
        if (mediaType == TUICallDefine.MediaType.Video) {
            String str = (String) TUICallState.getInstance().mResourceMap.get(TUICallState.getInstance().mScene == TUICallDefine.Scene.SINGLE_CALL ? "k_0000002_1" : "k_0000003");
            textFloatDescription.setText(str);

            imageAccept.setImageResource(R.drawable.tuicallkit_ic_dialing_video);
        } else {
            String str = (String) TUICallState.getInstance().mResourceMap.get(TUICallState.getInstance().mScene == TUICallDefine.Scene.SINGLE_CALL ? "k_0000002" : "k_0000003");
            textFloatDescription.setText(str);

            imageAccept.setImageResource(R.drawable.tuicallkit_ic_dialing);
        }
        imageReject.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                cancelIncomingView();
                TUICallEngine.createInstance(context).reject(null);
            }
        });

        layoutView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                cancelIncomingView();
                if (KitPermissionUtils.hasPermission(PermissionRequester.BG_START_PERMISSION)) {
                    Intent intentLaunchMain = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
                    if (intentLaunchMain != null) {
                        intentLaunchMain.putExtra("show_in_foreground", true);
                        intentLaunchMain.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        context.startActivity(intentLaunchMain);
                        TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
                    } else {
                        Logger.error(TAG, "Failed to get launch intent for package: " + context.getPackageName());
                    }
                } else {
                    TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
                }
            }
        });

        imageAccept.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                cancelIncomingView();
                TUICallEngine.createInstance(context).accept(null);
                if (KitPermissionUtils.hasPermission(PermissionRequester.BG_START_PERMISSION)) {
                    Intent intentLaunchMain = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
                    if (intentLaunchMain != null) {
                        intentLaunchMain.putExtra("show_in_foreground", true);
                        intentLaunchMain.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        context.startActivity(intentLaunchMain);
                        TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
                    } else {
                        Logger.error(TAG, "Failed to get launch intent for package: " + context.getPackageName());
                    }
                } else {
                    TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
                }
            }
        });

        mWindowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        mWindowManager.addView(layoutView, getViewParams());
    }

    private WindowManager.LayoutParams getViewParams() {
        mWindowLayoutParams = new WindowManager.LayoutParams();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            mWindowLayoutParams.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            mWindowLayoutParams.type = WindowManager.LayoutParams.TYPE_PHONE;
        }
        mWindowLayoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                | WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS;

        mWindowLayoutParams.gravity = Gravity.START | Gravity.TOP;
        mWindowLayoutParams.x = padding;
        mWindowLayoutParams.y = 0;

        mWindowLayoutParams.width = ScreenUtil.getRealScreenWidth(context) - padding * 2;
        mWindowLayoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
        mWindowLayoutParams.format = PixelFormat.TRANSPARENT;

        return mWindowLayoutParams;
    }

    public void cancelIncomingView() {
        Logger.info(TUICallKitPlugin.TAG, "IncomingFloatView  cancelIncomingView");

        if (layoutView != null && layoutView.isAttachedToWindow() && mWindowManager != null) {
            mWindowManager.removeView(layoutView);
        }
        layoutView = null;
    }
}