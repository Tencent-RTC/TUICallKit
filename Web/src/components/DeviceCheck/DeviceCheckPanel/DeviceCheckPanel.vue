<template>
  <div class="device-check-container">
    <div class="header">
      <p> {{ t('Device Detection') }} </p>
      <Icon :src="ChaSrc" :size="20" @click="$emit('closePanel')" style="cursor: pointer;"/>
    </div>
    <div class="camera-box box">
      <p class="device-title"> {{ t('Camera') }} </p>
      <div class="camera-content">
        <el-select
          v-model="showCamera"
          class="device-select"
          @change="updateCameraDevice">
          <el-option v-for="(item, index) in cameraList" :key="index" :label="item.label" :value="item.value"/>
        </el-select>
        <div class="camera-video" ref="video_bg"></div>  
        <el-checkbox 
          :checked="isMirror"
          :label="t('Mirror')"
          @change="handleMirrorChange"
        />
      </div>
    </div>
    <div class="mic-box box">
      <p class="device-title"> {{ t('Microphone') }} </p>
      <div class="mic-content">
        <el-select
          v-model="showMic"
          class="device-select"
          @change="updateMicDevice">
          <el-option v-for="(item, index) in micList" :key="index" :label="item.label" :value="item.value"/>
        </el-select>
        <p> {{ t('Please adjust the device volume and say \"hello\" into the microphone to test it~') }} </p>
        <div class="mic-volume">
          <p> {{ t('Output') }} </p>
          <div class="volume-box">
            <VolumeBar :volume="volume"/>
          </div>
        </div>
      </div>
    </div>
    <div class="speaker-box box">
      <p> {{ t('Speaker') }} </p>
      <div class="speaker-content">
        <el-select
          v-model="showSpeaker"
          class="device-select"
          @change="updateSpeakerDevice"
        >
          <el-option v-for="(item, index) in speakerList" :key="index" :label="item.label" :value="item.value"/>
        </el-select>
        <p> {{ t('Please adjust the device volume and click to play the audio below to test it~') }} </p>
        <div class="speaker-audio">
          <p> {{ t('Audio') }} </p>
          <audio class='audio-play' :src=audioSrc controls />
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, onUnmounted, ref, toRefs, watchEffect } from 'vue';
import { useLanguage, useDeviceCheck } from '../../../hooks';
import { DEVICE_TYPE } from '../../../interface';
import Icon from '../../common/Icon/Icon.vue';
import VolumeBar from '../VolumeBar/VolumeBar.vue';
import ChaSrc from '../../../assets/GroupCall/cha.svg';
import testAudioZh from '../../../assets/DeviceCheck/test-audio-zh.mp3';
import testAudioEn from '../../../assets/DeviceCheck/test-audio-en.mp3';

const { t, language } = useLanguage();
const { cameraList, speakerList, micList } = toRefs(useDeviceCheck());
const { volume, startLocalPreview, updateLocalPreview, updateCurrentDevice, destroyTRTC } = useDeviceCheck();

const isMirror = ref(false);
const showCamera = ref('');
const showMic = ref('');
const showSpeaker = ref('');

watchEffect(() => {
  showCamera.value = showCamera.value || cameraList.value[0]?.label;
  showMic.value = showMic.value || micList.value[0]?.label;
  showSpeaker.value = showSpeaker.value || speakerList.value[0]?.label;
});

const audioSrc = computed(() => {
  return language.value.includes('zh') ? testAudioZh : testAudioEn;
})

const handleMirrorChange = () => {
  isMirror.value = !isMirror.value;
  updateLocalPreview(isMirror.value);
}
const updateCameraDevice = async (value: string) => {
  await updateCurrentDevice(DEVICE_TYPE.CAMERA, value);
}
const updateMicDevice = async (value: string) => {
  await updateCurrentDevice(DEVICE_TYPE.MIC, value);
}
const updateSpeakerDevice = async (value: string) => { 
  await updateCurrentDevice(DEVICE_TYPE.SPEAKER, value);
}

onMounted(() => {
  startLocalPreview('camera-video');
})

onUnmounted(() => {
  destroyTRTC();
})
</script>

<style lang="scss" scoped>
.device-check-container {
  box-sizing: border-box;
  width: 520px;
  padding: 30px;
  background: #FFFFFF;
  box-shadow: 0px 3px 8px #E9F0FB;
  border-radius: 12px;
  position: absolute;
  z-index: 100;
  top: 80px;
  right: 15px;
  display: flex;
  flex-direction: column;
  gap: 30px 0;

  .header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    p {
      font-weight: 500;
      font-size: 20px;
      line-height: 24px;
      color: #000000;
    }
  }

  .camera-box {
    .camera-content {
      display: flex;
      flex-direction: column;
      gap: 16px 0;

      .camera-video {
        width: 360px;
        height: 200px;
        background-color: #E9F0FB;
      }
    }

  }

  .mic-box, .speaker-box {
    .mic-content, .speaker-content {
      display: flex;
      flex-direction: column;
      gap: 8px 0;
      &>p {
        font-weight: 400;
        font-size: 12px;
        color: #888888;
      }
      .mic-volume, .speaker-audio {
        display: flex;
        gap: 0 14px;
        align-items: center;
        p {
          font-weight: 400;
          font-size: 14px;
          color: #000000;
        }
      }
    }
  }
}

.box {
  display: flex;
  justify-content: space-between;
  gap: 0 30px;

  &>p {
    font-weight: 500;
    font-size: 16px;
    line-height: 22px;
    color: #000000;
  }
}
.device-select {
  width: 360px;
  height: 32px;
  background-color: #E9F0FB;
}
.audio-play {
  height: 34px;
  background: #F0F0F0;
  border-radius: 46px;
  margin-left: 3px;
}
.volume-box {
  display: flex;
  flex-direction: row;
  gap: 0 10px ;
}
</style>