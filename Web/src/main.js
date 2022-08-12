import Vue from 'vue'
import 'element-ui/lib/theme-chalk/index.css';
import {
  Input, Button, Message, MessageBox, Autocomplete, Dialog,
  DropdownItem, DropdownMenu, Dropdown, Form, FormItem, Checkbox,
  Link, Select, Option
} from 'element-ui';
import store from './store';
import { createRouter } from './router'
import { createTUICallEngine } from './tuiCallEngine';
import App from './App.vue'
import VConsole from 'vconsole';
import { browser } from './utils'

Vue.use(Input);
Vue.use(Button);
Vue.use(Autocomplete);
Vue.use(Dialog);
Vue.use(Dropdown);
Vue.use(DropdownMenu);
Vue.use(DropdownItem);
Vue.use(Form);
Vue.use(FormItem);
Vue.use(Checkbox);
Vue.use(Link);
Vue.use(Select);
Vue.use(Option);

Vue.prototype.$message = Message;
Vue.prototype.$confirm = MessageBox.confirm;

const { tim, tuiCallEngine, TUICallEvent, TUICallType } = createTUICallEngine();

Vue.prototype.$tim = tim;
Vue.prototype.$tuiCallEngine = tuiCallEngine;
Vue.prototype.TUICallEvent = TUICallEvent;
Vue.prototype.TUICallType = TUICallType;

Vue.config.productionTip = false

if (browser().isH5) {
  const vConsole = new VConsole();
  console.log(vConsole);
}

new Vue({
  render: h => h(App),
  store,
  router: createRouter()
}).$mount('#app')
