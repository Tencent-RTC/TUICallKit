<template>
  <div class="btn" @tap="handleCamera">
    <image class="btn-img" :src="imgSrc"></image>
    <text class="btn-text" v-if="isShowText">
      {{ isOpenCamera ? t("camera enabled") : t("camera disabled") }}
    </text>
  </div>
</template>

<script setup lang="ts">
import { computed, watch, ref, onMounted } from "vue";
import { t } from "../../callServices/locales";
import {
  NAME,
  StoreName,
} from "@/uni_modules/TencentCloud-Call/callkit/callServices/const";
import CAMERA_ON_SRC from "../assets/camera-on.png";
import CAMERA_OFF_SRC from "../assets/camera-off.png";
import { MediaType } from "../../../utssdk/interface";

const props = defineProps({
  isShowText: {
    type: Boolean,
    default: true,
  },
  defaultOpen: {
    type: Boolean,
    default: true,
  },
});

const isOpenCamera = ref(
  uni.$TUIStore.getData(StoreName.CALL, NAME.IS_LOCAL_CAMERA_OPEN)
);

const imgSrc = computed(() => {
  return !isOpenCamera.value ? CAMERA_OFF_SRC : CAMERA_ON_SRC;
});

const handleCamera = () => {
  if (isOpenCamera.value) {
    uni.$TUICallKit.closeCamera();
  } else {
    uni.$TUICallKit.openCamera();
  }
  isOpenCamera.value = !isOpenCamera.value;
  uni.$TUIStore.update(
    StoreName.CALL,
    NAME.IS_LOCAL_CAMERA_OPEN,
    isOpenCamera.value
  );
  uni.$TUIStore.update(
    StoreName.CALL,
    NAME.CURRENT_CAMERA_IS_OPEN,
    isOpenCamera.value
  );
};

onMounted(() => {
  const savedCameraIsOpen = uni.$TUIStore.getData(
    StoreName.CALL,
    NAME.CURRENT_CAMERA_IS_OPEN
  );
  const currentMediaType = uni.$TUIStore.getData(
    StoreName.CALL,
    NAME.MEDIA_TYPE
  );
  if (currentMediaType === MediaType.Video) return;
  if (savedCameraIsOpen !== undefined) {
    isOpenCamera.value = savedCameraIsOpen;
  } else {
    isOpenCamera.value = false;
    uni.$TUIStore.update(StoreName.CALL, NAME.IS_LOCAL_CAMERA_OPEN, false);
    uni.$TUIStore.update(StoreName.CALL, NAME.CURRENT_CAMERA_IS_OPEN, false);
  }
});
</script>

<style>
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
