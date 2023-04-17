<script setup lang="ts">
import { status, remoteList, dialingInfo, callType, getVolumeByUserID } from "../store"
import { STATUS, CALL_TYPE_STRING } from '../constants'
import MicrophoneIcon from "./MicrophoneIcon.vue";
import MicrophoneClosedSVG from '../icons/microphoneClosed.vue';
import { isMobile } from "../utils";
import { computed } from "@vue/reactivity";

const opacityValue = computed(() => {
  return (status.value === STATUS.DIALING_C2C && callType.value === CALL_TYPE_STRING.VIDEO) ? "1" : "0.7";
});

</script>

<template>
  <div class="dialing-wrapper" :style="`opacity: ${opacityValue}`">
    <!-- Preview local video when dialing 1v1 video call -->
    <div id="local-dialing" class="dialing-local" v-if="status === STATUS.DIALING_C2C && callType === CALL_TYPE_STRING.VIDEO"> 
    </div>
    <!-- The hint of calling. When previewing video in H5 mode, this component is not displayed.-->
    <div class="dialing-content" v-show="!(isMobile && status === STATUS.DIALING_C2C && callType === CALL_TYPE_STRING.VIDEO)">
      <div class="dialing-user-id">
        <template v-if="remoteList.length >= 1">
          {{ remoteList[0]?.nick }}
        </template>
        <div class="microphone-icon-container" v-if="status === STATUS.CALLING_C2C_AUDIO">
          <MicrophoneIcon :volume="getVolumeByUserID(remoteList[0].userID)" v-if="remoteList[0]?.microphone" />
          <MicrophoneClosedSVG v-else />
        </div>
      </div>
      <div class="dialing-info"> {{ dialingInfo }} </div>
    </div>
  </div>
</template>

<style scoped>
@import "../style.css";
</style>
