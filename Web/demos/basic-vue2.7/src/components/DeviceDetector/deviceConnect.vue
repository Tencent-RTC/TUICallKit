<template>
  <div class="device-connect">
    <div class="testing-title">Device connection</div>
    <div class="testing-prepare-info">
      {{ prepareInfo }}
    </div>
    <div class="device-display">
      <div v-for="(stepName, index) in stepNameList" :key="index">
        <div
          v-if="stepName === 'camera'"
          :class="showConnectResult && (deviceState.hasCameraConnect ? 'connect-success' : 'connect-fail')">
          <span class="device">
            <svg t="1630397874793" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="958" width="24" height="24"><path d="M489.244444 0a460.8 460.8 0 1 1 0 921.6A460.8 460.8 0 0 1 489.244444 0z m0 204.8a256 256 0 1 0 0 512 256 256 0 0 0 0-512z" opacity=".8" p-id="959"></path><path d="M489.244444 460.8m-153.6 0a153.6 153.6 0 1 0 307.2 0 153.6 153.6 0 1 0-307.2 0Z" opacity=".8" p-id="960"></path><path d="M120.604444 952.32a368.64 61.44 0 1 0 737.28 0 368.64 61.44 0 1 0-737.28 0Z" opacity=".8" p-id="961"></path></svg>
          </span>
        </div>
        <div
          v-if="stepName === 'microphone'"
          :class="showConnectResult && (deviceState.hasMicrophoneConnect ? 'connect-success' : 'connect-fail')">
          <span class="device">
            <svg t="1630397938861" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1205" width="24" height="24"><path d="M841.551448 434.423172A41.666207 41.666207 0 0 1 882.758621 476.548414c0 194.701241-144.454621 355.469241-329.551449 376.514207v86.722207h164.758069a41.666207 41.666207 0 0 1 41.207173 42.089931A41.666207 41.666207 0 0 1 717.965241 1024H306.034759A41.666207 41.666207 0 0 1 264.827586 981.874759a41.666207 41.666207 0 0 1 41.207173-42.089931h164.758069v-86.722207C285.696 832.052966 141.241379 671.249655 141.241379 476.548414a41.666207 41.666207 0 0 1 41.207173-42.125242 41.666207 41.666207 0 0 1 41.171862 42.125242c0 162.78069 129.129931 294.770759 288.379586 294.770758l8.827586-0.141241c155.153655-4.766897 279.552-134.850207 279.552-294.629517a41.666207 41.666207 0 0 1 41.171862-42.125242zM512 0c119.419586 0 216.275862 88.770207 216.275862 198.232276v317.228138c0 106.990345-92.513103 194.206897-208.154483 198.091034l-8.121379 0.141242c-119.419586 0-216.275862-88.770207-216.275862-198.232276V198.232276c0-106.990345 92.513103-194.206897 208.154483-198.091035L512 0z" opacity=".8" p-id="1206"></path></svg>
          </span>
        </div>
        <div
          v-if="stepName === 'speaker'"
          :class="showConnectResult && (deviceState.hasSpeakerConnect ? 'connect-success' : 'connect-fail')">
          <span class="device">
            <svg t="1629186923749" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="2923" width="24" height="24"><path d="M640 181.333333c0-46.037333-54.357333-70.4-88.746667-39.850666L359.552 311.850667a32 32 0 0 1-21.248 8.106666H181.333333A96 96 0 0 0 85.333333 415.957333v191.872a96 96 0 0 0 96 96h157.013334a32 32 0 0 1 21.248 8.106667l191.616 170.410667c34.389333 30.549333 88.789333 6.144 88.789333-39.850667V181.333333z m170.325333 70.272a32 32 0 0 1 44.757334 6.698667A424.917333 424.917333 0 0 1 938.666667 512a424.96 424.96 0 0 1-83.626667 253.696 32 32 0 0 1-51.413333-38.058667A360.917333 360.917333 0 0 0 874.666667 512a360.917333 360.917333 0 0 0-71.04-215.637333 32 32 0 0 1 6.698666-44.757334zM731.434667 357.12a32 32 0 0 1 43.392 12.928c22.869333 42.24 35.84 90.666667 35.84 141.994667a297.514667 297.514667 0 0 1-35.84 141.994666 32 32 0 0 1-56.32-30.464c17.92-33.152 28.16-71.082667 28.16-111.530666s-10.24-78.378667-28.16-111.530667a32 32 0 0 1 12.928-43.392z" opacity=".8" p-id="2924"></path></svg>
          </span>
        </div>
        <div
          v-if="stepName === 'network'"
          :class="showConnectResult && (deviceState.hasNetworkConnect ? 'connect-success' : 'connect-fail')">
          <span class="device">
            <svg t="1630400570252" class="icon" viewBox="0 0 1291 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1640" width="24" height="24"><path d="M992.211478 583.68A449.758609 449.758609 0 0 0 650.017391 426.295652c-136.904348 0-259.561739 61.039304-342.194087 157.384348a90.156522 90.156522 0 0 0 136.859826 117.359304 269.846261 269.846261 0 0 1 205.334261-94.430608c82.142609 0 155.737043 36.641391 205.334261 94.386087a90.156522 90.156522 0 1 0 136.859826-117.359305zM559.86087 922.134261a90.156522 90.156522 0 1 0 180.313043 0 90.156522 90.156522 0 0 0-180.313043 0z" opacity=".8" p-id="1641"></path><path d="M1253.064348 289.124174A809.316174 809.316174 0 0 0 650.017391 20.613565a809.316174 809.316174 0 0 0-603.046956 268.466087 90.156522 90.156522 0 1 0 127.777391 127.065044l0.311652 0.26713A629.581913 629.581913 0 0 1 650.017391 200.926609c189.395478 0 359.290435 83.389217 474.957913 215.485217l0.267131-0.26713a90.156522 90.156522 0 1 0 127.777391-127.065044z" opacity=".8" p-id="1642"></path></svg>
          </span>
        </div>
      </div>
      <div v-if="!showConnectResult" class="outer-progress">
        <div class="inner-progress" :style="{transform: `translateX(${progress - 100}%)`}"></div>
      </div>
    </div>
    <div v-if="!showConnectResult" class="text gray-text">The device is connecting, please wait</div>
    <div v-if="showConnectResult" :class="['text', `${connectResult.success ? 'green-text' : 'red-text'}`]">
      <span>{{connectResult.info}}</span>
      <div
        v-if="connectResult.remind"
        class="error-connect"
        @touchstart="() => setShowRemind(true)"
        @mouseenter="() => setShowRemind(true)"
        @touchend="() => setShowRemind(false)"
        @mouseleave="() => setShowRemind(false)">
        <span class="error-icon">
          <svg t="1626151898274" className="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3223" width="28" height="28"><path d="M1024 518.314667C1024 794.794667 794.737778 1024 505.685333 1024 229.205333 1024 0 794.737778 0 518.314667 0 229.262222 229.262222 0 505.685333 0 794.737778 0 1024 229.262222 1024 518.314667zM512 256a48.128 48.128 0 0 0-48.753778 51.370667L477.866667 614.4h68.266666l14.620445-307.029333A48.355556 48.355556 0 0 0 512 256z m0 512a51.2 51.2 0 1 0 0-102.4 51.2 51.2 0 0 0 0 102.4z" fill="#FF0000" p-id="3224"></path></svg>
        </span>
        <div v-if="showRemind" class="connect-attention-info" v-html="connectResult.remind"></div>
      </div>
    </div>
    <div class="button-container">
      <Button v-if="!showConnectResult" type='disabled'>Start detection</Button>
      <Button v-if="showReconnectButton" type='contained' :onClick="handleReset">reconnect</Button>
      <Button v-if="showStartDetectButton" type='contained' :onClick="startDeviceDetect">Start detection</Button>
    </div>
  </div>
