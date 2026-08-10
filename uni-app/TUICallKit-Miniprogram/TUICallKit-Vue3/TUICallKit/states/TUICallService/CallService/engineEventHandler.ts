import { ITUIStore } from '../interface/ITUIStore';
import { TUICallEvent } from '@trtc/call-engine-lite-wx';
import { IUserInfo } from '../interface/ICallService';
import { CallMediaType } from '@trtc/call-engine-lite-wx';
import { StoreName, CallStatus, NAME, CallRole, ErrorCode, ErrorMessage, NETWORK_QUALITY_THRESHOLD } from '../const/index';
import { CallTips, t } from '../locales/index';
import { initAndCheckRunEnv } from './miniProgram';
import { getRemoteUserProfile, analyzeEventData, deleteRemoteUser } from './utils';
import TuiStore from '../TUIStore/tuiStore';
const TUIStore: ITUIStore = TuiStore.getInstance();


export default class EngineEventHandler {
  static instance: EngineEventHandler;
  private _callService: any;
  private _isCallNotConnected = false;

  constructor(options) {
    this._callService = options.callService;
  }

  static getInstance(options) {
    if (!EngineEventHandler.instance) {
      EngineEventHandler.instance = new EngineEventHandler(options);
    }
    return EngineEventHandler.instance;
  }
  public addListenTuiCallEngineEvent() {
    const callEngine = this._callService?.getTUICallEngineInstance();

    if (!callEngine) {
      console.warn(`${NAME.PREFIX}add engine event listener failed, engine is empty.`);
      return;
    }

    callEngine.on(TUICallEvent.ERROR, this._handleError, this);
    callEngine.on(TUICallEvent.ON_CALL_RECEIVED, this._handleNewInvitationReceived, this); // 收到邀请事件
    TUICallEvent?.ON_CALL_BEGIN && callEngine.on(TUICallEvent.ON_CALL_BEGIN, this._handleOnCallBegin, this); // 主叫收到被叫接通事件
    callEngine.on(TUICallEvent.USER_ENTER, this._handleUserEnter, this); // 有用户进房事件
    callEngine.on(TUICallEvent.USER_LEAVE, this._handleUserLeave, this); // 有用户离开通话事件
    callEngine.on(TUICallEvent.REJECT, this._handleInviteeReject, this); // 主叫收到被叫的拒绝通话事件
    callEngine.on(TUICallEvent.NO_RESP, this._handleNoResponse, this); // 主叫收到被叫的无应答事件
    callEngine.on(TUICallEvent.LINE_BUSY, this._handleLineBusy, this); // 主叫收到被叫的忙线事件
    callEngine.on(TUICallEvent.ON_CALL_NOT_CONNECTED, this._handleCallNotConnected, this); // 主被叫在通话未建立时, 收到的取消事件
    callEngine.on(TUICallEvent.ON_USER_INVITING, this._handleOnUserInviting, this); // 通话存在邀请他人时, 通话里的所有人都会抛出
    callEngine.on(TUICallEvent.KICKED_OUT, this._handleKickedOut, this); // 未开启多端登录时, 多端登录收到的被踢事件
    // @ts-ignore
    // TUICallEvent.ON_USER_NETWORK_QUALITY_CHANGED && callEngine.on(TUICallEvent.ON_USER_NETWORK_QUALITY_CHANGED, this._handleNetworkQuality, this); // 用户网络质量
    callEngine.on(TUICallEvent.USER_VIDEO_AVAILABLE, this._handleUserVideoAvailable, this);
    callEngine.on(TUICallEvent.USER_AUDIO_AVAILABLE, this._handleUserAudioAvailable, this);
    callEngine.on(TUICallEvent.ON_CALL_END, this._handleCallingEnd, this); // 主被叫在通话结束时, 收到的通话结束事件
  }
  public removeListenTuiCallEngineEvent() {
    const callEngine = this._callService?.getTUICallEngineInstance();

    callEngine.off(TUICallEvent.ERROR, this._handleError, this);
    callEngine.off(TUICallEvent.ON_CALL_RECEIVED, this._handleNewInvitationReceived, this);
    TUICallEvent?.ON_CALL_BEGIN && callEngine.off(TUICallEvent.ON_CALL_BEGIN, this._handleOnCallBegin, this);
    callEngine.off(TUICallEvent.USER_ENTER, this._handleUserEnter, this);
    callEngine.off(TUICallEvent.USER_LEAVE, this._handleUserLeave, this);
    callEngine.off(TUICallEvent.REJECT, this._handleInviteeReject, this);
    callEngine.off(TUICallEvent.NO_RESP, this._handleNoResponse, this);
    callEngine.off(TUICallEvent.LINE_BUSY, this._handleLineBusy, this);
    callEngine.off(TUICallEvent.ON_CALL_NOT_CONNECTED, this._handleCallNotConnected, this);
    callEngine.off(TUICallEvent.ON_USER_INVITING, this._handleOnUserInviting, this);
    callEngine.off(TUICallEvent.KICKED_OUT, this._handleKickedOut, this);
    // @ts-ignore
    // TUICallEvent.ON_USER_NETWORK_QUALITY_CHANGED && callEngine.off(TUICallEvent.ON_USER_NETWORK_QUALITY_CHANGED, this._handleNetworkQuality, this);
    callEngine.off(TUICallEvent.USER_VIDEO_AVAILABLE, this._handleUserVideoAvailable, this);
    callEngine.off(TUICallEvent.USER_AUDIO_AVAILABLE, this._handleUserAudioAvailable, this);
    callEngine.off(TUICallEvent.ON_CALL_END, this._handleCallingEnd, this);
  }
  private _callerChangeToConnected() {
    const callRole = TUIStore.getData(StoreName.CALL, NAME.CALL_ROLE);
    const callStatus = TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS);

