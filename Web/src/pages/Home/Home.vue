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
    navigate('/login');
  }
  userInfo.currentPage.value = 'home';
})

</script>
