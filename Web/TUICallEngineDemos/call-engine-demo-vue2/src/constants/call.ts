export enum MediaType {
  'UNKNOWN' = 0,
  'AUDIO' = 1,
  'VIDEO' = 2,
}
export enum CallType {
  SINGLE_CALL = 0,
  GROUP_CALL = 1,
}
export enum CallTypeDesc {
  SINGLE_CALL = 'single',
  GROUP_CALL = 'group',
}
/**
 * 通话状态枚举定义
 * @param IDLE 空闲
 * @param CALLING 呼叫中
 * @param CONNECTED 通话中
 */
export enum CallState {
  /** 空闲 */
  IDLE,
  /** 呼叫中 */
  CALLING,
  /** 通话中 */
  CONNECTED,
}
export const DefaultAvatarUrl = 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/trtc/call/test/call-engine-demo/assets/defaultavatar.png';
export const DefaultSdkAppId = 0;
export const DefaultSecretKey = '';
export enum ObjectFit {
  Contain = 'contain',
  Cover = 'cover',
  Fill = 'fill'
}
export type TDeviceType = 'video' | 'audio';
export type TPlayOptions = {
  userID?: string;
  objectFit: ObjectFit;
  muted?: boolean;
  mirror?: boolean;
};
export type TMediaDevice = 'camera' | 'microphones';
export enum VideoResolution {
  '480p' = '480p',
  '720p' = '720p',
  '1080p' = '1080p',
}
