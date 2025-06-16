<template>
  <view class="btn" @tap="handleSwitchCamera">
    <image class="btn-img" :style="[style]" :src="ARROW_SRC"></image>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { t } from "../../callServices/locales";
import ARROW_SRC from "../assets/arrow.png";

const isFrontCamera = ref<boolean>(true);

const props = defineProps({
  size: {
    type: Number,
    default: 60,
  },
});
// transform: rotate(180deg); /* 旋转180度实现向上 */
const style = computed(() => ({
  width: props.size + "px",
  height: props.size + "px",
}));

const handleSwitchCamera = () => {};
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
</style>
