<template>
  <view class="btn" @tap="startFloatWindow">
    <image class="btn-img" :src="FLOAT_WINDOW_SRC"></image>
  </view>
</template>

<script setup lang="ts">
import FLOAT_WINDOW_SRC from "../assets/float-window.png";

const startFloatWindow = () => {
  uni.$TUICallKit.startFloatWindow();
};
</script>

<style scoped>
.btn-img {
  width: 24px;
  height: 24px;
}
</style>
