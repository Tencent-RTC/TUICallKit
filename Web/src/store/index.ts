import { ref, watch } from 'vue';
import { RemoteUser } from '../interface';
import { timerStart, timerClear, timerString } from '../utils/timer';
import { STATUS, CHANGE_STATUS_REASON, CALL_TYPE_STRING } from '../constants';
import { TUICallType } from 'tuicall-engine-webrtc';
import { TUICallKitServer } from '../index';
import languageData from '../locales/index';

const lang = ref<string>("zh-cn");

const status = ref<string>(STATUS.IDLE);
const isMinimized = ref<boolean>(false);
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
    changeDialingInfo(callType.value === CALL_TYPE_STRING.AUDIO ? t('start-voice-call') : t('start-video-call'));
  }
  if (status.value.split('-')[0] === "dialing") {
    changeDialingInfo(t('waiting'));
  }
  if (status.value.split('-')[0] === "calling") {
    changeDialingInfo("");
    timerStart();
  }
  if (status.value === STATUS.IDLE) {
    profile.value.microphone = true;
    profile.value.camera = true;
    isMinimized.value = false;
    changeDialingInfo("");
    changeRemoteList([]);
    TUICallKitServer.afterCalling && TUICallKitServer.afterCalling();
  }
});

function setLanguage(language: string): void {
  lang.value = language;
}

function t(key: any): string {
  for(let langKey in languageData) {
    if (langKey === lang.value) {
      let currentLanguage = languageData[langKey];
      for (let sentenceKey in currentLanguage) {
        if (sentenceKey === key) {
          return currentLanguage[sentenceKey];
        }
      }
    }
  }
  let enString = key['en']?.key;
  console.error("translation is not found: ", key);
  return enString;
}

function changeStatus(newValue: string, reason?: string, timeout = 0): void {
  console.log("TUICallKit Status: " + newValue);
  if (reason !== CHANGE_STATUS_REASON.CALL_TYPE_CHANGED) {
    console.log("TUICallKit timerClear");
    timerClear();
  }
  switch (reason) {
    case CHANGE_STATUS_REASON.REJECT: changeDialingInfo(`${t('be-rejected')}${callType.value === CALL_TYPE_STRING.AUDIO ? t('voice-call-end') : t('video-call-end')}`); break;
    case CHANGE_STATUS_REASON.NO_RESPONSE: changeDialingInfo(`${t('be-no-response')}${callType.value === CALL_TYPE_STRING.AUDIO ? t('voice-call-end') : t('video-call-end')}`); break;
    case CHANGE_STATUS_REASON.LINE_BUSY: changeDialingInfo(`${t('be-line-busy')}${callType.value === CALL_TYPE_STRING.AUDIO ? t('voice-call-end') : t('video-call-end')}`); break;
    case CHANGE_STATUS_REASON.CALLING_CANCEL: changeDialingInfo(t('be-canceled')); break;
    case CHANGE_STATUS_REASON.CALLING_TIMEOUT: changeDialingInfo(t('timeout')); break;
    default: changeDialingInfo(``); break;
  }
  setTimeout(() => {
    TUICallKitServer.statusChanged && TUICallKitServer.statusChanged({oldStatus: status.value, newStatus: newValue});
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

function removeRemoteListByUserID(userID: string): number {
  const isExisted = remoteList.value.findIndex((item: RemoteUser) => item.userID === userID);
  if (isExisted >= 0) {
    const resArray = remoteList.value;
    resArray.splice(isExisted, 1);
    changeRemoteList([...resArray]);
  }
  return remoteList.value.length;
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

function changeIsMinimized(newValue: boolean): void {
  isMinimized.value = newValue;
}

export {
  status,
  profile,
  dialingInfo,
  callType,
  isFromGroup,
  remoteList,
  isMinimized,
  changeStatus,
  changeCallType,
  changeIsFromGroup,
  changeDialingInfo,
  changeRemoteList,
  addRemoteListByUserID,
  removeRemoteListByUserID,
  changeRemoteDeviceByUserID,
  updateRemoteVolumeMap,
  updateProfile,
  changeIsMinimized,
  setLanguage,
  t
};
