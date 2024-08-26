<template>
  <div 
    class="icon-copy"
    v-show="userInfo?.currentPage.value !== 'login'"
    @click="handleCopy"
  >
    userID: 
    <Text :maxWidth="60"> {{ userInfo.userID }} </Text>
    <Icon :src="CopySrc" />
  </div>
</template>

<script lang="ts" setup>
import { toRefs } from 'vue';
import { useUserInfo, useCopy } from '../../../hooks/index';
import Icon from '../../common/Icon/Icon.vue';
import Text from '../../common/Text/Text.vue';
import CopySrc from '../../../assets/Container/copy.svg';

const { copyText } = useCopy();
const userInfo = toRefs(useUserInfo());
const handleCopy = () => {
  copyText(userInfo.userID.value);
}
</script>

<style scoped>
.icon-copy {
  display: flex;
  gap: 0 4px;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}
</style>