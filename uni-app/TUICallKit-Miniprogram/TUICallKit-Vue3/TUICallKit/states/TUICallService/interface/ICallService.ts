import { CallMediaType } from '@trtc/call-engine-lite-wx';
import { CallStatus, CallRole } from '../const/index';

type SDKAppID = { SDKAppID: number; } | { sdkAppID: number; };
export interface IInitParamsBase {
  userID: string;
  userSig: string;
  tim?: any;
  isFromChat?: boolean;
  component?: number;
  scene?: string;
}
export type IInitParams = IInitParamsBase & SDKAppID;

// userInfo interface
export interface IUserInfo {
  userId: string;
  nick?: string;
  avatar?: string;
  remark?: string;
  displayUserInfo?: string; // 远端用户信息展示: remark -> nick -> userId, 简化 UI 组件; 本地用户信息展示: nick -> userId
  isMicrophoneOpened?: boolean; // 用来设置: 麦克风是否打开
  isCameraOpened?: boolean; // 用来设置: 摄像头是否打开
  volume?: number;
  isEnter?: boolean; // 远端用户, 用来控制预览远端是否显示 loading 效果; 本地用户, 用来控制 "呼叫"、"接通" 接通后显示的 loading 效果
  domId?: string; // 播放流 dom 节点, localUserInfo 的 domId = 'localVideo'; remoteUserInfo 的 domId 就是 userId
}
export interface ISelfInfoParams {
  nickName: string;
  avatar: string;
}
export interface INetWorkQuality {
  userId: string;
  quality: number
}

export interface ICallInfo {
  callId?: string;
  roomId?: string;
  inviterId?: string;
  inviteeIds?: Array<string>;
  chatGroupId?: string;
  mediaType?: CallMediaType;
  result?: string;
  startTime?: number;
  duration?: number;
}
