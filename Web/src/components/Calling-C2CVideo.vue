<script setup lang="ts">
import { TUICallKitServer } from '../index';
import { onMounted, watch, ref, nextTick } from "vue";
import { remoteList, profile, t, getVolumeByUserID } from '../store/index';
import MicrophoneIcon from './MicrophoneIcon.vue';
import Switch2SVG from '../icons/switch2.vue';
import MicrophoneClosedSVG from '../icons/microphoneClosed.vue';
import { isMobile } from "../utils";
import "../style.css";

onMounted(() => {
  TUICallKitServer.startLocalView('local');
  checkUserViewRender();
});

watch(remoteList, () => {
  checkUserViewRender();
}, {
  flush: "post",
  deep: true,
});

const checkUserViewRender = () => {
  if (remoteList.value.length !== 1) return;
  const remoteUserItem = remoteList.value[0];
    if (!remoteUserItem.isEntered || !remoteUserItem.isReadyRender) return;
  TUICallKitServer.startRemoteView(remoteUserItem.userID);
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
          <MicrophoneIcon :volume="getVolumeByUserID(profile.userID)" v-if="profile?.microphone" />
          <MicrophoneClosedSVG v-else />
        </div>
        {{ `${profile?.nick} ${t('me')}` }}
      </span>
      <div class="switch-large-small" @click="switchUserView" v-show="!isMobile">
        <Switch2SVG />
      </div>
    </div>
    <template v-if="remoteList.length >= 1">
      <div :id="remoteList[0].userID" :class="remoteClass" @click="h5SwitchUserView">
        <span class="tag" v-show="!isMobile">
          <div class="microphone-icon-container">
            <MicrophoneIcon :volume="getVolumeByUserID(remoteList[0]?.userID)" v-if="remoteList[0]?.microphone" />
            <MicrophoneClosedSVG  v-else />
          </div>
          {{ remoteList[0]?.nick }}
        </span>
        <div class="switch-large-small" @click="switchUserView" v-show="!isMobile">
          <Switch2SVG />
        </div>
      </div>
    </template>
  </div>
</template>