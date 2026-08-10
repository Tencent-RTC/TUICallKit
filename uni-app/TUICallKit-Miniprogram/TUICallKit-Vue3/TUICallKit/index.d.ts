// Type definitions for @trtc/calls-uikit-wx-uniapp-engine
import { Ref, ComputedRef } from 'vue';
import { CallMediaType, AudioPlayBackDevice } from '@trtc/call-engine-lite-wx';

// ────── Constants ──────
export declare enum CallStatus {
  IDLE = 'idle',
  CALLING = 'calling',
  CONNECTED = 'connected',
}

export declare enum CallRole {
  UNKNOWN = 'unknown',
  CALLEE = 'callee',
  CALLER = 'caller',
}

export declare enum DeviceStatus {
  UNKNOWN = 'unknown',
  ON = 'on',
  OFF = 'off',
}

export declare enum FeatureButton {
  Camera = 'camera',
  Microphone = 'microphone',
  SwitchCamera = 'switchCamera',
  InviteUser = 'inviteUser',
}

export declare enum LayoutMode {
  LocalInLargeView = 'local',
  RemoteInLargeView = 'remote',
}

export declare const EVENT: {
  LOGIN_SUCCESS: string;
  LOGOUT_SUCCESS: string;
  ACTIVE_CONV_UPDATED: string;
  SEND_MESSAGE: string;
  ON_CALLS: string;
};

export declare const UI_PLATFORM: {
  UNI_MINI_APP: string;
};

export declare enum MessageType {
  MSG_TEXT = 'TIMTextElem',
  MSG_CUSTOM = 'TIMCustomElem',
}

// ────── Types ──────
export interface LoginParams {
  userId: string;
  userSig: string;
  sdkAppId: number;
  [key: string]: any;
}

export interface LoginUserInfo {
  userId: string;
  userName: string;
  avatarUrl: string;
  customInfo?: Record<string, any>;
}

export interface SetSelfInfoParams {
  userName?: string;
  avatarUrl?: string;
  customInfo?: Record<string, any>;
}

export interface ICallParticipant {
  id: string;
  name?: string;
  avatarUrl?: string;
  remark?: string;
  isMicrophoneOpened?: boolean;
  isCameraOpened?: boolean;
  volume?: number;
}

export interface ICallParticipantInfo {
  selfInfo: Partial<ICallParticipant> & { status?: CallStatus; role?: CallRole };
  callerInfo: Partial<ICallParticipant>;
  allParticipants: ICallParticipant[];
  speakerVolumes: any[];
  networkQualities: any[];
  isGroup: boolean;
}

// ────── Composable Hooks ──────
export declare function useCallListState(): {
  inviterId: Ref<string>;
  mediaType: Ref<CallMediaType>;
  duration: Ref<number>;
  pusherId: Ref<string>;
  calls: (params: any) => Promise<void>;
  accept: () => Promise<void>;
  reject: () => Promise<void>;
  hangup: () => Promise<void>;
  inviteUser: (params: any) => Promise<void>;
  setSoundMode: (type?: any) => Promise<void>;
  setSelfInfo: (params: any) => Promise<void>;
};

export declare function useCallParticipantState(): {
  callParticipantInfo: Ref<ICallParticipantInfo>;
};

export declare function useDeviceState(): {
  microphoneStatus: Ref<DeviceStatus>;
  cameraStatus: Ref<DeviceStatus>;
  isFrontCamera: Ref<boolean>;
  currentAudioRoute: Ref<AudioPlayBackDevice>;
  openLocalMicrophone: () => Promise<void>;
  closeLocalMicrophone: () => Promise<void>;
  openLocalCamera: () => Promise<void>;
  closeLocalCamera: () => Promise<void>;
  switchCamera: () => Promise<void>;
  setAudioRoute: () => Promise<void>;
};

export declare function useUIConfigState(): {
  hiddenButtons: ComputedRef<Set<FeatureButton>>;
  layoutMode: ComputedRef<LayoutMode>;
  viewBackground: ComputedRef<Record<string, string>>;
};

export declare function useLoginState(): {
  loginUserInfo: Ref<LoginUserInfo | null>;
  login: (options: LoginParams) => Promise<void>;
  logout: () => Promise<void>;
  setSelfInfo: (options: SetSelfInfoParams) => Promise<void>;
};

// ────── Service Exports ──────
export declare const TUIStore: any;
export declare const StoreName: any;
export declare const TUICallKitAPI: any;
export declare const NAME: Record<string, string>;
export declare function t(args: any): string;
export declare const uiDesign: any;

// ────── Utilities ──────
export declare function formatDuration(seconds: number): string;
export declare function removeC2C(str: string): string;
export declare function isJSON(str: string): boolean;
export declare function JSONToObject(str: string): any;

export interface PermissionCheckResult {
  granted: boolean;
  tip: string;
  level: 'granted' | 'mini-program' | 'system';
}
export declare function checkMicrophonePermission(): Promise<PermissionCheckResult>;
export declare function checkCameraPermission(): Promise<PermissionCheckResult>;
export declare function handlePermissionDenied(result: PermissionCheckResult): Promise<{ confirm: boolean }>;

// ────── TUIBridge ──────
export declare const TUIBridge: {
  registerEvent(eventName: string, notification: any): void;
  unregisterEvent(eventName: string, notification: any): void;
  notifyEvent(options: { eventName: string; params?: Record<string, any> }): void;
};
