import {
  CallEngine,
  CallsOptions,
  LoginOptions,
  InviteUserOptions,
  JoinOptions,
  Camera,
  AudioPlaybackDevice,
  CallbackOptions,
  SelfInfoOptions,
  TUICallEvent,
} from "@/uni_modules/TencentCloud-Call";
import {
  MediaType,
  CallRole,
  CallStatus,
  NAME,
  StoreName,
  CALL_DATA_KEY,
  CALL_PAGE_PATH,
} from "../const/index";
import {
  formatTime,
  performanceNow,
  Timer,
  paramValidate,
  VALIDATE_PARAMS,
  toast,
} from "../utils/index";
import { t, CallTips } from "../locales/index";
class CallService {
  static instance = null;
  public callEngine: any;
  private _timerId: number = -1;
  private _startTimeStamp: number = performanceNow();
  private _isInForeground: boolean = false;

  constructor() {
    console.log(`${NAME.PREFIX} constructor`);
    this.callEngine = new CallEngine();
    this._addListener();

    uni.onAppHide(() => {
      console.log(`${NAME.PREFIX} onAppHide`);
      this._isInForeground = false;
    });
    uni.onAppShow(() => {
      console.log(`${NAME.PREFIX} onAppShow`);
      this._isInForeground = true;
    });
  }

  static getInstance() {
    if (!CallService.instance) {
      CallService.instance = new CallService();
    }
    return CallService.instance;
  }

  private _addListener(): void {
    console.log(`${NAME.PREFIX} _addListener`);

    this.callEngine.on("onError", (res) => {
      console.error(`${NAME.PREFIX} onError, data: ${JSON.stringify(res)}`);
    });
    this.callEngine.on("onCallReceived", (res) => {
      console.log(
        `${NAME.PREFIX} onCallReceived, data: ${JSON.stringify(res)}`
      );
      !this._isInForeground && this.bringAppToForeground();
      this._hasPermission(res?.mediaType);
      const callTipsKey =
        res?.mediaType == MediaType.AUDIO
          ? CallTips.CALLEE_CALLING_AUDIO_MSG
          : CallTips.CALLEE_CALLING_VIDEO_MSG;
      uni.$TUIStore.update(
        StoreName.CALL,
        NAME.IS_GROUP_CALL,
        res.calleeIDList?.length > 1
      );
      let updateStoreParams = {
        [NAME.CALL_ROLE]: CallRole.CALLEE,
        [NAME.CALL_STATUS]: CallStatus.CALLING,
        [NAME.MEDIA_TYPE]: res?.mediaType,
        [NAME.CALL_TIPS]: t(callTipsKey),
        [NAME.CALLER_USER_INFO]: res?.callerID,
        [NAME.CHAT_GROUP_ID]: res?.info?.chatGroupId,
      };
      uni.$TUIStore.updateStore(updateStoreParams, StoreName.CALL);
      this._navigateToCallPage();
    });

    this.callEngine.on("onCallBegin", (res) => {
      console.log(`${NAME.PREFIX} onCallBegin, data: ${JSON.stringify(res)}`);
      const callStatus = uni.$TUIStore.getData(
        StoreName.CALL,
        NAME.CALL_STATUS
      );
      if (callStatus === CallStatus.CALLING) {
        uni.$TUIStore.update(
          StoreName.CALL,
          NAME.CALL_STATUS,
          CallStatus.CONNECTED
        );
        uni.$TUIStore.update(StoreName.CALL, NAME.CALL_TIPS, "");
        this._startTimer();
      }
    });

    this.callEngine.on("onCallEnd", (res) => {
      console.log(`${NAME.PREFIX} onCallEnd, data: ${JSON.stringify(res)}`);
      this._navigateBackCallPage();
      this.stopFloatWindow();
      this._resetCallStore();
    });

    this.callEngine.on("onCallNotConnected", (res) => {
      console.log(
        `${NAME.PREFIX} onCallNotConnected, data: ${JSON.stringify(res)}`
      );
      this._navigateBackCallPage();
      this.stopFloatWindow();
      this._resetCallStore();
    });

    this.callEngine.on("onUserReject", (res) => {
      console.log(`${NAME.PREFIX} onUserReject, data: ${JSON.stringify(res)}`);
      const toastInfo = {
        key: CallTips.OTHER_SIDE_REJECT_CALL,
      };
      toast.show(t(toastInfo));
    });

    this.callEngine.on("onUserNoResponse", (res) => {
      console.log(
        `${NAME.PREFIX} onUserNoResponse, data: ${JSON.stringify(res)}`
      );
      const toastInfo = {
        key: CallTips.CALL_TIMEOUT,
      };
      toast.show(t(toastInfo));
    });

    this.callEngine.on("onUserLineBusy", (res) => {
      console.log(
        `${NAME.PREFIX} onUserLineBusy, data: ${JSON.stringify(res)}`
      );
      const toastInfo = {
        key: CallTips.OTHER_SIDE_LINE_BUSY,
      };
      toast.show(t(toastInfo));
    });

    this.callEngine.on("onUserLeave", (res) => {
      console.log(`${NAME.PREFIX} onUserLeave, data: ${JSON.stringify(res)}`);
      const toastInfo = {
        key: CallTips.END_CALL,
        options: {
          userList: res.userID,
        },
      };
      toast.show(t(toastInfo));
    });

    this.callEngine.on("onKickedOffline", (res) => {
      console.log(
        `${NAME.PREFIX} onKickedOffline, data: ${JSON.stringify(res)}`
      );
      uni.$TUIStore.update(StoreName.CALL, NAME.CALL_TIPS, CallTips.KICK_OUT);
      this._resetCallStore();
      this._navigateBackCallPage();
    });

    this.callEngine.on("onUserSigExpired", (res) => {
      console.log(
        `${NAME.PREFIX} onUserSigExpired, data: ${JSON.stringify(res)}`
      );
      this._resetCallStore();
    });

    this.callEngine.on("onFloatWindowClick", (res) => {
      console.log(
        `${NAME.PREFIX} onFloatWindowClick, data: ${JSON.stringify(res)}`
      );
      this.stopFloatWindow();
      this._navigateToCallPage();
    });
  }

