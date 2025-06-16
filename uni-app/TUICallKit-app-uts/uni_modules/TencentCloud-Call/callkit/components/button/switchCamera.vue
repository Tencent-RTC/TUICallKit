<template>
  <view class="btn" @tap="handleSwitchCamera">
    <image class="btn-img" :style="[style]" :src="SWITCH_CAMERA_SRC"></image>
    <text class="btn-text" v-if="isShowText">
      {{ t("switch camera") }}
    </text>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { t } from "../../callServices/locales";
import SWITCH_CAMERA_SRC from "../assets/switch-camera.png";

const isFrontCamera = ref<boolean>(true);

const props = defineProps({
  size: {
    type: Number,
    default: 60,
  },
  isShowText: {
    type: Boolean,
    default: true,
  },
});

const style = computed(() => ({
  width: props.size + "px",
  height: props.size + "px",
}));

const handleSwitchCamera = () => {
  if (isFrontCamera.value) {
    uni.$TUICallKit.switchCamera(1);
  } else {
    uni.$TUICallKit.switchCamera(0);
  }
  isFrontCamera.value = !isFrontCamera.value;
};
</script>

<style scoped>
.btn {
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
