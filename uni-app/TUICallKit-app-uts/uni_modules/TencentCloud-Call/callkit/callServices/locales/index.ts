import { NAME, StoreName } from "../const/index";
import { zh } from "./zh-cn";
import { en } from "./en";
import { ja_JP } from "./ja_JP";
import { interpolate, isString, isPlainObject } from "../utils/common";

export const CallTips: any = {
  OTHER_SIDE: "other side",
  CANCEL: "cancel",
  OTHER_SIDE_REJECT_CALL: "other side reject call",
  REJECT_CALL: "reject call",
  OTHER_SIDE_LINE_BUSY: "other side line busy",
  IN_BUSY: "in busy",
  CALL_TIMEOUT: "call timeout",
  END_CALL: "end call",
  TIMEOUT: "timeout",
  KICK_OUT: "kick out",
  CALLER_CALLING_MSG: "caller calling message",
  CALLER_GROUP_CALLING_MSG: "wait to be called",
  CALLEE_CALLING_VIDEO_MSG: "callee calling video message",
  CALLEE_CALLING_AUDIO_MSG: "callee calling audio message",
  NO_MICROPHONE_DEVICE_PERMISSION: "no microphone access",
  NO_CAMERA_DEVICE_PERMISSION: "no camera access",
  EXIST_GROUP_CALL: "exist group call",
  LOCAL_NETWORK_IS_POOR: "The network is poor during your current call",
  REMOTE_NETWORK_IS_POOR:
    "The other user network is poor during the current call",
};

export const languageData: languageDataType = {
  "zh-cn": zh,
  en,
  ja_JP,
};

// language translate
export function t(args): string {
  const language = uni.$TUIStore.getData(StoreName.CALL, NAME.LANGUAGE);
  let translationContent = "";
  if (isString(args)) {
    translationContent = languageData?.[language]?.[args] || "";
  } else if (isPlainObject(args)) {
    const { key, options } = args;
    translationContent = languageData?.[language]?.[key] || "";
    translationContent = interpolate(translationContent, options);
  }

  return translationContent;
}

interface languageItemType {
  [key: string]: string;
}
interface languageDataType {
  [key: string]: languageItemType;
}
