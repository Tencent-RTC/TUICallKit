import { onMounted, onUnmounted, ref } from 'vue';
import TRTC from "trtc-sdk-v5";
import { IDeviceInfo, DEVICE_TYPE, IAudioVolumeEvent } from "../interface";

const trtc = TRTC.create();

export function useDevice() {
  const cameraList = ref<IDeviceInfo[]>([]);
  const micList = ref<IDeviceInfo[]>([]);
  const speakerList = ref<IDeviceInfo[]>([]);
  const volume = ref<number>(0);

  const getDeviceList = () => {
    TRTC.getCameraList().then((res: IDeviceInfo[]) => {
      res.map(item => item.value = item.deviceId);
      cameraList.value = res;
    })
    TRTC.getMicrophoneList().then((res: IDeviceInfo[]) => {
      res.map(item => item.value = item.deviceId);
      micList.value = res;
    })
    TRTC.getSpeakerList().then((res: IDeviceInfo[]) => {
      res.map(item => item.value = item.deviceId);
      speakerList.value = res;
    })
  }
  const updateCurrentDevice = async (type: DEVICE_TYPE, deviceId: string) => {
    if (type === DEVICE_TYPE.CAMERA) {
      await trtc.updateLocalVideo({ option: { cameraId: deviceId }});
    } else if (type === DEVICE_TYPE.MIC) {
      await trtc.updateLocalAudio({ option: { microphoneId: deviceId }});
    } else if (type === DEVICE_TYPE.SPEAKER) {
      await TRTC.setCurrentSpeaker(deviceId);
    }
  }
  const startLocalPreview = async (viewId: string) => {
    await trtc.startLocalVideo({
      view: (document.getElementsByClassName(viewId)[0]) as HTMLElement,
    });
    trtc.enableAudioVolumeEvaluation();
    await trtc.startLocalAudio({ publish: false });
  }
  const updateLocalPreview = async (isMirror: boolean) => {
    await trtc.updateLocalVideo({
      option: {
        mirror: isMirror ? 'publish' : 'view',
      }
    });
  }

  const handleAudioVolumeEvent = (event: IAudioVolumeEvent) => {
    volume.value = Math.ceil(event?.result[0].volume / 5);
  }
  const handleDeviceChangedEvent = () => {
    getDeviceList();
  }
  const addTRTCEventListener = () => {
    trtc.on(TRTC.EVENT.AUDIO_VOLUME, handleAudioVolumeEvent);
    trtc.on(TRTC.EVENT.DEVICE_CHANGED, handleDeviceChangedEvent);
  }
  const removeTRTCEventListener = () => {
    trtc.off(TRTC.EVENT.AUDIO_VOLUME, handleAudioVolumeEvent);
    trtc.off(TRTC.EVENT.DEVICE_CHANGED, handleDeviceChangedEvent);
  }

  const destroyTRTC = () => {
    trtc.stopLocalVideo().then();
    trtc.stopLocalAudio().then();
    removeTRTCEventListener();
  }

  onMounted(() => {
    getDeviceList();
    addTRTCEventListener();
  });

  onUnmounted(() => {
    destroyTRTC();
  })

  return {
    cameraList: cameraList,
    micList,
    speakerList,
    volume,
    startLocalPreview,
    updateLocalPreview,
    updateCurrentDevice,
    destroyTRTC,
  }
}

export default useDevice;
