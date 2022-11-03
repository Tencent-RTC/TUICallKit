<script setup lang="ts">
import { TUICallKitServer } from '../index';
import { onMounted, onUpdated, ref, nextTick } from "vue";
import { remoteList, profile, t } from '../store/index';
import MicrophoneIcon from './MicrophoneIcon.vue';
import Switch2SVG from '../icons/switch2.vue';
import MicrophoneClosedSVG from '../icons/microphoneClosed.vue';
import "../style.css";

onMounted(() => {
  refreshUserViewList();
});

onUpdated(() => {
  refreshUserViewList();
});

const refreshUserViewList = async () => {
  await nextTick();
  if (remoteList.value.length >= 1) {
    TUICallKitServer.startLocalView('local');
    TUICallKitServer.startRemoteView(remoteList.value[0].userID);
  }
}

const localClass = ref('small');
const remoteClass = ref('large');

const switchUserView = async () => {
  [localClass.value, remoteClass.value] = [remoteClass.value, localClass.value];
  await nextTick();
  const largeView = document.getElementsByClassName('large')[0] as HTMLElement;
  const smallView = document.getElementsByClassName('small')[0] as HTMLElement;
  smallView.style.height = "200px";
  largeView.style.height = "100%";
}

</script>
    
<template>
  <div class="calling-wrapper">
    <div id="local" :class="localClass">
      <span class="tag">
        <div class="microphone-icon-container">
          <MicrophoneIcon :volume="profile?.volume" v-if="profile?.microphone" />
          <!-- <img :src="microphoneClosedSVG" v-if="!profile?.microphone" /> -->
          <MicrophoneClosedSVG v-else />
        </div>
        {{ `${profile.userID} ${t('me')}` }}
      </span>
      <div class="switch-large-small" @click="switchUserView">
        <!-- <img :src="switch2SVG" /> -->
        <Switch2SVG />
      </div>
    </div>
    <template v-if="remoteList.length >= 1">
      <div :id='remoteList[0].userID' :class="remoteClass">
        <span class="tag">
          <div class="microphone-icon-container">
            <MicrophoneIcon :volume="remoteList[0].volume" v-if="remoteList[0]?.microphone" />
            <!-- <img :src="microphoneClosedSVG"  v-if="!remoteList[0]?.microphone"/> -->
            <MicrophoneClosedSVG  v-else />
          </div>
          {{ remoteList[0].userID }}
        </span>
        <div class="switch-large-small" @click="switchUserView">
          <!-- <img :src="switch2SVG" /> -->
          <Switch2SVG />
        </div>
      </div>
    </template>
  </div>
</template>