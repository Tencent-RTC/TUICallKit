<template>
  <div class="login-container">
    <Logo :src="LogoMain" />
    <div class="wrap">
      <LoginPanel :loading="loading" @login="handleLogin" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import isEmpty from 'lodash-es/isEmpty';
import { useRouter } from '@/router';
import { useUserInfoStore } from '@/stores';
import { ElMessage } from '@/components/compatibleComponents';
import LoginPanel from '@/components/LoginPanel.vue';
import Logo from '@/components/common/Logo.vue';
import * as tips from '@/constants/tips';
import LogoMain from '@/assets/loginMain.png';

const router = useRouter();
const userInfoStore = useUserInfoStore();
const loading = ref(false);

const handleLogin = async (userID: string) => {
  if (isEmpty(userID)) {
    ElMessage.error(tips.USERID_SHOULD_NOT_EMPTY);
    return;
  }

  try {
    // 这里对userID不做校验，只是将userID存储下来，并默认登录成功，登录逻辑根据具体业务做校验
    userInfoStore.updateUserInfo({
      userID,
      isLogin: true,
    });

    router.push('/call/home');
  } catch (err) {
    ElMessage.error(tips.LOGIN_FAIL);
    console.error(err);
  }
  loading.value = false;
};
</script>

<style lang="less" scoped>
.login-container {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  .wrap {
    position: relative;
    width: 500px;
    height: 53rem;
    max-width: 500px;
    max-height: 800px;
    display: flex;
    flex-direction: column;
    align-items: center;
    box-sizing: border-box;
    margin: 6rem 0 0 0rem;
    border-radius: 20px;
    box-shadow: 0 0 8px #3d8fff6b;
  }
}
</style>
