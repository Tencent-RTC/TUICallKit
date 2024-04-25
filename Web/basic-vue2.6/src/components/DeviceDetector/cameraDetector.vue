<template>
  <div v-if="activeDetector === currentDetector" class="testing-body">
      <div class="device-list">
        <span class="device-list-title">Camera selection</span>
        <DeviceSelect
          deviceType="camera"
          :choseDevice="choseDevice"
          :onChange="handleCameraChange"></DeviceSelect>
      </div>
      <div id="camera-video" class="camera-video"></div>
      <div class="testing-info-container">
        <div class="testing-info">Can you see yourself clearly?</div>
        <div class="button-list">
          <Button type="outlined" :onClick="handleError">can not see</Button>
          <Button type="contained" :onClick="handleSuccess">can see</Button>
        </div>
      </div>
    </div>
</template>
<script>
import TRTC from 'trtc-js-sdk';
import Button from './button.vue';
import DeviceSelect from './deviceSelect.vue';
export default {
  name: 'cameraDetector',
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
      currentDetector: 'camera',
      localStream: null,
      cameraLabel: '',
      cameraID: '',
      choseDevice: null,
    };
  },
  watch: {
    activeDetector(val, oldVal) {
      if (val === this.currentDetector && !this.localStream && this.cameraID) {
        this.initStream(this.cameraID);
      }
      if (oldVal === this.currentDetector) {
        this.localStream && this.localStream.close();
        this.localStream = null;
      }
    },
  },
  methods: {
    async initStream(cameraID) {
      this.localStream = TRTC.createStream({
        video: true,
        audio: false,
        cameraId: cameraID,
      });
      await this.localStream.initialize();
      this.localStream.play('camera-video');
    },


    async handleCameraChange(cameraDevice) {
      this.choseDevice = cameraDevice;
      const { deviceId, label } = cameraDevice;
      if (this.localStream) {
        this.localStream.switchDevice('video', deviceId);
      } else {
        this.initStream(deviceId);
      }
      this.cameraID = deviceId;
      this.cameraLabel = label;
    },

    handleError() {
      this.handleCompleted('error', this.cameraLabel);
    },

    handleSuccess() {
      this.handleCompleted('success', this.cameraLabel);
    },
  },
};
</script>
<style lang="scss" src="./index.scss" scoped></style>
