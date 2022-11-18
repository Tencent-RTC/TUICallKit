<script setup lang="ts">
import { TUICallKitServer } from '../index';
import { onMounted, onUpdated, ref, nextTick } from "vue";
import { remoteList, profile, t } from '../store/index';
import MicrophoneIcon from './MicrophoneIcon.vue';
import Switch2SVG from '../icons/switch2.vue';
import MicrophoneClosedSVG from '../icons/microphoneClosed.vue';
import { isMobile } from "../utils";
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
const localClassH5 = ref('small-h5');
const remoteClass = ref('large');

const switchUserView = async () => {
  if (isMobile) {
    [localClassH5.value, remoteClass.value] = [remoteClass.value, localClassH5.value];
  } else {
    [localClass.value, remoteClass.value] = [remoteClass.value, localClass.value];
    await nextTick();
    // reset to default size
    const largeView = document.getElementsByClassName('large')[0] as HTMLElement;
    const smallView = document.getElementsByClassName('small')[0] as HTMLElement;
    smallView.style.height = "170px";
    smallView.style.width = "260px";
    largeView.style.height = "100%";
    largeView.style.width = "100%";
  }
}

const h5SwitchUserView = async () => { 
  if (!isMobile) return;
  switchUserView();
}

</script>
    
<template>
  <div class="calling-wrapper">
    <div id="local" :class="isMobile ? localClassH5 : localClass" @click="h5SwitchUserView">
      <span class="tag" v-show="!isMobile">
        <div class="microphone-icon-container">
          <MicrophoneIcon :volume="profile?.volume" v-if="profile?.microphone" />
          <!-- <img :src="microphoneClosedSVG" v-if="!profile?.microphone" /> -->
          <MicrophoneClosedSVG v-else />
        </div>
        {{ `${profile.userID} ${t('me')}` }}
      </span>
      <div class="switch-large-small" @click="switchUserView" v-show="!isMobile">
        <!-- <img :src="switch2SVG" /> -->
        <Switch2SVG />
      </div>
    </div>
    <template v-if="remoteList.length >= 1">
      <div :id="remoteList[0].userID" :class="remoteClass" @click="h5SwitchUserView">
        <span class="tag" v-show="!isMobile">
          <div class="microphone-icon-container">
            <MicrophoneIcon :volume="remoteList[0].volume" v-if="remoteList[0]?.microphone" />
            <!-- <img :src="microphoneClosedSVG"  v-if="!remoteList[0]?.microphone"/> -->
            <MicrophoneClosedSVG  v-else />
          </div>
          {{ remoteList[0].userID }}
        </span>
        <div class="switch-large-small" @click="switchUserView" v-show="!isMobile">
          <!-- <img :src="switch2SVG" /> -->
          <Switch2SVG />
        </div>
      </div>
    </template>
  </div>
</template>