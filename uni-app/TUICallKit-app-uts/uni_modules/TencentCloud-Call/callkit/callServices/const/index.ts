export * from "./call";

export const CALL_DATA_KEY = {
  CALL_STATUS: "callStatus",
  CALL_ROLE: "callRole",
  MEDIA_TYPE: "mediaType",
  LOCAL_USER_INFO: "localUserInfo",
  REMOTE_USER_INFO_LIST: "remoteUserInfoList",
  CALLER_USER_INFO: "callerUserInfo",
  CALL_DURATION: "callDuration",
  CALL_TIPS: "callTips",
  LANGUAGE: "language",
  CHAT_GROUP_ID: "chatGroupID",
  ENABLE_FLOAT_WINDOW: "enableFloatWindow",
  IS_GROUP_CALL: "isGroupCall",
  IS_LOCAL_MIC_OPEN: "isLocalMicOpen",
  IS_LOCAL_CAMERA_OPEN: "isLocalCameraOpen",
  IS_EAR_PHONE: "isEarPhone",
  CURRENT_SPEAKER_STATUS: "currentSpeakerStatus",
  IS_LOCAL_BLUR_OPEN: "isLocalBlurOpen",
  CURRENT_CAMERA_IS_OPEN: "currentCameraIsOpen",
};
export const NAME = {
  PREFIX: "【CallKit】",
  AUDIO: "audio",
  VIDEO: "video",
  ERROR: "error",
  TIMEOUT: "timeout",
  DEFAULT: "default",
  BOOLEAN: "boolean",
  STRING: "string",
  NUMBER: "number",
  OBJECT: "object",
  ARRAY: "array",
  FUNCTION: "function",
  UNDEFINED: "undefined",
  UNKNOWN: "unknown",
  TRANSLATE: "translate",
  ...CALL_DATA_KEY,
};

export const MAX_NUMBER_ROOM_ID = 2147483647;
export const DEFAULT_BLUR_LEVEL = 3;
export const NETWORK_QUALITY_THRESHOLD = 4;
export const CALL_PAGE_PATH = "/uni_modules/TencentCloud-Call/callkit/callPage";
