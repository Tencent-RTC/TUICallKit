import Aegis from "aegis-web-sdk";

// import packageJson from "../../package.json"; 

const aegis = new Aegis({
  id: "iHWefAYqDNAiuxNMQZ",
  reportApiSpeed: true, // 接口测速
  reportAssetSpeed: true, // 静态资源测速
  version: "1.4.1",
});

const loginSuccess = (SDKAppID: number) =>  {
  aegis.reportEvent({
    name: "login",
    ext1: "login-success",
    ext2: "webTUICallKit",
    ext3: SDKAppID.toString()
  });
};

const loginFailed = (SDKAppID: number, errorMessage: string) =>  {
  aegis.reportEvent({
    name: "login",
    ext1: `login-failed-${errorMessage}`,
    ext2: "webTUICallKit",
    ext3: SDKAppID.toString()
  });
};

const loginWithTUICoreSuccess = (SDKAppID: number) =>  {
  aegis.reportEvent({
    name: "loginWithTUICore",
    ext1: "loginWithTUICore-success",
    ext2: "webTUICallKit",
    ext3: SDKAppID.toString()
  });
};

const loginWithTUICoreFailed = (SDKAppID: number, errorMessage: string) =>  {
  aegis.reportEvent({
    name: "loginWithTUICore",
    ext1: `loginWithTUICore-failed-${errorMessage}`,
    ext2: "webTUICallKit",
    ext3: SDKAppID.toString()
  });
};

const loginWithTIMSuccess = (SDKAppID: number) =>  {
  aegis.reportEvent({
    name: "loginWithTIM",
    ext1: "loginWithTIM-success",
    ext2: "webTUICallKit",
    ext3: SDKAppID.toString()
  });
};

const loginWithTIMFailed = (SDKAppID: number, errorMessage: string) =>  {
  aegis.reportEvent({
    name: "loginWithTIM",
    ext1: `loginWithTIM-failed-${errorMessage}`,
    ext2: "webTUICallKit",
    ext3: SDKAppID.toString()
  });
};

const switchCallType = (SDKAppID: number) =>  {
  aegis.reportEvent({
    name: "switchCallType",
    ext1: "switchCallType-success",
    ext2: "webTUICallKit",
    ext3: SDKAppID.toString()
  });
};

const callSuccess = (SDKAppID: number, callType: string, typeString: string) =>  {
  aegis.reportEvent({
    name: `${callType}-${typeString}`,
    ext1: `${callType}-${typeString}-success`,
    ext2: "webTUICallKit",
    ext3: SDKAppID.toString()
  });
};

const callFailed = (SDKAppID: number, callType: string, typeString: string, errorMessage: string) =>  {
  aegis.reportEvent({
    name: `${callType}-${typeString}`,
    ext1: `${callType}-${typeString}-failed-${errorMessage}`,
    ext2: "webTUICallKit",
    ext3: SDKAppID.toString()
  });
};

const MinimizeSuccess = (SDKAppID: number) =>  {
  aegis.reportEvent({
    name: "Minimized",
    ext1: "Minimized-success",
    ext2: "webTUICallKit",
    ext3: SDKAppID.toString()
  });
};

const logReporter = {
  loginSuccess,
  loginFailed,
  loginWithTUICoreSuccess,
  loginWithTUICoreFailed,
  loginWithTIMSuccess,
  loginWithTIMFailed,
  switchCallType,
  callSuccess,
  callFailed,
  MinimizeSuccess
};

export default logReporter;