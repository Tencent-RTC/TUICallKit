<template>
  <view class="button-panel-container" :style="{ width: viewWidth + 'px' }">
    <template v-if="mediaType === MediaType.AUDIO">
      <view
        class="button-group-row"
        v-if="callStatus === CallStatus.CALLING && callRole === CallRole.CALLER"
      >
        <tx-microphone />
        <hangup />
        <tx-handsfree :default-open="false" />
      </view>
      <view class="button-group-row" v-if="callStatus === CallStatus.CONNECTED">
        <tx-microphone />
        <hangup />
        <tx-handsfree :default-open="false" />
      </view>
      <view
        class="button-group-row"
        v-if="callStatus === CallStatus.CALLING && callRole === CallRole.CALLEE"
      >
        <reject />
        <accept />
      </view>
    </template>

    <template v-if="mediaType === MediaType.VIDEO">
      <view
        class="button-group"
        v-if="callStatus === CallStatus.CALLING && callRole === CallRole.CALLER"
      >
        <view class="button-group-row">
          <switch-camera />
          <blur />
          <tx-camera />
        </view>
        <view class="button-group-bottom">
          <hangup :is-show-text="false" />
        </view>
      </view>
      <view class="button-group" v-if="callStatus === CallStatus.CONNECTED">
        <view class="button-group-row">
          <tx-microphone />
          <tx-handsfree />
          <tx-camera />
        </view>
        <view class="button-group-row">
          <blur :size="35" :is-show-text="false" />
          <hangup :is-show-text="false" />
          <switch-camera :size="40" :is-show-text="false" />
        </view>
      </view>
      <view
        class="button-group"
        v-if="callStatus === CallStatus.CALLING && callRole === CallRole.CALLEE"
      >
        <view class="button-group-row">
          <switch-camera />
          <blur />
          <tx-camera />
        </view>
        <view class="button-group-row">
          <reject :is-show-text="false" />
          <accept :is-show-text="false" />
        </view>
      </view>
    </template>
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
import blur from "../button/blur.vue";
import txCamera from "../button/txCamera.vue";
import switchCamera from "../button/switchCamera.vue";

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
  justify-content: space-around;
  align-items: center;
}
.button-group-bottom {
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
