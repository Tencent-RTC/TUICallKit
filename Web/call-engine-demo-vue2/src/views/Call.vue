<template>
  <div class="call-container">
    <CallPlayer @call-control-event="handleCallControl" />
    <div class="wrap">
      <RouterView
        @call-control-event="handleCallControl"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue';
import { RouterView } from 'vue-router';
import { TUICallEngine, TUICallEvent } from 'tuicall-engine-webrtc';
import { useCallInfoStore, useUserInfoStore } from '@/stores';
import { useLoginAuth } from '@/hooks/useLoginAuth';
import CallPlayer from '@/components/call/CallPlayer.vue';
import { ElMessage, ElMessageBox } from '@/components/compatibleComponents';
import { AVATAR_MODIFY_FAIL, AVATAR_MODIFY_SUCCESS, CallState, CallTypeDesc, DefaultAvatarUrl, DefaultSdkAppId, MediaType, NICKNAME_MODIFY_FAIL, NICKNAME_MODIFY_SUCCESS, SDK_NOT_READY } from '@/constants';
import * as tips from '@/constants/tips';
import useTimInstance from '@/hooks/useTimInstance';
import { router } from '@/router';
import TIM from 'tim-js-sdk';
import { isEmpty, noop } from 'lodash';
import genTestUserSig from '@/utils/gen-test-user-sig';

useLoginAuth();
const callInfoStore = useCallInfoStore();
const userInfoStore = useUserInfoStore();

const isSDKReady = ref(false);
let tuiCallEngine: any = null;

async function updateDeviceList() {
  const cameras = await tuiCallEngine.getDeviceList('camera');
  const microphones = await tuiCallEngine.getDeviceList('microphones');
  callInfoStore.$patch({
    cameras,
    microphones,
    currentCamera: cameras?.[0]?.deviceId,
    currentMicrophone: microphones?.[0]?.deviceId,
  });
}
const handleSdkReady = async () => {
  isSDKReady.value = true;

  try {
    const tim = useTimInstance();
    const res = await tim.getMyProfile();
    let { nick, avatar } = res?.data;

    if (isEmpty(avatar)) {
      avatar = DefaultAvatarUrl;
    }

    userInfoStore.$patch({
      nickName: nick,
      avatar,
    });
  } catch (err) {
    console.error(err);
  }
};
const handleNewInvitationReceived = async (event: any) => {
  const { inviteData: { callType, roomID }, isFromGroup, sponsor } = event;
  callInfoStore.toggleCallState(CallState.CALLING);
  callInfoStore.callType = callType;
  ElMessageBox.confirm(
    `收到 ${sponsor} 通话邀请`,
    '通话邀请',
    {
      confirmButtonText: '接听',
      cancelButtonText: '拒绝',
    },
  ).then(async () => {
    router.push(`/call/panel/${isFromGroup ? CallTypeDesc.GROUP_CALL : CallTypeDesc.SINGLE_CALL}`);
    await tuiCallEngine.accept();
    callInfoStore.toggleCallState(CallState.CONNECTED);

    if (callType === MediaType.VIDEO) {
      await tuiCallEngine.openCamera('localVideoWrapper');
    }

    if (isFromGroup) {
      callInfoStore.roomID = roomID;
    }
  })
    .catch(async (err: any) => {
      await tuiCallEngine.reject();
      callInfoStore.toggleCallState(CallState.IDLE);
      console.warn(err);
    });
};
const handleUserLeave = (event: any) => {
  const { userID } = event;
  callInfoStore.removeRemoteUser({ userID });
};
const handleVideoAvailable = (event: any) => {
  const { userID, isVideoAvailable } = event;
  callInfoStore.updateRemoteUserList({ userID, isVideoAvailable });
  callInfoStore.toggleCallState(CallState.CONNECTED);
};
const handleCallingCancel = () => {
  try {
    ElMessageBox.close();
  } catch (err) {
    noop();
  }
  callInfoStore.toggleCallState(CallState.IDLE);
};
const handleNoResp = () => {
  callInfoStore.toggleCallState(CallState.IDLE);
};
const handleLineBusy = () => {
  callInfoStore.toggleCallState(CallState.IDLE);
};
const handleKickedOut = () => {
  callInfoStore.toggleCallState(CallState.IDLE);
};
const handleCallingEnd = () => {
  callInfoStore.toggleCallState(CallState.IDLE);
};

