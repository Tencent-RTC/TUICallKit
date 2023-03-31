/* eslint-disable @typescript-eslint/no-explicit-any */
import { TUICallEngine, TUICallEvent, TUICallType } from "tuicall-engine-webrtc";

import type { TUICallParam, TUIInitParam, TUIGroupCallParam, RemoteUser, CallbackParam, statusChangedReturnType, VideoResolution } from "./interface";
import * as store from "./store";
import { STATUS, CHANGE_STATUS_REASON, CALL_TYPE_STRING } from "./constants";
import packageJson from "../package.json"; 

/**
 * class TUICallKit
 */
export default class TUICallKit {
  public SDKAppID: number;
  public tuiCallEngine: any;
  public TUICore: any;
  public version: string;
  public beforeCalling: ((...args: any[]) => void) | undefined;
  public afterCalling: ((...args: any[]) => void) | undefined;
  public onMinimized: ((...args: any[]) => void) | undefined;
  public onMessageSentByMe: ((...args: any[]) => void) | undefined;
  public statusChanged: ((...args: any[]) => statusChangedReturnType) | undefined;
  public error: any;
  public tim: any;
  constructor() {
    this.TUICore = null;
    this.tuiCallEngine = null;
    this.SDKAppID = 0;
    this.version = packageJson.version;
    console.log("TUICallKit version: " + this.version);
  }

  /**
   * init 初始化
   * @param { TUIInitParam } params 初始化参数
   * @param { number } params.SDKAppID
   * @param { string } params.userID
   * @param { string } params.userSig
   * @param { any= } params.tim
   */
  public async init(params: TUIInitParam) {
    let { SDKAppID, tim } = params;
    const { userID, userSig, assetsPath } = params;
    if (this.TUICore) {
      SDKAppID = this.TUICore.SDKAppID;
      tim = this.TUICore.tim;
    }
    this.tim = tim;
    this.SDKAppID = SDKAppID;
    try {
      this.tuiCallEngine = TUICallEngine.createInstance({ SDKAppID, tim });
      this.bindTIMEvent();
      await this.tuiCallEngine.login({ userID, userSig, assetsPath });
      store.updateProfile(Object.assign(store.profile.value, { userID }));
      console.log("TUICallKit init successful");
    } catch (error: any) {
      console.error("TUICallKit init failed", error?.message);
      throw error;
    }
  }

  /**
   * call 呼叫
   * @param { TUICallParam } params 呼叫参数
   * @param { string } params.userID 被呼叫的用户
   * @param { number } params.type 呼叫类型 1-语音，2-视频
   * @param { number= } params.timeout 0为不超时, 单位 s(秒), 默认 30s
   * @param { offlinePushInfoType= } params.offlinePushInfo 自定义离线消息推送
   * @param { string= } params.offlinePushInfo.title 自定义离线消息推送
   * @param { string= } params.offlinePushInfo.description 自定义离线消息推送
   * @param { string= } params.offlinePushInfo.androidOPPOChannelID 自定义离线消息推送
   * @param { string= } params.offlinePushInfo.extension 自定义离线消息推送
   */
  public async call(params: TUICallParam) {
    this.checkStatus();
    const { userID, type, timeout, offlinePushInfo } = params;
    try {
      store.changeRemoteList([{ userID, isEntered: false }]);
      store.changeCallType(type);
      store.changeIsFromGroup(false);
      store.changeStatus(STATUS.DIALING_C2C);
      await this.tuiCallEngine.call({ userID, type, timeout, offlinePushInfo });
      await this.setDefaultDevice({ camera: type === TUICallType.VIDEO_CALL });
      await this.renderLocal();
      this.beforeCalling && this.beforeCalling("call");
    } catch (error: any) {
      if (this.error && this.beforeCalling) {
        this.beforeCalling("call", this.error);
      }
      this.error = null;
      store.changeStatus(STATUS.IDLE);
      console.error("TUICallKit call error: ", error.code, "+" , error?.message);
      throw error;
    }
  }

