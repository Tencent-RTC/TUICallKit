<template>
  <LoginPC v-if="!isH5"/>
  <LoginH5 v-else/>
</template>

<script setup lang="ts">
import { onMounted, toRefs } from 'vue';
import { isH5, getUrlParams } from '../../utils';
import { useUserInfo } from '../../hooks';
import LoginPC from './PC/Login.vue';
import LoginH5 from './H5/Login.vue';

const userInfo = toRefs(useUserInfo());

onMounted(() => {
  const { SDKAppID, SecretKey } = getUrlParams();
  userInfo.SDKAppID.value = Number(SDKAppID);
  userInfo.SecretKey.value = SecretKey;
  userInfo.currentPage.value = 'login';
})

</script>
