// 错误码
export const ErrorCode: any = {
  MICROPHONE_UNAVAILABLE: 60003,
  CAMERA_UNAVAILABLE: 60004,
  BAN_DEVICE: 60005,
  ERROR_BLACKLIST: 20007,
} as const;

export const ErrorMessage: any = {
  MICROPHONE_UNAVAILABLE: 'microphone-unavailable',
  CAMERA_UNAVAILABLE: 'camera-unavailable',
  BAN_DEVICE: 'ban-device',
  ERROR_BLACKLIST: 'blacklist-user-tips'
} as const;
