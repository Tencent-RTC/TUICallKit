/* eslint-disable @typescript-eslint/no-explicit-any */
export interface TUIInitParam {
  SDKAppID: number;
  tim?: any;
  userID: string;
  userSig: string;
  assetsPath?: string;
}

export interface offlinePushInfoType {
  title?: string;
  description?: string;
  androidOPPOChannelID?: string;
  extension?: string;
}

export interface TUICallParam {
  userID: string;
  type: number;
  timeout?: number;
  offlinePushInfo?: offlinePushInfoType;
}

export interface TUIGroupCallParam {
  userIDList: Array<string>;
  type: number;
  groupID: string;
  timeout?: number;
  offlinePushInfo?: offlinePushInfoType;
  roomID?: number
}

export interface RemoteUser {
  userID: string;
  isEntered: boolean;
  isReadyRender: boolean;
  microphone?: boolean;
  camera?: boolean;
  nick?: string;
  [key: string]: string | boolean | undefined;
}

export interface CallbackParam {
  beforeCalling?: (...args: any[]) => void;
  afterCalling?: (...args: any[]) => void;
  onMinimized?: (...args: any[]) => void;
  onMessageSentByMe?: (...args: any[]) => void;
}

export interface statusChangedReturnType {
  oldStatus: string;
  newStatus: string;
}