  /**
   * groupCall 呼叫
   * @param { TUIGroupCallParam } params 呼叫参数
   * @param { string } params.userIDList 被呼叫的用户列表
   * @param { number } params.type 呼叫类型 1-语音，2-视频
   * @param { string } params.groupID 呼叫群组ID
   * @param { number= } params.timeout 0为不超时, 单位 s(秒), 默认 30s
   * @param { offlinePushInfoType= } params.offlinePushInfo 自定义离线消息推送
   * @param { string= } params.offlinePushInfo.title 自定义离线消息推送
   * @param { string= } params.offlinePushInfo.description 自定义离线消息推送
   * @param { string= } params.offlinePushInfo.androidOPPOChannelID 自定义离线消息推送
   * @param { string= } params.offlinePushInfo.extension 自定义离线消息推送
   */
  public async groupCall(params: TUIGroupCallParam) {
    this.checkStatus();
    const { userIDList, type, groupID, timeout, offlinePushInfo, roomID } = params;
    try {
      const newRemoteList = userIDList.map(userID => ({ userID, isEntered: false }));
      store.changeRemoteList(newRemoteList);
      store.changeCallType(type);
      store.changeIsFromGroup(true);
      store.changeStatus(STATUS.DIALING_GROUP);
      await this.tuiCallEngine.groupCall({ userIDList, type, groupID, timeout, offlinePushInfo, roomID });
      await this.setDefaultDevice({ camera: type === TUICallType.VIDEO_CALL });
      await this.renderLocal();
      this.beforeCalling && this.beforeCalling("groupCall");
    } catch (error: any) {
      if (this.error && this.beforeCalling) {
        this.beforeCalling("groupCall", this.error);
      }
      this.error = null;
      console.error("TUICallKit groupCall error: " + error?.message);
      throw error;
    }
  }

  public async joinInGroupCall(params: any) {
    const { roomID, type, groupID } = params;
    await this.tuiCallEngine.joinInGroupCall({ roomID, type, groupID });
    this.beforeCalling && this.beforeCalling("groupCall");
    store.changeStatus(STATUS.DIALING_GROUP);
    store.changeCallType(type);
    store.changeIsFromGroup(true);
    this.getIntoCallingStatus();
  }
  
  private checkStatus() {
    if (store.status.value !== STATUS.IDLE) {
      console.error("TUICallKit groupCall error:", store.t("is-already-calling"));
      throw new Error(store.t("is-already-calling"));
    }
    if (!this.tuiCallEngine) {
      console.error("TUICallKit groupCall error:", store.t("need-init"));
      throw new Error(store.t("need-init"));
    }
  }

  public async updateCameraList() {
    store.cameraList.value = await this.tuiCallEngine.getDeviceList("camera");
    console.log("TUICallKit updateDevice camera", store.cameraList.value);
  }

  public async updateMicrophoneList() {
    store.microphoneList.value = await this.tuiCallEngine.getDeviceList("microphones");
    console.log("TUICallKit updateDevice microphones", store.microphoneList.value);
  }

  private async setDefaultDevice(options: { camera: boolean }) {
    try {
      await this.updateMicrophoneList();
      if (store.microphoneList.value.length > 0) {
        const index = store.microphoneList.value.findIndex((microphoneItem: any) => microphoneItem.deviceId === store.currentCamera.value);
        const isExisted = (index !== -1);
        if (!isExisted || store.currentMicrophone.value === "") {
          await this.switchDevice("audio", store.microphoneList.value[0]?.deviceId);
        }
      }
    } catch (error: any) {
      console.error("TUICallKit set default microphone error", error?.message);
    }
    try {
      if (!options.camera) return;
      await this.updateCameraList();
      if (store.cameraList.value.length > 0) {
        const index = store.cameraList.value.findIndex((cameraItem: any) => cameraItem.deviceId === store.currentCamera.value);
        const isExisted = (index !== -1);
        if (!isExisted || store.currentCamera.value === "") {
          await this.switchDevice("video", store.cameraList.value[0]?.deviceId);
        }
      }
    } catch (error: any) {
      console.error("TUICallKit set default camera error", error?.message);
    }
  }

