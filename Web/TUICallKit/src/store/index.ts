import { ref, watch, triggerRef } from "vue";
import type { RemoteUser } from "../interface";
import { VideoDisplayMode, VideoResolution } from "../interface";
import { timerStart, timerClear, timerString } from "../utils/timer";
import { STATUS, CHANGE_STATUS_REASON, CALL_TYPE_STRING } from "../constants";
import { TUICallType } from "tuicall-engine-webrtc";
import { TUICallKitServer } from "../index";
import { languageData } from "../locales/index";

export const lang = ref<string>("zh-cn");
export const currentDisplayMode = ref<VideoDisplayMode>(VideoDisplayMode.COVER);
export const currentVideoResolution = ref<VideoResolution>(VideoResolution.RESOLUTION_480P);

export const cameraList = ref<any>([]);
export const microphoneList = ref<any>([]);
export const currentCamera = ref<string>("");
export const currentMicrophone = ref<string>("");
export const remoteWaitList = ref(new Set<string>());

export const status = ref<string>(STATUS.IDLE);
export const isMinimized = ref<boolean>(false);
export const dialingInfo = ref<string>("waiting");
export const callType = ref<string>();
export const isFromGroup = ref<boolean>(false);
export const remoteList = ref<Array<RemoteUser>>([]);
export const volumeMap = ref<Map<string, number>>(new Map<string, number>());
export const profile = ref<RemoteUser>({
  userID: "",
  isEntered: true,
  microphone: true,
  camera: true,
});

watch(timerString, () => {
  changeDialingInfo(timerString.value);
});

