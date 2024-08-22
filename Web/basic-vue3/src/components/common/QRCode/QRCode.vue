<template>
  <div class="qr-box">
    <Icon :src="qrCodeUrl" :size="120" />
    <div class="qr-arrow"></div>
  </div>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue';
// @ts-ignore
import QRCode from 'qrcode';
import { useUserInfo } from '../../../hooks';
import { BASE_URL } from '../../../utils';
import Icon from '../Icon/Icon.vue';

const userInfo = useUserInfo();
const qrCodeUrl = ref('');

onMounted(() => {
  getQrCodeUrl();
})

const getQrCodeUrl = async () => {
  qrCodeUrl.value = `${BASE_URL}#/login?SDKAppID=${userInfo.SDKAppID}&SecretKey=${userInfo.SecretKey}`;
  try {
    const imgData = await QRCode.toDataURL(qrCodeUrl.value, {
      errorCorrectionLevel: "M",
      type: "image/jpeg",
      margin: 0,
    });
    if (imgData) {
      qrCodeUrl.value = imgData
    } else {
      alert("failed to resolve qrCode");
    }
  } catch (err) {
    console.error(err);
  }
};

</script>

<style lang="scss">
.qr-box {
  width: 160px;
  height: 160px;
  background: #FFFFFF;
  box-shadow: 0px 6px 16px rgba(73, 108, 162, 0.2);
  border-radius: 12px;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  z-index: 300;

  .qr-code {
    width: 120px;
    height: 120px;
  }

  .qr-arrow {
    width: 16px;
    height: 16px;
    border-radius: 2px;
    background-color: #ffffff;
    transform: rotate(45deg);
    position: absolute;
    top: 150px;
  }
}

</style>