  public async switchDevice(deviceType: string, deviceId: string) {
    console.log("TUICallKit switchDevice deviceType deviceId", deviceType, deviceId);
    try {
      await this.tuiCallEngine.switchDevice({ deviceType, deviceId });
      if (deviceType === "video") store.currentCamera.value = deviceId;
      if (deviceType === "audio") store.currentMicrophone.value = deviceId;
      await this.setVideoQuality(store.currentVideoResolution.value);
    } catch (error: any) { 
      console.error("TUICallKit switchDevice error", error?.message);
    }
  }

  public bindTUICore(TUICore: any) {
    this.TUICore = TUICore;
  }

  public setCallback(params: CallbackParam) {
    const { beforeCalling, afterCalling, onMinimized, onMessageSentByMe } = params;
    beforeCalling && (this.beforeCalling = beforeCalling);
    afterCalling && (this.afterCalling = afterCalling);
    onMinimized && (this.onMinimized = onMinimized);
    onMessageSentByMe && (this.onMessageSentByMe = onMessageSentByMe);
  }

  public setLanguage(language: string) {
    console.log("TUICallKit change language: ", language);
    if (language !== "en" && language !== "zh-cn") {
      console.warn("TUICallKit change language warning: ", `${language} in not supported, has changed to default English`);
      language = "en";
    }
    store.setLanguage(language);
  }

  public toggleMinimize() {
    console.log("TUICallKit toggleMinimize called", store.isMinimized.value, "->", !store.isMinimized.value);
    this.onMinimized && this.onMinimized(store.isMinimized.value, !store.isMinimized.value);
    store.changeIsMinimized(!store.isMinimized.value);
    // logReporter.MinimizeSuccess(this.SDKAppID);
  }

  public async accept() {
    try {
      await this.tuiCallEngine.accept();
      this.getIntoCallingStatus();
      await this.setDefaultDevice({ camera: store.callType.value ===  CALL_TYPE_STRING.VIDEO });
    } catch (error: any) {
      console.error("TUICallKit accept error catch: ", error?.message);
      // TODO: 提示无权限
      store.changeStatus(STATUS.IDLE);
    }
  }

  public async reject() {
    try {
      await this.tuiCallEngine.reject();
    } catch (error: any) {
      console.error("TUICallKit reject error catch: ", error?.message);
    }
    store.changeStatus(STATUS.IDLE);
  }

  /**
   * @deprecated since sdk version 1.3.2
   */
  public async startLocalView(local: string) {
    console.log("TUICallKit startLocalView");
    await this.tuiCallEngine.startLocalView({ userID: store.profile.value.userID, videoViewDomID: local });
  }

  /**
   * @deprecated since sdk version 1.3.2
   */
  public async stopLocalView() {
    await this.tuiCallEngine.stopLocalView({ userID: store.profile.value.userID});
  }

  public async startRemoteView(userID: string) {
    if (!userID) {
      console.log("TUICallKit startRemoteView userID is empty");
      return;
    }
    if (!document.getElementById(userID)) {
      console.log("TUICallKit startRemoteView can't find HTMLElement id =", userID);
      return;
    }
    try {
      await this.tuiCallEngine.startRemoteView({ userID, videoViewDomID: userID, options: { objectFit: store.currentDisplayMode.value }});
      console.log("TUICallKit startRemoteView success", userID);
    } catch (error: any) {
      console.warn("TUICallKit startRemoteView error", error, userID);
    }
  }

  public async stopRemoteView(userID: string) {
    await this.tuiCallEngine.stopRemoteView({ userID });
  }

  public async hangup() {
    await this.tuiCallEngine.hangup();
    store.changeStatus(STATUS.IDLE);
  }

