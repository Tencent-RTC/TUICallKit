import { ref, watch } from 'vue';
import { CallMediaType, AudioPlayBackDevice } from '@trtc/call-engine-lite-wx';
import {
  TUIStore,
  StoreName,
  TUICallKitAPI,
  NAME,
} from './TUICallService/index';

const inviterId = ref<string>('');
const mediaType = ref<CallMediaType>(CallMediaType.UNKNOWN);
const duration = ref<number>(0);
const pusherId = ref<string>(TUIStore.getData(StoreName.CALL, NAME.PUSHER_ID));

TUIStore?.watch(StoreName.CALL, {
  [NAME.CALL_MEDIA_TYPE]: _handleCallMediaTypeChange,
  [NAME.DURATION]: _handleCallDurationChange,
  [NAME.CALL_INFO]: _handleCallInfoChange,
  [NAME.PUSHER_ID]: _handlePusherIdChange,
});
function _handleCallMediaTypeChange(value: CallMediaType) {
  mediaType.value = value;
}
function _handleCallDurationChange(value: Number) {
  duration.value = value;
}
function _handleCallInfoChange(obj: any) {
  if (inviterId.value === obj.inviterId) return;
  inviterId.value = obj.inviterId || '';
}
function _handlePusherIdChange(value: string) {
  pusherId.value = value;
}

const calls = async (params: any) => await TUICallKitAPI.calls(params);
const accept = async () => await TUICallKitAPI.accept();
const reject = async () => await TUICallKitAPI.reject();
const hangup = async () => await TUICallKitAPI.hangup();

// Group call: invite additional users into an ongoing group call.
const inviteUser = async (params: any) => await TUICallKitAPI.inviteUser(params);

const setSelfInfo = async (params) => await TUICallKitAPI.setSelfInfo(params);
const setSoundMode = async (type) => await TUICallKitAPI.setSoundMode(type);


function useCallListState() {
  return {
    // state
    inviterId,
    mediaType,
    duration,
    pusherId,

    // actions
    calls,
    accept,
    reject,
    hangup,
    inviteUser,
    setSoundMode,
    setSelfInfo,
  };
}

export { useCallListState };
