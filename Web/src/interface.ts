export interface TUIInitParam {
  SDKAppID: number;
  tim?: any;
  userID: string;
  userSig: string;
}

export interface TUICallParam {
  userID: string;
  type: number;
}

export  interface TUIGroupCallParam {
  userIDList: Array<string>;
  type: number;
  groupID: string;
}

export interface RemoteUser {
  userID: string;
  isEntered: boolean;
  microphone?: boolean;
  camera?: boolean;
  volume?: number;
}

export interface CallbackParam {
  beforeCalling?: Function;
  afterCalling?: Function;
}