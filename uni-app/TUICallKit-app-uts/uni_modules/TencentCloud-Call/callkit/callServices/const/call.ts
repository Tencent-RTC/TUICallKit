export enum StoreName {
  CALL = "call",
  CUSTOM = "custom",
}

export enum MediaType {
  UNKNOWN,
  AUDIO,
  VIDEO,
}

export enum CallRole {
  UNKNOWN = "unknown",
  CALLEE = "callee",
  CALLER = "caller",
}

export enum CallStatus {
  IDLE = "idle",
  CALLING = "calling",
  CONNECTED = "connected",
}

export enum LanguageType {
  EN = "en",
  "ZH-CN" = "zh-cn",
  JA_JP = "ja_JP",
}

export enum AudioPlaybackDevice {
  Speakerphone = 0,
  Earpiece = 1,
}
