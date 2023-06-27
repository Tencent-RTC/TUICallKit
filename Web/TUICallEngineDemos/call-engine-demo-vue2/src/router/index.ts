import Vue, { getCurrentInstance } from "vue";
import VueRouter from "vue-router";
import { BaseRoutes } from "./routes";
// import { useUserInfoStore } from '@/stores';

Vue.use(VueRouter);

const router = new VueRouter({
  mode: "history",
  base: import.meta.env.BASE_URL,
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
//     return { name: 'Login' }
//   }
// });

const useRouter = () => {
  const vm = getCurrentInstance();
  if (!vm) throw new Error('must be called in setup');
  return vm.proxy.$router;
};
const useRoute = () => {
  const vm = getCurrentInstance()
  if (!vm) throw new Error('must be called in setup')
  return vm.proxy.$route;
};

export {
  router,
  useRouter,
  useRoute,
};
