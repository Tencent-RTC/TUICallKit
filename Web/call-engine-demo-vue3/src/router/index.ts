import { createRouter, createWebHistory, useRouter, useRoute } from 'vue-router';
import { BaseRoutes } from './routes';
// import { useUserInfoStore } from '@/stores';

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: BaseRoutes,
});

// router.beforeEach(async (to, from) => {
//   const { isLogin } = useUserInfoStore();
//   if (
//     // 检查用户是否已登录
//     !isLogin &&
//     // ❗️ 避免无限重定向
//     to.name !== 'Login'
//   ) {
//     // 将用户重定向到登录页面
//     return { name: 'Login' };
//   }
// });

export {
  router,
  useRouter,
  useRoute,
};
