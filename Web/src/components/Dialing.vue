<script setup lang="ts">
import { remoteList, dialingInfo } from "../store"
import MicrophoneIcon from "./MicrophoneIcon.vue";
import microphoneClosedSVG from '../assets/microphoneClosed.svg';
import "../style.css"
</script>

<template>
  <div class="dialing-wrapper">
    <div class="dialing-content">
      <div class="dialing-user-id">
        {{ remoteList.length && remoteList[0].userID }}
        <div class="microphone-icon-container">
          <MicrophoneIcon :volume="remoteList[0]?.volume" v-if="remoteList[0]?.microphone" />
          <img :src="microphoneClosedSVG" v-if="!remoteList[0]?.microphone" />
        </div>
      </div>
      <div class="dialing-info"> {{ dialingInfo }} </div>
    </div>
  </div>
</template>
