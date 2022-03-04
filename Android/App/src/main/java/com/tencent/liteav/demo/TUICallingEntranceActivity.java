package com.tencent.liteav.demo;

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
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.basic.ImageLoader;
import com.tencent.liteav.basic.IntentUtils;
import com.tencent.liteav.basic.UserModel;
import com.tencent.liteav.basic.UserModelManager;
import com.tencent.liteav.trtccalling.TUICalling;
import com.tencent.liteav.trtccalling.TUICallingImpl;
import com.tencent.liteav.trtccalling.model.impl.base.CallingInfoManager;
import com.tencent.liteav.trtccalling.ui.common.RoundCornerImageView;

import java.util.ArrayList;
import java.util.List;

public class TUICallingEntranceActivity extends Activity {

    private Toolbar              mToolbar;       //导航栏，主要负责监听导航栏返回按钮
    private TextView             mTvTitle;       //导航栏标题
    private EditText             mEtSearchUser;  //输入手机号码的编辑文本框
    private ImageView            mIvClearSearch; //清除搜索框文本按钮
    private TextView             mTvSearch;      //开始搜索用户的按钮
    private TextView             mTextUserId;    //自己的手机号
    private LinearLayout         mLlContract;    //用来展示对方信息的layout
    private RoundCornerImageView mIvAvatar;      //用来展示对方头像
    private TextView             mTvUserName;    //用来展示对方昵称
    private Button               mBtnStartCall;  //开始呼叫按钮
    private ConstraintLayout     mClTips;        //显示搜索提示信息
    private ImageButton          mBtnLink;       //跳转官网链接
    private ListView             mListMembers;   //已添加成员（多人通话）

    private UserModel mSelfModel;    //表示当前用户的 UserModel
    private UserModel mSearchModel;  //表示当前搜索的 UserModel
    private int       mType;         //表示当前是 videocall/audiocall

    public static final int TYPE_UNKNOWN          = 0;
    public static final int TYPE_AUDIO_CALL       = 1;
    public static final int TYPE_VIDEO_CALL       = 2;
    public static final int TYPE_MULTI_AUDIO_CALL = 3;
    public static final int TYPE_MULTI_VIDEO_CALL = 4;

    private static final int MULTI_CALL_MAX_NUM        = 8; //C2C多人通话最大人数是9(需包含自己)
    private static final int ERROR_CODE_USER_NOT_EXIST = 206;

    private final List<UserModel> mUserModelList = new ArrayList<>();

