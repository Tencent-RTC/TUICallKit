import  { useEffect, useState } from "react";
import TRTC from "trtc-sdk-v5";
import { IDeviceInfo, DEVICE_TYPE } from "../interface";

const trtc = TRTC.create();
export function useDevice() {
  const [cameraList, setCameraList] = useState<IDeviceInfo[]>([]);
  const [micList, setMicList] = useState<IDeviceInfo[]>([]);
  const [speakerList, setSpeakerList] = useState<IDeviceInfo[]>([]);
  const [volume, setVolume] = useState<number>(0);

  const getDeviceList = () => {
    TRTC.getCameraList().then((res: IDeviceInfo[]) => {
      res.map(item => item.value = item.deviceId);
      setCameraList(res);
    })
    TRTC.getMicrophoneList().then((res: IDeviceInfo[]) => {
      res.map(item => item.value = item.deviceId);
      setMicList(res);
    })
    TRTC.getSpeakerList().then((res: IDeviceInfo[]) => {
      res.map(item => item.value = item.deviceId);
      setSpeakerList(res);
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
  const addTRTCEventListener = () => {
    trtc.on(TRTC.EVENT.AUDIO_VOLUME, event => { 
      setVolume(Math.ceil(event.result[0].volume / 5));
    });
    trtc.on(TRTC.EVENT.DEVICE_CHANGED, () => {
      getDeviceList();
    });
  }
  const removeTRTCEventListener = () => {
    trtc.off(TRTC.EVENT.AUDIO_VOLUME, () => {});
    trtc.off(TRTC.EVENT.DEVICE_CHANGED, () => {});
  }

  useEffect(() => {
    getDeviceList();
    addTRTCEventListener();
    return () => {
      trtc.stopLocalVideo().then();
      trtc.stopLocalAudio().then();
      removeTRTCEventListener();
    }
  }, []);

  return {
    cameraList,
    micList,
    speakerList,
    volume,
    startLocalPreview,
    updateLocalPreview,
    updateCurrentDevice,
  }
}

export default useDevice;
