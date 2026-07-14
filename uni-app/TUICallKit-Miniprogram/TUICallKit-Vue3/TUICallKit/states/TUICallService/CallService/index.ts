import { IUserInfo, ISelfInfoParams, IInitParams } from '../interface/ICallService';
import { CallMediaType, CameraPosition, AudioPlayBackDevice, LOG_LEVEL } from '@trtc/call-engine-lite-wx';
import { ICallsParams } from '@trtc/call-engine-lite-wx';
import { StoreName, CallStatus, NAME, CALL_DATA_KEY, CallRole, COMPONENT, FeatureButton, ButtonState, LayoutMode, CALL_RING_EVENTS } from '../const/index';
import { TUICallEngine } from '@trtc/call-engine-lite-wx';
import { useRingPlugin } from '../../../plugin/ring';
import { beforeCall, handlePackageError } from './miniProgram';
import { checkMicrophonePermission, checkCameraPermission, handlePermissionDenied } from '../../../utils/permission';
import { CallTips, t } from '../locales/index';
import { handleModalError, notifyBusyCall } from './UIKitModal';
import { vueVersion } from '../../../adapter/vue-demi';
import { handleRepeatedCallError, performanceNow } from '../utils/common-utils';
import { getMyProfile, getRemoteUserProfile, noDevicePermissionToast, setLocalUserInfoAudioVideoAvailable } from './utils';
import { ITUIStore } from '../interface/index';
import TuiStore from '../TUIStore/tuiStore';
import ChatCombine from './chatCombine';
import EngineEventHandler from './engineEventHandler';
import { UIDesign } from './UIDesign';
const TUIStore: ITUIStore = TuiStore.getInstance();
const uiDesign = UIDesign.getInstance();
uiDesign.setTUIStore(TUIStore);
const version = '5.0.1';
export { TUIStore, uiDesign };
const defaultOfflinePushInfo = { title: '', description: t('you have a new call') };

export default class TUICallService {
  static instance: TUICallService;
  public _tuiCallEngine: any;
  private _tim: any = null;
  private _timerId: any = -1;
  private _startTimeStamp: number = performanceNow();
  private _isFromChat: boolean = false;
  private _offlinePushInfo = null;
  private _permissionCheckTimer: any = null;
  private _chatCombine: any = null;
  private _engineEventHandler: any = null;
  // Ring plugin instance (@trtc/call-ring-wx). Stored only for lifecycle
  // cleanup; the plugin works purely through the uni event bus and the host
  // never calls its internal methods directly (except the documented
  // enableMuteMode / setCallingBell passthroughs below).
  private _ringPlugin: any = null;

