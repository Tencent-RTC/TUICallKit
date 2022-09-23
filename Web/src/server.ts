import { TUICallEngine, TUICallEvent } from "tuicall-engine-webrtc";

import { TUICallParam, TUIInitParam, TUIGroupCallParam, RemoteUser, CallbackParam } from "./interface";
import {
  status,
  profile,
  callType,
  isFromGroup,
  changeStatus,
  updateProfile,
  changeCallType,
  changeRemoteList,
  changeIsFromGroup,
  addRemoteListByUserID,
  updateRemoteVolumeMap,
  removeRemoteListByUserID,
  changeRemoteDeviceByUserID
} from './store';
import { STATUS, CHANGE_STATUS_REASON, CALL_TYPE_STRING } from './constants';

/**
 * class TUICallKit
 *
 * TUIGroup 逻辑主体
 */
export default class TUICallKit {
  public tuiCallEngine: any;
  public TUICore: any;
  public beforeCalling: Function | undefined;
  public afterCalling: Function | undefined;
  constructor() {
    this.TUICore = null;
    this.tuiCallEngine = null;
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
    let { SDKAppID, tim, userID, userSig } = params;
    if (this.TUICore) {
      SDKAppID = this.TUICore.SDKAppID;
      tim = this.TUICore.tim;
    }
    if (this.tuiCallEngine) this.tuiCallEngine.destroyInstance(); 
    this.tuiCallEngine = TUICallEngine.createInstance({ SDKAppID, tim });
    this.bindTIMEvent();
    await this.tuiCallEngine.login({ userID, userSig });
    updateProfile(Object.assign(profile.value, { userID }));
  }

  /**
   * call 呼叫
   * @param { TUICallParam } params 呼叫参数
   * @param { string } params.userID 被呼叫的用户
   * @param { number } params.type 呼叫类型 1-语音，2-视频
   */
  public async call(params: TUICallParam) {
    this.checkStatus();
    const { userID, type } = params;
    await this.tuiCallEngine.call({ userID, type });
    changeStatus(STATUS.DIALING_C2C);
    changeRemoteList([{ userID, isEntered: false, microphone: false, camera: false }]);
    changeCallType(type);
    changeIsFromGroup(false);
  } 

  /**
   * groupCall 呼叫
   * @param { TUIGroupCallParam } params 呼叫参数
   * @param { string } params.userIDList 被呼叫的用户列表
   * @param { number } params.type 呼叫类型 1-语音，2-视频
   * @param { string } params.groupID 呼叫群组ID
   */
  public async groupCall(params: TUIGroupCallParam) {
    this.checkStatus();
    const { userIDList, type, groupID } = params;
    await this.tuiCallEngine.groupCall({ userIDList, type, groupID });
    const newRemoteList: Array<RemoteUser> = [];
    userIDList.forEach((userID: string) => {
      newRemoteList.push({ userID, isEntered: false, microphone: false, camera: false });
    });
    changeRemoteList(newRemoteList);
    changeStatus(STATUS.DIALING_GROUP);
    changeCallType(type);
    changeIsFromGroup(true);
  }

  private checkStatus() {
    if (status.value !== STATUS.IDLE) {
      throw new Error("TUICallKit: 已在通话状态");
    }
    if (!this.tuiCallEngine) {
      throw new Error("TUICallKit: 发起通话前需先进行初始化");
    }
  }

  public async getDeviceList(deviceType: string) {
    return await this.tuiCallEngine.getDeviceList(deviceType);
  }

  public async switchDevice(deviceType: string, deviceId: string) {
    return await this.tuiCallEngine.switchDevice({ deviceType, deviceId });
  }

  public bindTUICore(TUICore: any) {
    this.TUICore = TUICore;
  }

  public setCallback(params: CallbackParam) {
    const { beforeCalling, afterCalling } = params;
    this.beforeCalling = beforeCalling;
    this.afterCalling = afterCalling;
  }

  public async accept() {
    this.tuiCallEngine.accept().then(() => {
      this.getIntoCallingStatus();
    }).catch((error: any) => {
      console.warn('TUICallKit accept error:', error);
      changeStatus(STATUS.IDLE);
    });
  }

  public async reject() {
    await this.tuiCallEngine.reject();
    changeStatus(STATUS.IDLE);
  }

  public async startLocalView(local: string) {
    await this.tuiCallEngine.startLocalView({ userID: profile.value.userID, videoViewDomID: local });
  }

  public async startRemoteView(userID: string) {
    await this.tuiCallEngine.startRemoteView({ userID, videoViewDomID: userID });
  }

  public async hangup() {
    await this.tuiCallEngine.hangup();
    changeStatus(STATUS.IDLE);
  }

  public async openCamera() {
    this.tuiCallEngine.openCamera().then(() => {
      updateProfile(Object.assign(profile.value, { camera: true }));
    }).catch((error: any) => {
      console.warn('openCamera error:', error);
    });
  }

