<script setup lang="ts">
import { status, remoteList, dialingInfo, callType, getVolumeByUserID } from "../store"
import { STATUS, CALL_TYPE_STRING } from '../constants'
import MicrophoneIcon from "./MicrophoneIcon.vue";
import MicrophoneClosedSVG from '../icons/microphoneClosed.vue';
import "../style.css"
import { onMounted } from "vue";
import { TUICallKitServer } from "../";
import { isMobile } from "../utils";

onMounted(() => {
  if (status.value === STATUS.DIALING_C2C && callType.value === CALL_TYPE_STRING.VIDEO) {
    TUICallKitServer.openCamera("local");
    const dialingWrapper = document.getElementsByClassName("dialing-wrapper")[0] as HTMLElement;
    dialingWrapper.style.opacity = "100%";
  }
});

</script>

<template>
  <div class="dialing-wrapper">
    <!-- Preview local video when dialing 1v1 video call -->
    <div id="local" class="dialing-local" v-if="status === STATUS.DIALING_C2C && callType === CALL_TYPE_STRING.VIDEO"> </div>
    <!-- The hint of calling. Displayed when 1.it is not in the h5 mode (desktop mode) 2.it is in the h5 mode, be invited by other users 3.during the audio call-->
    <div class="dialing-content" v-if="!isMobile || status === STATUS.BE_INVITED || status === STATUS.CALLING_C2C_AUDIO">
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
