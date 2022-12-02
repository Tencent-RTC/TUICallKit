<template>
  <div v-if="activeDetector === currentDetector" class="testing-body">
    <div class="device-list">
      <span class="device-list-title">扬声器选择</span>
      <DeviceSelect
        deviceType="speaker"
        :choseDevice="choseDevice"
        :onChange="handleSpeakerChange"></DeviceSelect>
    </div>
    <div class="audio-player-container">
      <div class="audio-player-info">请调高设备音量，点击播放下面的音频试试～</div>
      <audio id="audio-player" :src="audioUrl" controls></audio>
    </div>
    <div class="testing-info-container">
      <div class="testing-info">是否可以听到声音？</div>
      <div class="button-list">
        <Button type="outlined" :onClick="() => handleCompleted('error', speakerLabel)">听不到</Button>
        <Button type="contained" :onClick="() => handleCompleted('success', speakerLabel)">听的到</Button>
      </div>
    </div>
  </div>
</template>

<script>
import DeviceSelect from './deviceSelect.vue';
import Button from './button.vue';
export default {
  name: 'speakerDetector',
  props: {
    audioUrl: {
      type: String,
      default: 'https://1256993030.vod2.myqcloud.com/d520582dvodtransgzp1256993030/45f1edea3701925920950247965/v.f1010.mp3',
    },
    activeDetector: String,
    handleCompleted: Function,
  },
  components: {
    DeviceSelect,
    Button,
  },
  data() {
    return {
      audioPlayer: null,
      currentDetector: 'speaker',
      speakerLabel: '',
      url: '',
      choseDevice: null,
    };
  },
  watch: {
    activeDetector(val, oldVal) {
      if (val === this.currentDetector) {
        this.audioPlayer = document.getElementById('audio-player');
      }
      if (oldVal === this.currentDetector) {
        if (this.audioPlayer && !this.audioPlayer.paused) {
          this.audioPlayer.pause();
        }
        if (this.audioPlayer) {
          this.audioPlayer.currentTime = 0;
        }
      }
    },
  },
  methods: {
    async handleSpeakerChange(speakerDevice) {
      this.choseDevice = speakerDevice;
      const { deviceId, label } = speakerDevice;
      this.audioPlayer && (await this.audioPlayer.setSinkId(deviceId));
      this.speakerLabel = label;
    },
  },
};
</script>

<style lang="scss" src="./index.scss" scoped></style>