  public async renderLocal() {
    if (store.status.value === STATUS.IDLE) {
      console.log("TUICallKit renderLocal not working because status is idle");
      return;
    }
    store.profile.value.microphone ? this.openMicrophone() : this.closeMicrophone();
    if (store.callType.value === CALL_TYPE_STRING.VIDEO) {
      let localDomName = store.isFromGroup.value ? "local-group" : "local-c2c";
      if (store.status.value === STATUS.DIALING_C2C) localDomName = "local-dialing";
      store.profile.value.camera ? this.openCamera(localDomName) : this.closeCamera();
    }
  }

  public async renderRemoteWaitList() {
    console.log("TUICallKit renderRemoteWaitList", store.remoteWaitList.value);
    while (store.remoteWaitList.value.size > 0) {
      const iterator = store.remoteWaitList.value.values();
      const value = iterator.next().value;
      await this.startRemoteView(value);
      store.remoteWaitList.value.delete(value);
    }
  }

  public async renderRemoteList(list: RemoteUser[]) {
    console.log("TUICallKit renderRemoteList", list);
    for (let i = 0; i < list.length; i++) {
      const { userID, isEntered, isReadyRender } = list[i];
      isEntered && isReadyRender && await this.startRemoteView(userID);
    }
  }

  public async openCamera(videoViewDomID: string) {
    console.log("TUICallKit openCamera", videoViewDomID);
    try {
      await this.tuiCallEngine.openCamera(videoViewDomID);
      store.updateProfile(Object.assign(store.profile.value, { camera: true }));
    } catch (error: any) {
      console.error("TUICallKit openCamera error:", error);
      store.updateProfile(Object.assign(store.profile.value, { camera: false }));
    }
  }

  public async closeCamera() {
    try {
      await this.tuiCallEngine.closeCamera();
      store.updateProfile(Object.assign(store.profile.value, { camera: false }));
    } catch (error: any) {
      console.error("TUICallKit closeCamera error:", error?.message);
    }
  }

  public async openMicrophone() {
    try {
      await this.tuiCallEngine.openMicrophone();
      store.updateProfile(Object.assign(store.profile.value, { microphone: true }));
    } catch (error: any) {
      console.error("TUICallKit openMicrophone error:", error);
      store.updateProfile(Object.assign(store.profile.value, { microphone: false }));
    }
  }

  public async closeMicrophone() {
    try {
      await this.tuiCallEngine.closeMicrophone();
      store.updateProfile(Object.assign(store.profile.value, { microphone: false }));
    } catch (error: any) {
      console.error("TUICallKit closeMicrophone error:", error?.message);
    }
  }

  public async setVideoQuality(videoProfile: VideoResolution) {
    await this.tuiCallEngine.setVideoQuality(videoProfile);
    store.currentVideoResolution.value = videoProfile;
  }

  public async switchCallMediaType() {
    console.log("TUICallKit switchCallMediaType", TUICallType.AUDIO_CALL);
    try {
      await this.tuiCallEngine.switchCallMediaType(TUICallType.AUDIO_CALL);
    } catch (error: any) {
      console.error("TUICallKit switchCallMediaType error:", error?.message);
    }
  }

  public onStatusChanged(statusChanged: (...args: any[]) => statusChangedReturnType) {
    this.statusChanged = statusChanged;
  }

  // open/close AI noise reduction
  public async enableAIVoice(enable: boolean) {
    try {
      this.tuiCallEngine.enableAIVoice(enable);
      console.log("TUICallKit enableAIVoice:", enable);
    } catch (error: any) {
      console.error("TUICallKit enableAIVoice failed", error.message);
    }
  }

  // inviteUser
  public async inviteUser(params: any) {
    const { userIDList = [] } = params;
    console.log("TUICallKit inviteUser", params);
    try {
      const res = this.tuiCallEngine && await this.tuiCallEngine.inviteUser(params);
      const newRemoteList: Array<RemoteUser> = store.remoteList.value;
      userIDList.forEach((userID: string) => {
        newRemoteList.push({ userID, isEntered: false });
      });
      store.changeRemoteList(newRemoteList);
      console.log("TUICallKit inviteUser success: ", res);
    } catch (error: any) {
      console.error("TUICallKit inviteUser error: " + error?.message);
      throw error;
    }
  }

