import { createApp } from 'vue';
import ElementPlus from 'element-plus'
import VConsole from 'vconsole';
import App from './App.vue';
import i18n from './locales';
import { router } from './routes/index';
import 'element-plus/dist/index.css';
import './style/index.scss';

// Enable VConsole so logs are visible directly in the browser (dev and production).
new VConsole();

createApp(App)
  .use(ElementPlus)
  .use(router)
  .use(i18n)
  .mount('#app')

