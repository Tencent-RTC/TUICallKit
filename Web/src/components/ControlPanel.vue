<script setup lang="ts">
import { TUICallKitServer } from '../index';
import { onMounted, ref } from 'vue';
import ControlPanelItem from './ControlPanelItem.vue';
import { profile, remoteList, changeRemoteList, callType, status, t, dialingInfo } from '../store';
import { STATUS, CALL_TYPE_STRING } from '../constants'
import RejectSVG from '../icons/reject.vue';
import AcceptAudioSVG from '../icons/acceptAudio.vue';
import AcceptVideoSVG from '../icons/acceptVideo.vue';
import AddSVG from '../icons/add.vue';
import CameraSVG from '../icons/camera.vue';
import MicrophoneSVG from '../icons/microphone.vue';
import SwitchSVG from '../icons/switch.vue';
import HangupSVG from '../icons/hangup.vue'
import MicrophoneClosedBigSVG from '../icons/microphoneClosedBig.vue';
import CameraClosedBigSVG from '../icons/cameraClosedBig.vue';
import { isMobile } from '../utils';
import "../style.css";

const cameraList = ref<any>([]);
const microphoneList = ref<any>([]);
const currentCamera = ref<string>("");
const currentMicrophone = ref("");
const currentVideoQuality = ref("");

const openCameraDetail = ref<boolean>(false);
const openMicrophoneDetail = ref<boolean>(false);

const freshDeviceList = async () => {
  cameraList.value = await TUICallKitServer.getDeviceList('camera');
  microphoneList.value = await TUICallKitServer.getDeviceList('microphones');
}

onMounted(() => {
  freshDeviceList();
  document.documentElement.addEventListener('click', (e) => {
    openCameraDetail.value = false;
    openMicrophoneDetail.value = false;
  });
});

const hangup = () => {
  TUICallKitServer.hangup();
}
function switchCameraDevice() {
  TUICallKitServer.switchDevice("video", currentCamera.value);
  openCameraDetail.value = false;
}

const switchMicrophoneDevice = () => {
  TUICallKitServer.switchDevice('audio', currentMicrophone.value);
  openMicrophoneDetail.value = false;
};

const toggleCamera = async () => {
  if (profile.value?.camera) {
    await TUICallKitServer.closeCamera();
  } else {
    await TUICallKitServer.openCamera();
  }
}

const toggleMicrophone = async () => {
  if (profile.value?.microphone) {
    await TUICallKitServer.closeMicrophone();
  } else {
    await TUICallKitServer.openMicrophone();
  }
}

const setVideoQuality = async () => {
  await TUICallKitServer.setVideoQuality(currentVideoQuality.value);
}

const switchCallMediaType = async () => {
  await TUICallKitServer.switchCallMediaType();
}

function addPerson_debug() {
  changeRemoteList([...remoteList.value, {
    userID: `qerTest${remoteList.value.length}`,
    isEntered: false,
    microphone: true,
    camera: true,
    isReadyRender: false,
  }])
}

function accept() {
  TUICallKitServer.accept();
}

function reject() {
  TUICallKitServer.reject();
}

</script>

