package com.tencent.qcloud.tuikit.tuicallkit.demo.basic;

import android.util.Log;

import com.google.gson.Gson;
import com.tencent.qcloud.tuicore.util.SPUtils;

public class UserModelManager {
    private static final String TAG = "UserModelManager";

    private static final String PER_DATA       = "per_profile_manager";
    private static final String PER_USER_MODEL = "per_user_model";

    private static UserModelManager sInstance;
    private        UserModel        mUserModel;

    public static UserModelManager getInstance() {
        if (sInstance == null) {
            synchronized (UserModelManager.class) {
                if (sInstance == null) {
                    sInstance = new UserModelManager();
                }
            }
        }
        return sInstance;
    }

    public synchronized UserModel getUserModel() {
        if (mUserModel == null) {
            loadUserModel();
        }
        return mUserModel == null ? new UserModel() : mUserModel;
    }

    public synchronized void setUserModel(UserModel model) {
        mUserModel = model;
        try {
            SPUtils.getInstance(PER_DATA).put(PER_USER_MODEL, new Gson().toJson(mUserModel));
        } catch (Exception e) {
            Log.e(TAG, "setUserModel, e: " + e);
        }
    }

    private void loadUserModel() {
        try {
            String json = SPUtils.getInstance(PER_DATA).getString(PER_USER_MODEL);
            mUserModel = new Gson().fromJson(json, UserModel.class);
        } catch (Exception e) {
            Log.e(TAG, "loadUserModel, e: " + e);
        }
    }
}