    if (callStatus === CallStatus.CALLING && callRole === CallRole.CALLER) {
      TUIStore.update(StoreName.CALL, NAME.CALL_STATUS, CallStatus.CONNECTED);
      this._callService?.startTimer();
    }
  }
  private _unNormalEventsManager(event: any, eventName: TUICallEvent): void {
    console.log(`${NAME.PREFIX}${eventName} event data: ${JSON.stringify(event)}.`);
    const isGroup = TUIStore.getData(StoreName.CALL, NAME.IS_GROUP);
    const remoteUserInfoList = TUIStore.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST);

    switch (eventName) {
      case TUICallEvent.REJECT:
      case TUICallEvent.LINE_BUSY: {
        const { userID: userId } = analyzeEventData(event);
        let callTipsKey = eventName === TUICallEvent.REJECT ? CallTips.OTHER_SIDE_REJECT_CALL : CallTips.OTHER_SIDE_LINE_BUSY;
        let userListNeedToShow = '';
        if (isGroup) {
          userListNeedToShow = (remoteUserInfoList.find(obj => obj.userId === userId) || {}).displayUserInfo || userId;
          callTipsKey = eventName === TUICallEvent.REJECT ? CallTips.REJECT_CALL : CallTips.IN_BUSY;
        }
        TUIStore.update(StoreName.CALL, NAME.TOAST_INFO, { content: { key: callTipsKey, options: { userList: userListNeedToShow } } });
        userId && deleteRemoteUser([userId]);
        if (TUIStore.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST).length === 0) {
          this._callService?._resetCallStore();
        }
        break;
      }
      case TUICallEvent.NO_RESP: {
        const { userIDList = [] } = analyzeEventData(event);
        const callTipsKey = isGroup ? CallTips.TIMEOUT : CallTips.CALL_TIMEOUT;
        const userInfoList: string[] = userIDList.map(userId => {
          const userInfo: IUserInfo = remoteUserInfoList.find(obj => obj.userId === userId) || {};
          return userInfo.displayUserInfo || userId;
        });
        TUIStore.update(StoreName.CALL, NAME.TOAST_INFO, { content: { key: callTipsKey, options: { userList: userInfoList.join() } } });
        userIDList.length > 0 && deleteRemoteUser(userIDList);
        // When no remote users remain (1v1 timeout, or all invitees timed out),
        // tear down the call so both the store and the engine return to IDLE,
        // mirroring the REJECT / LINE_BUSY handling above. Without this the
        // store stays stuck in CALLING and the engine can be left holding a
        // stale active call, which breaks the next `calls()`.
        if (TUIStore.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST).length === 0) {
          this._callService?._resetCallStore();
        }
        break;
      }
      case TUICallEvent.ON_CALL_NOT_CONNECTED: {
        this._callService?._resetCallStore();
        break;
      }
    }
  }

  private _handleError(event: any): void {
    const { code, message } = event || {};
    const index = Object.values(ErrorCode).indexOf(code);
    let callTips = '';

    if (index !== -1) {
      const key = Object.keys(ErrorCode)[index];
      callTips = t(ErrorMessage[key]);
      callTips && TUIStore.update(StoreName.CALL, NAME.TOAST_INFO, { content: ErrorMessage[key], type: NAME.ERROR });
    }
    console.error(`${NAME.PREFIX}_handleError, errorCode: ${code}; errorMessage: ${callTips || message}.`);
  }
  private async _handleNewInvitationReceived(event: any) {
    console.log(`${NAME.PREFIX}onCallReceived event data: ${JSON.stringify(event)}.`);
    const { callerId = '', callMediaType, inviteData = {}, calleeIdList = [], chatGroupID: groupID = '', roomID, strRoomID } = analyzeEventData(event);
    const currentUserInfo: IUserInfo = TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO);
    const remoteUserIdList: string[] = [callerId, ...calleeIdList.filter((userId: string) => userId !== currentUserInfo.userId)];
    const type = callMediaType || inviteData.callType;
    const callTipsKey = type === CallMediaType.AUDIO ? CallTips.CALLEE_CALLING_AUDIO_MSG : CallTips.CALLEE_CALLING_VIDEO_MSG;
    let updateStoreParams = {
      [NAME.CALL_ROLE]: CallRole.CALLEE,
      [NAME.IS_GROUP]: (!!groupID || calleeIdList.length > 1),
      [NAME.CALL_STATUS]: CallStatus.CALLING,
      [NAME.CALL_MEDIA_TYPE]: type,
      [NAME.CALL_TIPS]: callTipsKey,
      [NAME.CALLER_USER_INFO]: { userId: callerId },
      // Populate CALL_INFO.inviterId on the callee side too (the caller side
      // sets it in _updateCallStoreAfterCall). Without this, inviterId stays
      // empty on the callee, so the group-call waiting page cannot match the
      // real caller by id and falls back to allParticipants[0] positionally -
      // which renders the wrong avatar/name whenever the participant list is
      // reordered by async profile fetch / user-enter / invitee updates.
      [NAME.CALL_INFO]: { mediaType: type, inviterId: callerId },
      [NAME.GROUP_ID]: groupID,
    };
    initAndCheckRunEnv();
    this._isCallNotConnected = false;
    // If ON_CALL_NOT_CONNECTED fired during deviceCheck, the flag will be set.
    if (this._isCallNotConnected) {
      return;
    }
    TUIStore.updateStore(updateStoreParams, StoreName.CALL);

    const remoteUserInfoList = await getRemoteUserProfile(remoteUserIdList, this._callService?.getTim());
    const [userInfo] = remoteUserInfoList.filter((userInfo: IUserInfo) => userInfo.userId === callerId);

    remoteUserInfoList.length > 0 && TUIStore.updateStore({
      [NAME.REMOTE_USER_INFO_LIST]: remoteUserInfoList,
      [NAME.REMOTE_USER_INFO_EXCLUDE_VOLUMN_LIST]: remoteUserInfoList,
      [NAME.CALLER_USER_INFO]: {
        userId: callerId,
        nick: userInfo?.nick || '',
        avatar: userInfo?.avatar || '',
        displayUserInfo: userInfo?.remark || userInfo?.nick || callerId,
      },
    }, StoreName.CALL);
  }
  private async _handleOnCallBegin(event: any): Promise<void> {
    this._callerChangeToConnected();
    TUIStore.update(StoreName.CALL, NAME.CALL_TIPS, { text: 'answered', duration: 2000 });
    // Respect the user's mic preference chosen during the CALLING phase.
    // The caller-side flow marks the mic as opened by default in
    // _updateCallStoreAfterCall, and the user may have toggled it off before
    // the callee accepted. Only re-open the mic if the current UI state says
    // it should be on, otherwise keep it closed to honor the user's choice.
    const localUserInfo = TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO);
    if (localUserInfo?.isMicrophoneOpened) {
      await this._callService.openMicrophone();
    }
    console.log(`${NAME.PREFIX}accept event data: ${JSON.stringify(event)}.`);
  }
  private async _handleUserEnter(event: any): Promise<void> {
    const { userID: userId, data } = analyzeEventData(event);

    if (userId && TUIStore.getData(StoreName.CALL, NAME.CALL_ROLE) === CallRole.CALLEE) {
      if (TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS) === CallStatus.CALLING) {
        this._callService._handleAcceptResponse({});
      }
    }

    this._callerChangeToConnected();
    await this._addUserToRemoteUserInfoList(userId);
    let remoteUserInfoList = TUIStore.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST);
    remoteUserInfoList = remoteUserInfoList.map((obj: IUserInfo) => {
      if (obj.userId === userId) obj.isEnter = true;
      return obj;
    });

    if (remoteUserInfoList.length > 0) {
      TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST, remoteUserInfoList);
      TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_EXCLUDE_VOLUMN_LIST, remoteUserInfoList);
    }
    console.log(`${NAME.PREFIX}userEnter event data: ${JSON.stringify(event)}.`);
  }
  private _handleUserLeave(event: any): void {
    console.log(`${NAME.PREFIX}userLeave event data: ${JSON.stringify(event)}.`);
    const { data, userID: userId } = analyzeEventData(event);
    if (TUIStore.getData(StoreName.CALL, NAME.IS_GROUP)) {
      const remoteUserInfoList = TUIStore.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST);
      const userListNeedToShow: string = (remoteUserInfoList.find(obj => obj.userId === userId) || {}).displayUserInfo || userId;
      TUIStore.update(StoreName.CALL, NAME.TOAST_INFO, { content: { key: CallTips.END_CALL, options: { userList: userListNeedToShow } } });
    }
    userId && deleteRemoteUser([userId]);
  }
  private _handleInviteeReject(event: any): void {
    this._unNormalEventsManager(event, TUICallEvent.REJECT);
  }
  private _handleNoResponse(event: any): void {
    this._unNormalEventsManager(event, TUICallEvent.NO_RESP);
  }
  private _handleLineBusy(event: any): void {
    this._unNormalEventsManager(event, TUICallEvent.LINE_BUSY);
  }
  private _handleCallNotConnected(event: any): void {
    this._isCallNotConnected = true;
    this._unNormalEventsManager(event, TUICallEvent.ON_CALL_NOT_CONNECTED);
  }
  private async _handleOnUserInviting(event: any) {
    const { userID: userId } = analyzeEventData(event);
    if (!userId) return;

    if (userId !== TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO).userId) {
      await this._addUserToRemoteUserInfoList(userId);
    }
  }
  private _handleCallingEnd(event: any): void {
    console.log(`${NAME.PREFIX}callEnd event data: ${JSON.stringify(event)}.`);
    this._callService?._resetCallStore();
  }
  private _handleKickedOut(event: any): void {
    console.log(`${NAME.PREFIX}kickOut event data: ${JSON.stringify(event)}.`);
    this._callService?.kickedOut && this._callService?.kickedOut(event);
    TUIStore.update(StoreName.CALL, NAME.CALL_TIPS, CallTips.KICK_OUT);
    this._callService?._resetCallStore();
  }
  // private _handleNetworkQuality(event) {
  //   const { networkQualityList = [] } = analyzeEventData(event);
  //   TUIStore.update(StoreName.CALL, NAME.NETWORK_STATUS, networkQualityList);
  //   const isGroup = TUIStore.getData(StoreName.CALL, NAME.IS_GROUP);
  //   const localUserInfo = TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO);
  //   const remoteUserInfoList = TUIStore.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST);

  //   if(!isGroup) {
  //     const isRemoteNetworkPoor = networkQualityList.find(user => remoteUserInfoList[0]?.userId === user?.userId && user?.quality >= NETWORK_QUALITY_THRESHOLD);
  //     if(isRemoteNetworkPoor) {
  //       TUIStore.update(StoreName.CALL, NAME.CALL_TIPS, CallTips.REMOTE_NETWORK_IS_POOR);
  //       return;
  //     };
  //     const isLocalNetworkPoor = networkQualityList.find(user => localUserInfo?.userId === user?.userId && user?.quality >= NETWORK_QUALITY_THRESHOLD);
  //     if(isLocalNetworkPoor) {
  //       TUIStore.update(StoreName.CALL, NAME.CALL_TIPS, CallTips.LOCAL_NETWORK_IS_POOR);
  //       return;
  //     }
  //   }
  // }
  private async _startRemoteView(userId: string) {
    if (!userId) {
      console.warn(`${NAME.PREFIX}_startRemoteView userID is empty`);
      return;
    }

    try {
      const displayMode = TUIStore.getData(StoreName.CALL, NAME.DISPLAY_MODE);
      await this._callService?.getTUICallEngineInstance().startRemoteView({ userID: userId, videoViewDomID: `${userId}_0`, options: { objectFit: displayMode } });
    } catch (error: any) {
      console.error(`${NAME.PREFIX}_startRemoteView error: ${error}.`);
      return Promise.reject(error);
    }
  }
  private _setRemoteUserInfoAudioVideoAvailable(isAvailable: boolean, type: string, userId: string) {
    let remoteUserInfoList = TUIStore.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST);

    remoteUserInfoList = remoteUserInfoList.map((obj: IUserInfo) => {
      if (obj.userId === userId) {
        if (type === NAME.AUDIO) {
          return { ...obj, isMicrophoneOpened: isAvailable };
        }
        if (type === NAME.VIDEO) {
          return { ...obj, isCameraOpened: isAvailable };
        }
      }
      return obj;
    });

    if (remoteUserInfoList.length > 0) {
      TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST, remoteUserInfoList);
      TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_EXCLUDE_VOLUMN_LIST, remoteUserInfoList);
    }
  }
  private async _handleUserVideoAvailable(event: any): Promise<any> {
    const { userID: userId, isVideoAvailable } = analyzeEventData(event);
    console.log(`${NAME.PREFIX}_handleUserVideoAvailable event data: ${JSON.stringify(event)}.`);

    this._setRemoteUserInfoAudioVideoAvailable(isVideoAvailable, NAME.VIDEO, userId);
    try {
      isVideoAvailable && await this._startRemoteView(userId);
    } catch (error) {
      console.error(`${NAME.PREFIX}_startRemoteView failed, error: ${error}.`);
    }
  }
  private _handleUserAudioAvailable(event: any): void  {
    const { userID: userId, isAudioAvailable } = analyzeEventData(event);
    console.log(`${NAME.PREFIX}_handleUserAudioAvailable event data: ${JSON.stringify(event)}.`);

    this._setRemoteUserInfoAudioVideoAvailable(isAudioAvailable, NAME.AUDIO, userId);
  }
  private async _addUserToRemoteUserInfoList(userId: string) {
    let remoteUserInfoList = TUIStore.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST);
    const isInRemoteUserList = remoteUserInfoList.find(item => item?.userId === userId);

    if (!isInRemoteUserList) {
      remoteUserInfoList.push({ userId });
      TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST, remoteUserInfoList);
      TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_EXCLUDE_VOLUMN_LIST, remoteUserInfoList);

      const [userInfo] = await getRemoteUserProfile([userId], this._callService?.getTim());
      // Re-read the current list so concurrent audio/video toggles that
      // arrived while the profile request was in flight are preserved, then
      // merge the fetched nick/avatar/remark onto the matching entry.
      remoteUserInfoList = TUIStore.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST);
      remoteUserInfoList = remoteUserInfoList.map((obj: IUserInfo) => (
        obj?.userId === userId ? { ...obj, ...userInfo } : obj
      ));

      TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST, remoteUserInfoList);
      TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_EXCLUDE_VOLUMN_LIST, remoteUserInfoList);
    }
  }
}
