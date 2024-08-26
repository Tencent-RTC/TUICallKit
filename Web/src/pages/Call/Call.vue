<template>
  <CallPC v-if="!isH5" />
  <CallH5 v-else />
</template>

<script lang="ts" setup>
import {onMounted, toRefs } from 'vue';
import { useUserInfo, useMyRouter } from '../../hooks';
import { isH5 } from '../../utils';
import CallPC from './PC/Call.vue';
import CallH5 from './H5/Call.vue';

const { navigate } = useMyRouter();
const userInfo = toRefs(useUserInfo());

onMounted(() => {
  if (!userInfo?.isLogin.value) {
    navigate('/login');
  }
  userInfo.currentPage.value = 'call';
})
</script>
