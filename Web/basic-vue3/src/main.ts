import { createApp } from 'vue';
import ElementPlus from 'element-plus'
import App from './App.vue';
import i18n from './locales';
import { router } from './routes/index';
import 'element-plus/dist/index.css';
import './style/index.scss';

createApp(App)
  .use(ElementPlus)
  .use(router)
  .use(i18n)
  .mount('#app')

