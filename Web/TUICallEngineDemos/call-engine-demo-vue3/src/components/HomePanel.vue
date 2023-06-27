<template>
  <el-container style="width: 100%;">
    <el-header class="card-header">
      <UserInfo :user-info="userInfo">
        <template #userMenue>
          <el-button @click="handleLogout">
            <IconExit />
            退出登录
          </el-button>
        </template>
      </UserInfo>
    </el-header>
    <el-main class="card-main">
      <div class="logo">
        <img alt="Vue logo" class="logo" src="@/assets/logo.png" width="264.41" />
        <span>版本：1.0.0</span>
      </div>
      <div class="content">
        <IconButton
          icon="el-icon-single-person"
          text="单人通话"
          :handle-click="() => goToCallPage(CallTypeDesc.SINGLE_CALL)"
        />
        <IconButton
          icon="el-icon-group-person"
          text="群组通话"
          :handle-click="() => goToCallPage(CallTypeDesc.GROUP_CALL)"
        />
      </div>
    </el-main>
    <div class="card-footer">
      <ExternalLink />
    </div>
  </el-container>
</template>

<script setup lang="ts">
import { useRouter } from '@/router';
import { useUserInfoStore } from '@/stores';
import IconButton from '@/components/common/IconButton.vue';
import IconExit from '@/components/icons/IconExit.vue';
import { ElMessage } from '@/components/compatibleComponents';
import UserInfo from '@/components/UserInfo.vue';
import ExternalLink from '@/components/ExternalLink.vue';
import { LOGOUT_FAIL, CallTypeDesc } from '@/constants';
import useTimInstance from '@/hooks/useTimInstance';
import { ref, watch } from 'vue';

const router = useRouter();
const userInfoStore = useUserInfoStore();
const tim = useTimInstance();
const userInfo = ref({});

watch(userInfoStore, () => {
  userInfo.value = {
    avatar: userInfoStore.avatar,
    nickName: userInfoStore.nickName,
    userID: userInfoStore.userID,
  };
}, {
  immediate: true,
});

const goToCallPage = (callType: CallTypeDesc) => {
  router.push(`/call/panel/${callType}`);
};
const handleLogout = async () => {
  try {
    await tim.logout();
    userInfoStore.resetUserInfo();
    router.push('/');
  } catch (err) {
    ElMessage.error(LOGOUT_FAIL);
    console.error(err);
  }
};
</script>

<style lang="less" scoped>
.card-header {
  display: flex;
  height: 12% !important;
}
.card-main {
  padding: 0;
  .logo {
    display: flex;
    flex-direction: column;
    align-items: center;
    img {
      width: 52%;
    }
  }
  .content {
    width: 60%;
    margin: 9.8rem auto 0 auto;
    .btn {
      width: 100%;
      margin-top: 1.2rem;
      background-color: #006EFF;
    }
  }
}
.card-footer {
  position: absolute;
  bottom: 5.3rem;
  width: 100%;
  .external-link {
    width: 60%;
    margin: 0 auto;
  }
}
</style>
