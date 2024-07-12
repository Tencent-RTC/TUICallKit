import React from "react";

export interface IDeviceInfo {
  deviceId: string;
  getCapabilities?: () => void ;
  groupId?: string;
  kind: string;
  label: string;
  value?: string;
}

export interface ITRTCEvent {
  setVolume: React.Dispatch<number>;
  getDeviceList: () => void;
}

export enum DEVICE_TYPE {
  CAMERA,
  MIC,
  SPEAKER,
}

export type IVolumeArrItem = [number, number, Array<number>];

export interface IRenderVolumeBarProps {
  volume: number;
}

export interface IOperateDevicePanel {
  isShowPanel?: boolean,
  setIsShowPanel: React.Dispatch<boolean>;
}
export interface IDeviceCheckPanelProps {
  operateDevicePanel: IOperateDevicePanel;
}

export interface ICardProps {
  title?: JSX.Element;
  body?: JSX.Element;
  className?: string;
}

export interface IUserInfo {
  userID: string;
  SDKAppID: number;
  SecretKey: string;
  userSig: string;
  isLogin: boolean;
  currentPage: string;
  isCall: boolean;
}

export interface IUserInfoContext {
  userInfo: IUserInfo;
  setUserInfo: React.Dispatch<IUserInfo>;
}

export interface IContentProps {
  children?: JSX.Element;
}
