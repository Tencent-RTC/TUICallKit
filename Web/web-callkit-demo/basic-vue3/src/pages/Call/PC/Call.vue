<template>
  <div class="call-container">
    <CreateUserTip> {{ t('Create more userIDs to enable one-on-one calls') }} </CreateUserTip>
    <el-input
      class="call-input"
      v-model="calleeUserID"
      :placeholder="placeholderText"
      @input="handleCallUserID"
      @change="handleCall"
    >
      <template #append>
        <Button class="call-btn" @click="handleCall"> {{ t('Initiate Call')}} </Button>
      </template>
    </el-input>
    <p class="error-tip" v-show="isError"> {{ t('The called userID does not exist. Please verify if it is correct') }} </p>
    <div class="call-tip-qr">
      {{ t('Scanning QR Code') }}
      <Icon :src="QRSrc" :size="16" @click="showQRCode" style="cursor: pointer;"/>
      <QRCode class="call-qr" v-if="isShowQRcode" />
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed } from 'vue';
import { useLanguage } from '../../../hooks';
import useCall from '../useCall';
import { trim } from '../../../utils';
import QRCode from '../../../components/common/QRCode/QRCode.vue';
import Button from '../../../components/common/Button/Button.vue';
import Icon from '../../../components/common/Icon/Icon.vue';
import QRSrc from '../../../assets/Call/qr.svg';
import CreateUserTip from '../../../components/CreateUserTip/CreateUserTip.vue';

const calleeUserID = ref('');
const { t } = useLanguage();
const { call } = useCall();
const isError = ref(false);
const isShowQRcode = ref(false);

const placeholderText = computed(() => {
  return t('input the userID to Call');
})

const handleCall = async () => {
  const res = await call(calleeUserID);
  isError.value = !!res;
}

const handleCallUserID = () => {
  calleeUserID.value = trim(calleeUserID.value)
}

const showQRCode = () => {
  isShowQRcode.value = !isShowQRcode.value;
}
</script>


<style lang='scss'>
.el-input__wrapper {
  background: #F0F4FA;
  border-radius: 28px;
}
.el-input-group__append {
  border-radius: 28px;
}
.el-input-group--append>.el-input__wrapper {
  border-bottom-right-radius: 28px;
  border-top-right-radius: 28px;
}
</style>

<style lang="scss" scoped>
.call-container {
  width: 520px;
  margin-top: 85px;

  .call-tip {
    display: flex;
    font-weight: 400;
    font-size: 14px;
    color: #8F9AB2;
  }

  .error-tip {
    margin-top: 12px;
    margin-left: 20px;
    font-weight: 400;
    font-size: 14px;
    color: #E6395C;
  }

  .call-input {
    width: 520px;
    height: 48px;
    padding: 5px 10px;
    margin-top: 12px;
    background: #F0F4FA;
    border-radius: 28px;

    .call-btn {
      width: 89px;
      height: 40px;
      background: #1C66E5;
      border-radius: 26px;
      font-weight: 600;
      font-size: 14px;
      color: #FFFFFF;
    }
  }

  .call-tip-qr {
    margin-top: 175px;
    display: flex;
    justify-content: center;
    align-items: center;
    font-weight: 400;
    font-size: 14px;
    color: #8F9AB2;
    position: relative;

    .call-qr {
      position: absolute;
      right: 45px;
      top: -170px;
    }
  }
}
</style>