  public getTim() {
    if (this.tim) return this.tim;
    if (!this.tuiCallEngine) {
      console.warn("TUICallKit getTim warning: tuiCallEngine Instance is not available");
      return;
    }
    return this.tuiCallEngine.tim;
  }

  /**
   * component destroyed
   */
  public async destroyed() {
    this.unbindTIMEvent();
    store.changeStatus(STATUS.IDLE);
    try {
      if (this.tuiCallEngine) await this.tuiCallEngine.destroyInstance(); 
      console.log("TUICallKit destroyInstance success");
    } catch (error: any) {
      console.error("TUICallKit destroyed error:", error);
      throw error;
    }
  }

  private getIntoCallingStatus() {
    if (!store.isFromGroup.value && store.callType.value === CALL_TYPE_STRING.AUDIO) store.changeStatus(STATUS.CALLING_C2C_AUDIO);
    if (!store.isFromGroup.value && store.callType.value === CALL_TYPE_STRING.VIDEO) store.changeStatus(STATUS.CALLING_C2C_VIDEO);
    if (store.isFromGroup.value && store.callType.value === CALL_TYPE_STRING.AUDIO) store.changeStatus(STATUS.CALLING_GROUP_AUDIO);
    if (store.isFromGroup.value && store.callType.value === CALL_TYPE_STRING.VIDEO) store.changeStatus(STATUS.CALLING_GROUP_VIDEO);
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                    TUICallEngine listener
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  private bindTIMEvent() {
    this.tuiCallEngine.on(TUICallEvent.ERROR, this.handleError, this);
    this.tuiCallEngine.on(TUICallEvent.SDK_READY, this.handleSDKReady, this);
    this.tuiCallEngine.on(TUICallEvent.INVITED, this.handleInvited, this);
    this.tuiCallEngine.on(TUICallEvent.USER_ACCEPT, this.handleUserAccept, this);
    this.tuiCallEngine.on(TUICallEvent.USER_ENTER, this.handleUserEnter, this);
    this.tuiCallEngine.on(TUICallEvent.USER_LEAVE, this.handleUserLeave, this);
    this.tuiCallEngine.on(TUICallEvent.REJECT, this.handleReject, this);
    this.tuiCallEngine.on(TUICallEvent.NO_RESP, this.handleNoResponse, this);
    this.tuiCallEngine.on(TUICallEvent.LINE_BUSY, this.handleLineBusy, this);
    this.tuiCallEngine.on(TUICallEvent.CALLING_CANCEL, this.handleCallingCancel, this);
    this.tuiCallEngine.on(TUICallEvent.KICKED_OUT, this.handleKickedOut, this);
    this.tuiCallEngine.on(TUICallEvent.CALLING_TIMEOUT, this.handleCallingTimeOut, this);
    this.tuiCallEngine.on(TUICallEvent.CALLING_END, this.handleCallingEnd, this);
    this.tuiCallEngine.on(TUICallEvent.USER_VIDEO_AVAILABLE, this.handleUserVideoAvailable, this);
    this.tuiCallEngine.on(TUICallEvent.USER_AUDIO_AVAILABLE, this.handleUserAudioAvailable, this);
    this.tuiCallEngine.on(TUICallEvent.USER_VOICE_VOLUME, this.handleUserVoiceVolume, this);
    this.tuiCallEngine.on(TUICallEvent.CALL_TYPE_CHANGED, this.handleCallTypeChanged, this);
    this.tuiCallEngine.on(TUICallEvent.MESSAGE_SENT_BY_ME, this.handleMessageSentByMe, this);
  }

  private unbindTIMEvent() {
    this.tuiCallEngine.off(TUICallEvent.ERROR, this.handleError, this);
    this.tuiCallEngine.off(TUICallEvent.SDK_READY, this.handleSDKReady, this);
    this.tuiCallEngine.off(TUICallEvent.INVITED, this.handleInvited);
    this.tuiCallEngine.off(TUICallEvent.USER_ACCEPT, this.handleUserAccept);
    this.tuiCallEngine.off(TUICallEvent.USER_ENTER, this.handleUserEnter, this);
    this.tuiCallEngine.off(TUICallEvent.USER_LEAVE, this.handleUserLeave, this);
    this.tuiCallEngine.off(TUICallEvent.REJECT, this.handleReject, this);
    this.tuiCallEngine.off(TUICallEvent.NO_RESP, this.handleNoResponse, this);
    this.tuiCallEngine.off(TUICallEvent.LINE_BUSY, this.handleLineBusy, this);
    this.tuiCallEngine.off(TUICallEvent.CALLING_CANCEL, this.handleCallingCancel, this);
    this.tuiCallEngine.off(TUICallEvent.KICKED_OUT, this.handleKickedOut, this);
    this.tuiCallEngine.off(TUICallEvent.CALLING_TIMEOUT, this.handleCallingTimeOut, this);
    this.tuiCallEngine.off(TUICallEvent.CALLING_END, this.handleCallingEnd, this);
    this.tuiCallEngine.off(TUICallEvent.USER_VIDEO_AVAILABLE, this.handleUserVideoAvailable, this);
    this.tuiCallEngine.off(TUICallEvent.USER_AUDIO_AVAILABLE, this.handleUserAudioAvailable, this);
    this.tuiCallEngine.off(TUICallEvent.USER_VOICE_VOLUME, this.handleUserVoiceVolume, this);
    this.tuiCallEngine.off(TUICallEvent.CALL_TYPE_CHANGED, this.handleCallTypeChanged, this);
    this.tuiCallEngine.off(TUICallEvent.MESSAGE_SENT_BY_ME, this.handleMessageSentByMe, this);
  }

  private handleError(event: any) {
    const { code } = event;
    this.error = {
      code,
      type: "",
      message: ""
    };
    switch (code) {
      case 60001:
        this.error.type = store.t("method-call-failed");
        this.error.message = `switchToAudioCall ${store.t("call-failed")}`;
        break;
      case 60002:
        this.error.type = store.t("method-call-failed");
        this.error.message = `switchToVideoCall ${store.t("call-failed")}`;
        break;
      case 60003:
        this.error.type = store.t("failed-to-obtain-permission");
        this.error.message = store.t("microphone-unavailable");
        break;
      case 60004:
        this.error.type = store.t("failed-to-obtain-permission");
        this.error.message = store.t("camera-unavailable");
        break;
      case 60005:
        this.error.type = store.t("failed-to-obtain-permission");
        this.error.message = store.t("ban-device");
        break;
      case 60006:
        this.error.type = store.t("environment-detection-failed");
        this.error.message = store.t("not-supported-webrtc");
        break;
    }
    console.error("TUICallKit Error", JSON.stringify(this.error));
    if (store.status.value === STATUS.BE_INVITED) {
      this.beforeCalling && this.beforeCalling("invited", this.error);
    }
    store.changeStatus(STATUS.IDLE);
  }

  private handleSDKReady(event: any) {
    console.log("TUICallKit SDK is ready.", event);
  }

  private handleKickedOut(event: any) {
    console.error("TUICallKit Kicked Out", JSON.stringify(event));
  }

  private async handleUserVideoAvailable(event: any) {
    console.log("TUICallKit handleUserVideoAvailable", event);
    const { userID, isVideoAvailable } = event;
    store.changeRenderReadyStatusByUserID(userID, true);
    store.changeRemoteDeviceStatusByUserID(userID, CALL_TYPE_STRING.VIDEO, isVideoAvailable);
    if (!isVideoAvailable) return;
    if (!document.getElementById(userID)) {
      console.log("TUICallKit add remoteWaitList", userID);
      store.remoteWaitList.value.add(userID);
    } else {
      await this.startRemoteView(userID);
    }
  }

  private handleUserAudioAvailable(event: any) {
    console.log("TUICallKit handleUserAudioAvailable", event);
    const { userID, isAudioAvailable } = event;
    store.changeRemoteDeviceStatusByUserID(userID, CALL_TYPE_STRING.AUDIO, isAudioAvailable);
  }

  private handleUserVoiceVolume(event: any) {
    const { volumeMap } = event;
    store.updateRemoteVolumeMap(volumeMap);
  }

  private handleInvited(event: any) {
    console.log("TUICallKit handleInvited", event);
    this.beforeCalling && this.beforeCalling("invited", this.error);
    if (this.error) { 
      this.reject();
      this.error = null;
      return; 
    }
    const { sponsor, isFromGroup, inviteData } = event;
    const { callType } = inviteData;
    store.changeStatus(STATUS.BE_INVITED);
    store.changeRemoteList([{ userID: sponsor, isEntered: false }]);
    store.changeCallType(callType);
    store.changeIsFromGroup(isFromGroup);
  }

  private handleUserAccept(event: any) {
    console.log("TUICallKit handleUserAccept", event);
    const { userID } = event;
    if (store.status.value === STATUS.BE_INVITED) {
      console.log(`TUICallKit userID=${userID} accept the call`);
      return;
    }
    this.getIntoCallingStatus();
  }

  private handleUserEnter(event: any) {
    console.log("TUICallKit handleUserEnter", event);
    const { userID } = event;
    store.addRemoteListByUserID(userID);
  }

  private handleUserLeave(event: any) {
    console.log("TUICallKit handleUserLeave", event);
    const { userID } = event;
    store.removeRemoteListByUserID(userID);
  }

  private handleReject(event: any) {
    console.log("TUICallKit handleReject", event);
    const { userID } = event;
    if (store.status.value === STATUS.BE_INVITED) return;
    if (store.status.value === STATUS.CALLING_GROUP_AUDIO || store.status.value === STATUS.CALLING_GROUP_VIDEO || store.status.value === STATUS.DIALING_GROUP) {
      store.removeRemoteListByUserID(userID);
      return;
    }
    store.changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.REJECT, 1000);
  }

