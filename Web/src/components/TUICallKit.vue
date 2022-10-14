<script setup lang="ts">
import Dialing from "./Dialing.vue";
import ControlPanel from "./ControlPanel.vue";
import CallingGroup from "./Calling-Group.vue";
import CallingC2CVideo from "./Calling-C2CVideo.vue";
import { profile, status, isMinimized } from "../store";
import { STATUS } from "../constants";
import { TUICallKitServer } from "../index";
import FloatCallEnd from "../icons/floatCallEnd.vue";
import FloatMicrophoneSVG from '../icons/floatMicrophone.vue';
import FloatMicrophoneClosedSVG from '../icons/floatMicrophoneClosed.vue';
import MinimizeSVG from '../icons/minimize.vue';
import FullScreenSVG from '../icons/fullScreen.vue';
import "../style.css";

const props = withDefaults(defineProps<{
  beforeCalling?: Function;
  afterCalling?: Function;
  onMinimized?: Function;
  allowedMinimized?: boolean;
}>(), {
  allowedMinimized: true,
});
const { beforeCalling, afterCalling, onMinimized, allowedMinimized } = props;
TUICallKitServer.setCallback({ beforeCalling, afterCalling, onMinimized });

function toggleMinimize() {
  TUICallKitServer.toggleMinimize();
}

const hangup = () => {
  TUICallKitServer.hangup();
};

const toggleMicrophone = async () => {
  if (profile.value?.microphone) {
    await TUICallKitServer.closeMicrophone();
  } else {
    await TUICallKitServer.openMicrophone();
  }
}
</script>

<template>
  <div class="tui-call-kit" v-if="status !== STATUS.IDLE" v-show="!isMinimized">
    <div
      class="minimize"
      @click="toggleMinimize"
      v-if="status !== STATUS.IDLE && allowedMinimized === true && status !== STATUS.DIALING_C2C && status !== STATUS.DIALING_GROUP && status !== STATUS.BE_INVITED"
    >
    <MinimizeSVG />
  </div>
    <Dialing
      v-if="
        status === STATUS.BE_INVITED ||
        status === STATUS.DIALING_C2C ||
        status === STATUS.CALLING_C2C_AUDIO
      "
    />
    <CallingC2CVideo v-if="status === STATUS.CALLING_C2C_VIDEO" />
    <CallingGroup
      v-if="
        status === STATUS.DIALING_GROUP ||
        status === STATUS.CALLING_GROUP_AUDIO ||
        status === STATUS.CALLING_GROUP_VIDEO
      "
    />
    <ControlPanel v-if="status !== STATUS.IDLE" />
  </div>
</template>