  private _removeListenr(): void {
    this.callEngine.off("onError");
    this.callEngine.off("onCallReceived");
    this.callEngine.off("onCallBegin");
    this.callEngine.off("onCallEnd");
    this.callEngine.off("onCallNotConnected");
    this.callEngine.off("onUserReject");
    this.callEngine.off("onUserNoResponse");
    this.callEngine.off("onUserLineBusy");
    this.callEngine.off("onUserLeave");
    this.callEngine.off("onKickedOffline");
    this.callEngine.off("onUserSigExpired");
    this.callEngine.off("onFloatWindowClick");
  }

  @paramValidate(VALIDATE_PARAMS.login)
  public login(options: LoginOptions): void {
    console.log(`${NAME.PREFIX} login, data: ${JSON.stringify(options)}`);
    const params = {
      SDKAppID: options.SDKAppID,
      userID: options.userID,
      userSig: options.userSig,
      success: () => {
        options?.success?.();
        uni.$TUIStore.update(
          StoreName.CALL,
          NAME.LOCAL_USER_INFO,
          options.userID
        );
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };
    this.callEngine.login(params);
  }

  public logout(options: CallbackOptions): void {
    const params = {
      success: () => {
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };
    this.callEngine.logout(params);
    this._resetCallStore();
  }

  @paramValidate(VALIDATE_PARAMS.calls)
  public calls(options: CallsOptions): void {
    console.log(`${NAME.PREFIX} calls, data: ${JSON.stringify(options)}`);
    const userIDList = options.userIDList.filter(
      (item, index) =>
        item != null &&
        item !== "" &&
        options.userIDList.indexOf(item) === index
    );
    uni.$TUIStore.update(
      StoreName.CALL,
      NAME.IS_GROUP_CALL,
      userIDList?.length > 1
    );
    const params: CallsOptions = {
      userIDList: userIDList,
      mediaType: options.mediaType,
      callParams: options.callParams,
      success: () => {
        this._hasPermission(options.mediaType);
        let callTips = CallTips.CALLER_CALLING_MSG;
        if (options?.callParams?.chatGroupID || userIDList.length > 1) {
          callTips = "";
        }
        let updateStoreParams = {
          [NAME.CALL_ROLE]: CallRole.CALLER,
          [NAME.CALL_STATUS]: CallStatus.CALLING,
          [NAME.MEDIA_TYPE]: options?.mediaType,
          [NAME.CALL_TIPS]: t(callTips),
          [NAME.CHAT_GROUP_ID]: options?.info?.chatGroupID,
        };
        uni.$TUIStore.updateStore(updateStoreParams, StoreName.CALL);
        this._navigateToCallPage();
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
        this.handleExceptionExit();
      },
    };

    this.callEngine.calls(params);
  }

  public inviteUser(options: InviteUserOptions): void {
    console.log(`${NAME.PREFIX} inviteUser, data: ${JSON.stringify(options)}`);
    const params: InviteUserOptions = {
      userIDList: options.userIDList,
      success: () => {
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };

    this.callEngine.inviteUser(params);
  }

  public join(options: JoinOptions): void {
    console.log(`${NAME.PREFIX} join, data: ${JSON.stringify(options)}`);
    const params: JoinOptions = {
      callID: options.callID,
      success: () => {
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };
    this.callEngine.join(params);
  }

  public accept(options?: CallbackOptions): void {
    console.log(`${NAME.PREFIX} accept`);
    const params: CallbackOptions = {
      success: () => {
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };
    this.callEngine.accept(params);
  }

  public reject(options?: CallbackOptions): void {
    console.log(`${NAME.PREFIX} reject`);
    const params: CallbackOptions = {
      success: () => {
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };
    this.callEngine.reject(params);
  }

  public hangup(options?: CallbackOptions): void {
    console.log(`${NAME.PREFIX} hangup`);
    const params: CallbackOptions = {
      success: () => {
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };
    this.callEngine.hangup(params);
    this._navigateBackCallPage();
  }

  public openCamera(options?: CallbackOptions): void {
    console.log(`${NAME.PREFIX} openCamera`);
    const params: CallbackOptions = {
      success: () => {
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };
    this.callEngine.openCamera(params);
  }

  public closeCamera(): void {
    console.log(`${NAME.PREFIX} closeCamera`);
    this.callEngine.closeCamera();
  }

  public switchCamera(camera: Camera): void {
    console.log(`${NAME.PREFIX} switchCamera`);
    this.callEngine.switchCamera(camera);
  }

  public openMicrophone(options?: CallbackOptions): void {
    console.log(`${NAME.PREFIX} openMicrophone`);
    const params: CallbackOptions = {
      success: () => {
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };
    this.callEngine.openMicrophone(params);
  }

  public closeMicrophone(): void {
    this.callEngine.closeMicrophone();
  }

  public selectAudioPlaybackDevice(device: AudioPlaybackDevice): void {
    this.callEngine.selectAudioPlaybackDevice(device);
  }

  public setSelfInfo(options: SelfInfoOptions): void {
    this.callEngine.setSelfInfo(options);
  }

  public enableVirtualBackground(enable: boolean): void {
    this.callEngine.enableVirtualBackground(enable);
  }

  public setBlurBackground(level: number): void {
    this.callEngine.setBlurBackground(level);
  }

  public startFloatWindow(): void {
    console.log(`${NAME.PREFIX} startFloatWindow`);
    this.callEngine.startFloatWindow({
      success: () => {
        console.log(`${NAME.PREFIX} startFloatWindow success `);
        uni.$TUIStore.update(StoreName.CALL, NAME.ENABLE_FLOAT_WINDOW, true);
        this._navigateBackCallPage();
      },
      fail: () => {
        console.log(`${NAME.PREFIX} startFloatWindow fail`);
      },
    });
  }


  public stopFloatWindow(): void {
    console.log(`${NAME.PREFIX} stopFloatWindow`);
    this.callEngine.stopFloatWindow();
    uni.$TUIStore.update(StoreName.CALL, NAME.ENABLE_FLOAT_WINDOW, false);
  }

  public bringAppToForeground(): void {
    this.callEngine.bringAppToForeground();
  }

  public handleExceptionExit() {
    console.log(`${NAME.PREFIX} handleExceptionExit`);
    try {
      const callStatus = uni.$TUIStore.getData(
        StoreName.CALL,
        NAME.CALL_STATUS
      );
      const callRole = uni.$TUIStore.getData(StoreName.CALL, NAME.CALL_ROLE);
      if (callStatus === CallStatus.IDLE) return;
      this._navigateBackCallPage();
      if (callRole === CallRole.CALLER || callStatus === CallStatus.CONNECTED) {
        this.hangup();
      } else if (callRole === CallRole.CALLEE) {
        this.reject();
      }
      this._resetCallStore();
    } catch (error) {
      console.error(
        `${NAME.PREFIX} handleExceptionExit failed, error: ${error}.`
      );
    }
  }

  public getTUICallEngineInstance() {
    return this.callEngine;
  }

  private _navigateToCallPage() {
    const pagesList = getCurrentPages();
    const currentPage = pagesList[pagesList.length - 1].route;
    console.log(
      `${
        NAME.PREFIX
      } _navigateToCallPage, currentPage = ${currentPage}, ${currentPage.indexOf(
        "callkit/callPage"
      )}`
    );
    if (currentPage.indexOf("callkit/callPage") === -1) {
      uni.navigateTo({
        url: CALL_PAGE_PATH,
        animationType: "slide-in-top",
        success: (result) => {
          console.log(
            `${NAME.PREFIX} _navigateToCallPage success, ${JSON.stringify(
              result
            )}`
          );
        },
        fail: (result) => {
          console.log(
            `${NAME.PREFIX} _navigateToCallPage fail, ${JSON.stringify(result)}`
          );
        },
        complete: (result) => {
          console.log(
            `${NAME.PREFIX} _navigateToCallPage complete, ${JSON.stringify(
              result
            )}`
          );
        },
      });
    }
  }

  private _navigateBackCallPage(): void {
    const pagesList = getCurrentPages();
    const currentPage = pagesList[pagesList.length - 1].route;
    console.log(
      `${NAME.PREFIX} _navigateBackCallPage, currentPage = ${currentPage}`
    );
    if (currentPage.indexOf("callkit/callPage") > 0) {
      uni.navigateBack({
        success: (result) => {
          console.log(
            `${NAME.PREFIX} _navigateBackCallPage success, ${JSON.stringify(
              result
            )}`
          );
        },
        fail: (result) => {
          console.log(
            `${NAME.PREFIX} _navigateBackCallPage fail, ${JSON.stringify(
              result
            )}`
          );
        },
        complete: (result) => {
          console.log(
            `${NAME.PREFIX} _navigateBackCallPage complete, ${JSON.stringify(
              result
            )}`
          );
        },
      });
    }
  }

  private _updateCallDuration(): void {
    const callDurationNum = Math.round(
      (performanceNow() - this._startTimeStamp) / 1000
    );
    const callDurationStr = formatTime(callDurationNum);
    uni.$TUIStore.update(StoreName.CALL, NAME.CALL_DURATION, callDurationStr);
  }

  private _startTimer(): void {
    if (this._timerId === -1) {
      this._startTimeStamp = performanceNow();
      this._timerId = Timer.run(
        NAME.TIMEOUT,
        this._updateCallDuration.bind(this),
        { delay: 1000 }
      );
    }
  }

  private _stopTimer(): void {
    if (this._timerId !== -1) {
      Timer.clearTask(this._timerId);
      this._timerId = -1;
    }
  }

  private _hasPermission(type: number) {
    console.log(`${NAME.PREFIX} _hasPermission, data: ${type}`);
    this.callEngine.hasPermission({
      type,
      success: () => {
        console.log(`${NAME.PREFIX} _hasPermission success`);
      },
      fail: (errCode, errMsg) => {
        console.log(`${NAME.PREFIX} _hasPermission fail`);
        this.handleExceptionExit();
      },
    });
  }

  private _resetCallStore(): void {
    this._stopTimer();
    this.stopFloatWindow();
    let notResetOrNotifyKeys = Object.keys(CALL_DATA_KEY).filter((key) => {
      switch (CALL_DATA_KEY[key]) {
        case NAME.CALL_STATUS:
        case NAME.LANGUAGE:
        case NAME.LOCAL_USER_INFO: {
          return false;
        }
        default: {
          return true;
        }
      }
    });
    notResetOrNotifyKeys = notResetOrNotifyKeys.map(
      (key) => CALL_DATA_KEY[key]
    );
    uni.$TUIStore.reset(StoreName.CALL, notResetOrNotifyKeys);
    const callStatus = uni.$TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS);
    callStatus !== CallStatus.IDLE &&
      uni.$TUIStore.reset(StoreName.CALL, [NAME.CALL_STATUS], true);
    uni.$TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST, []);
  }
}

export const TUICallKit = CallService.getInstance();