  public async closeCamera() {
    this.tuiCallEngine.closeCamera().then(() => {
      updateProfile(Object.assign(profile.value, { camera: false }));
    }).catch((error: any) => {
      console.warn('closeCamera error:', error);
    });
  }

  public async openMicrophone() {
    this.tuiCallEngine.openMicrophone().then(() => {
      updateProfile(Object.assign(profile.value, { microphone: true }));
    }).catch((error: any) => {
      console.warn('openMicrophone error:', error);
    });
  }

  public async closeMicrophone() {
    this.tuiCallEngine.closeMicrophone().then(() => {
      updateProfile(Object.assign(profile.value, { microphone: false }));
    }).catch((error: any) => {
      console.warn('closeMicrophone error:', error);
    });
  }

  public async setVideoQuality(profile: string) {
    await this.tuiCallEngine.setVideoQuality(profile);
  }

  public switchCallMediaType() {
    this.tuiCallEngine.switchCallMediaType(1);
  }

  /**
   * 组件销毁
   */
  public destroyed() {
    this.unbindTIMEvent();
    changeStatus(STATUS.IDLE);
  }

  private getIntoCallingStatus() {
    if (!isFromGroup.value && callType.value === CALL_TYPE_STRING.AUDIO) changeStatus(STATUS.CALLING_C2C_AUDIO);
    if (!isFromGroup.value && callType.value === CALL_TYPE_STRING.VIDEO) changeStatus(STATUS.CALLING_C2C_VIDEO);
    if (isFromGroup.value && callType.value === CALL_TYPE_STRING.AUDIO) changeStatus(STATUS.CALLING_GROUP_AUDIO);
    if (isFromGroup.value && callType.value === CALL_TYPE_STRING.VIDEO) changeStatus(STATUS.CALLING_GROUP_VIDEO);
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                    TUICallEngine 事件监听注册接口
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
  }

  private handleError(event: any) {
    throw new Error(event);
  }

  private handleSDKReady(event: any) {
    console.log("TUICallKit SDK is ready.", event);
  }

  private handleKickedOut() {
    throw new Error("Kicked Out");
  }

  private handleUserVideoAvailable(event: any) {
    const { userID, isVideoAvailable } = event;
    changeRemoteDeviceByUserID(userID, CALL_TYPE_STRING.VIDEO, isVideoAvailable);
  }

  private handleUserAudioAvailable(event: any) {
    const { userID, isAudioAvailable } = event;
    changeRemoteDeviceByUserID(userID, CALL_TYPE_STRING.AUDIO, isAudioAvailable);
  }

  private handleUserVoiceVolume(event: any) {
    const { volumeMap } = event;
    updateRemoteVolumeMap(volumeMap);
  }

  private handleInvited(event: any) {
    this.beforeCalling && this.beforeCalling();
    const { sponsor, isFromGroup, inviteData } = event;
    const { callType } = inviteData;
    changeStatus(STATUS.BE_INVITED);
    changeRemoteList([{ userID: sponsor, isEntered: false }]);
    changeCallType(callType);
    changeIsFromGroup(isFromGroup);
  }

  private handleUserAccept(event: any) {
    const { userID } = event;
    if (userID !== profile.value.userID) return;
    if (status.value === STATUS.BE_INVITED) return;
    this.getIntoCallingStatus();
  }

  private handleUserEnter(event: any) {
    const { userID } = event;
    addRemoteListByUserID(userID);
  }

  private handleUserLeave(event: any) {
    const { userID } = event;
    removeRemoteListByUserID(userID);
  }

  private handleReject(event: any) {
    const { userID } = event;
    if (status.value === STATUS.BE_INVITED) return;
    if (status.value === STATUS.CALLING_GROUP_AUDIO || status.value === STATUS.CALLING_GROUP_VIDEO || status.value === STATUS.DIALING_GROUP) {
      removeRemoteListByUserID(userID);
      return;
    }
    changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.REJECT, 1000);
  }

  private handleNoResponse(event: any) {
    changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.NO_RESPONSE, 1000);
  }

  private handleLineBusy() {
    changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.LINE_BUSY, 1000);
  }

  private handleCallingCancel() {
    changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.CALLING_CANCEL, 1000);
  }

  private handleCallingTimeOut(event: any) {
    if (status.value === STATUS.CALLING_GROUP_AUDIO || status.value === STATUS.CALLING_GROUP_VIDEO || status.value === STATUS.DIALING_GROUP) {
      const { userIDList } = event;
      userIDList.forEach((userID: string) => {
        removeRemoteListByUserID(userID);
      })
      return;
    }
    changeStatus(STATUS.IDLE, CHANGE_STATUS_REASON.CALLING_TIMEOUT, 1000);
  }

  private handleCallingEnd() {
    changeStatus(STATUS.IDLE);
  }

  private handleCallTypeChanged(event: any) {
    const { newCallType } = event;
    changeCallType(newCallType);
    changeStatus(STATUS.CALLING_C2C_AUDIO, CHANGE_STATUS_REASON.CALL_TYPE_CHANGED);
  }
}
