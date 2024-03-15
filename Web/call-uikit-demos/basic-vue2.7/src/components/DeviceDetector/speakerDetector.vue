<template>
  <div v-if="activeDetector === currentDetector" class="testing-body">
    <div class="device-list">
      <span class="device-list-title">Speaker selection</span>
      <DeviceSelect
        deviceType="speaker"
        :choseDevice="choseDevice"
        :onChange="handleSpeakerChange"></DeviceSelect>
    </div>
    <div class="audio-player-container">
      <div class="audio-player-info">Please turn up the volume of your device and click to play the audio below to try ~</div>
      <audio id="audio-player" :src="audioUrl" controls></audio>
    </div>
    <div class="testing-info-container">
      <div class="testing-info">Can you hear the sound?</div>
      <div class="button-list">
        <Button type="outlined" :onClick="() => handleCompleted('error', speakerLabel)">Can't hear</Button>
        <Button type="contained" :onClick="() => handleCompleted('success', speakerLabel)">Can hear</Button>
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
