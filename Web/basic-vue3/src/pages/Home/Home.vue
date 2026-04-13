<template>
  <HomePC v-if="!isH5" />
  <HomeH5 v-else/>
</template>
<script lang="ts" setup>
import { onMounted, toRefs } from 'vue';
import { useMyRouter, useUserInfo } from '../../hooks';
import { isH5 } from '../../utils';
import HomePC from './PC/Home.vue';
import HomeH5 from './H5/Home.vue';

const { navigate } = useMyRouter();
const userInfo = toRefs(useUserInfo());

onMounted(() => {
  if (!userInfo?.isLogin.value) {
    const hashList = window.location.hash.split('?');
    const queryParamStr = hashList.length > 1 ? hashList[1] : '';

    navigate(`/login?${queryParamStr}`);
  }
  userInfo.currentPage.value = 'home';
})

</script>
