// Main entry point for @trtc/calls-uikit-wx-uniapp-engine.
// Exports composable hooks, login state, constants, types, and utilities.

export { useCallListState } from './states/CallListState';
export { useCallParticipantState } from './states/CallParticipantState';
export type { ICallParticipant, ICallParticipantInfo } from './states/CallParticipantState';
export { useDeviceState } from './states/DeviceState';
export { useUIConfigState, FeatureButton, LayoutMode } from './states/UIConfigState';
export { useLoginState } from './states/LoginState';

// Re-export TUICallService internals for advanced usage.
export {
  TUIStore,
  StoreName,
  TUICallKitAPI,
  NAME,
  CallStatus,
  CallRole,
  t,
  uiDesign,
} from './states/TUICallService/index';

// Re-export constants.
export { DeviceStatus } from './constants/call';
export { UI_PLATFORM, MessageType } from './constants/chat';
export { EVENT } from './constants/event';

// Re-export types.
export type { LoginParams, LoginUserInfo, SetSelfInfoParams } from './types/login';

// Re-export utilities.
export { formatDuration, removeC2C, isJSON, JSONToObject } from './utils/index';
export { checkMicrophonePermission, checkCameraPermission, handlePermissionDenied } from './utils/permission';

// TUIBridge singleton (event bus for Chat integration).
export { TUIBridge } from './TUIBridge/index';

