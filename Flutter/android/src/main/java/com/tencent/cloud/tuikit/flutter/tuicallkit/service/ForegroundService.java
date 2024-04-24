package com.tencent.cloud.tuikit.flutter.tuicallkit.service;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.text.TextUtils;

import androidx.core.app.NotificationCompat;

import java.util.List;

public class ForegroundService extends Service {
    private static final int NOTIFICATION_ID = 1001;

    @Override
    public void onCreate() {
        super.onCreate();
        // Get service notice
        Notification notification = createForegroundNotification();
        //Place the service in the startup state, notification_id refers to the ID of the created notice
        startForeground(NOTIFICATION_ID, notification);
    }

    public static void start(Context context) {
        if (isServiceRunning(context, ForegroundService.class.getName())) {
            return;
        }
        Intent starter = new Intent(context, ForegroundService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(starter);
        } else {
            context.startService(starter);
        }
    }

    public static void stop(Context context) {
        Intent intent = new Intent(context, ForegroundService.class);
        context.stopService(intent);
    }

    private Notification createForegroundNotification() {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        String notificationChannelId = "notification_channel_id_01";
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            String channelName = "TUICallKit Foreground Service Notification";
            NotificationChannel notificationChannel = new NotificationChannel(
                    notificationChannelId, channelName, NotificationManager.IMPORTANCE_LOW);
            notificationChannel.setDescription("Channel description");
            if (notificationManager != null) {
                notificationManager.createNotificationChannel(notificationChannel);
            }
        }
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, notificationChannelId);
        return builder.build();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_NOT_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        super.onTaskRemoved(rootIntent);
        stopSelf();
    }

    private static boolean isServiceRunning(Context context, String className) {
        if (context == null || TextUtils.isEmpty(className)) {
            return false;
        }
        ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningServiceInfo> info = am.getRunningServices(0x7FFFFFFF);
        if (info == null || info.size() == 0) {
            return false;
        }
        for (ActivityManager.RunningServiceInfo aInfo : info) {
            if (className.equals(aInfo.service.getClassName())) {
                return true;
            }
        }
        return false;
    }
}
