import Aegis from "aegis-web-sdk";

import { Version } from "@tencentcloud/call-uikit-vue2";

const aegis = new Aegis({
  id: "iHWefAYqUsdWyZYVKV",
  reportApiSpeed: true, // 接口测速
  reportAssetSpeed: true, // 静态资源测速
  version: Version
});

const loginSuccess = (SDKAppID: number) =>  {
  aegis.reportEvent({
    name: "login",
    ext1: "login-success",
    ext2: "webTUICallKitBasicVue2",
    ext3: SDKAppID.toString()
  });
};

const loginFailed = (SDKAppID: number, errorMessage: string) =>  {
  aegis.reportEvent({
    name: "login",
    ext1: `login-failed-${errorMessage}`,
    ext2: "webTUICallKitBasicVue2",
    ext3: SDKAppID.toString()
  });
};

const callSuccess = (SDKAppID: number, callType: string, typeString: string) =>  {
  aegis.reportEvent({
    name: `${callType}-${typeString}`,
    ext1: `${callType}-${typeString}-success`,
    ext2: "webTUICallKitBasicVue2",
    ext3: SDKAppID.toString()
  });
};

const callFailed = (SDKAppID: number, callType: string, typeString: string, errorMessage: string) =>  {
  aegis.reportEvent({
    name: `${callType}-${typeString}`,
    ext1: `${callType}-${typeString}-failed-${errorMessage}`,
    ext2: "webTUICallKitBasicVue2",
    ext3: SDKAppID.toString()
  });
};

const logReporter = {
  loginSuccess,
  loginFailed,
  callSuccess,
  callFailed,
};

export default logReporter;