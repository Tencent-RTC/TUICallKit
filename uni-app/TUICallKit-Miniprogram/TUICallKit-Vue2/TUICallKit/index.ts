// Main entry point for @trtc/calls-uikit-wx-uniapp-engine.
// Exports composable hooks, login state, constants, types, and utilities.
// Supports both Vue 2 (with @vue/composition-api + unplugin-vue2-script-setup)
// and Vue 3 via the adapter/vue-demi compatibility layer.

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

// Vue version adapter — exposes `vueVersion` (2 or 3) for runtime detection.
export { vueVersion } from './adapter/vue-demi';