watch(status, () => {
  if (status.value === STATUS.BE_INVITED) {
    changeDialingInfo(callType.value === CALL_TYPE_STRING.AUDIO ? t("start-voice-call") : t("start-video-call"));
  }
  if (status.value.split("-")[0] === "dialing") {
    changeDialingInfo(t("waiting"));
  }
  if (status.value.split("-")[0] === "calling") {
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

export function setLanguage(language: string): void {
  lang.value = language;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function t(key: any): string {
  for(const langKey in languageData) {
    if (langKey === lang.value) {
      const currentLanguage = languageData[langKey];
      for (const sentenceKey in currentLanguage) {
        if (sentenceKey === key) {
          return currentLanguage[sentenceKey];
        }
      }
    }
  }
  const enString = key["en"]?.key;
  console.error("translation is not found: ", key);
  return enString;
}

export function changeStatus(newValue: string, reason = "", timeout = 0): void {
  console.log("TUICallKit changeStatus", newValue, reason, timeout);
  if (status.value === newValue) {
    console.log("TUICallKit already be this status: " + newValue);
    return;
  }
  if (reason !== CHANGE_STATUS_REASON.CALL_TYPE_CHANGED) {
    console.log("TUICallKit timerClear");
    timerClear();
  }
  switch (reason) {
    case CHANGE_STATUS_REASON.REJECT: changeDialingInfo(`${t("be-rejected")}${callType.value === CALL_TYPE_STRING.AUDIO ? t("voice-call-end") : t("video-call-end")}`); break;
    case CHANGE_STATUS_REASON.NO_RESPONSE: changeDialingInfo(`${t("be-no-response")}${callType.value === CALL_TYPE_STRING.AUDIO ? t("voice-call-end") : t("video-call-end")}`); break;
    case CHANGE_STATUS_REASON.LINE_BUSY: changeDialingInfo(`${t("be-line-busy")}${callType.value === CALL_TYPE_STRING.AUDIO ? t("voice-call-end") : t("video-call-end")}`); break;
    case CHANGE_STATUS_REASON.CALLING_CANCEL: changeDialingInfo(t("be-canceled")); break;
    case CHANGE_STATUS_REASON.CALLING_TIMEOUT: changeDialingInfo(t("timeout")); break;
    default: changeDialingInfo(""); break;
  }
  setTimeout(() => {
    TUICallKitServer.statusChanged && TUICallKitServer.statusChanged({oldStatus: status.value, newStatus: newValue});
    console.log(`TUICallKit status changed: ${status.value} -> ${newValue}`);
    status.value = newValue;
  }, timeout);
}

export function addRemoteListByUserID(userID: string): void {
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

export function removeRemoteListByUserID(userID: string): number {
  let isExisted = remoteList.value.findIndex((item: RemoteUser) => item.userID === userID);
  if (isExisted >= 0) {
    const resArray = remoteList.value;
    resArray.splice(isExisted, 1);
    changeRemoteList([...resArray]);
  }
  remoteWaitList.value.delete(userID); // 等待渲染的队列也要删除此用户
  return remoteList.value.length;
}

export function changeRemoteDeviceStatusByUserID(userID: string, deviceType: string, value: boolean): void {
  const isExisted = remoteList.value.findIndex((item: RemoteUser) => item.userID === userID);
  if (isExisted >= 0) {
    if (deviceType === CALL_TYPE_STRING.VIDEO) remoteList.value[isExisted].camera = value;
    else if (deviceType === CALL_TYPE_STRING.AUDIO) remoteList.value[isExisted].microphone = value;
  }
}

export function changeRenderReadyStatusByUserID(userID: string, value: boolean): void {
  const isExisted = remoteList.value.findIndex((item: RemoteUser) => item.userID === userID);
  if (isExisted >= 0) {
    remoteList.value[isExisted].isReadyRender = value;
  }
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function updateRemoteVolumeMap(newVolumeMap: any): void {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  newVolumeMap.forEach((item: any) => {
    const { userId, audioVolume } = item;
    volumeMap.value.set(userId, audioVolume);
  });
}

export function changeDialingInfo(newValue: string): void {
  dialingInfo.value = newValue;
}

export function changeCallType(newValue: number): void {
  // change call type
  switch (newValue) {
    case TUICallType.AUDIO_CALL: 
      callType.value = CALL_TYPE_STRING.AUDIO;
      break;
    case TUICallType.VIDEO_CALL:
      callType.value = CALL_TYPE_STRING.VIDEO;
      break;
    default:
      console.error("TUICallKit changeCallType: unknown call type value ", newValue);
      return;
  }
  // change status
  if (status.value === STATUS.CALLING_C2C_VIDEO && callType.value === CALL_TYPE_STRING.AUDIO) {
    changeStatus(STATUS.CALLING_C2C_AUDIO, CHANGE_STATUS_REASON.CALL_TYPE_CHANGED);
  }
  if (status.value === STATUS.CALLING_C2C_AUDIO && callType.value === CALL_TYPE_STRING.VIDEO) {
    changeStatus(STATUS.CALLING_C2C_VIDEO, CHANGE_STATUS_REASON.CALL_TYPE_CHANGED);
  }
  if (status.value === STATUS.BE_INVITED) {
    changeDialingInfo(callType.value === CALL_TYPE_STRING.AUDIO ? t("start-voice-call") : t("start-video-call"));
  }
}

export function changeIsFromGroup(newValue: boolean): void {
  isFromGroup.value = newValue;
}

async function getNickByUserID(userID: string) {
  const tim = TUICallKitServer.getTim();
  if (!tim) {
    console.warn("TUICallKit request nick name error, reason: tim is empty/null");
    return userID;
  }
  let nick = userID;
  const { data } = await tim.getUserProfile({ userIDList: [ userID ] }) || {};
  if (data && data.length > 0) {
    nick = data[0].nick;
  }
  if (nick === "") nick = userID;
  return nick;
}

export async function changeRemoteList(newValue: RemoteUser[]) {
  remoteList.value = newValue;
  for (const user of remoteList.value) {
    if (user?.nick) continue;
    user.nick = await getNickByUserID(user.userID);
    triggerRef(remoteList);
  }
}

export async function updateProfile(newValue: RemoteUser) {
  profile.value = newValue;
  profile.value.nick = await getNickByUserID(newValue.userID);
  triggerRef(profile);
}

export function changeIsMinimized(newValue: boolean): void {
  isMinimized.value = newValue;
}

export function getVolumeByUserID(userID: string): number {
  return volumeMap.value.get(userID) || 0;
}
