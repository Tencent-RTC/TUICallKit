import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

function createStore() {
  return new Vuex.Store({
    state: {
      isLogin: false,
      loginUserInfo: null,

      // trtc 相关
      callStatus: '', // 状态, idle, calling, connected
      isInviter: false, // c2c 通话，说不定一开始不是 inviter, 后面邀请了别人就是 inviter 了
      isAccepted: false,
      meetingUserIdList: [],
      muteVideoUserIdList: [],
      muteAudioUserIdList: [],
      callType: 0, // 通话类型, 1: 语音通话, 2: 视频通话
      devices: {
        micList: [],
        cameraList: [],
        currentMicrophone: {},
        currentCamera: {}
      }
    },
    mutations: {
      userLoginSuccess(state) {
        state.isLogin = true;
      },
      userLogoutSuccess(state) {
        state.isLogin = false;
        state.loginUserInfo = null;
      },
      setLoginUserInfo(state, payload) {
        const { userId, userSig, nick, avatar } = payload;
        state.loginUserInfo = {
          userId, userSig, nick, avatar
        }
      },

      updateIsInviter(state, isInviter) {
        state.isInviter = isInviter;
      },
      updateCallStatus(state, callStatus) {
        state.callStatus = callStatus;
      },
      userJoinMeeting(state, userId) {
        if (state.meetingUserIdList.indexOf(userId) === -1) {
          state.meetingUserIdList.push(userId);
        }
      },
      userAccepted(state, isAccepted) {
        state.isAccepted = isAccepted;
      },
      userLeaveMeeting(state, userId) {
        const index = state.meetingUserIdList.findIndex(item => item === userId);
        if (index >= 0) {
          state.meetingUserIdList.splice(index, 1);
        }
      },
      dissolveMeeting(state) {
        state.meetingUserIdList = [];
        state.muteVideoUserIdList = [];
        state.muteAudioUserIdList = [];
      },
      updateMuteVideoUserIdList(state, userIdList) {
        state.muteVideoUserIdList = userIdList;
      },
      updateMuteAudioUserIdList(state, userIdList) {
        state.muteAudioUserIdList = userIdList;
      },
      updateCallType(state, newCallType) {
        state.callType = newCallType;
      },
      updateDeviceList(state, updateDevices) {
        state.devices = updateDevices;
      }
    }
  });
}

const store = createStore();
export default store;
