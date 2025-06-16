<template>
  <text class="time" v-if="callStatus == CallStatus.CONNECTED">
    {{ callDuration }}
  </text>
</template>

<script setup lang="ts">
import { computed, watch, ref, onMounted } from "vue";
import {
  CallMediaType,
  CallRole,
  CallStatus,
  MediaType,
  NAME,
  StoreName,
} from "@/uni_modules/TencentCloud-Call/callkit/callServices/const";

const callDuration = ref(
  uni.$TUIStore.getData(StoreName.CALL, NAME.CALL_DURATION)
);
const callStatus = ref(uni.$TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS));

onMounted(() => {
  uni.$TUIStore.watch(StoreName.CALL, {
    [NAME.CALL_DURATION]: (res) => {
      callDuration.value = res;
    },
    [NAME.CALL_STATUS]: (res) => {
      callStatus.value = res;
    },
  });
});
</script>

<style>
.time {
  font-weight: 500;
  font-size: 14px;
  color: #d5e0f2;
}
</style>
