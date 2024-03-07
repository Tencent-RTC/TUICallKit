<template>
  <div v-if="activeDetector === currentDetector" class="testing-body">
    <div class="testing-list">
      <div class="testing-item-container">
        <div>operating system</div>
        <div :class="!detectorInfo.system ? 'network-loading' : ''">
          {{ detectorInfo.system }}
        </div>
      </div>
      <div class="testing-item-container">
        <div>Browser</div>
        <div :class="!detectorInfo.browser ? 'network-loading' : ''">
          {{ detectorInfo.browser }}
        </div>
      </div>
      <div class="testing-item-container">
        <div>Whether to support TRTC</div>
        <div :class="!detectorInfo.TRTCSupport ? 'network-loading' : ''">
          {{ detectorInfo.TRTCSupport }}
        </div>
      </div>
      <div class="testing-item-container">
        <div>Whether to support screen sharing</div>
        <div :class="!detectorInfo.screenMediaSupport ? 'network-loading' : ''">
          {{ detectorInfo.screenMediaSupport }}
        </div>
      </div>
      <div class="testing-item-container">
        <div>Network delay</div>
        <div :class="!detectorInfo.rtt ? 'network-loading' : ''">
          {{ detectorInfo.rtt ? `${detectorInfo.rtt}ms` : '' }}
        </div>
      </div>
      <div class="testing-item-container">
        <div>Uplink network quality</div>
        <div :class="!NETWORK_QUALITY[detectorInfo.uplinkQuality] ? 'network-loading' : ''">
          {{ NETWORK_QUALITY[detectorInfo.uplinkQuality] || '' }}
        </div>
      </div>
      <div class="testing-item-container">
        <div>Downstream network quality</div>
        <div :class="!NETWORK_QUALITY[detectorInfo.downlinkQuality] ? 'network-loading' : ''">
          {{ NETWORK_QUALITY[detectorInfo.downlinkQuality] || '' }}
        </div>
      </div>
    </div>
    <Button v-if="count > 0" class="gray-button" type="disabled">{{ `Remaining detection time（${count}）s` }}</Button>
    <Button
      v-else
      class="report-button"
      type="contained"
      :onClick="generateReport">View test report</Button>
  </div>
</template>

<script>
import RTCDetect from 'rtc-detect';
import TRTC from 'trtc-js-sdk';
import Button from './button.vue';
import { NETWORK_QUALITY } from './utils';
export default {
  name: 'networkDetector',
  components: {
    Button,
  },
  props: {
    activeDetector: String,
    networkDetectInfo: Object,
    handleCompleted: Function,
    generateReport: Function,
  },
  data() {
    return {
      NETWORK_QUALITY,
      currentDetector: 'network',
      detectorInfo: {},
      count: 15,
      timer: null,
      uplinkClient: null,
      uplinkStream: null,
      downlinkClient: null,
      networkTestingResult: {
        uplinkNetworkQualities: [],
        downlinkNetworkQualities: [],
        rttList: [],
      },
    };
  },
  computed: {
  },
  watch: {
    activeDetector(val, oldVal) {
      if (val === this.currentDetector && this.count !== 0) {
        this.count = 15;
        this.getDetectorInfo();
      }
      if (oldVal === this.currentDetector) {
        clearInterval(this.timer);
        this.uplinkStream && this.uplinkStream.close();
        this.uplinkClient && this.uplinkClient.leave();
        this.downlinkClient && this.downlinkClient.leave();
      }
    },
    count(val) {
      if (val === 0) {
        this.getAverageInfo(this.detectorInfo);
        this.uplinkStream && this.uplinkStream.close();
        this.uplinkClient && this.uplinkClient.leave();
        this.downlinkClient && this.downlinkClient.leave();
      }
    },
  },
  methods: {
    async testUplinkNetworkQuality() {
      const { sdkAppId, roomId } = this.networkDetectInfo;
      const { uplinkUserId, uplinkUserSig } = this.networkDetectInfo.uplinkUserInfo;
      this.uplinkClient = TRTC.createClient({
        sdkAppId,
        userId: uplinkUserId,
        userSig: uplinkUserSig,
        mode: 'rtc',
        useStringRoomId: typeof(roomId) === 'string',
      });

      this.uplinkStream = TRTC.createStream({ audio: true, video: true });
      await this.uplinkStream.initialize();

      this.uplinkClient.on('network-quality', async (event) => {
        const { uplinkNetworkQuality } = event;
        this.networkTestingResult.uplinkNetworkQualities.push(uplinkNetworkQuality);
        this.detectorInfo.uplinkQuality = uplinkNetworkQuality;
        const { rtt } = await this.uplinkClient.getTransportStats();
        this.detectorInfo.rtt = rtt;
        this.networkTestingResult.rttList.push(rtt);
      });

      await this.uplinkClient.join({ roomId });
      await this.uplinkClient.publish(this.uplinkStream);
    },
    async testDownlinkNetworkQuality() {
      const { sdkAppId, roomId } = this.networkDetectInfo;
      const { downlinkUserId, downlinkUserSig } = this.networkDetectInfo.downlinkUserInfo;
      this.downlinkClient = TRTC.createClient({
        sdkAppId,
        userId: downlinkUserId,
        userSig: downlinkUserSig,
        mode: 'rtc',
        useStringRoomId: typeof(roomId) === 'string',
      });

      this.downlinkClient.on('stream-added', async (event) => {
        await this.downlinkClient.subscribe(event.stream, { audio: true, video: true });
        this.downlinkClient.on('network-quality', (event) => {
          const { downlinkNetworkQuality } = event;
          this.networkTestingResult.downlinkNetworkQualities.push(downlinkNetworkQuality);
          this.detectorInfo.downlinkQuality = downlinkNetworkQuality;
        });
      });

      await this.downlinkClient.join({ roomId });
    },
    getAverageInfo(detectorInfo) {
      const uplinkAverageQuality = Math.ceil(this.networkTestingResult.uplinkNetworkQualities
        .reduce((value, current) => value + current, 0) / this.networkTestingResult.uplinkNetworkQualities.length);
      const downlinkAverageQuality = Math.ceil(this.networkTestingResult.downlinkNetworkQualities
        .reduce((value, current) => value + current, 0) / this.networkTestingResult.downlinkNetworkQualities.length);
      const rttAverageQuality = Math.ceil(this.networkTestingResult.rttList
        .reduce((value, current) => value + current, 0) / this.networkTestingResult.rttList.length);
      const detectorResultInfo = {
        ...detectorInfo,
        uplinkQuality: uplinkAverageQuality,
        downlinkQuality: downlinkAverageQuality,
        rtt: rttAverageQuality,
      };
      this.handleCompleted('success', detectorResultInfo);
      this.detectorInfo = detectorResultInfo;
    },
    async getDetectorInfo() {
      const detect = new RTCDetect();
      const systemResult = detect.getSystem();
      const webRTCSupportResult = await detect.isTRTCSupported();
      const APISupportResult = detect.getAPISupported();

      this.detectorInfo = {
        system: systemResult.OS,
        browser: `${systemResult.browser.name} ${systemResult.browser.version}`,
        TRTCSupport: webRTCSupportResult.result ? 'support' : 'not support',
        screenMediaSupport: APISupportResult.isScreenCaptureAPISupported ? 'support' : 'not support',
      };

      this.timer = setInterval(() => {
        this.count = this.count - 1;
        if (this.count === 0) {
          clearInterval(this.timer);
        }
      }, 1000);

      this.testUplinkNetworkQuality();
      this.testDownlinkNetworkQuality();
    },
  },
};
</script>

<style lang="scss" src="./index.scss" scoped></style>
