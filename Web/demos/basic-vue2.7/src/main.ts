import App from './App.vue'
import { i18n } from "./utils/locale"
import Vue from 'vue'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'

Vue.use(ElementUI)
Vue.use(i18n)

const app = new Vue({ i18n, render: (h) => h(App) })
app.$mount('#app')