</template>

<script>
import Button from './button.vue';
import {
  isOnline,
  handleGetUserMediaError,
} from './utils';
import TRTC from 'trtc-js-sdk';

const deviceFailAttention = '1. If the browser prompts, please select "Allow"<br>'
  + '2. If the anti-virus software pops up a prompt, please select "Allow"<br>'
  + '3. Check system settings to allow browser access to camera and microphone<br>'
  + '4. Check your browser settings to allow web pages to access your camera and microphone<br>'
  + '5. Check if the camera/microphone is correctly connected and turned on<br>'
  + '6. Try reconnecting camera/microphone<br>'
  + '7. Try restarting the device and re-detecting it';
const networkFailAttention = '1. Please check if the device is connected to the Internet<br>'
  + '2. Please refresh the webpage and check again<br>'
  + '3. Please try changing the network and testing again.';

export default {
  name: 'deviceConnect',
  components: {
    Button,
  },
  props: {
    stepNameList: {
      type: Array,
      default: () => [],
    },
    startDeviceDetect: Function,
  },
  data() {
    return {
      progress: 0,
      deviceState: {},
      connectResult: {},
      showConnectResult: false,
      progressInterval: null,
      showRemind: true,
    };
  },
  computed: {
    prepareInfo() {
      return 'Please confirm that the device is connected before device detection'
        + `${this.hasCameraDetect ? 'camera' : ''}`
        + `${this.hasMicrophoneDetect ? ',microphone' : ''}`
        + `${this.hasSpeakerDetect ? ',speaker' : ''}`
        + `${this.hasNetworkDetect ? 'and network' : ''}`;
    },
    hasCameraDetect() {
      return this.stepNameList.indexOf('camera') >= 0;
    },
    hasMicrophoneDetect() {
      return this.stepNameList.indexOf('microphone') >= 0;
    },
    hasSpeakerDetect() {
      return this.stepNameList.indexOf('speaker') >= 0;
    },
    hasNetworkDetect() {
      return this.stepNameList.indexOf('network') >= 0;
    },
    showReconnectButton() {
      const { deviceState } = this;
      return this.showConnectResult
        && !(deviceState.hasCameraConnect
        && deviceState.hasMicrophoneConnect
        && deviceState.hasSpeakerConnect
        && deviceState.hasNetworkConnect);
    },
    showStartDetectButton() {
      const { deviceState } = this;
      return this.showConnectResult
        && (deviceState.hasCameraConnect
        && deviceState.hasMicrophoneConnect
        && deviceState.hasSpeakerConnect
        && deviceState.hasNetworkConnect);
    },
  },
  watch: {
    showConnectResult: {
      immediate: true,
      handler(val) {
        if (!val) {
          this.progressInterval = setInterval(() => {
            this.progress += 10;
            if (this.progress === 100) {
              clearInterval(this.progressInterval);
              this.showConnectResult = true;
            }
          }, 200);
        }
      },
    },
  },
  methods: {
    setShowRemind(val) {
      this.showRemind = val;
    },
    handleReset() {
      this.progress = 0;
      this.connectResult = {};
      this.showConnectResult = false;
    },
    async getDeviceConnectResult() {
      let cameraList = [];
      let micList = [];
      let speakerList = [];
      try {
        cameraList = await TRTC.getCameras();
        micList = await TRTC.getMicrophones();
        speakerList = await TRTC.getSpeakers();
      } catch (error) {
        console.log('rtc-device-detector getDeviceList error', error);
      }
      const hasCameraDevice = cameraList.length > 0;
      const hasMicrophoneDevice = micList.length > 0;
      const hasSpeakerDevice = this.hasSpeakerDetect ? speakerList.length > 0 : true;
      const hasNetworkConnect = this.hasNetworkDetect ? await isOnline() : true;
      let deviceStateObj = {
        hasCameraDevice,
        hasMicrophoneDevice,
        hasSpeakerDevice,
        hasNetworkConnect,
        hasCameraConnect: false,
        hasMicrophoneConnect: false,
        hasSpeakerConnect: hasSpeakerDevice,
      };
      this.deviceState = deviceStateObj;
      this.connectResult = this.getDeviceConnectInfo(deviceStateObj);

      if (hasCameraDevice) {
        navigator.mediaDevices
          .getUserMedia({ video: true, audio: false })
          .then((stream) => {
            deviceStateObj = {
              ...deviceStateObj,
              hasCameraConnect: true,
            };
            this.deviceState = deviceStateObj;
            this.connectResult = this.getDeviceConnectInfo(deviceStateObj);
            stream.getTracks()[0].stop();
          })
          .catch((error) => {
            handleGetUserMediaError(error);
          });
      }

      if (hasMicrophoneDevice) {
        navigator.mediaDevices
          .getUserMedia({ video: false, audio: hasMicrophoneDevice })
          .then((stream) => {
            deviceStateObj = {
              ...deviceStateObj,
              hasMicrophoneConnect: hasMicrophoneDevice,
            };
            this.deviceState = deviceStateObj;
            this.connectResult = this.getDeviceConnectInfo(deviceStateObj);
            stream.getTracks()[0].stop();
          })
          .catch((error) => {
            handleGetUserMediaError(error);
          });
      }
    },
    getDeviceConnectInfo(deviceState) {
      let connectInfo = 'Connection error, please try again';
      if (deviceState.hasCameraConnect
        && deviceState.hasMicrophoneConnect
        && deviceState.hasSpeakerConnect
        && deviceState.hasNetworkConnect) {
        connectInfo = this.hasNetworkDetect ? 'The device and network are connected successfully, please start device detection.' : 'The device is connected successfully, please start device detection.';
        return {
          info: connectInfo,
          success: true,
        };
      }
      if (!(deviceState.hasCameraDevice && deviceState.hasMicrophoneDevice && deviceState.hasSpeakerDevice)) {
        connectInfo = `not detected${deviceState.hasCameraDevice ? '' : '【camera】'}${deviceState.hasMicrophoneDevice ? '' : '【microphone】'}${deviceState.hasSpeakerDevice ? '' : '【speaker】'}device, please check the device connection`;
        return {
          info: connectInfo,
          success: false,
        };
      }
      if (!(deviceState.hasCameraConnect && deviceState.hasMicrophoneConnect)) {
        connectInfo = deviceState.hasNetworkConnect
          ? 'Please allow the browser and web page to access the camera/microphone device'
          : 'Please allow the browser and web page to access the camera/microphone device and check the network connection';
        return {
          info: connectInfo,
          success: false,
          remind: deviceFailAttention,
        };
      }
      if (!deviceState.hasNetworkConnect) {
        connectInfo = 'Network connection failed, please check the network connection';
        return {
          info: connectInfo,
          success: false,
          remind: networkFailAttention,
        };
      }
      return {
        info: connectInfo,
        success: false,
      };
    },
  },
  mounted() {
    this.getDeviceConnectResult();
  },
};
</script>

<style lang="scss" src="./index.scss" scoped></style>
