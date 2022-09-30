import Server from "./server";
import TUICallKit from "./components/TUICallKit.vue";
import { STATUS } from "./constants"

const TUICallKitServer = new Server();

const plugin = (TUICore: any) => {
  TUICore.component("TUICallKit", TUICallKit);
  TUICallKitServer.bindTUICore(TUICore);
  return TUICallKit;
};

const install = (app: any) => {
  console.log("TUICallKit installed", app);
};

(TUICallKit as any).plugin = plugin;
(TUICallKit as any).install = install;

export {
  TUICallKit,
  TUICallKitServer,
  STATUS
};
