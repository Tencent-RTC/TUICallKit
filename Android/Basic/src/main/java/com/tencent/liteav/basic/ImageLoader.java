package com.tencent.liteav.basic;

import android.graphics.drawable.Drawable;
import android.support.annotation.DrawableRes;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.widget.ImageView;

import com.squareup.picasso.Callback;
import com.squareup.picasso.Picasso;

public class ImageLoader {

    public static void load(String url, @DrawableRes int placeholderResId, @DrawableRes int errorResId, ImageView target) {
        load(url, placeholderResId, errorResId, target, null);
    }

    public static void load(String url, @NonNull Drawable placeholderDrawable, @NonNull Drawable errorDrawable, ImageView target) {
        load(url, placeholderDrawable, errorDrawable, target, null);
    }

    public static void load(String url, ImageView target) {
        load(url, target, null);
    }

    public static void load(String url, @DrawableRes int placeholderResId, @DrawableRes int errorResId, ImageView target, Callback callback) {
        if (TextUtils.isEmpty(url)) {
            if (target != null && errorResId != 0) {
                target.setImageResource(errorResId);
            }
            if (callback != null) {
                callback.onError(new Exception("Invalid url."));
            }
            return;
        }
        Picasso.get().load(url).placeholder(placeholderResId).error(errorResId).into(target, callback);
    }

    public static void load(String url, @NonNull Drawable placeholderDrawable, @NonNull Drawable errorDrawable, ImageView target, Callback callback) {
        if (TextUtils.isEmpty(url)) {
            if (target != null && errorDrawable != null) {
                target.setImageDrawable(errorDrawable);
            }
            if (callback != null) {
                callback.onError(new Exception("Invalid url."));
            }
            return;
        }
        Picasso.get().load(url).placeholder(placeholderDrawable).error(errorDrawable).into(target, callback);
    }

    public static void load(String url, ImageView target, Callback callback) {
        if (TextUtils.isEmpty(url)) {
            if (callback != null) {
                callback.onError(new Exception("Invalid url."));
            }
            return;
        }
        Picasso.get().load(url).into(target, callback);
    }
}
