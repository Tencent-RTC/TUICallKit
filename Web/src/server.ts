/* eslint-disable @typescript-eslint/no-explicit-any */
import { TUICallEngine, TUICallEvent, TUICallType } from "tuicall-engine-webrtc";

import type { TUICallParam, TUIInitParam, TUIGroupCallParam, RemoteUser, CallbackParam, statusChangedReturnType } from "./interface";
import * as store from "./store";
import { STATUS, CHANGE_STATUS_REASON, CALL_TYPE_STRING } from "./constants";
import logReporter from "./utils/aegis";

/**
 * class TUICallKit
 */
export default class TUICallKit {
  public SDKAppID: number;
  public tuiCallEngine: any;
  public TUICore: any;
  public beforeCalling: ((...args: any[]) => void) | undefined;
  public afterCalling: ((...args: any[]) => void) | undefined;
  public onMinimized: ((...args: any[]) => void) | undefined;
  public onMessageSentByMe: ((...args: any[]) => void) | undefined;
  public statusChanged: ((...args: any[]) => statusChangedReturnType) | undefined;
  public callingAPIMutex: string | undefined;
  public error: any;
  public tim: any;
  constructor() {
    this.TUICore = null;
    this.tuiCallEngine = null;
    this.SDKAppID = 0;
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
      console.log("TUICallKit login successful");
      if (this.TUICore) {
        logReporter.loginWithTUICoreSuccess(SDKAppID);
      } else if (!this.TUICore && tim) {
        logReporter.loginWithTIMSuccess(SDKAppID);
      } else {
        logReporter.loginSuccess(SDKAppID);
      }
    } catch (error: any) {
      if (this.TUICore) {
        logReporter.loginWithTUICoreFailed(SDKAppID, JSON.stringify(error));
      } else if (!this.TUICore && tim) {
        logReporter.loginWithTIMFailed(SDKAppID, JSON.stringify(error));
      } else {
        logReporter.loginFailed(SDKAppID, JSON.stringify(error));
      }
      console.error("TUICallKit login failed", JSON.stringify(error));
      throw new Error(error);
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
    if (this.callingAPIMutex) {
      return;
    }
    this.callingAPIMutex = "call";
    this.checkStatus();
    const { userID, type, timeout, offlinePushInfo } = params;
    try {
      await this.tuiCallEngine.call({ userID, type, timeout, offlinePushInfo });
      this.beforeCalling && this.beforeCalling("call");
      store.changeStatus(STATUS.DIALING_C2C);
      store.changeRemoteList([{ userID, isEntered: false }]);
      store.changeCallType(type);
      store.changeIsFromGroup(false);
      logReporter.callSuccess(this.SDKAppID, "call", type === 1 ? "audio" : "video");
    } catch (error: any) {
      if (this.error && this.beforeCalling) {
        this.beforeCalling("call", this.error);
      }
      this.error = null;
      this.callingAPIMutex = "";
      store.changeStatus(STATUS.IDLE);
      logReporter.callFailed(this.SDKAppID, "call", type === 1 ? "audio" : "video", JSON.stringify(error));
      console.error("TUICallKit call error: " + JSON.stringify(error));
      throw new Error(error);
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
    if (this.callingAPIMutex) {
      return;
    }
    this.callingAPIMutex = "groupCall";
    this.checkStatus();
    const { userIDList, type, groupID, timeout, offlinePushInfo, roomID } = params;
    try {
      await this.tuiCallEngine.groupCall({ userIDList, type, groupID, timeout, offlinePushInfo, roomID });
      this.beforeCalling && this.beforeCalling("groupCall");
      const newRemoteList: Array<RemoteUser> = [];
      userIDList.forEach((userID: string) => {
        newRemoteList.push({ userID, isEntered: false });
      });
      store.changeRemoteList(newRemoteList);
      store.changeStatus(STATUS.DIALING_GROUP);
      store.changeCallType(type);
      store.changeIsFromGroup(true);
      logReporter.callSuccess(this.SDKAppID, "groupCall", type === 1 ? "audio" : "video");
    } catch (error: any) {
      if (this.error && this.beforeCalling) {
        this.beforeCalling("groupCall", this.error);
      }
      this.error = null;
      this.callingAPIMutex = "";
      logReporter.callFailed(this.SDKAppID, "groupCall", type === 1 ? "audio" : "video", JSON.stringify(error));
      console.error("TUICallKit groupCall error: " + JSON.stringify(error));
      throw new Error(error);
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
    logReporter.callSuccess(this.SDKAppID, "groupCall", type === 1 ? "audio" : "video");
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

  public async getDeviceList(deviceType: string) {
    return await this.tuiCallEngine.getDeviceList(deviceType);
  }

  public async switchDevice(deviceType: string, deviceId: string) {
    try {
      await this.tuiCallEngine.switchDevice({ deviceType, deviceId });
    } catch (error) { 
      console.error("TUICallKit switchDevice error", JSON.stringify(error));
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
    logReporter.MinimizeSuccess(this.SDKAppID);
  }

  public async accept() {
    if (this.callingAPIMutex === "accept") {
      return;
    }
    this.callingAPIMutex = "accept";
    try {
      await this.tuiCallEngine.accept();
      this.getIntoCallingStatus();
    } catch (error) {
      console.error("TUICallKit accept error catch: ", error);
      // TODO: 提示无权限
      store.changeStatus(STATUS.IDLE);
      this.callingAPIMutex = "";
    }
  }

  public async reject() {
    if (this.callingAPIMutex === "reject") {
      return;
    }
    this.callingAPIMutex = "reject";
    try {
      await this.tuiCallEngine.reject();
    } catch (error) {
      console.error("TUICallKit reject error catch: ", error);
    }
    store.changeStatus(STATUS.IDLE);
    this.callingAPIMutex = "";
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
    console.log("TUICallKit startRemoteView", userID);
    if (!userID) return;
    try {
      await this.tuiCallEngine.startRemoteView({ userID, videoViewDomID: userID });
    } catch (err: any) {
      console.warn("TUICallKit startRemoteView error", err);
    }
  }

  public async stopRemoteView(userID: string) {
    await this.tuiCallEngine.stopRemoteView({ userID });
  }

  public async hangup() {
    if (this.callingAPIMutex === "hangup") {
      return;
    }
    this.callingAPIMutex = "hangup";
    await this.tuiCallEngine.hangup();
    store.changeStatus(STATUS.IDLE);
    this.callingAPIMutex = "";
  }

  public async renderLocal() {
    if (store.status.value === STATUS.IDLE) {
      console.log("TUICallKit renderLocal now working because status is idle");
      return;
    }
    store.profile.value.camera ? this.openCamera("local") : this.closeCamera();
    store.profile.value.microphone ? this.openMicrophone() : this.closeMicrophone();
  }

  public async renderRemote() {
    store.remoteList.value
    for (let i = 0; i < store.remoteList.value.length; i++) {
      await this.startRemoteView(store.remoteList.value[i].userID);
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
      console.error("TUICallKit closeCamera error:", error);
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
      console.error("TUICallKit closeMicrophone error:", error);
    }
  }

  public async setVideoQuality(videoProfile: string) {
    await this.tuiCallEngine.setVideoQuality(videoProfile);
  }

  public async switchCallMediaType() {
    console.log("TUICallKit switchCallMediaType", TUICallType.AUDIO_CALL);
    if (this.callingAPIMutex === "switchCallMediaType") {
      return;
    }
    this.callingAPIMutex = "switchCallMediaType";
    try {
      await this.tuiCallEngine.switchCallMediaType(TUICallType.AUDIO_CALL);
    } catch (error: any) {
      console.error("TUICallKit switchCallMediaType error:", error);
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
      console.error("TUICallKit inviteUser error: " + JSON.stringify(error));
      throw new Error(error);
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
    this.callingAPIMutex = "";
    try {
      if (this.tuiCallEngine) await this.tuiCallEngine.destroyInstance(); 
      console.log("TUICallKit destroyInstance success");
    } catch (error: any) {
      console.error("TUICallKit destroyed error:", error);
      throw new Error(error);
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

  private handleUserVideoAvailable(event: any) {
    console.log("TUICallKit handleUserVideoAvailable", event);
    const { userID, isVideoAvailable } = event;
    this.startRemoteView(userID);
    store.changeRemoteDeviceByUserID(userID, CALL_TYPE_STRING.VIDEO, isVideoAvailable);
  }

  private handleUserAudioAvailable(event: any) {
    console.log("TUICallKit handleUserAudioAvailable", event);
    const { userID, isAudioAvailable } = event;
    store.changeRemoteDeviceByUserID(userID, CALL_TYPE_STRING.AUDIO, isAudioAvailable);
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
    this.callingAPIMutex = "be_invited";
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
    this.callingAPIMutex = "";
  }

  private handleNoResponse(event: any) {
    console.log("TUICallKit handleNoResponse", event);
    const { userIDList } = event;
    userIDList.forEach((userID: string) => {
      if (store.removeRemoteListByUserID(userID) <= 0) {
        store.changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.NO_RESPONSE, store.isFromGroup.value ? 0 : 1000);
        this.callingAPIMutex = "";
      }
    });
  }

  private handleLineBusy(event: any) {
    console.log("TUICallKit handleLineBusy", event);
    const { userID } = event;
    if (store.removeRemoteListByUserID(userID) <= 0) {
      store.changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.LINE_BUSY, store.isFromGroup.value ? 0 : 1000);
    }
    this.callingAPIMutex = "";
  }

  private handleCallingCancel(event: any) {
    console.log("TUICallKit handleCallingCancel", event);
    store.changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.CALLING_CANCEL, 1000);
    this.callingAPIMutex = "";
  }

  private handleCallingTimeOut(event: any) {
    console.log("TUICallKit handleCallingTimeOut", event);
    const { userIDList } = event;
    userIDList.forEach((userID: string) => {
      if (store.removeRemoteListByUserID(userID) <= 0 || userID === store.profile.value.userID) {
        store.changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.CALLING_TIMEOUT, store.isFromGroup.value ? 0 : 1000);
        this.callingAPIMutex = "";
      }
    });
  }

  private handleCallingEnd(event: any) {
    console.log("TUICallKit handleCallingEnd", event);
    store.changeStatus(STATUS.IDLE);
    this.callingAPIMutex = "";
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
