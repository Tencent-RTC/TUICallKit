<template>
  <div>
    <select class="device-select" :value="activeDeviceId" @change="handleChange">
      <option
        v-for="(item, index) in deviceList"
        :value="item.deviceId"
        :key="index">{{ item.label }}</option>
    </select>
    </div>
</template>

<script>
import TRTC from 'trtc-js-sdk';
const getDeviceList = async (deviceType) => {
  let deviceList = [];
  switch (deviceType) {
    case 'camera':
      deviceList = await TRTC.getCameras();
      break;
    case 'microphone':
      deviceList = await TRTC.getMicrophones();
      break;
    case 'speaker':
      deviceList = await TRTC.getSpeakers();
      break;
    default:
      break;
  }
  return deviceList;
};
export default {
  name: 'DeviceSelect',
  props: {
    deviceType: String,
    onChange: Function,
    choseDevice: Object,
  },
  data() {
    return {
      deviceList: [],
      activeDevice: {},
      activeDeviceId: '',
    };
  },
  watch: {
    activeDevice: {
      deep: true,
      handler(val) {
        if (val && JSON.stringify(val) !== '{}') {
          this.onChange && this.onChange(val);
        }
      },
    },
  },
  methods: {
    async getDeviceListData() {
      const list = await getDeviceList(this.deviceType);
      const deviceIdList = list.map(item => item.deviceId);
      this.deviceList = list;
      if (this.choseDevice && deviceIdList.indexOf(this.choseDevice.deviceId) >= 0) {
        [this.activeDevice] = list.filter(item => item.deviceId === this.choseDevice.deviceId);
        this.activeDeviceId = this.choseDevice.deviceId;
      } else {
        [this.activeDevice] = list;
        this.activeDeviceId = list[0].deviceId;
      }
    },
    handleChange(event) {
      const deviceID = event.target.value;
      const activeDevice = this.deviceList.find(item => item.deviceId === deviceID);
      this.activeDevice = activeDevice;
      this.activeDeviceId = deviceID;
    },
  },
  mounted() {
    navigator.mediaDevices.addEventListener('devicechange', async () => {
      const newList = await getDeviceList(this.deviceType);
      this.deviceList = newList;
    });
    this.getDeviceListData();
  },
};
</script>

<style lang="scss" src="./index.scss" scoped></style>
