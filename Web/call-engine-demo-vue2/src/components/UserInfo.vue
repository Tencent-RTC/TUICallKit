<template>
  <div class="user-info-wrap">
    <div style="display: flex; align-items: center">
      <div ref="avatarRef" class="avatar-wrap" @click="() => isShowUserMenu = true">
        <el-avatar :size="50" :src="userInfo.avatar">
          <img :src="DefaultAvatarUrl" />
        </el-avatar>
      </div>
      <div class="user-desc">
        <div class="nickname">{{ userInfo.nickName }}</div>
        <div class="userid">userID: {{ userInfo.userID }}</div>
      </div>
    </div>
    <div v-show="isShowUserMenu" class="user-menu">
      <slot name="userMenue"></slot>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useOnClickOutSide } from '@/hooks/useOnClickOutSide';
import { DefaultAvatarUrl, TUserInfo } from '@/constants';

defineProps<{ userInfo: TUserInfo }>();

const isShowUserMenu = ref(false);
const avatarRef = ref<HTMLElement>();

useOnClickOutSide(avatarRef, () => {
  isShowUserMenu.value = false;
});
</script>

<style lang="less" scope>
.user-info-wrap {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  width: 100%;
  padding: 15px 0 0 15px;
  .avatar-wrap {
    display: flex;
  }
  .user-desc {
    font-weight: 600;
    font-size: 14px;
    line-height: 17px;
    margin-left: 6px;
    .userid {
      font-size: 12px;
      font-weight: 500;
    }
  }
  .user-menu {
    position: absolute;
    top: 66.5px;
  }
}
</style>
