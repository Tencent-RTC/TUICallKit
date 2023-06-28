import { defineStore } from 'pinia';
import { MediaType, CallState, TRemoteUser } from '@/constants';

export const useCallInfoStore = defineStore('callInfo', {
  state: () => ({
    callType: MediaType.VIDEO,
    roomID: '',
    groupID: '',
    audioDeviceId: '',
    videoDeviceId: '',
    cameras: [],
    microphones: [],
    currentCamera: null,
    currentMicrophone: null,
    remoteUserList: [] as TRemoteUser[],
    callState: CallState.IDLE,
  }),
  actions: {
    updateRemoteUserList({ userID, isVideoAvailable }: TRemoteUser) {
      const index = this.remoteUserList.findIndex(item => item.userID === userID);

      if (index !== -1) {
        this.remoteUserList[index].isVideoAvailable = isVideoAvailable;
      } else {
        this.remoteUserList.push({ userID, isVideoAvailable });
      }
    },
    removeRemoteUser({ userID }: { userID: string }) {
      const index = this.remoteUserList.findIndex(item => item.userID === userID);
      this.remoteUserList.splice(index, 1);
    },
    toggleCallState(state: CallState) {
      this.callState = state;
      if (state === CallState.IDLE) {
        this.resetCallInfo();
      }
    },
    resetCallInfo() {
      this.$patch({
        groupID: '',
        roomID: '',
        remoteUserList: [],
        callState: CallState.IDLE,
        callType: MediaType.VIDEO,
      });
    },
  },
});