  constructor() {
    console.log(`${NAME.PREFIX}version: ${version}`);
    this._watchTUIStore();
    this._engineEventHandler = EngineEventHandler.getInstance({ callService: this });

    this._chatCombine = ChatCombine.getInstance({ callService: this });
  }
  static getInstance() {
    if (!TUICallService.instance) {
      TUICallService.instance = new TUICallService();
    }
    return TUICallService.instance;
  }
  public async init(params: IInitParams) {
    try {
      if (this._tuiCallEngine) return;
      // @ts-ignore
      let { userID, tim, userSig, sdkAppID, SDKAppID, isFromChat, component = COMPONENT.TUI_CALL_KIT } = params;
      this._tim = tim;
      console.log(`${NAME.PREFIX}init sdkAppId: ${sdkAppID || SDKAppID}, userId: ${userID}`);
      this._tuiCallEngine = TUICallEngine.createInstance({
        tim,
        sdkAppID: sdkAppID || SDKAppID, // 兼容传入 SDKAppID 的问题
        callkitVersion: version,
        isFromChat: isFromChat || false,
        component,
        scene: vueVersion === 2 ? 'wx-uniapp-vue2-v5' : 'wx-uniapp-vue3-v5',
      } as any);
      uiDesign.setEngineInstance(this._tuiCallEngine);
      this._addListenTuiCallEngineEvent();
      this.registerPlugin(useRingPlugin());

      TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO, { userId: userID });
      TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO_EXCLUDE_VOLUMN, { userId: userID });
      uiDesign.updateViewBackgroundUserId('local');
      await this._tuiCallEngine.login({ userID, userSig, assetsPath: '' }); // web && mini
      // Populate the local user's own IM profile (nick / avatar) into
      // LOCAL_USER_INFO so the self tile renders the same avatar remote peers
      // see when the camera is off. Without this the local avatar stays empty
      // and falls back to the default image, mismatching the remote view.
      await getMyProfile(userID, this.getTim());
      const uiConfig = TUIStore.getData(StoreName.CALL, NAME.CUSTOM_UI_CONFIG);
      this._tuiCallEngine?.reportLog?.({
        name: 'TUICallkit.init',
        data: {
          uiConfig,
        }
      });
    } catch (error) {
      console.error(`${NAME.PREFIX}init failed, error: ${error}.`);
      throw error;
    }
  }
  // component destroy
  public async destroyed() {
    try {
      const currentCallStatus = TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS);
      if (currentCallStatus !== CallStatus.IDLE) {
        throw new Error(`please destroyed when status is idle, current status: ${currentCallStatus}`);
      }
      if (this._tuiCallEngine) {
        this._removeListenTuiCallEngineEvent();
        await this._tuiCallEngine.destroyInstance();
        this._tuiCallEngine = null;
        this._unwatchTUIStore();
        // Tear down the ring plugin (unsubscribes from the event bus and
        // releases the audio context).
        this._ringPlugin?.destroy?.();
        this._ringPlugin = null;
      }
    } catch (error) {
      console.error(`${NAME.PREFIX}destroyed failed, error: ${error}.`);
      throw error;
    }
  }
  // ===============================【通话操作】===============================
  public async calls(callsParams: ICallsParams) {
    // Guard: only allow a new call when current status is IDLE.
    // The call UI may not be mounted yet, so we trigger a global modal via the
    // UI bridge (UIKitModal) instead of touching any UI code from this layer.
    if (TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS) !== CallStatus.IDLE) {
      notifyBusyCall();
      return;
    }
    try {
      TUIStore.update(StoreName.CALL, NAME.PUSHER_ID, NAME.NEW_PUSHER);
      const { userIDList, type, groupID: chatGroupID, offlinePushInfo } = callsParams;
      if (TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS) !== CallStatus.IDLE) return;
      const remoteUserInfoList = userIDList.map(userId => ({ userId }));
      const callStatus = await this._updateCallStoreBeforeCall(type, remoteUserInfoList, chatGroupID);
      // When the microphone permission check fails, beforeCall returns IDLE.
      // Abort here before invoking the engine, otherwise the call would still be
      // placed while the UI stays IDLE, leaving the engine in an inconsistent
      // state that breaks the next call (e.g. white screen on retry).
      if (callStatus === CallStatus.IDLE) {
        this._resetCallStore();
        return;
      }
      callsParams.offlinePushInfo = { ...defaultOfflinePushInfo, ...offlinePushInfo };
      let response: any;
      try {
        response = await this._tuiCallEngine.calls(callsParams);
      } catch (err: any) {
        // Self-heal a store/engine state desync: our store is IDLE (the guard
        // above passed) but the engine still holds a stale "active call" left
        // over from a previous call whose teardown did not fully release the
        // engine. Force-release the engine, then retry the call once so the
        // user is not permanently blocked from starting a new call.
        if (String(err?.message || err).includes('active call')) {
          try {
            await this._tuiCallEngine.hangup();
          } catch (hangupErr) {
            console.warn(`${NAME.PREFIX}calls self-heal hangup failed: ${hangupErr}.`);
          }
          response = await this._tuiCallEngine.calls(callsParams);
        } else {
          throw err;
        }
      }
      await this._updateCallStoreAfterCall(userIDList, response);
    } catch (error: any) {
      handleModalError(error);
      this._handleCallError(error, 'calls');
    }
  }
  public async inviteUser(params: { userIDList?: string[] } | any) {
    if (TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS) === CallStatus.IDLE) return; // avoid double click when application stuck
    if (!this._tuiCallEngine) return;
    try {
      const { userIDList = [] } = params || {};
      if (userIDList.length === 0) return;
      // Merge with the existing remote list so the tile is rendered before
      // USER_ENTER arrives; the engine fires ON_USER_INVITING / USER_ENTER
      // events to confirm and update the local state.
      const remoteUserInfoList = TUIStore.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST) || [];
      const knownUserIds = new Set(remoteUserInfoList.map((u: any) => u.userId));
      const newUserInfoList = [
        ...remoteUserInfoList,
        ...userIDList
          .filter((userId: string) => !knownUserIds.has(userId))
          .map((userId: string) => ({ userId })),
      ];
      TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST, newUserInfoList);
      TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_EXCLUDE_VOLUMN_LIST, newUserInfoList);
      // @trtc/call-engine-lite-wx v3 does not expose a public `inviteUser` method; the
      // server-side invite dispatch is handled implicitly by the engine
      // when new USER_ENTER events come in. We keep the local store up to
      // date above so the UI can render a placeholder tile for each
      // invitee before the engine confirms.
      if (typeof (this._tuiCallEngine as any).inviteUser === 'function') {
        try {
          await (this._tuiCallEngine as any).inviteUser(params);
        } catch (engineErr) {
          console.warn(`${NAME.PREFIX}engine.inviteUser is not supported in this build: ${engineErr}.`);
        }
      }
    } catch (error: any) {
      console.error(`${NAME.PREFIX}inviteUser failed, error: ${error}.`);
    }
  }
  // Actively join an ongoing group call.
  // NOTE: the current `@trtc/call-engine-lite-wx` (lite) build does not implement a
  // `join` method (see @trtc/call-engine-lite-wx type definitions). We keep the public
  // API to align with the TUICallKit interface doc and degrade gracefully:
  // when the engine gains `join`, this method drives the full connected flow.
  public async join(params: { callId?: string } | any) {
    if (TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS) === CallStatus.CONNECTED) return; // avoid double click when application stuck
    if (typeof this._tuiCallEngine?.join !== 'function') {
      console.warn(`${NAME.PREFIX}join is not supported by the current @trtc/call-engine-lite-wx build.`);
      return;
    }
    try {
      const response = await this._tuiCallEngine.join(params);
      TUIStore.update(StoreName.CALL, NAME.IS_CLICKABLE, true);
      this.startTimer();

      const updateStoreParams = {
        [NAME.CALL_ROLE]: CallRole.CALLEE,
        [NAME.IS_GROUP]: true,
        [NAME.CALL_STATUS]: CallStatus.CONNECTED,
        [NAME.CALL_MEDIA_TYPE]: TUIStore.getData(StoreName.CALL, NAME.CALL_MEDIA_TYPE) || CallMediaType.AUDIO, // default audio callMediaType
      };
      TUIStore.updateStore(updateStoreParams, StoreName.CALL);

      this.setSoundMode(params.type === CallMediaType.AUDIO ? AudioPlayBackDevice.EAR : AudioPlayBackDevice.SPEAKER);
      const localUserInfo = TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO);
      TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO, { ...localUserInfo, isEnter: true });
      TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO_EXCLUDE_VOLUMN, { ...localUserInfo, isEnter: true });

      await this.openMicrophone();
      setLocalUserInfoAudioVideoAvailable(true, NAME.AUDIO);
    } catch (error) {
      this._handleCallError(error, 'join');
    }
  }
  // ===============================【插件注册】===============================
  /**
   * Register an external plugin (e.g. the ring plugin created via
   * `useRingPlugin()` from `@trtc/call-ring-wx`) before login.
   *
   * The plugin self-subscribes to the uni global event bus; the host only
   * keeps a reference so it can be torn down in `destroyed()`.
   *
   * @example TUICallKitAPI.registerPlugin(useRingPlugin());
   */
  public registerPlugin(plugin: any): void {
    this._ringPlugin = plugin;
  }
  // ===============================【其它对外接口】===============================
  public getTUICallEngineInstance(): any {
    return this?._tuiCallEngine || null;
  }
  public setLogLevel(level: LOG_LEVEL) {
    this?._tuiCallEngine?.setLogLevel(level);
  }
  public enableFloatWindow(enable: boolean) {
    TUIStore.update(StoreName.CALL, NAME.ENABLE_FLOAT_WINDOW, enable);
  }
  public async setSelfInfo(params: ISelfInfoParams) {
    const { nickName, avatar } = params;
    try {
      await this._tuiCallEngine.setSelfInfo(nickName, avatar);
    } catch (error) {
      console.error(`${NAME.PREFIX}setSelfInfo failed, error: ${error}.`);
    }
  }
  public async enableMuteMode(enable: boolean) {
    try {
      this._ringPlugin?.enableMuteMode?.(enable);
    } catch (error) {
      console.warn(`${NAME.PREFIX}enableMuteMode failed, error: ${error}.`);
    }
  }
  /**
   * Set a custom ringtone for incoming calls (callee side).
   * @param filePath absolute path to an audio file; pass an empty string to
   *                 restore the default ringtone. Delegates to the ring plugin.
   */
  public setCallingBell(filePath?: string) {
    try {
      this._ringPlugin?.setCallingBell?.(filePath);
    } catch (error) {
      console.warn(`${NAME.PREFIX}setCallingBell failed, error: ${error}.`);
    }
  }
  // =============================【UI 定制接口】=============================
  // Hide a feature button (camera / microphone / switchCamera / inviteUser).
  public hideFeatureButton(buttonName: FeatureButton) {
    uiDesign.hideFeatureButton(buttonName);
  }
  // Set the local user's call-view background image (local or network url).
  public setLocalViewBackgroundImage(url: string) {
    uiDesign.setLocalViewBackgroundImage(url);
  }
  // Set a remote user's call-view background image. Pass '*' for all users.
  public setRemoteViewBackgroundImage(userId: string, url: string) {
    uiDesign.setRemoteViewBackgroundImage(userId, url);
  }
  // Set the call-view layout mode (local / remote in large view).
  public setLayoutMode(layoutMode: LayoutMode) {
    uiDesign.setLayoutMode(layoutMode);
  }
  // Set whether the camera is opened by default when the call connects.
  public setCameraDefaultState(isOpen: boolean) {
    uiDesign.setCameraDefaultState(isOpen);
  }
  // =============================【实验性接口】=============================
  public callExperimentalAPI(jsonStr: string) {
    const jsonObj = JSON.parse(jsonStr);
    if (jsonObj === jsonStr) return;

    const { api, params } = jsonObj;
    if (!api || !params) return;

    try {
      switch(api) {
        case 'forceUseV2API':
          const { enable } = params;
          TUIStore.update(StoreName.CALL, NAME.IS_FORCE_USE_V2_API, !!enable);
          break;
        default:
          break;
      }
    } catch (error) {
      this._tuiCallEngine?.reportLog?.({ name: 'TUICallKit.callExperimentalAPI.fail', data: { error } });
    }
  }
  // =============================【内部按钮操作方法】=============================
  public async accept() {
    const callStatus = TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS);
    this._tuiCallEngine?.reportLog?.({
      name: 'TUICallKit.accept.start',
      data: { callStatus },
    });
    if (callStatus === CallStatus.CONNECTED) return; // avoid double click when application stuck, especially for miniProgram
    try {
      const callMediaType = TUIStore.getData(StoreName.CALL, NAME.CALL_MEDIA_TYPE);
      // Microphone permission is mandatory before answering a call.
      const micCheck = await checkMicrophonePermission();
      if (!micCheck.granted) {
        const { confirm } = await handlePermissionDenied(micCheck);
        // Callee side: if the user declined to grant the mandatory microphone
        // permission by cancelling the dialog, reject the incoming call
        // directly so the caller is not left waiting on an unanswerable ring.
        const callRole = TUIStore.getData(StoreName.CALL, NAME.CALL_ROLE);
        if (!confirm && callRole === CallRole.CALLEE) {
          await this.reject();
        }
        return;
      }
      // Camera permission is mandatory for video calls — a denial blocks answering.
      if (callMediaType === CallMediaType.VIDEO) {
        const cameraCheck = await checkCameraPermission();
        if (!cameraCheck.granted) {
          const { confirm } = await handlePermissionDenied(cameraCheck);
          // Callee side: if the user declined to grant the mandatory camera
          // permission by cancelling the dialog, reject the incoming call
          // directly so the caller is not left waiting on an unanswerable ring.
          const callRole = TUIStore.getData(StoreName.CALL, NAME.CALL_ROLE);
          if (!confirm && callRole === CallRole.CALLEE) {
            await this.reject();
          }
          return;
        }
      }
      TUIStore.update(StoreName.CALL, NAME.PUSHER_ID, NAME.NEW_PUSHER);
      const response = await this._tuiCallEngine.accept();

      await this._handleAcceptResponse(response);
    } catch (error) {
      this._tuiCallEngine?.reportLog?.({
        name: 'TUICallKit.accept.fail',
        level: 'error',
        error,
      });
      if (handleRepeatedCallError(error)) return;
      handleModalError(error);
      noDevicePermissionToast(error, CallMediaType.AUDIO, this._tuiCallEngine);
      this._resetCallStore();
    }
  }
  private async _handleAcceptResponse(response) {
    if (response) {
      if (TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS) === CallStatus.CONNECTED) return;

      // 小程序接通时会进行授权弹框, 状态需要放在 accept 后, 否则先接通后再拉起权限设置
      TUIStore.update(StoreName.CALL, NAME.CALL_STATUS, CallStatus.CONNECTED);
      TUIStore.update(StoreName.CALL, NAME.IS_CLICKABLE, true);
      this.startTimer();
      const callMediaType = TUIStore.getData(StoreName.CALL, NAME.CALL_MEDIA_TYPE);
      const isCameraDefaultStateClose = this._getFeatureButtonDefaultState(FeatureButton.Camera) === ButtonState.Close;
      // Respect any camera/mic toggle the user made during CALLING (mirrors
      // the caller-side logic in _updateCallStoreAfterCall).
      const currentCameraOpened = TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO)?.isCameraOpened;
      const shouldOpenCameraByDefault = currentCameraOpened !== false;
      if ((callMediaType === CallMediaType.VIDEO) && !isCameraDefaultStateClose && shouldOpenCameraByDefault) {
        await this.openCamera(NAME.LOCAL_VIDEO);
      }
      await this.openMicrophone()
      // Apply the default audio playback route only if the user has not
      // manually toggled the speaker/receiver during the CALLING phase
      // (mirrors the caller-side logic; see _updateCallStoreAfterCall).
      const currentIsEarPhone = TUIStore.getData(StoreName.CALL, NAME.IS_EAR_PHONE);
      if (currentIsEarPhone === undefined) {
        this.setSoundMode(callMediaType === CallMediaType.AUDIO ? AudioPlayBackDevice.EAR : AudioPlayBackDevice.SPEAKER);
      }
      const localUserInfo = TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO);
      TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO, { ...localUserInfo, isEnter: true });
      TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO_EXCLUDE_VOLUMN, { ...localUserInfo, isEnter: true });
      // Default-open the microphone only if the user has not explicitly
      // muted it during the CALLING phase.
      const currentMicOpened = TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO)?.isMicrophoneOpened;
      if (currentMicOpened !== false) {
        setLocalUserInfoAudioVideoAvailable(true, NAME.AUDIO); // web && mini default open audio
      }
    }
  }
  public enableMultiDeviceAbility(enable: boolean) {
    this._tuiCallEngine.enableMultiDeviceAbility(enable);
  }
  public async hangup() {
    if (TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS) === CallStatus.IDLE) return; // avoid double click when application stuck
    await this._tuiCallEngine.hangup();
    this._resetCallStore();
  }
  public async reject() {
    if (TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS) === CallStatus.IDLE) return; // avoid double click when application stuck

    await this._tuiCallEngine.reject();
    this._resetCallStore();
  }
  public async openCamera(videoViewDomID: string) {
    try {
      const currentPosition = TUIStore.getData(StoreName.CALL, NAME.CAMERA_POSITION);
      const isFrontCamera = currentPosition === CameraPosition.FRONT ? true : false;
      this._tuiCallEngine.openCamera(videoViewDomID, isFrontCamera);

      setLocalUserInfoAudioVideoAvailable(true, NAME.VIDEO);
    } catch (error: any) {
      noDevicePermissionToast(error, CallMediaType.VIDEO, this._tuiCallEngine);
      console.error(`${NAME.PREFIX}openCamera error: ${error}.`);
    }
  }
  public async closeCamera() {
    try {
      await this._tuiCallEngine.closeCamera();
      setLocalUserInfoAudioVideoAvailable(false, NAME.VIDEO);
    } catch (error: any) {
      console.error(`${NAME.PREFIX}closeCamera error: ${error}.`);
    }
  }
  public async openMicrophone() {
    try {
      await this._tuiCallEngine.openMicrophone();
      setLocalUserInfoAudioVideoAvailable(true, NAME.AUDIO);
    } catch (error: any) {
      console.error(`${NAME.PREFIX}openMicrophone failed, error: ${error}.`);
    }
  }
  public async closeMicrophone() {
    try {
      await this._tuiCallEngine.closeMicrophone();
      setLocalUserInfoAudioVideoAvailable(false, NAME.AUDIO);
    } catch (error: any) {
      console.error(`${NAME.PREFIX}closeMicrophone failed, error: ${error}.`);
    }
  }
  public switchScreen(userId: string) {
    if(!userId) return;
    TUIStore.update(StoreName.CALL, NAME.BIG_SCREEN_USER_ID, userId);
  }
  public async switchCamera() {
    const currentPosition = TUIStore.getData(StoreName.CALL, NAME.CAMERA_POSITION);
    const targetPosition = currentPosition === CameraPosition.BACK ? CameraPosition.FRONT : CameraPosition.BACK;
    try {
      await this._tuiCallEngine.switchCamera(targetPosition);
      TUIStore.update(StoreName.CALL, NAME.CAMERA_POSITION, targetPosition);
    } catch (error) {
      console.error(`${NAME.PREFIX}_switchCamera failed, error: ${error}.`);
    }
  }
  public setSoundMode(type?: AudioPlayBackDevice): void {
    try {
      const currentIsEarPhone = TUIStore.getData(StoreName.CALL, NAME.IS_EAR_PHONE);
      // NOTE: AudioPlayBackDevice.SPEAKER === 0, so `type || fallback` would
      // incorrectly treat an explicit SPEAKER argument as "no argument".
      // Detect the explicit-argument case with a strict undefined/null check.
      const hasExplicitType = type !== undefined && type !== null;
      const soundMode: AudioPlayBackDevice = hasExplicitType
        ? (type as AudioPlayBackDevice)
        : (currentIsEarPhone ? AudioPlayBackDevice.SPEAKER : AudioPlayBackDevice.EAR);
      this._tuiCallEngine?.selectAudioPlaybackDevice(soundMode);
      // Always derive isEarPhone from the actual soundMode we just applied,
      // instead of toggling it manually (which can drift out of sync).
      const nextIsEarPhone = soundMode === AudioPlayBackDevice.EAR;
      TUIStore.update(StoreName.CALL, NAME.IS_EAR_PHONE, nextIsEarPhone);
    } catch (error) {
      console.error(`${NAME.PREFIX}setSoundMode failed, error: ${error}.`);
    }
  }
  // ==========================【TUICallEngine 事件处理】==========================
  private _addListenTuiCallEngineEvent() {
    this._engineEventHandler.addListenTuiCallEngineEvent();
  }
  private _removeListenTuiCallEngineEvent() {
    this._engineEventHandler.removeListenTuiCallEngineEvent();
  }
  // 处理用户异常退出的情况, 小程序 ”右滑“、"左上角退出"; web 页面关闭浏览器或关闭 tab 页面
  public async handleExceptionExit(event?: any) {
    try {
      const callStatus = TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS);
      const callRole = TUIStore.getData(StoreName.CALL, NAME.CALL_ROLE);
      this._tuiCallEngine?.reportLog?.({ name: 'TUICallkit.handleExceptionExit', data: { callStatus, callRole } });

      if (callStatus === CallStatus.IDLE) return;
      // 在呼叫状态下，被叫调用 reject，主叫调用 hangup
      if (callStatus === CallStatus.CALLING) {
        if (callRole === CallRole.CALLER) {
          await this?.hangup();
        } else {
          await this?.reject();
        }
      }
      if (callStatus === CallStatus.CONNECTED) {
        await this?.hangup();
      }
      this?._resetCallStore();
    } catch (error) {
      console.error(`${NAME.PREFIX} handleExceptionExit failed, error: ${error}.`);
    }
    if (event) {
      event.returnValue = '';
    }
  }
  // 通话时长更新
  public startTimer(): void {
    if (this._timerId === -1) {
      this._startTimeStamp = performanceNow();
      this._timerId = setInterval(() => this._updateCallDuration(), 1000);
    }
  }
  private _stopTimer(): void {
    if (this._timerId !== -1) {
      clearInterval(this._timerId);
      this._timerId = -1;
    }
  }
  // =========================【private methods for service use】=========================
  // 处理 “呼叫” 抛出的异常
  private _handleCallError(error: any, methodName?: string) {
    this._permissionCheckTimer && clearInterval(this._permissionCheckTimer);
    if (handleRepeatedCallError(error)) return;
    noDevicePermissionToast(error, CallMediaType.AUDIO, this._tuiCallEngine);
    console.error(`${NAME.PREFIX}${methodName} failed, error: ${error}.`);
    this._resetCallStore();
    throw error;
  }
  private async _updateCallStoreBeforeCall(type: number, remoteUserInfoList: IUserInfo[], groupID?: string): Promise<CallStatus> {
    let callTips = CallTips.CALLER_CALLING_MSG;
    let updateStoreParams: any = {
      [NAME.CALL_MEDIA_TYPE]: type,
      [NAME.CALL_ROLE]: CallRole.CALLER,
      [NAME.REMOTE_USER_INFO_LIST]: remoteUserInfoList,
      [NAME.REMOTE_USER_INFO_EXCLUDE_VOLUMN_LIST]: remoteUserInfoList,
      [NAME.IS_GROUP]: (!!groupID || remoteUserInfoList.length > 1),
      [NAME.CALL_TIPS]: callTips,
      [NAME.GROUP_ID]: groupID
    };
    const callStatus = await beforeCall(type); // IDLE when permission is denied; the call is set to calling only after permission is granted (differs from web)
    console.log(`${NAME.PREFIX}mini beforeCall return callStatus: ${callStatus}.`);
    TUIStore.updateStore({ ...updateStoreParams, [NAME.CALL_STATUS]: callStatus }, StoreName.CALL);
    const remoteUserInfoLists = await getRemoteUserProfile(remoteUserInfoList.map(obj => obj.userId), this.getTim());

    if (remoteUserInfoLists.length > 0) {
      TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST, remoteUserInfoLists);
      TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_EXCLUDE_VOLUMN_LIST, remoteUserInfoLists);
    }
    // Permission is already requested and resolved inside `beforeCall` (via permission.ts),
    // and the resulting call status is written to the store above, so no extra polling is needed.
    return callStatus;
  }
  private async _updateCallStoreAfterCall(userIdList: string[], response: any) {
    const callMediaType = TUIStore.getData(StoreName.CALL, NAME.CALL_MEDIA_TYPE);
    let localUserInfo = TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO);
    TUIStore.update(StoreName.CALL, NAME.CALL_INFO, { mediaType: callMediaType, inviterId: localUserInfo.userId });
    if (response) {
      TUIStore.update(StoreName.CALL, NAME.IS_CLICKABLE, true);
      // Apply the default audio playback route only if the user has not
      // manually toggled the speaker/receiver during the CALLING phase.
      // isEarPhone is reset to `undefined` in _resetCallStore, so any
      // defined value here means the user (or a prior default) has already
      // chosen; skip re-applying to respect that choice.
      const currentIsEarPhone = TUIStore.getData(StoreName.CALL, NAME.IS_EAR_PHONE);
      if (currentIsEarPhone === undefined) {
        this.setSoundMode(callMediaType === CallMediaType.AUDIO ? AudioPlayBackDevice.EAR : AudioPlayBackDevice.SPEAKER);
      }

      const isCameraDefaultStateClose = this._getFeatureButtonDefaultState(FeatureButton.Camera) === ButtonState.Close;
      // Respect any camera toggle the user made during CALLING: only open
      // the camera by default if the current UI state has not explicitly
      // marked it as closed.
      const currentCameraOpened = TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO)?.isCameraOpened;
      const shouldOpenCameraByDefault = currentCameraOpened !== false;
      if ((callMediaType === CallMediaType.VIDEO) && !isCameraDefaultStateClose && shouldOpenCameraByDefault) {
        await this.openCamera(NAME.LOCAL_VIDEO);
      }
      localUserInfo = TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO);
      TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO, { ...localUserInfo, isEnter: true });
      TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO_EXCLUDE_VOLUMN, { ...localUserInfo, isEnter: true });
      // Default-open the microphone only if the user has not explicitly
      // muted it during the CALLING phase (isMicrophoneOpened === false).
      const currentMicOpened = TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO)?.isMicrophoneOpened;
      if (currentMicOpened !== false) {
        setLocalUserInfoAudioVideoAvailable(true, NAME.AUDIO); // web && mini, default open audio
      }
    } else {
      this._permissionCheckTimer && clearInterval(this._permissionCheckTimer);
      this._permissionCheckTimer = null;
      this._resetCallStore();
    }
  }
  private _getFeatureButtonDefaultState(buttonName: FeatureButton) {
    const { button: buttonConfig } = TUIStore.getData(StoreName.CALL, NAME.CUSTOM_UI_CONFIG);
    return buttonConfig?.[buttonName]?.state;
  }
  private _updateCallDuration(): void {
    TUIStore.update(StoreName.CALL, NAME.DURATION, Math.round((performanceNow() - this._startTimeStamp) / 1000));
  }
  private _resetCallStore() {
    this._stopTimer();
    // localUserInfo, language 在通话结束后不需要清除
    // callStatus 清除需要通知; isMinimized 也需要通知（basic-vue3 中切小窗关闭后, 再呼叫还是小窗, 因此需要通知到组件侧）
    // isGroup 也不清除(engine 先抛 cancel 事件, 再抛 reject 事件)
    // displayMode、videoResolution 也不能清除, 组件不卸载, 这些属性也需保留, 否则采用默认值.
    // enableFloatWindow 不清除：开启/关闭悬浮窗功能。
    let notResetOrNotifyKeys = Object.keys(CALL_DATA_KEY).filter((key) => {
      switch (CALL_DATA_KEY[key]) {
        case NAME.CALL_STATUS:
        case NAME.LANGUAGE:
        case NAME.IS_GROUP:
        case NAME.ENABLE_FLOAT_WINDOW:
        case NAME.LOCAL_USER_INFO:
        case NAME.IS_FORCE_USE_V2_API:
        case NAME.LOCAL_USER_INFO_EXCLUDE_VOLUMN: {
          return false;
        }
        default: {
          return true;
        }
      }
    });
    notResetOrNotifyKeys = notResetOrNotifyKeys.map(key => CALL_DATA_KEY[key]);
    TUIStore.reset(StoreName.CALL, notResetOrNotifyKeys);
    const callStatus = TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS);
    callStatus !== CallStatus.IDLE && TUIStore.reset(StoreName.CALL, [NAME.CALL_STATUS], true); // callStatus reset need notify
    TUIStore.reset(StoreName.CALL, [NAME.IS_MINIMIZED], true); // isMinimized reset need notify
    // duration reset needs notify too, otherwise CallListState keeps the last
    // call's duration and the next call briefly shows a stale value before the
    // timer's first tick (duration "jumps" instead of starting from 0).
    TUIStore.reset(StoreName.CALL, [NAME.DURATION], true);
    // Reset isEarPhone to `undefined` (rather than the default `false`) so
    // the next call cycle can distinguish "user has not chosen yet" from
    // "user explicitly picked speaker". Notify so DeviceState resyncs its
    // currentAudioRoute back to the default.
    TUIStore.update(StoreName.CALL, NAME.IS_EAR_PHONE, undefined);
    TUIStore.reset(StoreName.CALL, [NAME.PUSHER_ID], true); // pusher unload reset need notify
    // Reset device flags to `undefined` (not `false`) so the next call
    // cycle treats them as "not set" and applies the default (opened)
    // instead of mistakenly interpreting the leftover value as a user
    // opt-out.
    TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO, {
      ...TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO),
      isCameraOpened: undefined,
      isMicrophoneOpened: undefined,
    });
    TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO_EXCLUDE_VOLUMN, {
      ...TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO_EXCLUDE_VOLUMN),
      isCameraOpened: undefined,
      isMicrophoneOpened: undefined,
    });
    TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST, []);
    TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_EXCLUDE_VOLUMN_LIST, []);
    TUIStore.update(StoreName.CALL, NAME.CAMERA_POSITION, CameraPosition.FRONT);
    TUIStore.update(StoreName.CALL, NAME.CALL_INFO, {});
  }
  // =========================【监听 TUIStore 中的状态及处理】=========================
  // Bridge callRole changes to the ring plugin via the uni event bus.
  // Emitted before callStatus (updateStore notifies callRole first), so the
  // plugin already knows the role when callStatus becomes 'calling'.
  private _handleCallRoleChange = (value: CallRole) => {
    // @ts-ignore uni is a uniapp runtime global
    uni.$emit(CALL_RING_EVENTS.ROLE_CHANGED, value);
  };
  private _handleCallStatusChange = async (value: CallStatus) => {
    // Bridge callStatus changes to the ring plugin: 'calling' starts the ring,
    // any other status ('connected' / 'idle') stops it.
    // @ts-ignore uni is a uniapp runtime global
    uni.$emit(CALL_RING_EVENTS.STATUS_CHANGED, value);
    try {
      if (value === CallStatus.CALLING) {
      } else {
        // 状态变更通知
        if (value === CallStatus.CONNECTED) {
          const isGroup = TUIStore.getData(StoreName.CALL, NAME.IS_GROUP);
          const callMediaType = TUIStore.getData(StoreName.CALL, NAME.CALL_MEDIA_TYPE);
          const remoteUserInfoList = TUIStore.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST);
          TUIStore.update(StoreName.CALL, NAME.CALL_TIPS, '');
          if (!isGroup && callMediaType === CallMediaType.VIDEO) {
            this.switchScreen(remoteUserInfoList[0].domId);
          }
        }
      }
    } catch (error) {
      console.warn(`${NAME.PREFIX}handleCallStatusChange, ${error}.`);
    }
  };
  private _watchTUIStore() {
    TUIStore?.watch(StoreName.CALL, {
      [NAME.CALL_ROLE]: this._handleCallRoleChange,
      [NAME.CALL_STATUS]: this._handleCallStatusChange,
    });
  }
  private _unwatchTUIStore() {
    TUIStore?.unwatch(StoreName.CALL, {
      [NAME.CALL_ROLE]: this._handleCallRoleChange,
      [NAME.CALL_STATUS]: this._handleCallStatusChange,
    });
  }
  // =========================【set、get methods】=========================
  public getTim() {
    if (this._tim) return this._tim;
    if (!this._tuiCallEngine) {
      console.warn(`${NAME.PREFIX}getTim warning: _tuiCallEngine Instance is not available.`);
      return null;
    }
    return this._tuiCallEngine?.tim || this._tuiCallEngine?.getTim(); // mini support getTim interface
  }
  public setIsFromChat(isFromChat: boolean) {
    this._isFromChat = isFromChat;
  }
}
