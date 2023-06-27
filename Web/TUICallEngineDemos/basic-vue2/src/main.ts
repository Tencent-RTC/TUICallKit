import Vue from 'vue';
import { createPinia, PiniaVuePlugin } from 'pinia';
import ElementUI from 'element-ui';
import 'element-ui/lib/theme-chalk/index.css';

import App from "./App.vue";
import { router } from './router';

import './assets/main.css';

Vue.use(PiniaVuePlugin);
const pinia = createPinia();

Vue.use(ElementUI);

new Vue({
  pinia,
  router,
  render: (h) => h(App),
}).$mount('#app');
