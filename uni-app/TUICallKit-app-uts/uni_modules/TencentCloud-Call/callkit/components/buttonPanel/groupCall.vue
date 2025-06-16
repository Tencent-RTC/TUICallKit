<template>
  <view class="button-panel-container" :style="{ width: viewWidth + 'px' }">
    <view
      class="button-group"
      v-if="callRole === CallRole.CALLER || callStatus === CallStatus.CONNECTED"
    >
      <view class="button-group-row">
        <tx-microphone />
        <tx-handsfree :default-open="mediaType === MediaType.VIDEO" />
        <tx-camera :default-open="mediaType === MediaType.VIDEO" />
      </view>
      <view class="button-group-bottom">
        <hangup :is-show-text="false" />
      </view>
    </view>

    <view
      class="button-group-bottom"
      v-if="callStatus === CallStatus.CALLING && callRole === CallRole.CALLEE"
    >
      <reject />
      <accept />
    </view>
  </view>
</template>

<script setup lang="ts">
import { onMounted, ref, toRefs, watch, defineProps } from "vue";
import {
  MediaType,
  CallStatus,
  CallRole,
} from "../../callServices/const/index";
import accept from "../button/accept.vue";
import hangup from "../button/hangup.vue";
import reject from "../button/reject.vue";
import txMicrophone from "../button/txMicrophone.vue";
import txHandsfree from "../button/txHandsfree.vue";
import txCamera from "../button/txCamera.vue";

const props = defineProps({
  callStatus: {
    type: CallStatus,
    default: CallStatus.IDLE,
  },
  mediaType: {
    type: MediaType,
    default: MediaType.UNKNOWN,
  },
  callRole: {
    type: CallRole,
    default: CallRole.UNKNOWN,
  },
});

const viewWidth = ref<number>(360);
const viewHeight = ref<number>(700);

onMounted(() => {
  viewWidth.value = uni.getWindowInfo().windowWidth;
  viewHeight.value = uni.getWindowInfo().windowHeight;
});
</script>

<style>
.button-panel-container {
  display: flex;
  justify-content: center;
}

.button-group {
  display: flex;
  flex-direction: column;
  justify-content: center;
  flex-wrap: wrap;
}

.button-group-row {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
}
.button-group-bottom {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
}
</style>
