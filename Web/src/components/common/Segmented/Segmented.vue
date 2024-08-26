<template>
  <div class="segmented">
    <div
      v-for="(item, index) in items"
      class="segmented-box"
      :key="index"
      :class="{ active: activeIndex === index }"
      @click="selectItem(index)"
    >
      {{ item }}
    </div>
  </div>
</template>

<script lang="ts" setup>
import { computed, ref, toRefs } from 'vue';
import { useLanguage, useUserInfo } from '../../../hooks/index';

const callType = ['video', 'audio'];

const { t } = useLanguage();
const activeIndex = ref(0);
const userInfo = toRefs(useUserInfo());
const items = computed(() => [t('Video Call'), t('Voice Call')] );

const selectItem = (index: number) => {
  activeIndex.value = index;
  userInfo.currentCallType.value = callType[index];
};

</script>

<style>
.segmented {
  height: 36px;
  display: flex;
  align-items: center;
  background: rgba(169, 185, 217, 0.24);
  border-radius: 24px;
}

.segmented-box {
  padding: 5px 20px;
  margin: 2px;
  border-radius: 22px;
  font-weight: 400;
  color: #8F9AB2;
  cursor: pointer;
}

.segmented .active {
  font-weight: 500;
  background: #FFFFFF;
  color: #1C66E5;
}

</style>