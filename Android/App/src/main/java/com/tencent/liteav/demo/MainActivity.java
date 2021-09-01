package com.tencent.liteav.demo;

import android.app.Dialog;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import androidx.constraintlayout.widget.ConstraintLayout;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.basic.ImageLoader;
import com.tencent.liteav.basic.UserModel;
import com.tencent.liteav.basic.UserModelManager;
import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.liteav.trtccalling.model.TRTCCalling;
import com.tencent.liteav.trtccalling.model.TRTCCallingDelegate;
import com.tencent.liteav.trtccalling.model.impl.base.CallingInfoManager;
import com.tencent.liteav.trtccalling.ui.audiocall.TRTCAudioCallActivity;
import com.tencent.liteav.trtccalling.ui.common.RoundCornerImageView;
import com.tencent.liteav.trtccalling.ui.videocall.TRTCVideoCallActivity;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 联系人选择Activity，可以通过此界面搜索已注册用户，并发起通话；
 */
public class MainActivity extends AppCompatActivity {
    private static final String TAG = "MainActivity";

    private Toolbar          mToolbar;      //导航栏，主要负责监听导航栏返回按钮
    private EditText         mEtSearchUser; //输入手机号码的编辑文本框
    private ImageView        mIvClearSearch;//清除搜索框文本按钮
    private TextView         mTvSearch;     //开始搜索用户的按钮
    private TextView         mTvSelfUserId;  //自己的userId
    private LinearLayout     mLlContract;   //用来展示对方信息的layout
    private RoundCornerImageView mIvAvatar;    //用来展示对方头像
    private TextView         mTvUserName;   //用来展示对方昵称
    private Button           mBtnStartCall; //开始呼叫按钮
    private ConstraintLayout mClTips;       //显示搜索提示信息
    private ImageButton      mBtnLink;      //跳转官网链接

    private UserModel mSelfModel;    //表示当前用户的UserModel
    private UserModel mSearchModel;  //表示当前搜索的usermodel
    private int       mType; //表示当前是 videocall/audiocall
    private TRTCCalling mTRTCCalling;

    private TRTCCallingDelegate mTRTCCallingDelegate = new TRTCCallingDelegate() {
        @Override
        public void onError(int code, String msg) {
        }

        @Override
        public void onInvited(String sponsor, final List<String> userIdList, boolean isFromGroup, final int callType) {
            //1. 收到邀请，先到服务器查询
            CallingInfoManager.getInstance().getUserInfoByUserId(sponsor, new CallingInfoManager.UserCallback() {
                @Override
                public void onSuccess(final UserModel model) {
                    if (callType == TRTCCalling.TYPE_VIDEO_CALL) {
                        TRTCVideoCallActivity.UserInfo selfInfo = new TRTCVideoCallActivity.UserInfo();
                        selfInfo.userId = UserModelManager.getInstance().getUserModel().userId;
                        selfInfo.userAvatar = UserModelManager.getInstance().getUserModel().userAvatar;
                        selfInfo.userName = UserModelManager.getInstance().getUserModel().userName;
                        TRTCVideoCallActivity.UserInfo callUserInfo = new TRTCVideoCallActivity.UserInfo();
                        callUserInfo.userId = model.userId;
                        callUserInfo.userAvatar = model.userAvatar;
                        callUserInfo.userName = model.userName;
                        TRTCVideoCallActivity.startBeingCall(MainActivity.this, selfInfo, callUserInfo, null);
                    } else if (callType == TRTCCalling.TYPE_AUDIO_CALL) {
                        TRTCAudioCallActivity.UserInfo selfInfo = new TRTCAudioCallActivity.UserInfo();
                        selfInfo.userId = UserModelManager.getInstance().getUserModel().userId;
                        selfInfo.userAvatar = UserModelManager.getInstance().getUserModel().userAvatar;
                        selfInfo.userName = UserModelManager.getInstance().getUserModel().userName;
                        TRTCAudioCallActivity.UserInfo callUserInfo = new TRTCAudioCallActivity.UserInfo();
                        callUserInfo.userId = model.userId;
                        callUserInfo.userAvatar = model.userAvatar;
                        callUserInfo.userName = model.userName;
                        TRTCAudioCallActivity.startBeingCall(MainActivity.this, selfInfo, callUserInfo, null);
                    }
                }

                @Override
                public void onFailed(int code, String msg) {

                }
            });
        }

        @Override
        public void onGroupCallInviteeListUpdate(List<String> userIdList) {

        }

        @Override
        public void onUserEnter(String userId) {

        }

        @Override
        public void onUserLeave(String userId) {

        }

        @Override
        public void onReject(String userId) {

        }

        @Override
        public void onNoResp(String userId) {

        }

        @Override
        public void onLineBusy(String userId) {

        }

        @Override
        public void onCallingCancel() {

        }

        @Override
        public void onCallingTimeout() {

        }

        @Override
        public void onCallEnd() {

        }

        @Override
        public void onUserVideoAvailable(String userId, boolean isVideoAvailable) {

        }

        @Override
        public void onUserAudioAvailable(String userId, boolean isVideoAvailable) {

        }

        @Override
        public void onUserVoiceVolume(Map<String, Integer> volumeMap) {

        }

        @Override
        public void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, ArrayList<TRTCCloudDef.TRTCQuality> remoteQuality) {

        }

