export const STATUS = {
  IDLE: 'idle',
  BE_INVITED: 'be-invited',
  DIALING_C2C: 'dialing-c2c',
	DIALING_GROUP: 'dialing-group',
	CALLING_C2C_AUDIO: 'calling-c2c-audio',
	CALLING_C2C_VIDEO: 'calling-c2c-video',
	CALLING_GROUP_AUDIO: 'calling-group-audio',
	CALLING_GROUP_VIDEO: 'calling-group-video',
} as const;

export const CHANGE_STATUS_REASON = {
  REJECT: 'change-status-because-of-rejected',
  NO_RESPONSE: 'change-status-because-of-no-response',
  LINE_BUSY: 'change-status-because-of-line-busy',
  CALLING_CANCEL: 'change-status-because-of-calling-cancel',
  CALLING_TIMEOUT: 'change-status-because-of-calling-timeout',
  CALL_TYPE_CHANGED: ' call-type-changed',
} as const;

export const CALL_TYPE_STRING = {
  VIDEO: 'call-type-string-video',
  AUDIO: 'call-type-string-audio',
} as const;
