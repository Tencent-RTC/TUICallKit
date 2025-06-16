import { NAME, MAX_NUMBER_ROOM_ID } from "../../const/index";

export const VALIDATE_PARAMS = {
  login: {
    SDKAppID: {
      required: true,
      rules: [NAME.NUMBER],
      allowEmpty: false,
    },
    userID: {
      required: true,
      rules: [NAME.STRING],
      allowEmpty: false,
    },
    userSig: {
      required: true,
      rules: [NAME.STRING],
      allowEmpty: false,
    },
    tim: {
      required: false,
      rules: [NAME.OBJECT],
    },
  },
  calls: {
    userIDList: {
      required: true,
      rules: [NAME.ARRAY],
      allowEmpty: false,
    },
    mediaType: {
      required: true,
      rules: [NAME.NUMBER],
      range: [1, 2],
      allowEmpty: false,
    },
    callParams: {
      required: false,
      rules: [NAME.OBJECT],
      allowEmpty: false,
    },
  },
  join: {
    callID: {
      required: true,
      rules: [NAME.STRING],
      allowEmpty: false,
    },
  },
  inviteUser: {
    userIDList: {
      required: true,
      rules: [NAME.ARRAY],
      allowEmpty: false,
    },
  },
  setSelfInfo: {
    nickName: {
      required: true,
      rules: [NAME.STRING],
      allowEmpty: false,
    },
    avatar: {
      required: true,
      rules: [NAME.STRING],
      allowEmpty: false,
    },
  },
  enableFloatWindow: [
    {
      key: "enable",
      required: false,
      rules: [NAME.BOOLEAN],
      allowEmpty: false,
    },
  ],
  enableAIVoice: [
    {
      key: "enable",
      required: true,
      rules: [NAME.BOOLEAN],
      allowEmpty: false,
    },
  ],
  enableMuteMode: [
    {
      key: "enable",
      required: true,
      rules: [NAME.BOOLEAN],
      allowEmpty: false,
    },
  ],
  setCallingBell: [
    {
      key: "filePath",
      required: false,
      rules: [NAME.STRING],
      allowEmpty: true,
    },
  ],
  setLanguage: [
    {
      key: "language",
      required: true,
      rules: [NAME.STRING],
      allowEmpty: false,
    },
  ],
};
