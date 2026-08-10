export * from './call';
export * from './error';

export const CALL_DATA_KEY: any = {
  CALL_STATUS: 'callStatus',
  CALL_ROLE: 'callRole',
  CALL_MEDIA_TYPE: 'callMediaType',
  LOCAL_USER_INFO: 'localUserInfo',
  LOCAL_USER_INFO_EXCLUDE_VOLUMN: 'localUserInfoExcludeVolume',
  REMOTE_USER_INFO_LIST: 'remoteUserInfoList',
  REMOTE_USER_INFO_EXCLUDE_VOLUMN_LIST: 'remoteUserInfoExcludeVolumeList',
  CALLER_USER_INFO: 'callerUserInfo',
  IS_GROUP: 'isGroup',
  DURATION: 'duration',
  CALL_TIPS: 'callTips',
  TOAST_INFO: 'toastInfo',
  IS_MINIMIZED: 'isMinimized',
  ENABLE_FLOAT_WINDOW: 'enableFloatWindow',
  BIG_SCREEN_USER_ID: 'bigScreenUserId',
  LANGUAGE: 'language',
  IS_CLICKABLE: 'isClickable',
  DISPLAY_MODE: 'displayMode',
  IS_EAR_PHONE: 'isEarPhone',
  SHOW_PERMISSION_TIP: 'SHOW_PERMISSION_TIP',
  NETWORK_STATUS: 'NetWorkStatus',
  GROUP_ID: 'groupID',
  CALL_INFO: 'callInfo',
  PUSHER_ID: 'pusherId',
};

export const PUSHER_ID = {
  INITIAL_PUSHER: 'initialPusher',
  NEW_PUSHER: 'newPusher'
};

export const CHAT_DATA_KEY: any = {
  "INNER_ATTR_KIT_INFO": "inner_attr_kit_info",
};

export const NAME = {
  PREFIX: '【CallService】',
  AUDIO: 'audio',
  VIDEO: 'video',
  LOCAL_VIDEO: 'localVideo',
  ERROR: 'error',
  TIMEOUT: 'timeout',
  BOOLEAN: 'boolean',
  STRING: 'string',
  NUMBER: 'number',
  OBJECT: 'object',
  FUNCTION: 'function',
  UNDEFINED: "undefined",
  UNKNOWN: 'unknown',
  ALL: 'all',
  MYSELF: 'myself',
  CAMERA_POSITION: 'cameraPosition',
  CUSTOM_UI_CONFIG: 'customUIConfig',
  ...PUSHER_ID,
  ...CALL_DATA_KEY,
  ...CHAT_DATA_KEY,
};

export const AudioCallIcon = 'https://web.sdk.qcloud.com/component/TUIKit/assets/call.png';
export const VideoCallIcon = 'https://web.sdk.qcloud.com/component/TUIKit/assets/call-video-reverse.svg';
export const MAX_NUMBER_ROOM_ID = 2147483647;
export const DEFAULT_BLUR_LEVEL = 3;
export const NETWORK_QUALITY_THRESHOLD = 4;
export enum PLATFORM {
  // eslint-disable-next-line no-unused-vars
  MAC = 'mac',
  // eslint-disable-next-line no-unused-vars
  WIN = 'win',
};
export enum COMPONENT {
  // eslint-disable-next-line no-unused-vars
  TUI_CALL_KIT = 14,
  // eslint-disable-next-line no-unused-vars
  TIM_CALL_KIT = 15,
};

export const EVENT = {
  LOGIN_SUCCESS: 'LoginState.LoginSuccess',
  LOGOUT_SUCCESS: 'logout_success',
  ACTIVE_CONV_UPDATED: 'active_conv_updated',
  SEND_MESSAGE: 'send_message',
  ON_CALLS: 'On_Calls',
}