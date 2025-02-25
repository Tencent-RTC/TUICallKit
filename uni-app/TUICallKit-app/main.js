import App from './App';
import VueI18n from 'vue-i18n';
import messages from './locale/index.js';

// #ifndef VUE3
import Vue from 'vue';
Vue.use(VueI18n);
Vue.config.productionTip = false;
App.mpType = 'app';
const i18nConfig = { locale: uni.getLocale(), messages };
const i18n = new VueI18n(i18nConfig);
const app = new Vue({
  ...App,
  i18n,
});
app.$mount();
// #endif

// #ifdef VUE3
import { createSSRApp } from 'vue';
export function createApp() {
  const app = createSSRApp(App);
  return { app };
}
// #endif