    /**
     * 开始呼叫某人
     */
    private void startCallSomeone() {
        String[] userIDs = new String[mUserModelList.size()];
        for (int i = 0; i < userIDs.length; i++) {
            userIDs[i] = mUserModelList.get(i).userId;
        }
        if (userIDs.length == 0) {
            ToastUtils.showShort(getString(R.string.app_toast_no_member));
            return;
        }
        TUICalling.Type callType = (mType == TYPE_VIDEO_CALL || mType == TYPE_MULTI_VIDEO_CALL)
                ? TUICalling.Type.VIDEO : TUICalling.Type.AUDIO;
        TUICallingImpl.sharedInstance(this).call(userIDs, callType);
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
        mTvTitle = (TextView) findViewById(R.id.toolbar_title);
        mEtSearchUser = (EditText) findViewById(R.id.et_search_user);
        mIvClearSearch = (ImageView) findViewById(R.id.iv_clear_search);
        mTvSearch = (TextView) findViewById(R.id.tv_search);
        mTextUserId = (TextView) findViewById(R.id.tv_self_userid);
        mLlContract = (LinearLayout) findViewById(R.id.ll_contract);
        mIvAvatar = (RoundCornerImageView) findViewById(R.id.img_avatar);
        mTvUserName = (TextView) findViewById(R.id.tv_user_name);
        mBtnStartCall = (Button) findViewById(R.id.btn_start_call);
        mClTips = (ConstraintLayout) findViewById(R.id.cl_tips);
        mListMembers = findViewById(R.id.list_member);
        //导航栏，主要负责监听导航栏返回按钮
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mBtnLink = (ImageButton) findViewById(R.id.btn_link);

        mTextUserId.setText(getString(R.string.call_self_format, mSelfModel.userId));

        if (mType == TYPE_VIDEO_CALL) {
            mTvTitle.setText(getString(R.string.video_call));
        } else if (mType == TYPE_AUDIO_CALL) {
            mTvTitle.setText(getString(R.string.audio_call));
        } else if (mType == TYPE_MULTI_VIDEO_CALL) {
            mTvTitle.setText(getString(R.string.app_item_multi_video_call));
        } else if (mType == TYPE_MULTI_AUDIO_CALL) {
            mTvTitle.setText(getString(R.string.app_item_multi_video_call));
        }
        if (isMultiMemberCall()) {
            initMemberList();
            mBtnStartCall.setText(R.string.app_add);
            mBtnLink.setVisibility(View.GONE);
            findViewById(R.id.btn_ok).setVisibility(View.VISIBLE);
            findViewById(R.id.btn_ok).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    startCallSomeone();
                }
            });
        }
    }

    public void initListener() {
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        //跳转官网链接
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
                    ToastUtils.showShort(getString(R.string.toast_not_call_myself));
                    return;
                }

                if (mUserModelList.size() >= MULTI_CALL_MAX_NUM) {
                    ToastUtils.showShort(getString(R.string.app_toast_multi_call_num_exceed));
                    return;
                }
                if (isMultiMemberCall()) {
                    for (UserModel model : mUserModelList) {
                        if (TextUtils.equals(model.userId, mSearchModel.userId)) {
                            ToastUtils.showShort(getString(R.string.app_toast_user_added));
                            return;
                        }
                    }
                    mUserModelList.add(mSearchModel);
                    ((BaseAdapter) mListMembers.getAdapter()).notifyDataSetChanged();
                } else {
                    //1V1单聊,每次清除搜索用户信息
                    mUserModelList.clear();
                    mUserModelList.add(mSearchModel);
                    startCallSomeone();
                }
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

    private boolean isMultiMemberCall() {
        return mType == TYPE_MULTI_AUDIO_CALL || mType == TYPE_MULTI_VIDEO_CALL;
    }

    private void showSearchUserModel(UserModel model) {
        if (null == model) {
            mLlContract.setVisibility(View.GONE);
            mClTips.setVisibility(View.VISIBLE);
            return;
        }
        mClTips.setVisibility(View.GONE);
        mLlContract.setVisibility(View.VISIBLE);
        ImageLoader.loadImage(this, mIvAvatar, model.userAvatar, R.drawable.ic_avatar);
        mTvUserName.setText(model.userName);
    }

    private void initMemberList() {
        BaseAdapter adapter = new BaseAdapter() {
            @Override
            public int getCount() {
                return mUserModelList.size();
            }

            @Override
            public Object getItem(int position) {
                return mUserModelList.get(position);
            }

            @Override
            public long getItemId(int position) {
                return position;
            }

            @Override
            public View getView(final int position, View convertView, ViewGroup parent) {
                View view = View.inflate(TUICallingEntranceActivity.this, R.layout.calling_list_item_user, null);
                UserModel userModel = (UserModel) getItem(position);
                TextView textView = view.findViewById(R.id.tv_user_name);
                RoundCornerImageView imageView = view.findViewById(R.id.img_avatar);
                textView.setText(userModel.userId);
                ImageLoader.loadImage(TUICallingEntranceActivity.this,
                        imageView, userModel.userAvatar, R.drawable.ic_avatar);
                Button button = view.findViewById(R.id.btn_remove);
                button.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mUserModelList.remove(position);
                        notifyDataSetChanged();
                    }
                });
                return view;
            }
        };
        mListMembers.setAdapter(adapter);
        findViewById(R.id.ll_list).setVisibility(View.VISIBLE);
    }

    private void searchContactsByUserId(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        CallingInfoManager.getInstance().getUserInfoByUserId(userId, new CallingInfoManager.UserCallback() {
            @Override
            public void onSuccess(com.tencent.liteav.trtccalling.model.impl.UserModel model) {
                mSearchModel = new UserModel();
                mSearchModel.userId = model.userId;
                mSearchModel.userName = TextUtils.isEmpty(model.userName) ? model.userId : model.userName;
                showSearchUserModel(mSearchModel);
            }

            @Override
            public void onFailed(int code, String msg) {
                showSearchUserModel(null);
                if (code == ERROR_CODE_USER_NOT_EXIST) {
                    ToastUtils.showLong(getString(R.string.app_user_not_exist));
                } else {
                    ToastUtils.showLong(getString(R.string.trtccalling_toast_search_fail, msg));
                }
            }
        });
    }
}
