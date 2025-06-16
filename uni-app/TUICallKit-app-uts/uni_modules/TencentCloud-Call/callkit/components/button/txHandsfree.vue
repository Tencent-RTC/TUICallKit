<template>
  <view class="btn" @tap="handleSwitchAudioPlay">
    <image class="btn-img" :src="handsFreeSrc"></image>
    <text class="btn-text">
      {{ t("speaker") }}
      {{ isEarPhone ? t("speaker disabled") : t("speaker enabled") }}
    </text>
  </view>
</template>

<script setup lang="ts">
import { computed, ref, onMounted } from "vue";
import {
  NAME,
  StoreName,
} from "@/uni_modules/TencentCloud-Call/callkit/callServices/const";
import { t } from "../../callServices/locales";
import HANDSFREE_ON_SRC from "../assets/handsfree-on.png";
import HANDSFREE_OFF_SRC from "../assets/handsfree-off.png";
import { AudioPlaybackDevice, MediaType } from "../../../utssdk/interface";

const isEarPhone = ref();


const handsFreeSrc = computed(() => {
  return isEarPhone.value ? HANDSFREE_OFF_SRC : HANDSFREE_ON_SRC;
});

const handleSwitchAudioPlay = () => {
  const targetAudioPlay = isEarPhone.value
    ? AudioPlaybackDevice.Speakerphone
    : AudioPlaybackDevice.Earpiece;
  uni.$TUICallKit.selectAudioPlaybackDevice(targetAudioPlay);
  isEarPhone.value = !isEarPhone.value;
  uni.$TUIStore.update(
    StoreName.CALL,
    NAME.IS_LOCAL_SPEAKER_OPEN,
    isEarPhone.value
  );
  uni.$TUIStore.update(
    StoreName.CALL,
    NAME.CURRENT_SPEAKER_STATUS,
    targetAudioPlay
  );
};

onMounted(() => {
  const savedSpeakerStatus = uni.$TUIStore.getData(
    StoreName.CALL,
    NAME.CURRENT_SPEAKER_STATUS
  );
  const currentType = uni.$TUIStore.getData(StoreName.CALL, NAME.MEDIA_TYPE);

  if (savedSpeakerStatus !== undefined) {
    isEarPhone.value = savedSpeakerStatus === AudioPlaybackDevice.Earpiece;
  } else {
    isEarPhone.value = currentType === MediaType.Audio;
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
