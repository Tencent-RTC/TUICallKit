import { createWebHashHistory, createRouter } from 'vue-router'

import Login from '../pages/Login/Login.vue';
import Home from '../pages/Home/Home.vue';
import Call from '../pages/Call/Call.vue';
import GroupCall from '../pages/GroupCall/GroupCall.vue';

const routes = [
  { 
    path: '',
    component: Home,
  },
  { 
    path: '/login',
    component: Login,
  },
  { 
    path: '/home',
    component: Home,
  },
  { 
    path: '/call',
    component: Call,
  },
  { 
    path: '/groupCall',
    component: GroupCall,
  },
]

export const router = createRouter({
  history: createWebHashHistory(),
  routes,
})