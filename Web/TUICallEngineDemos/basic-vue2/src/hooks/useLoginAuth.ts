import { useUserInfoStore } from '@/stores';
import { useRouter } from '@/router';

/**
* @function 验证登录态的hook函数
* @description
*   用来验证是否登录，未登录返回登录页，目前没有做登录态的持久化，后面登录态持久化
*   仍可以通过此函数验证，在页面中直接调用即可
* @example
*   useLoginAuth();
*/
export function useLoginAuth() {
  const userInfoStore = useUserInfoStore();
  const router = useRouter();

  if (!userInfoStore.isLogin) {
    router.replace('/');
  }
}
