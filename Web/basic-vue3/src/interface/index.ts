
export enum DEVICE_TYPE {
  CAMERA,
  MIC,
  SPEAKER,
}

// ============== context ==============
export interface IUserInfo {
  userID: string;
  SDKAppID: number;
  SecretKey: string;
  userSig: string;
  isLogin: boolean;
  currentPage: string;
  isCall: boolean;
}

export interface IDeviceInfo {
  deviceId: string;
  getCapabilities?: () => void ;
  groupId?: string;
  kind: string;
  label: string;
  value?: string;
}

interface IAudioVolumeArray {
  userId?: string;
  volume: number;
}
export interface IAudioVolumeEvent {
  result: IAudioVolumeArray[]
}

export type IVolumeArrItem = [number, number, Array<number>];
export interface IRenderVolumeBarProps {
  volume: number;
}

export enum LanguageType {
  en = 'en',
  'zh-CN' = 'zh-cn',
  ja = "ja_JP",
}

// ============== component/groupCall ==============
export interface IMemberList {
  userID: string;
}

// ============== utils ==============
export interface IUrlPrams {
  SDKAppID: number;
  SecretKey: string;
}

export interface IDeviceInfo {
  deviceId: string;
  getCapabilities?: () => void ;
  groupId?: string;
  kind: string;
  label: string;
  value?: string;
}