  private handleNoResponse(event: any) {
    console.log("TUICallKit handleNoResponse", event);
    const { userIDList } = event;
    userIDList.forEach((userID: string) => {
      if (store.removeRemoteListByUserID(userID) <= 0) {
        store.changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.NO_RESPONSE, store.isFromGroup.value ? 0 : 1000);
      }
    });
  }

  private handleLineBusy(event: any) {
    console.log("TUICallKit handleLineBusy", event);
    const { userID } = event;
    if (store.removeRemoteListByUserID(userID) <= 0) {
      store.changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.LINE_BUSY, store.isFromGroup.value ? 0 : 1000);
    }
  }

  private handleCallingCancel(event: any) {
    console.log("TUICallKit handleCallingCancel", event);
    store.changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.CALLING_CANCEL, 1000);
  }

  private handleCallingTimeOut(event: any) {
    console.log("TUICallKit handleCallingTimeOut", event);
    const { userIDList } = event;
    userIDList.forEach((userID: string) => {
      if (store.removeRemoteListByUserID(userID) <= 0 || userID === store.profile.value.userID) {
        store.changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.CALLING_TIMEOUT, store.isFromGroup.value ? 0 : 1000);
      }
    });
  }

  private handleCallingEnd(event: any) {
    console.log("TUICallKit handleCallingEnd", event);
    store.changeStatus(STATUS.IDLE);
  }

  private handleCallTypeChanged(event: any) {
    console.log("TUICallKit handleCallTypeChanged", event);
    const { newCallType } = event;
    store.changeCallType(newCallType);
  }

  private handleMessageSentByMe(event: any) {
    const message = event?.data;
    console.log("TUICallKit MessageSentByMe", message);
    this.onMessageSentByMe && this.onMessageSentByMe(message);
  }
}
