package com.tencent.qcloud.tuikit.tuicallkit.demo;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
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
import android.widget.ListView;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;
import com.tencent.qcloud.tuikit.tuicallkit.demo.basic.IntentUtils;
import com.tencent.qcloud.tuikit.tuicallkit.demo.basic.UserModel;
import com.tencent.qcloud.tuikit.tuicallkit.demo.basic.UserModelManager;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;

import java.util.ArrayList;
import java.util.List;

public class TUICallingEntranceActivity extends Activity {

    private Toolbar          mToolbar;
    private EditText         mEtSearchUser;
    private ImageView        mIvClearSearch;
    private TextView         mTvSearch;
    private TextView         mTextUserId;    // Own userId
    private LinearLayout     mLayoutContact;
    private ImageView        mIvAvatar;
    private TextView         mTvUserName;
    private Button           mBtnStartCall;
    private ConstraintLayout mClTips;        // Search hint
    private ImageButton      mBtnLink;       // Official website link
    private ListView         mListMembers;   // Added members(Multi call)

    private UserModel mSelfModel;
    private UserModel mSearchModel;
    private int       mType;         //Call type:  videoCall/audioCall

    public static final int TYPE_AUDIO_CALL = 1;
    public static final int TYPE_VIDEO_CALL = 2;

    private static final int ERROR_CODE_USER_NOT_EXIST = 206;

    // Make a Call
    private void startCallSomeone() {
        if (mSearchModel == null || TextUtils.isEmpty(mSearchModel.userId)) {
            return;
        }
        TUICallDefine.MediaType callType = (mType == TYPE_VIDEO_CALL)
                ? TUICallDefine.MediaType.Video : TUICallDefine.MediaType.Audio;
        TUICallKit.createInstance(this).call(mSearchModel.userId, callType);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_entrance);
        mSelfModel = UserModelManager.getInstance().getUserModel();
        mType = getIntent().getIntExtra("TYPE", TYPE_VIDEO_CALL);
        initStatusBar();
        initView();
        initListener();
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

    private void initView() {
        TextView mTvTitle = (TextView) findViewById(R.id.toolbar_title);
        mEtSearchUser = (EditText) findViewById(R.id.et_search_user);
        mIvClearSearch = (ImageView) findViewById(R.id.iv_clear_search);
        mTvSearch = (TextView) findViewById(R.id.tv_search);
        mTextUserId = (TextView) findViewById(R.id.tv_self_userid);
        mLayoutContact = (LinearLayout) findViewById(R.id.ll_contract);
        mIvAvatar = (ImageView) findViewById(R.id.img_avatar);
        mTvUserName = (TextView) findViewById(R.id.tv_user_name);
        mBtnStartCall = (Button) findViewById(R.id.btn_start_call);
        mClTips = (ConstraintLayout) findViewById(R.id.cl_tips);
        mListMembers = findViewById(R.id.list_member);

        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mBtnLink = (ImageButton) findViewById(R.id.btn_link);

        mTextUserId.setText(getString(R.string.call_self_format, mSelfModel.userId));

        if (mType == TYPE_VIDEO_CALL) {
            mTvTitle.setText(getString(R.string.video_call));
        } else if (mType == TYPE_AUDIO_CALL) {
            mTvTitle.setText(getString(R.string.audio_call));
        }
    }

    public void initListener() {
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        // Jump to official website link
        mBtnLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                if (mType == TYPE_VIDEO_CALL) {
                    intent.setData(Uri.parse("https://cloud.tencent.com/document/product/647/42045"));
                    IntentUtils.safeStartActivity(TUICallingEntranceActivity.this, intent);
                }
                if (mType == TYPE_AUDIO_CALL) {
                    intent.setData(Uri.parse("https://cloud.tencent.com/document/product/647/42047"));
                    IntentUtils.safeStartActivity(TUICallingEntranceActivity.this, intent);
                }
            }
        });
        mBtnStartCall.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mSelfModel.userId.equals(mSearchModel.userId)) {
                    ToastUtil.toastShortMessage(getString(R.string.toast_not_call_myself));
                    return;
                }
                startCallSomeone();
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
    }

    private void showSearchUserModel(UserModel model) {
        if (null == model) {
            mLayoutContact.setVisibility(View.GONE);
            mClTips.setVisibility(View.VISIBLE);
            return;
        }
        mClTips.setVisibility(View.GONE);
        mLayoutContact.setVisibility(View.VISIBLE);
        ImageLoader.loadImage(this, mIvAvatar, model.userAvatar, R.drawable.ic_avatar);
        mTvUserName.setText(model.userName);
    }

    private void searchContactsByUserId(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        List<String> userList = new ArrayList<>();
        userList.add(userId);
        V2TIMManager.getInstance().getUsersInfo(userList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int errorCode, String errorMsg) {
                showSearchUserModel(null);
                if (errorCode == ERROR_CODE_USER_NOT_EXIST) {
                    ToastUtil.toastLongMessage(getString(R.string.app_user_not_exist));
                } else {
                    ToastUtil.toastLongMessage(getString(R.string.app_toast_search_fail, errorMsg));
                }
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> userFullInfoList) {
                if (null == userFullInfoList || userFullInfoList.isEmpty() || null == userFullInfoList.get(0)) {
                    return;
                }
                V2TIMUserFullInfo model = userFullInfoList.get(0);
                mSearchModel = new UserModel();
                mSearchModel.userId = model.getUserID();
                mSearchModel.userAvatar = model.getFaceUrl();
                mSearchModel.userName = model.getNickName();
                showSearchUserModel(mSearchModel);
            }
        });
    }
}