const  bindCallEngineEvents = async () => {
  tuiCallEngine.on(TUICallEvent.SDK_READY, handleSdkReady);
  tuiCallEngine.on(TUICallEvent.INVITED, handleNewInvitationReceived);
  tuiCallEngine.on(TUICallEvent.USER_VIDEO_AVAILABLE, handleVideoAvailable);
  tuiCallEngine.on(TUICallEvent.NO_RESP, handleNoResp);
  tuiCallEngine.on(TUICallEvent.LINE_BUSY, handleLineBusy);
  tuiCallEngine.on(TUICallEvent.KICKED_OUT, handleKickedOut);
  tuiCallEngine.on(TUICallEvent.CALLING_END, handleCallingEnd);
  tuiCallEngine.on(TUICallEvent.CALLING_CANCEL, handleCallingCancel);
  tuiCallEngine.on(TUICallEvent.USER_LEAVE, handleUserLeave);
};

/**
 * 1. 初始化TUICallEngine
 * 2. 绑定事件
 * 3. 更新设备列表
*/
const initTUICallEngine = async (options) => {
  const { sdkAppID, tim } = options;
  tuiCallEngine = TUICallEngine.createInstance({
    SDKAppID: sdkAppID,
    tim,
  });
  await tuiCallEngine.init({ userID: userInfoStore.userID, userSig: userInfoStore.userSig });
  bindCallEngineEvents();
  await updateDeviceList();
};

