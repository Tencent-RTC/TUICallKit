<template>
  <div class="btn" @tap="handleMic">
    <image class="btn-img" :src="micSrc"></image>
    <text class="btn-text">
      {{ isOpenMic ? t("microphone enabled") : t("microphone disabled") }}
    </text>
  </div>
</template>

<script setup lang="ts">
import { watch, ref, computed, onMounted } from "vue";
import {
  NAME,
  StoreName,
} from "@/uni_modules/TencentCloud-Call/callkit/callServices/const";
import { t } from "../../callServices/locales";
import MIC_ON_SRC from "../assets/mic-on.png";
import MIC_OFF_SRC from "../assets/mic-off.png";

const isOpenMic = ref(
  uni.$TUIStore.getData(StoreName.CALL, NAME.IS_LOCAL_MIC_OPEN)
);
const props = defineProps({
  isShowText: {
    type: Boolean,
    default: true,
  },
});

const micSrc = computed(() => {
  return !isOpenMic.value ? MIC_OFF_SRC : MIC_ON_SRC;
});

const handleMic = () => {
  if (isOpenMic.value) {
    uni.$TUICallKit.closeMicrophone();
  } else {
    uni.$TUICallKit.openMicrophone();
  }
  isOpenMic.value = !isOpenMic.value;
  uni.$TUIStore.update(StoreName.CALL, NAME.IS_LOCAL_MIC_OPEN, isOpenMic.value);
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
