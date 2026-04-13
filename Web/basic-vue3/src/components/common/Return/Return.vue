<template>
  <div class="return-container" @click="goHome">
    <Icon :src="ReturnSrc" :size="16" />
    {{ t('Call Back') }}
  </div>
</template>

<script lang='ts' setup>
import ReturnSrc from '../../../assets/common/return.svg';
import { useLanguage, useMyRouter } from '../../../hooks';
import Icon from '../Icon/Icon.vue';

const { navigate } = useMyRouter();
const { t } = useLanguage();

const goHome = () => {
  const hashList = window.location.hash.split('?');
  const queryParamStr = hashList.length > 1 ? hashList[1] : '';
  navigate(`/home?${queryParamStr}`);
}

</script>

<style lang="scss" scoped>
.return-container {
  display: flex;
  gap: 0 8px;
  align-items: center;
  font-weight: 500;
  color: #4F586B;
  cursor: pointer;
}
</style>
