<template>
  <view class="top-bar">
    <float-window></float-window>
    <view class="top-bar-time">
      <timer></timer>
    </view>
  </view>
</template>

<script setup lang="ts">
import timer from "../timer/timer.vue";
import floatWindow from "../button/floatWindow.vue";
</script>

<style>
.top-bar {
  display: flex;
  flex-direction: row;
  align-items: center;
  margin-top: 40px;
  padding: 0 15px;
}

.top-bar-time {
  margin-left: 250rpx;
}
</style>
