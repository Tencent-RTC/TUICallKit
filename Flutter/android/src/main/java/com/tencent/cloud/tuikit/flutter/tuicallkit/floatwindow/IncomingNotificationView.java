package com.tencent.cloud.tuikit.flutter.tuicallkit.floatwindow;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationChannelGroup;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;
import android.widget.RemoteViews;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.request.target.SimpleTarget;
import com.bumptech.glide.request.transition.Transition;
import com.tencent.cloud.tuikit.flutter.tuicallkit.R;
import com.tencent.cloud.tuikit.flutter.tuicallkit.TUICallKitPlugin;
import com.tencent.cloud.tuikit.flutter.tuicallkit.state.User;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Constants;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.KitAppUtils;
import com.tencent.cloud.tuikit.tuicall_engine.utils.Logger;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;

public class IncomingNotificationView {
    private static IncomingNotificationView sInstance;
    private String TAG = "IncomingNotificationView";
    private String channelID      = "CallChannelId";
    private int    notificationId = 9909;

    private Context             context;
    private RemoteViews         remoteViews;
    private NotificationManager notificationManager;
    private Notification        notification;

    public IncomingNotificationView(Context context) {
        this.context = context;
        notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
    }

    public static IncomingNotificationView getInstance(Context context) {
        if (sInstance == null) {
            synchronized (IncomingNotificationView.class) {
                if (sInstance == null) {
                    sInstance = new IncomingNotificationView(context);
                }
            }
        }
        return sInstance;
    }

    public void showNotification(User caller, TUICallDefine.MediaType mediaType) {
        Logger.info(TUICallKitPlugin.TAG, "IncomingNotificationView  showNotification | UserId:" + caller.id);

        String userId = caller.id;
        String userName = caller.nickname;
        String avatar = caller.avatar;

        createChannel();
        notification = createNotification();

        if (TextUtils.isEmpty(userName)) {
            remoteViews.setTextViewText(R.id.tv_incoming_title, userId);
        } else {
            remoteViews.setTextViewText(R.id.tv_incoming_title, userName);
        }

        if (mediaType == TUICallDefine.MediaType.Video) {
            remoteViews.setTextViewText(R.id.tv_desc,"video call");
            remoteViews.setImageViewResource(R.id.img_media_type, R.drawable.tuicallkit_ic_video_incoming);
        } else {
            remoteViews.setTextViewText(R.id.tv_desc, "voice call");
            remoteViews.setImageViewResource(R.id.img_media_type, R.drawable.tuicallkit_ic_float);
        }


        Glide.with(context).asBitmap().load(Uri.parse(avatar)).diskCacheStrategy(DiskCacheStrategy.ALL)
                .placeholder(R.drawable.tuicallkit_ic_avatar)
                .apply(RequestOptions.bitmapTransform(new RoundedCorners(15)))
                .into(new SimpleTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(@NonNull Bitmap resource,
                                                @Nullable Transition<? super Bitmap> transition) {
                        remoteViews.setImageViewBitmap(R.id.img_incoming_avatar, resource);
                        if (notificationManager != null) {
                            notificationManager.notify(notificationId, notification);
                        }
                    }

                    @Override
                    public void onLoadFailed(@Nullable Drawable errorDrawable) {
                        remoteViews.setImageViewResource(R.id.img_incoming_avatar, R.drawable.tuicallkit_ic_avatar);
                        if (notificationManager != null) {
                            notificationManager.notify(notificationId, notification);
                        }
                    }

                });
    }

    public void cancelNotification() {
        Logger.info(TUICallKitPlugin.TAG, "IncomingNotificationView  cancelNotification | notificationManager is exist:" + (notificationManager != null));
        if (notificationManager != null) {
            notificationManager.cancel(notificationId);
        }
    }

    private void createChannel() {
        Logger.info(TUICallKitPlugin.TAG, "IncomingNotificationView  createChannel");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            String channelName = "CallChannel";
            String groupID = "CallGroupId";
            String groupName = "CallGroup";

            NotificationChannelGroup channelGroup = new NotificationChannelGroup(groupID, groupName);
            notificationManager.createNotificationChannelGroup(channelGroup);
            NotificationChannel channel = new NotificationChannel(channelID, channelName,
                    NotificationManager.IMPORTANCE_HIGH);
            channel.setGroup(groupID);
            channel.enableLights(true);
            channel.setShowBadge(true);
            channel.setSound(null, null);
            notificationManager.createNotificationChannel(channel);
        }
    }

    private Notification createNotification() {
        Logger.info(TUICallKitPlugin.TAG, "IncomingNotificationView  createNotification");
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelID)
                .setOngoing(true)
                .setWhen(System.currentTimeMillis())
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setTimeoutAfter(30 * 1000L); //todo

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            builder.setCategory(NotificationCompat.CATEGORY_CALL);
            builder.setPriority(NotificationCompat.PRIORITY_MAX);
        }

        builder.setChannelId(channelID);
        builder.setTimeoutAfter(30 * 1000L); //todo
        builder.setSmallIcon(R.drawable.tuicallkit_ic_avatar);
        builder.setSound(null);

        builder.setContentIntent(getPendingIntent());

        remoteViews =new RemoteViews(context.getPackageName(), R.layout.tuicallkit_incoming_notification_view);
        builder.setCustomContentView(remoteViews);
        builder.setCustomBigContentView(remoteViews);
        return builder.build();
    }

    private PendingIntent getPendingIntent() {
        Logger.info(TUICallKitPlugin.TAG, "IncomingNotificationView  getPendingIntent");
        Intent intentLaunchMain = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
        if (intentLaunchMain != null) {
            intentLaunchMain.putExtra("show_in_foreground", true);
            intentLaunchMain.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            TUICore.notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
        } else {
            Log.e(TAG, "Failed to get launch intent for package: " + context.getPackageName());
        }
        return PendingIntent.getActivity(context, 0, intentLaunchMain, PendingIntent.FLAG_IMMUTABLE);
    }
}

