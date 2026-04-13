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
    const hashList = window.location.hash.split('?');
    const queryParamStr = hashList.length > 1 ? hashList[1] : '';
    navigate(`/login?${queryParamStr}`);
  }
  userInfo.currentPage.value = 'call';
})

</script>
