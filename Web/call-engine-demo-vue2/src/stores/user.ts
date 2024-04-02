import { defineStore } from 'pinia';
import { DefaultAvatarUrl, TUserInfo } from '@/constants';

const DefaultUserInfo = {
  userID: '',
  nickName: '',
  isLogin: false,
  avatar: DefaultAvatarUrl,
  userSig: '',
  secretKey: '',
};

export const useUserInfoStore = defineStore('userInfo', {
  state: () => DefaultUserInfo,
  actions: {
    updateUserInfo(params: TUserInfo) {
      this.$patch(params);
    },
    resetUserInfo() {
      this.$patch({
        userID: '',
        nickName: '',
        avatar: '',
        userSig: '',
        isLogin: false,
      });
    },
  },
});
