<template>
  <GroupCallPC v-if="!isH5" />
  <GroupCallH5 v-else />
</template>

<script lang="ts" setup>
import { toRefs, onMounted } from 'vue';
import { useUserInfo, useMyRouter } from '../../hooks';
import { isH5 } from '../../utils';
import GroupCallPC from './PC/GroupCall.vue';
import GroupCallH5 from './H5/GroupCall.vue';


const { navigate } = useMyRouter();
const userInfo = toRefs(useUserInfo());

onMounted(() => {
  if (!userInfo?.isLogin.value) {
    navigate('/login');
  }
  userInfo.currentPage.value = 'call';
})

</script>
