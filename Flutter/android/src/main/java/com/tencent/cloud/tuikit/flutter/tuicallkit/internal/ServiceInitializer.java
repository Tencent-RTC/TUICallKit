package com.tencent.cloud.tuikit.flutter.tuicallkit.internal;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;

/**
 * `TUICallKit` uses `ContentProvider` to be registered with `TUICore`.
 * (`TUICore` is the connection and communication class of each component)
 */
public final class ServiceInitializer extends ContentProvider {
    public void init(Context context) {
        TUICallingService callingService = TUICallingService.sharedInstance();
        callingService.init(context);
        TUICore.registerService(TUIConstants.TUICalling.SERVICE_NAME, callingService);
    }

    @Override
    public boolean onCreate() {
        Context appContext = getContext().getApplicationContext();
        init(appContext);
        return false;
    }

    @Nullable
    @Override
    public Cursor query(@NonNull Uri uri, @Nullable String[] projection, @Nullable String selection,
                        @Nullable String[] selectionArgs, @Nullable String sortOrder) {
        return null;
    }

    @Nullable
    @Override
    public String getType(@NonNull Uri uri) {
        return null;
    }

    @Nullable
    @Override
    public Uri insert(@NonNull Uri uri, @Nullable ContentValues values) {
        return null;
    }

    @Override
    public int delete(@NonNull Uri uri, @Nullable String selection, @Nullable String[] selectionArgs) {
        return 0;
    }

    @Override
    public int update(@NonNull Uri uri, @Nullable ContentValues values, @Nullable String selection,
                      @Nullable String[] selectionArgs) {
        return 0;
    }
}
