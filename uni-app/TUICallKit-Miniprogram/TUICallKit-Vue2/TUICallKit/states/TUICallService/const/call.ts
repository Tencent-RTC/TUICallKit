import { CallMediaType } from "@trtc/call-engine-lite-wx";

/**
 * @property {String} call 1v1 通话 + 群组通话
 * @property {String} CUSTOM 自定义 Store
*/
export enum StoreName {
  CALL = 'call',
  CUSTOM = 'custom'
}
/**
 * @property {String} caller 主叫
 * @property {String} callee 被叫
*/
export enum CallRole {
  UNKNOWN = 'unknown',
  CALLEE = 'callee',
  CALLER = 'caller',
}
/**
 * @property {String} idle 空闲
 * @property {String} calling 呼叫等待中
 * @property {String} connected 通话中
*/
export enum CallStatus {
  IDLE = 'idle',
  CALLING = 'calling',
  CONNECTED = 'connected',
}
// 支持的语言
export enum LanguageType {
  EN = 'en',
  'ZH-CN' = 'zh-cn',
  JA_JP = 'ja_JP',
}

export enum FeatureButton {
  Camera = 'camera',
  Microphone = 'microphone',
  SwitchCamera = 'switchCamera',
  InviteUser = 'inviteUser',
}

export enum ButtonState {
  Open = 'open',
  Close = 'close',
}

// Map of userId -> background image url. userId '*' means all remote users.
export interface IViewBackgroundImage {
  [userId: string]: string,
}

export enum ViewName {
  LOCAL = 'local',
  REMOTE = 'remote',
}

// Call view layout mode, aligned with the TUICallKit interface doc.
export enum LayoutMode {
  LocalInLargeView = ViewName.LOCAL,
  RemoteInLargeView = ViewName.REMOTE,
}

// Custom UI config persisted in the store and consumed by the call views.
export interface ICustomUIConfig {
  button?: {
    [buttonName in FeatureButton]?: {
      show?: boolean;
      state?: ButtonState;
    };
  }
  viewBackground?: IViewBackgroundImage;
  layoutMode?: LayoutMode,
}

/**
 * Event names published on the uni global event bus for the ring plugin
 * (@trtc/call-ring-wx). The plugin listens on the same channels; neither side
 * imports from the other — the event name string is the only contract.
 *
 * Payloads reuse the CallStatus / CallRole enum string values directly
 * ('calling' / 'connected' / 'idle' and 'caller' / 'callee').
 */
export const CALL_RING_EVENTS = {
  /** Fired when callStatus changes. Payload: CallStatus enum value. */
  STATUS_CHANGED: 'callRing:statusChanged',
  /** Fired when callRole changes. Payload: CallRole enum value. */
  ROLE_CHANGED: 'callRing:roleChanged',
  /** Fired from App.onShow so the ring plugin can rebuild+resume playback. */
  APP_SHOW: 'callRing:appShow',
  /** Fired from App.onHide so the ring plugin can mark background state. */
  APP_HIDE: 'callRing:appHide',
} as const;

