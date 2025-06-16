import App from "./App";
import { TUICallKit } from "@/uni_modules/TencentCloud-Call/callkit/callServices/services/index";

import { TUIStore } from "@/uni_modules/TencentCloud-Call/callkit/callServices/TUIStore/index";

uni.$TUICallKit = TUICallKit;
uni.$TUIStore = TUIStore;

// #ifndef VUE3
import Vue from "vue";
import "./uni.promisify.adaptor";
Vue.config.productionTip = false;
App.mpType = "app";
app.$mount();
// #endif

// #ifdef VUE3
import { createSSRApp } from "vue";
export function createApp() {
  const app = createSSRApp(App);
  // app.component('tui-callkit', callkit)
  return {
    app,
  };
}
// #endif
