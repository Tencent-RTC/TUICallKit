import { ref } from '../adapter/vue-demi';
import { AudioPlayBackDevice } from '@trtc/call-engine-lite-wx';
import {
  TUIStore,
  StoreName,
  TUICallKitAPI,
  NAME,
} from './TUICallService/index';
import { DeviceStatus } from '../constants/call';

// Device UI state.
// `microphoneStatus` / `cameraStatus` mirror the local user info from the
// store; `currentAudioRoute` mirrors the isEarPhone flag maintained by the
// call service (SPEAKER = 0, EAR = 1).
const microphoneStatus = ref<DeviceStatus>(DeviceStatus.OFF);
const cameraStatus = ref<DeviceStatus>(DeviceStatus.OFF);
const isFrontCamera = ref<boolean>(true);
const currentAudioRoute = ref<AudioPlayBackDevice>(AudioPlayBackDevice.SPEAKER);

const duration = ref<number>(0);

const openLocalCamera = async () => await TUICallKitAPI.openCamera('localVideo');
const closeLocalCamera = async () => await TUICallKitAPI.closeCamera();
const switchCamera = async () => await TUICallKitAPI.switchCamera();
const openLocalMicrophone = async () => await TUICallKitAPI.openMicrophone();
const closeLocalMicrophone = async () => await TUICallKitAPI.closeMicrophone();
const setAudioRoute = async () => await TUICallKitAPI.setSoundMode();


TUIStore?.watch(StoreName.CALL, {
  [NAME.CAMERA_POSITION]: _handleCameraPositionChange,
  [NAME.IS_EAR_PHONE]: _handleIsEarPhoneChange,
  [NAME.LOCAL_USER_INFO]: _handleLocalUserInfoChange,
});
function _handleCameraPositionChange(value: boolean) {
  isFrontCamera.value = value;
}
function _handleIsEarPhoneChange(value: boolean | undefined) {
  // isEarPhone === true      -> audio route is EAR (receiver)
  // isEarPhone === false     -> audio route is SPEAKER (loudspeaker)
  // isEarPhone === undefined -> not yet chosen, fall back to SPEAKER default
  currentAudioRoute.value = value === true ? AudioPlayBackDevice.EAR : AudioPlayBackDevice.SPEAKER;
}
function _handleLocalUserInfoChange(value: any) {
  // Keep device UI state in sync with the authoritative local user info
  // written by openMicrophone / openCamera / closeMicrophone / closeCamera.
  microphoneStatus.value = value?.isMicrophoneOpened ? DeviceStatus.ON : DeviceStatus.OFF;
  cameraStatus.value = value?.isCameraOpened ? DeviceStatus.ON : DeviceStatus.OFF;
}


function useDeviceState() {
  return {
    // state
    microphoneStatus,
    cameraStatus,
    isFrontCamera,
    currentAudioRoute,

    // actions
    openLocalMicrophone,
    closeLocalMicrophone,
    openLocalCamera,
    closeLocalCamera,
    switchCamera,
    setAudioRoute,
  };
}

export { useDeviceState };