// 统一处理呼叫，挂断等视频设置的函数
const handleCallControl = async (type: { key: string, value: any }) => {
  const { key, value } = type;
  switch (key) {
    case 'call':
      if (!isSDKReady.value) {
        ElMessage.error(SDK_NOT_READY);
        return;
      }

      try {
        const tim = useTimInstance();
        callInfoStore.toggleCallState(CallState.CALLING);
        const {
          callType,
          isGroupCall,
          inviteeId,
          userData = '',
          timeout = 0,
          offlinePushInfo,
        } = value;

        if (isGroupCall) {
          const memberList: { userID: string}[] = [];
          const userIDList = inviteeId.split(',');
          [...userIDList, userInfoStore.userID].forEach((user) => {
            memberList.push({ userID: user });
          });
          const res = await tim.createGroup({
            type: TIM.TYPES.GRP_PUBLIC,
            name: 'group-call',
            memberList,
          });
          const { groupID } = res.data.group;
          await tuiCallEngine.groupCall({
            userIDList,
            type: callType,
            groupID,
            userData,
            timeout,
            offlinePushInfo,
          });
          callInfoStore.$patch({
            groupID,
          });
        } else {
          await tuiCallEngine.call({
            userID: inviteeId,
            type: callType,
            userData,
            timeout,
            offlinePushInfo,
          });
        }

        if (callType === MediaType.VIDEO) {
          await tuiCallEngine.openCamera('localVideoWrapper');
        }
      } catch (err) {
        callInfoStore.toggleCallState(CallState.IDLE);
        ElMessage.error(tips.CALL_FAIL);
        console.error(err);
      }
      break;
    case 'controlCamera':
      if (value) {
        await tuiCallEngine.openCamera('localVideoWrapper');
      } else {
        await tuiCallEngine.closeCamera();
      }
      break;
    case 'profile':
      await tuiCallEngine.setVideoQuality(value);
      break;
    case 'hangup':
      try {
        await tuiCallEngine.hangup();
        callInfoStore.toggleCallState(CallState.IDLE);
      } catch (err) {
        ElMessage.error(tips.HANGUP_FAIL);
        console.error(err);
      }
      callInfoStore.resetCallInfo();;
      break;
    case 'controlMicrophone':
      if (value) {
        await tuiCallEngine.openMicrophone();
      } else {
        await tuiCallEngine.closeMicrophone();
      }
      break;
    case 'enableAIVoice':
      await tuiCallEngine.enableAIVoice(value);
      break;
    case 'switchCallMediaType':
      await tuiCallEngine.switchCallMediaType(value);
      break;
    case 'objectFit':
      await tuiCallEngine.setVideoRenderParams({ objectFit: value });
      break;
    case 'switchDevice':
      await tuiCallEngine.switchDevice(value);
      break;
    case 'nickName':
      try {
        await tuiCallEngine.setSelfInfo({ nickName: value });
        userInfoStore.nickName = value;
        ElMessage.success(NICKNAME_MODIFY_SUCCESS);
      } catch (err) {
        ElMessage.error(NICKNAME_MODIFY_FAIL);
        console.error(err);
      }
      break;
    case 'avatar':
      try {
        await tuiCallEngine.setSelfInfo({ avatar: value });
        userInfoStore.avatar = value;
        ElMessage.success(AVATAR_MODIFY_SUCCESS);
      } catch (err) {
        ElMessage.error(AVATAR_MODIFY_FAIL);
        console.error(err);
      }
      break;
    case 'startRemoteView':
      try {
        await tuiCallEngine.startRemoteView(value);
      } catch (err) {
        ElMessage.error(tips.START_REMOTE_VIEW_FAIL);
        console.error(err);
      }
      break;
    case 'stopRemoteView':
      try {
        await tuiCallEngine.stopRemoteView({ userID: value });
      } catch (err) {
        ElMessage.error(tips.STOP_REMOTE_VIEW_FAIL);
        console.error(err);
      }
      break;
  }
};

onMounted(async () => {
  try {
    const { userID } = userInfoStore;

    if (!isEmpty(userID)) {
      // 初始化并登录Tim
      const info = genTestUserSig(userID);
      const { userSig } = info;
      userInfoStore.userSig = userSig;
      const tim = useTimInstance(DefaultSdkAppId);
      await tim.login({ userID, userSig });

      // 初始化TUICallEngine
      initTUICallEngine({ sdkAppID: DefaultSdkAppId, tim });
    }
  } catch (err) {
    console.error(err);
  }
});

onUnmounted(() => {
  tuiCallEngine?.off(TUICallEvent.INVITED, handleNewInvitationReceived);
  tuiCallEngine?.off(TUICallEvent.USER_VIDEO_AVAILABLE, handleVideoAvailable);
  tuiCallEngine?.off(TUICallEvent.NO_RESP, handleNoResp);
  tuiCallEngine?.off(TUICallEvent.LINE_BUSY, handleLineBusy);
  tuiCallEngine?.off(TUICallEvent.KICKED_OUT, handleKickedOut);
  tuiCallEngine?.off(TUICallEvent.CALLING_END, handleCallingEnd);
  tuiCallEngine?.off(TUICallEvent.CALLING_CANCEL, handleCallingCancel);
  tuiCallEngine?.off(TUICallEvent.USER_LEAVE, handleUserLeave);
  tuiCallEngine?.off(TUICallEvent.SDK_READY, handleSdkReady);
});
</script>

<style lang="less" scoped>
.call-container {
  width: 100%;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
}
.wrap {
  box-sizing: border-box;
  position: relative;
  width: 33rem;
  height: 53rem;
  max-width: 500px;
  max-height: 800px;
  min-width: 300px;
  margin-top: 6rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  border-radius: 20px;
  box-shadow: 0 0 8px #3d8fff6b;
}
</style>