<template>
  <div class="control-wrapper">
    <div v-if="isMobile && status !== STATUS.CALLING_C2C_AUDIO"> {{ dialingInfo }} </div>
    <div class="panel-button-area"> 
      <template v-if="status === STATUS.BE_INVITED">
        <ControlPanelItem :action="reject" :isMobile="isMobile" :size="isMobile ? 'medium' : 'small'">
          <template #text>
            {{ t('reject') }}
          </template>
          <template #icon>
            <RejectSVG />
          </template>
        </ControlPanelItem>

        <ControlPanelItem :action="accept" :isMobile="isMobile" :size="isMobile ? 'medium' : 'small'">
          <template #text>
            {{ t('accept') }}
          </template>
          <template #icon>
            <template v-if="callType === CALL_TYPE_STRING.AUDIO">
              <AcceptAudioSVG />
            </template>
            <template v-else-if="callType === CALL_TYPE_STRING.VIDEO">
              <AcceptVideoSVG />
            </template>
          </template>
        </ControlPanelItem>
      </template>

      <template v-else-if="status !== 'idle'">
        <ControlPanelItem :action="toggleCamera" :hasDetail="!isMobile" v-if="callType === CALL_TYPE_STRING.VIDEO" :isMobile="isMobile" :size="isMobile ? 'medium' : 'small'">
          <template #text>
            {{ profile?.camera ? t('camera-opened') : t('camera-closed') }}
          </template>
          <template #icon>
            <CameraSVG v-if="profile?.camera"/>
            <CameraClosedBigSVG v-if="!profile?.camera"/>
          </template>
          <template #detail>
            <div class="control-item-detail-row">
              <div> {{ t('camera') }} </div>
              <select class="device-select" v-model="currentCamera" @change="switchCameraDevice">
                <option value="" selected disabled hidden>{{ cameraList && cameraList[0]?.label }}</option>
                <option v-for="camera in cameraList" :value="camera.deviceId" :key="camera.deviceId"> {{ camera.label }} </option>
              </select>
            </div>
            <div v-if="status === STATUS.DIALING_C2C">
              <div> {{ t('image-resolution') }} </div>
              <select class="device-select" v-model="currentVideoQuality" @change="setVideoQuality">
                <option value="" selected disabled hidden>{{ t('default-image-resolution') }} </option>
                <option value="480p" selected> 480p </option>
                <option value="720p" selected> 720p </option>
                <option value="1080p" selected> 1080p </option>
              </select>
            </div>
          </template>
        </ControlPanelItem>

        <ControlPanelItem :action="toggleMicrophone" :hasDetail="!isMobile" :isMobile="isMobile" :size="isMobile ? 'medium' : 'small'">
          <template #text>
            {{ profile?.microphone ? t('microphone-opened') : t('microphone-closed') }}
          </template>
          <template #icon>
            <MicrophoneSVG v-if="profile?.microphone"/>
            <MicrophoneClosedBigSVG v-if="!profile?.microphone" />
          </template>
          <template #detail>
            <div>
              {{ t('microphone') }}
              <select class="device-select" v-model="currentMicrophone" @change="switchMicrophoneDevice">
                <option value="" selected disabled hidden>{{ microphoneList && microphoneList[0]?.label }}</option>
                <option v-for="microphone in microphoneList" :value="microphone.deviceId" :key="microphone.deviceId"> {{ microphone.label }}
                </option>
              </select>
            </div>
          </template>
        </ControlPanelItem>

        <ControlPanelItem :action="addPerson_debug" v-if="false">
          <template #text>
            {{ t('invited-person') }}
          </template>
          <template #icon>
            <AddSVG />
          </template>
        </ControlPanelItem>

        <ControlPanelItem :action="switchCallMediaType" v-if="status === 'calling-c2c-video'" v-show="!isMobile">
          <template #text>
            {{ t('video-to-audio') }}
          </template>
          <template #icon>
            <SwitchSVG />
          </template>
        </ControlPanelItem>

        <ControlPanelItem :action="hangup" v-show="!isMobile">
          <template #text>
            {{ isMobile ? '' : t('hangup') }}
          </template>
          <template #icon>
            <HangupSVG />
          </template>
        </ControlPanelItem>
      </template>
    </div>
    <div class="panel-hangup" v-if="status !== STATUS.IDLE && status !== STATUS.BE_INVITED">
      <ControlPanelItem :action="hangup" :size="isMobile ? 'large' : 'small'" v-show="isMobile">
        <template #text>
          {{ isMobile ? '' : t('hangup') }}
        </template>
        <template #icon>
          <HangupSVG />
        </template>
      </ControlPanelItem>
    </div>
  </div>
</template>