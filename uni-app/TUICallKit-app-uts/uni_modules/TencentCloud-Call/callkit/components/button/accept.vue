<template>
  <view class="btn" @tap="handleAccept">
    <image class="btn-img" :src="ACCEPT_SRC"></image>
    <text class="btn-text" v-if="isShowText">
      {{ t("accept") }}
    </text>
  </view>
</template>

<script setup lang="ts">
import { t } from "../../callServices/locales";
import ACCEPT_SRC from "../assets/accept.png";

const props = defineProps({
  isShowText: {
    type: Boolean,
    default: true,
  },
});

const handleAccept = () => {
  uni.$TUICallKit.accept();
};
</script>

<style scoped>
.btn {
  width: 60px;
  margin: 10px 20px;
}

.btn-img {
  width: 60px;
  height: 60px;
  border-radius: 140px;
}

.btn-text {
  font-size: 12px;
  color: #d5e0f2;
  font-weight: 400;
  text-align: center;
  margin-top: 10px;
}
</style>
