import Server from "./server";
import TUICallKit from "./components/TUICallKit.vue";
import TUICallKitMini from "./components/TUICallKitMini.vue";
import { STATUS } from "./constants"

const TUICallKitServer = new Server();

const plugin = (TUICore: any) => {
  TUICore.component('TUICallKit', { server: TUICallKitServer });
  TUICore.component('TUICallKitMini', { server: TUICallKitServer });
  TUICallKitServer.bindTUICore(TUICore);
  return TUICallKit;
};

const install = (app: any) => {
  app.component('TUICallKitMini', TUICallKitMini);
  app.component('TUICallKit', TUICallKit);
  console.log("TUICallKit&mini installed", app);
};

(TUICallKit as any).plugin = plugin;
(TUICallKit as any).install = install;

export {
  TUICallKit,
  TUICallKitMini,
  TUICallKitServer,
  STATUS
};
