<script setup lang="ts">
import Dialing from "./Dialing.vue";
import ControlPanel from "./ControlPanel.vue";
import CallingGroup from "./Calling-Group.vue";
import CallingC2CVideo from './Calling-C2CVideo.vue';
import { status } from "../store";
import { STATUS } from '../constants';
import { TUICallKitServer } from "../index";
import '../style.css';

const props = defineProps<{
  beforeCalling?: Function,
  afterCalling?: Function
}>()
const { beforeCalling, afterCalling } = props;
TUICallKitServer.setCallback({ beforeCalling, afterCalling });

</script>

<template>
  <div class="tui-call-kit">
    <Dialing
      v-if="status === STATUS.BE_INVITED || status === STATUS.DIALING_C2C || status === STATUS.CALLING_C2C_AUDIO" />
    <CallingC2CVideo v-if="status === STATUS.CALLING_C2C_VIDEO" />
    <CallingGroup
      v-if="status === STATUS.DIALING_GROUP || status === STATUS.CALLING_GROUP_AUDIO || status === STATUS.CALLING_GROUP_VIDEO" />
    <ControlPanel v-if="status !== STATUS.IDLE" />
  </div>
</template>
