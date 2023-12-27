<template>
  <div v-if="activeDetector === currentDetector" class="testing-body">
      <div class="device-list">
        <span class="device-list-title">麦克风选择</span>
        <DeviceSelect
          deviceType="microphone"
          :choseDevice="choseDevice"
          :onChange="handleMicrophoneChange"></DeviceSelect>
      </div>
      <div class="mic-testing-container">
        <div class="mic-testing-info">对着麦克风说"哈喽"试试～</div>
        <div class="mic-bar-container">
          <div
            v-for="(item, index) in new Array(28).fill('')"
            :key="index"
            :class="[`mic-bar ${volumeNum > index && 'active'}`]"></div>
        </div>
        <div id="audio-container"></div>
      </div>
      <div class="testing-info-container">
        <div class="testing-info">是否可以看到音量图标跳动？</div>
        <div class="button-list">
          <Button type="outlined" :onClick="() => handleCompleted('error', microphoneLabel)">看不到</Button>
          <Button type="contained" :onClick="() => handleCompleted('success', microphoneLabel)">看的到</Button>
        </div>
      </div>
    </div>
</template>

<script>
import TRTC from 'trtc-js-sdk';
import Button from './button.vue';
import DeviceSelect from './deviceSelect.vue';
export default {
  name: 'micDetector',
  props: {
    activeDetector: String,
    handleCompleted: Function,
  },
  components: {
    Button,
    DeviceSelect,
  },
  data() {
    return {
      currentDetector: 'microphone',
      localStream: null,
      microphoneID: '',
      microphoneLabel: '',
      volumeNum: 0,
      choseDevice: null,
      timer: null,
    };
  },
  watch: {
    activeDetector(val, oldVal) {
      if (val === this.currentDetector && !this.localStream && this.microphoneID) {
        this.initStream(this.microphoneID);
      }
      if (oldVal === this.currentDetector) {
        this.localStream && this.localStream.close();
        this.localStream = null;
        clearInterval(this.timer);
        this.volumeNum = 0;
      }
    },
  },
  methods: {
    async initStream(microphoneID) {
      console.log('microphoneID', microphoneID);
      this.localStream = TRTC.createStream({
        video: false,
        audio: true,
        microphoneId: microphoneID,
      });
      await this.localStream.initialize();
      this.localStream.play('audio-container');
      this.timer = setInterval(() => {
        const volume = this.localStream.getAudioLevel();
        this.volumeNum = Math.ceil(28 * volume);
      }, 100);
    },

    async handleMicrophoneChange(microphoneDevice) {
      this.choseDevice = microphoneDevice;
      const { deviceId, label } = microphoneDevice;
      if (this.localStream) {
        this.localStream.switchDevice('audio', deviceId);
      } else {
        this.initStream(deviceId);
      }
      this.microphoneID = deviceId;
      this.microphoneLabel = label;
    },
  },
};
</script>

<style lang="scss" src="./index.scss" scoped></style>
