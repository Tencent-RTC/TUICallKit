<script setup lang="ts">
import { status, remoteList, dialingInfo } from "../store"
import { STATUS } from '../constants'
import MicrophoneIcon from "./MicrophoneIcon.vue";
import MicrophoneClosedSVG from '../icons/microphoneClosed.vue';
import "../style.css"
</script>

<template>
  <div class="dialing-wrapper">
    <div class="dialing-content">
      <div class="dialing-user-id">
        <template v-if="remoteList.length >= 1">
          {{ remoteList[0].userID }}
        </template>
        <div class="microphone-icon-container" v-if="status === STATUS.CALLING_C2C_AUDIO">
          <MicrophoneIcon :volume="remoteList[0]?.volume" v-if="remoteList[0]?.microphone" />
          <!-- <img :src="microphoneClosedSVG" v-if="!remoteList[0]?.microphone" /> -->
          <MicrophoneClosedSVG v-else />
        </div>
      </div>
      <div class="dialing-info"> {{ dialingInfo }} </div>
    </div>
  </div>
</template>
