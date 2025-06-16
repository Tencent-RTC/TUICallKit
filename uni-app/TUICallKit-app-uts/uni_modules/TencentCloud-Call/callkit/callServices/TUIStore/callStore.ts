import {
  CallStatus,
  CallRole,
  MediaType,
  NAME,
  AudioPlaybackDevice,
} from "../const/index";
import { deepClone, getLanguage } from "../utils/index";
import { ICallStore } from "../interface/ICallStore";
import { t } from "../locales/index";

export default class CallStore {
  public defaultStore: ICallStore = {
    callStatus: CallStatus.IDLE,
    callRole: CallRole.UNKNOWN,
    mediaType: MediaType.UNKNOWN,
    localUserInfo: "",
    remoteUserInfoList: [],
    callerUserInfo: "",
    callDuration: "00:00:00",
    callTips: "",
    language: getLanguage(),
    chatGroupID: "",
    translate: t,
    enableFloatWindow: false,
    isGroupCall: false,
    isLocalMicOpen: true,
    isLocalCameraOpen: true,
    isEarPhone: false,
    currentSpeakerStatus: undefined,
    isLocalBlurOpen: false,
    currentCameraIsOpen: undefined,
  };

  public store: ICallStore = deepClone(this.defaultStore);
  public prevStore: ICallStore = deepClone(this.defaultStore);

  public update(key: keyof ICallStore, data: any): void {
    switch (key) {
      case NAME.CALL_TIPS:
      case NAME.CALL_STATUS:
        const preData = this.getData(key);
        (this.prevStore[key] as any) = preData;
      default:
        // resolve "Type 'any' is not assignable to type 'never'.ts", ref: https://github.com/microsoft/TypeScript/issues/31663
        (this.store[key] as any) = data as any;
    }
  }

  public getPrevData(key: string | undefined): any {
    if (!key) return this.prevStore;
    return this.prevStore[key as keyof ICallStore];
  }

  public getData(key: string | undefined): any {
    if (!key) return this.store;
    return this.store[key as keyof ICallStore];
  }

  public reset(keyList: Array<string> = []) {
    if (keyList.length === 0) {
      keyList = Object.keys(this.store);
    }
    const resetToDefault = keyList.reduce(
      (acc, key) => ({
        ...acc,
        [key]: this.defaultStore[key as keyof ICallStore],
      }),
      {}
    );
    this.store = {
      ...this.defaultStore,
      ...this.store,
      ...resetToDefault,
    };
  }
}
