import { ref, watch } from 'vue';
import { RemoteUser } from '../interface';
import { timerStart, timerClear, timerString } from '../utils/timer';
import { STATUS, CHANGE_STATUS_REASON, CALL_TYPE_STRING } from '../constants';
import { TUICallType } from 'tuicall-engine-webrtc';
import { TUICallKitServer } from '../index';

const status = ref<string>(STATUS.IDLE);
const dialingInfo = ref<string>("waiting");
const callType = ref<string>();
const isFromGroup = ref<boolean>(false);
const remoteList = ref<Array<RemoteUser>>([]);
const profile = ref<RemoteUser>({
  userID: "not login",
  isEntered: true,
  microphone: true,
  camera: true,
  volume: 0
});

watch(timerString, () => {
  changeDialingInfo(timerString.value);
});

watch(status, () => {
  if (status.value === STATUS.BE_INVITED) {
    TUICallKitServer.beforeCalling && TUICallKitServer.beforeCalling();
    changeDialingInfo(`发起的${callType.value === CALL_TYPE_STRING.AUDIO ? '语音通话' : '视频通话'}`);
  }
  if (status.value.split('-')[0] === "dialing") {
    TUICallKitServer.beforeCalling && TUICallKitServer.beforeCalling();
    changeDialingInfo("等待接听...");
  }
  if (status.value.split('-')[0] === "calling") {
    changeDialingInfo("");
    timerStart();
  }
  if (status.value === STATUS.IDLE) {
    changeDialingInfo(`发起的${callType.value === CALL_TYPE_STRING.AUDIO ? '语音通话' : '视频通话'}`);
    changeDialingInfo("");
    changeRemoteList([]);
    TUICallKitServer.afterCalling && TUICallKitServer.afterCalling();
  }
});

function changeStatus(newValue: string, reason?: string, timeout: number = 0): void {
  console.log("Status: " + newValue);
  if (reason !== CHANGE_STATUS_REASON.CALL_TYPE_CHANGED) {
    timerClear();
  }
  switch (reason) {
    case CHANGE_STATUS_REASON.REJECT: changeDialingInfo(`对方已拒绝，${callType.value === CALL_TYPE_STRING.AUDIO ? '语音通话' : '视频通话'}结束`); break;
    case CHANGE_STATUS_REASON.NO_RESPONSE: changeDialingInfo(`对方无应答，${callType.value === CALL_TYPE_STRING.AUDIO ? '语音通话' : '视频通话'}结束`); break;
    case CHANGE_STATUS_REASON.LINE_BUSY: changeDialingInfo(`对方忙线中，${callType.value === CALL_TYPE_STRING.AUDIO ? '语音通话' : '视频通话'}结束`); break;
    case CHANGE_STATUS_REASON.CALLING_CANCEL: changeDialingInfo(`对方已取消`); break;
    case CHANGE_STATUS_REASON.CALLING_TIMEOUT: changeDialingInfo(`本次通话超时未应答`); break;
    default: changeDialingInfo(``); break;
  }
  setTimeout(() => {
    status.value = newValue;
  }, timeout);
}

function addRemoteListByUserID(userID: string): void {
  const isExisted = remoteList.value.findIndex((item: RemoteUser) => item.userID === userID);
  if (isExisted >= 0) {
    remoteList.value[isExisted].isEntered = true;
  } else {
    changeRemoteList([...remoteList.value, {
      userID,
      isEntered: true,
    }]);
  }
}

function removeRemoteListByUserID(userID: string): void {
  const isExisted = remoteList.value.findIndex((item: RemoteUser) => item.userID === userID);
  if (isExisted >= 0) {
    const resArray = remoteList.value;
    resArray.splice(isExisted, 1);
    changeRemoteList([...resArray]);
  }
}

function changeRemoteDeviceByUserID(userID: string, deviceType: string, value: boolean): void {
  const isExisted = remoteList.value.findIndex((item: RemoteUser) => item.userID === userID);
  if (isExisted >= 0) {
    if (deviceType === CALL_TYPE_STRING.VIDEO) remoteList.value[isExisted].camera = value;
    else if (deviceType === CALL_TYPE_STRING.AUDIO) remoteList.value[isExisted].microphone = value;
  }
}

function updateRemoteVolumeMap(volumeMap: any): void {
  volumeMap.forEach((item: any) => {
    const { userId, audioVolume } = item;
    if (userId === profile.value.userID) {
      profile.value.volume = audioVolume;
      return;
    }
    const isExisted = remoteList.value.findIndex((item: RemoteUser) => item.userID === userId);
    if (isExisted >= 0) {
      remoteList.value[isExisted].volume = audioVolume;
    }
  });
}

function changeDialingInfo(newValue: string): void {
  dialingInfo.value = newValue;
}

function changeCallType(newValue: number): void {
  if (newValue === TUICallType.AUDIO_CALL) callType.value = CALL_TYPE_STRING.AUDIO;
  if (newValue === TUICallType.VIDEO_CALL) callType.value = CALL_TYPE_STRING.VIDEO;
}

function changeIsFromGroup(newValue: boolean): void {
  isFromGroup.value = newValue;
}

function changeRemoteList(newValue: RemoteUser[]): void {
  remoteList.value = newValue;
}

function updateProfile(newValue: RemoteUser): void {
  profile.value = newValue;
}

export {
  status,
  profile,
  dialingInfo,
  callType,
  isFromGroup,
  remoteList,
  changeStatus,
  changeCallType,
  changeIsFromGroup,
  changeDialingInfo,
  changeRemoteList,
  addRemoteListByUserID,
  removeRemoteListByUserID,
  changeRemoteDeviceByUserID,
  updateRemoteVolumeMap,
  updateProfile
};
