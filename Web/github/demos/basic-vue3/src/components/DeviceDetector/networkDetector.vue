<template>
  <div v-if="activeDetector === currentDetector" class="testing-body">
    <div class="testing-list">
      <div class="testing-item-container">
        <div>操作系统</div>
        <div :class="!detectorInfo.system ? 'network-loading' : ''">
          {{ detectorInfo.system }}
        </div>
      </div>
      <div class="testing-item-container">
        <div>浏览器</div>
        <div :class="!detectorInfo.browser ? 'network-loading' : ''">
          {{ detectorInfo.browser }}
        </div>
      </div>
      <div class="testing-item-container">
        <div>是否支持TRTC</div>
        <div :class="!detectorInfo.TRTCSupport ? 'network-loading' : ''">
          {{ detectorInfo.TRTCSupport }}
        </div>
      </div>
      <div class="testing-item-container">
        <div>是否支持屏幕分享</div>
        <div :class="!detectorInfo.screenMediaSupport ? 'network-loading' : ''">
          {{ detectorInfo.screenMediaSupport }}
        </div>
      </div>
      <div class="testing-item-container">
        <div>网络延时</div>
        <div :class="!detectorInfo.rtt ? 'network-loading' : ''">
          {{ detectorInfo.rtt ? `${detectorInfo.rtt}ms` : '' }}
        </div>
      </div>
      <div class="testing-item-container">
        <div>上行网络质量</div>
        <div :class="!NETWORK_QUALITY[detectorInfo.uplinkQuality] ? 'network-loading' : ''">
          {{ NETWORK_QUALITY[detectorInfo.uplinkQuality] || '' }}
        </div>
      </div>
      <div class="testing-item-container">
        <div>下行网络质量</div>
        <div :class="!NETWORK_QUALITY[detectorInfo.downlinkQuality] ? 'network-loading' : ''">
          {{ NETWORK_QUALITY[detectorInfo.downlinkQuality] || '' }}
        </div>
      </div>
    </div>
    <Button v-if="count > 0" class="gray-button" type="disabled">{{ `剩余检测时间（${count}）s` }}</Button>
    <Button
      v-else
      class="report-button"
      type="contained"
      :onClick="generateReport">查看检测报告</Button>
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
    // 获取上行网络质量和RTT
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

      await this.uplinkClient.join({ roomId }); // 加入用于测试的房间
      await this.uplinkClient.publish(this.uplinkStream);
    },
    // 获取下行网络质量
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

      await this.downlinkClient.join({ roomId }); // 加入用于测试的房间
    },
    // 获取15秒检测平均值
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
        TRTCSupport: webRTCSupportResult.result ? '支持' : '不支持',
        screenMediaSupport: APISupportResult.isScreenCaptureAPISupported ? '支持' : '不支持',
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
