import Vue from 'vue';
import Router from 'vue-router';

import store from '../store';
import HomePage from '../views/home-page';
import Login from '../views/login';
import Profile from '../views/profile';
import Call from '../views/call';

Vue.use(Router);

export function createRouter () {
  const router = new Router({
    mode: 'hash',
    fallback: false,
    routes: [
      { path: '/', redirect:'login'},
      { path: '/home', name:'home', component: HomePage},
      { path: '/login', name:'login', component: Login},
      { path: '/profile', name:'profile', component: Profile},
      { path: '/call', name:'call', component: Call},
    ]
  });
  router.beforeEach((to, from, next) => {
    if (!store.state.isLogin) {
      if (to.fullPath !== '/login') {
        if (from.fullPath !== '/login') {
          next('/login');
        }
        return;
      }
    }
    next();
  })

  return router;
}

const originalPush = Router.prototype.push
   Router.prototype.push = function push(location) {
   return originalPush.call(this, location).catch(err => err)
}