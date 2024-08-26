<template>
  <div class="call-h5">
    <div class="header">
      <Icon :src="LeftArrowSrc" @click="goHome"/>
      <p> {{ t('1v1 Call') }} </p>
    </div>
    <div class="content">
      <el-input
        class="call-input"
        v-model="calleeUserID"
        :placeholder="placeholderText"
        @input="handleCallUserID"
        @change="handleCall"
      >
        <template #prepend> userID </template>
      </el-input>
      <div
        class="call-btn"
        @click="handleCall"
      > 
        {{ t('Initiate Call') }}
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed } from 'vue';
import { useLanguage, useMyRouter } from '../../../hooks';
import useCall from '../useCall';
import { trim } from '../../../utils';
import Icon from '../../../components/common/Icon/Icon.vue';
import LeftArrowSrc from '../../../assets/Call/left-arrow.svg';

const { t } = useLanguage();
const { navigate } = useMyRouter();
const { call } = useCall();
const calleeUserID = ref('');

const placeholderText = computed(() => {
  return t('input the userID to Call');
})

const handleCall = async () => {
  await call(calleeUserID);
}

const handleCallUserID = () => {
  calleeUserID.value = trim(calleeUserID.value);
}

const goHome = () => {
  navigate('/home');
}

</script>

<style lang="scss" scoped>
@import './Call.scss';
</style>