        @Override
        public void onSwitchToAudio(boolean success, String message) {

        }
        // </editor-fold  desc="视频监听代码">
    };


    /**
     * 开始呼叫某人
     */
    private void startCallSomeone() {
        if (mType == TRTCCalling.TYPE_VIDEO_CALL) {
            ToastUtils.showShort(getString(R.string.toast_video_call, mSearchModel.userName));
            TRTCVideoCallActivity.startCallSomeone(this, mSelfModel, mSearchModel);
        } else if (mType == TRTCCalling.TYPE_AUDIO_CALL){
            ToastUtils.showShort(getString(R.string.toast_voice_call, mSearchModel.userName));
            TRTCAudioCallActivity.startCallSomeone(this, mSelfModel, mSearchModel);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mSelfModel = UserModelManager.getInstance().getUserModel();
        mType = getIntent().getIntExtra("TYPE", TRTCCalling.TYPE_VIDEO_CALL);
        initStatusBar();
        initView();
        initData();
    }

    private void initView() {
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mEtSearchUser = (EditText) findViewById(R.id.et_search_user);
        mIvClearSearch = (ImageView) findViewById(R.id.iv_clear_search);
        mTvSearch = (TextView) findViewById(R.id.tv_search);
        mTvSelfUserId = (TextView) findViewById(R.id.tv_self_userId);
        mLlContract = (LinearLayout) findViewById(R.id.ll_contract);
        mIvAvatar = (RoundCornerImageView) findViewById(R.id.img_avatar);
        mTvUserName = (TextView) findViewById(R.id.tv_user_name);
        mBtnStartCall = (Button) findViewById(R.id.btn_start_call);
        mClTips = (ConstraintLayout) findViewById(R.id.cl_tips);
        mBtnLink = (ImageButton) findViewById(R.id.btn_trtccalling_link);
        mBtnLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                if (mType == TRTCCalling.TYPE_VIDEO_CALL) {
                    intent.setData(Uri.parse("https://cloud.tencent.com/document/product/647/42045"));
                    startActivity(intent);
                } else if (mType == TRTCCalling.TYPE_AUDIO_CALL) {
                    intent.setData(Uri.parse("https://cloud.tencent.com/document/product/647/42047"));
                    startActivity(intent);
                }
            }
        });

        // 导航栏回退/设置
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        //呼叫选择
        mBtnStartCall.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mSelfModel.userId.equals(mSearchModel.userId)) {
                    ToastUtils.showShort(getString(R.string.toast_not_call_myself));
                    return;
                }
                showChooseDialog();
            }
        });

        mEtSearchUser.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                    searchContactsByUserId(v.getText().toString());
                    return true;
                }
                return false;
            }
        });

        mEtSearchUser.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence text, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence text, int start, int before, int count) {
                if (text.length() == 0) {
                    mIvClearSearch.setVisibility(View.GONE);
                } else {
                    mIvClearSearch.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });

        mTvSearch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                searchContactsByUserId(mEtSearchUser.getText().toString());
            }
        });

        mIvClearSearch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mEtSearchUser.setText("");
            }
        });
        mTvSelfUserId.setText(getString(R.string.call_self_format, mSelfModel.phone));
    }

    private void showChooseDialog() {
        final Dialog dialog = new BottomSheetDialog(this, R.style.BottomDialog);
        dialog.setContentView(R.layout.calling_choose_dialog);
        TextView tvAudio = (TextView) dialog.findViewById(R.id.tv_audio_type);
        TextView tvVideo = (TextView) dialog.findViewById(R.id.tv_video_type);
        TextView tvCancel = (TextView) dialog.findViewById(R.id.tv_cancel_call);

        tvAudio.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mType = TRTCCalling.TYPE_AUDIO_CALL;
                startCallSomeone();
                dialog.dismiss();
            }
        });
        tvVideo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mType = TRTCCalling.TYPE_VIDEO_CALL;
                startCallSomeone();
                dialog.dismiss();
            }
        });
        tvCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
            }
        });
        dialog.show();
    }

    private void showSearchUserModel(UserModel model) {
        if (model == null) {
            mLlContract.setVisibility(View.GONE);
            mClTips.setVisibility(View.VISIBLE);
            return;
        }
        mClTips.setVisibility(View.GONE);
        mLlContract.setVisibility(View.VISIBLE);
        ImageLoader.loadImage(this, mIvAvatar, model.userAvatar, R.drawable.trtccalling_ic_avatar);
        mTvUserName.setText(model.userName);
    }

    private void initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    private void searchContactsByUserId(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        CallingInfoManager.getInstance().getUserInfoByUserId(userId, new CallingInfoManager.UserCallback() {
            @Override
            public void onSuccess(UserModel model) {
                mSearchModel = model;
                showSearchUserModel(model);
            }

            @Override
            public void onFailed(int code, String msg) {
                showSearchUserModel(null);
                ToastUtils.showLong(getString(R.string.trtccalling_toast_search_fail, msg));
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mTRTCCalling != null) {
            mTRTCCalling.removeDelegate(mTRTCCallingDelegate);
        }
    }

    private void initData() {
        final UserModel userModel = UserModelManager.getInstance().getUserModel();
        mTRTCCalling = TRTCCalling.sharedInstance(this);
        mTRTCCalling.addDelegate(mTRTCCallingDelegate);
        mTRTCCalling.login(GenerateTestUserSig.SDKAPPID, userModel.userId, userModel.userSig, new TRTCCalling.ActionCallBack() {
            @Override
            public void onError(int code, String msg) {
                Log.d(TAG, "code: "+code + " msg:"+msg);
            }

            @Override
            public void onSuccess() {

            }
        });
    }

}
