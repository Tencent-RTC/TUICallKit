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

/**
 * contain 优先保证视频内容全部显示。视频尺寸等比缩放，直至视频窗口的一边与视窗边框对齐。如果视频尺寸与显示视窗尺寸不一致，在保持长宽比的前提下，将视频进行缩放后填满视窗，缩放后的视频四周会有一圈黑边。
 * cover 优先保证视窗被填满。视频尺寸等比缩放，直至整个视窗被视频填满。如果视频长宽与显示窗口不同，则视频流会按照显示视窗的比例进行周边裁剪或图像拉伸后填满视窗。
 * fill 保证视窗被填满的同时保证视频内容全部显示，但是不保证视频尺寸比例不变。视频的宽高会被拉伸至和视窗尺寸一致。
 * 默认值是 cover
*/
export const enum VideoDisplayMode {
  CONTAIN = "contain",
  COVER = "cover",
  FILL = "fill",
}

/**
 * 默认值是 RESOLUTION_480P
*/
export const enum VideoResolution {
  RESOLUTION_480P = "480p",
  RESOLUTION_720P = "720p",
  RESOLUTION_1080P = "1080p",
}