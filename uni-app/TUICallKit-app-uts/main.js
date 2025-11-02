import App from "./App";
import { TUICallKit } from "@/uni_modules/TencentCloud-Call/callkit/callServices/services/index";

import { TUIStore } from "@/uni_modules/TencentCloud-Call/callkit/callServices/TUIStore/index";
import { createI18n } from 'vue-i18n';
import locale from '@/locale/index.js';

uni.$TUICallKit = TUICallKit;
uni.$TUIStore = TUIStore;

function getSystemLanguage() {
  let systemLang = 'en';
  try {
    const systemInfo = uni.getSystemInfoSync();
    if (systemInfo.language.includes('zh')) {
      systemLang = 'zh-Hans';
    } else {
      systemLang = 'en';
    }
  } catch (e) {
    console.log('getSystemInfoSync failed:', e);
  }
  return systemLang;
}

const i18n = createI18n({
  legacy: true,
  locale: getSystemLanguage(),
  fallbackLocale: 'en',
  messages: locale,
});

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
  app.use(i18n);
  // app.component('tui-callkit', callkit)
  return {
    app,
  };
}
// #endif
