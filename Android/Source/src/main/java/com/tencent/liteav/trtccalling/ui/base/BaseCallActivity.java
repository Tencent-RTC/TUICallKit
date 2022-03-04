package com.tencent.liteav.trtccalling.ui.base;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import com.tencent.liteav.trtccalling.TUICalling;
import com.tencent.liteav.trtccalling.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtccalling.model.util.TUICallingConstants;
import com.tencent.liteav.trtccalling.ui.audiocall.TUICallAudioView;
import com.tencent.liteav.trtccalling.ui.audiocall.TUIGroupCallAudioView;
import com.tencent.liteav.trtccalling.ui.common.Utils;
import com.tencent.liteav.trtccalling.ui.videocall.TUICallVideoView;
import com.tencent.liteav.trtccalling.ui.videocall.TUIGroupCallVideoView;

public class BaseCallActivity extends Activity {
    private static final String TAG = "BaseCallActivity";

    private BaseTUICallView mCallView;
    private TUICalling.Type mType;
    private TUICalling.Role mRole;
    private String[]        mUserIds;
    private String          mSponsorID;
    private String          mGroupID;
    private boolean         mIsFromGroup;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TRTCLogger.d(TAG, "===== onCreate ===== ");
        Utils.setScreenLockParams(getWindow());
        Intent intent = getIntent();
        mType = (TUICalling.Type) intent.getExtras().get(TUICallingConstants.PARAM_NAME_TYPE);
        mRole = (TUICalling.Role) intent.getExtras().get(TUICallingConstants.PARAM_NAME_ROLE);
        mUserIds = intent.getExtras().getStringArray(TUICallingConstants.PARAM_NAME_USERIDS);
        mSponsorID = intent.getExtras().getString(TUICallingConstants.PARAM_NAME_SPONSORID);
        mGroupID = intent.getExtras().getString(TUICallingConstants.PARAM_NAME_GROUPID);
        mIsFromGroup = intent.getExtras().getBoolean(TUICallingConstants.PARAM_NAME_ISFROMGROUP);
        if (isGroupCall(mGroupID, mUserIds, mRole, mIsFromGroup)) {
            if (TUICalling.Type.AUDIO == mType) {
                mCallView = createGroupAudioView(mRole, mType, mUserIds, mSponsorID, mGroupID, mIsFromGroup);
            } else if (TUICalling.Type.VIDEO == mType) {
                mCallView = createGroupVideoView(mRole, mType, mUserIds, mSponsorID, mGroupID, mIsFromGroup);
            }
        } else {
            if (TUICalling.Type.AUDIO == mType) {
                mCallView = createAudioView(mRole, mType, mUserIds, mSponsorID, mGroupID, mIsFromGroup);
            } else if (TUICalling.Type.VIDEO == mType) {
                mCallView = createVideoView(mRole, mType, mUserIds, mSponsorID, mGroupID, mIsFromGroup);
            }
        }
        setContentView(mCallView);
    }

    //创建C2C语音通话视图
    private BaseTUICallView createAudioView(TUICalling.Role role, TUICalling.Type type, String[] userIds,
                                            String sponsorID, String groupID, boolean isFromGroup) {
        return new TUICallAudioView(this, role, userIds, sponsorID, groupID, isFromGroup) {
            @Override
            public void finish() {
                super.finish();
                BaseCallActivity.this.finish();
            }
        };
    }

    //创建C2C视频通话视图
    private BaseTUICallView createVideoView(TUICalling.Role role, TUICalling.Type type, String[] userIds,
                                            String sponsorID, String groupID, boolean isFromGroup) {
        return new TUICallVideoView(this, role, userIds, sponsorID, groupID, isFromGroup) {
            @Override
            public void finish() {
                super.finish();
                BaseCallActivity.this.finish();
            }
        };
    }

    //创建群聊语音通话视图
    private BaseTUICallView createGroupAudioView(TUICalling.Role role, TUICalling.Type type, String[] userIds,
                                                 String sponsorID, String groupID, boolean isFromGroup) {
        return new TUIGroupCallAudioView(this, role, userIds, sponsorID, groupID, isFromGroup) {
            @Override
            public void finish() {
                super.finish();
                BaseCallActivity.this.finish();
            }
        };
    }

    //创建群聊视频通话视图
    private BaseTUICallView createGroupVideoView(TUICalling.Role role, TUICalling.Type type, String[] userIds,
                                                 String sponsorID, String groupID, boolean isFromGroup) {
        return new TUIGroupCallVideoView(this, role, userIds, sponsorID, groupID, isFromGroup) {
            @Override
            public void finish() {
                super.finish();
                BaseCallActivity.this.finish();
            }
        };
    }

    private boolean isGroupCall(String groupID, String[] userIDs, TUICalling.Role role, boolean isFromGroup) {
        if (!TextUtils.isEmpty(groupID)) {
            return true;
        }
        if (TUICalling.Role.CALL == role) {
            return userIDs.length >= 2;
        } else {
            return userIDs.length >= 1 || isFromGroup;
        }
    }

    @Override
    public void onBackPressed() {
        //不可删除,音视频通话中不支持返回
    }
}
