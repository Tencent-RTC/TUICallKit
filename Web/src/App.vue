<template>
  <div id="app">
    <header-nav></header-nav>
    <transition name="fade" mode="out-in">
      <router-view class="view"></router-view>
    </transition>
    <el-dialog :title="callTypeDisplayName" :visible.sync="isShowNewInvitationDialog" width="400px">
      <span>{{this.getNewInvitationDialogContent()}}</span>
      <span slot="footer" class="dialog-footer">
        <el-button @click="handleRejectCall">拒绝</el-button>
        <el-button type="primary" @click="handleAccept">接听</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import { mapState } from "vuex";
import { log } from "./utils";
import HeaderNav from "./components/header-nav";
let timeout;

export default {
  name: "App",
  components: {
    HeaderNav
  },
  watch: {
  },
  computed: mapState({
    isLogin: state => state.isLogin,
    loginUserInfo: state => state.loginUserInfo,
    callStatus: state => state.callStatus,
    isAccepted: state => state.isAccepted,
    meetingUserIdList: state => state.meetingUserIdList,
    muteVideoUserIdList: state => state.muteVideoUserIdList,
    muteAudioUserIdList: state => state.muteAudioUserIdList
  }),
  async created() {
    this.initListener();
  },
  data() {
    return {
      isInviterCanceled: false,
      isShowNewInvitationDialog: false,
      inviterName: "",
      callTypeDisplayName: "",
      inviteData: {},
      inviteId: "",
      hiddenCallEndMessage: false
    };
  },
  destroyed() {
    this.removeListener();
  },
  methods: {
    initListener: function() {
      this.$tuiCallEngine.on(this.TUICallEvent.ERROR, this.handleError);
      this.$tuiCallEngine.on(
        this.TUICallEvent.INVITED,
        this.handleNewInvitationReceived
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.USER_ACCEPT,
        this.handleUserAccept
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.USER_ENTER,
        this.handleUserEnter
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.USER_LEAVE,
        this.handleUserLeave
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.REJECT,
        this.handleInviteeReject
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.LINE_BUSY,
        this.handleInviteeLineBusy
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.CALLING_CANCEL,
        this.handleInviterCancel
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.KICKED_OUT,
        this.handleKickedOut
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.CALLING_TIMEOUT,
        this.handleCallTimeout
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.NO_RESP,
        this.handleNoResponse
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.CALLING_END,
        this.handleCallEnd
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.USER_VIDEO_AVAILABLE,
        this.handleUserVideoChange
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.USER_AUDIO_AVAILABLE,
        this.handleUserAudioChange
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.CALL_TYPE_CHANGED,
        this.handleCallTypeChange
      );
      this.$tuiCallEngine.on(
        this.TUICallEvent.DEVICED_UPDATED,
        this.handleDeviceUpdated
      );
    },
    removeListener: function() {
      this.$tuiCallEngine.off(this.TUICallEvent.ERROR, this.handleError);
      this.$tuiCallEngine.off(
        this.TUICallEvent.INVITED,
        this.handleNewInvitationReceived
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.USER_ACCEPT,
        this.handleUserAccept
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.USER_ENTER,
        this.handleUserEnter
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.USER_LEAVE,
        this.handleUserLeave
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.REJECT,
        this.handleInviteeReject
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.LINE_BUSY,
        this.handleInviteeLineBusy
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.CALLING_CANCEL,
        this.handleInviterCancel
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.KICKED_OUT,
        this.handleKickedOut
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.CALLING_TIMEOUT,
        this.handleCallTimeout
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.NO_RESP,
        this.handleNoResponse
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.CALLING_END,
        this.handleCallEnd
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.USER_VIDEO_AVAILABLE,
        this.handleUserVideoChange
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.USER_AUDIO_AVAILABLE,
        this.handleUserAudioChange
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.CALL_TYPE_CHANGED,
        this.handleCallTypeChange
      );
      this.$tuiCallEngine.off(
        this.TUICallEvent.DEVICED_UPDATED,
        this.handleDeviceUpdated
      );
    },
    handleError: function() {},
    async handleNewInvitationReceived(payload) {
      const { inviteID, sponsor, inviteData } = payload;
      log(`handleNewInvitationReceived ${JSON.stringify(payload)}`);
      if (inviteData.callEnd) {
        // 最后一个人发送 invite 进行挂断
        this.$store.commit("updateCallStatus", "idle");
        return;
      }

      // 这里需要考虑忙线的情况
      if (this.callStatus === "calling" || this.callStatus === "connected") {
        await this.$tuiCallEngine.reject({ inviteID, isBusy: true });
        return;
      }

      const { callType } = inviteData;
      this.inviteData = inviteData;
      this.inviteID = inviteID;
      this.isInviterCanceled = false;
      this.$store.commit("updateIsInviter", false);
      this.$store.commit("updateCallStatus", "calling");
      const response  = await this.$tim.getUserProfile({userIDList: [sponsor]})
      this.inviterName = response.data[0].nick || sponsor;
      this.callTypeDisplayName =
        callType === this.TUICallType.AUDIO_CALL
          ? "语音通话"
          : "视频通话";
      this.isShowNewInvitationDialog = true;
      this.$store.commit("updateCallType", callType);
    },
    getNewInvitationDialogContent: function() {
      return `来自${this.inviterName}的${this.callTypeDisplayName}`;
    },
    handleRejectCall: async function() {
      try {
        const { callType } = this.inviteData;
        await this.$tuiCallEngine.reject({
          inviteID: this.inviteID,
          isBusy: false,
          callType
        });
        this.dissolveMeetingIfNeed();
      } catch (e) {
        this.dissolveMeetingIfNeed();
      }
    },

    handleAccept: function() {
      this.handleDebounce(this.handleAcceptCall(), 500);
    },

    handleDebounce: function(func, wait) {
      let context = this;
      let args = arguments;
      if (timeout) clearTimeout(timeout);
      timeout = setTimeout(() => {
        func.apply(context, args);
      }, wait);
    },

    handleAcceptCall: async function() {
      try {
        const { callType, roomID } = this.inviteData;
        this.$store.commit("userJoinMeeting", this.loginUserInfo.userId);
        await this.$tuiCallEngine.accept({
          inviteID: this.inviteID,
          roomID,
          callType
        });
        this.isShowNewInvitationDialog = false;
        this.$router.push({
          name: 'call',
          query: {
            type: callType
          }
        });
      } catch (e) {
        this.dissolveMeetingIfNeed();
      }
    },
    handleUserAccept: function({ userID }) {
      this.$store.commit("userAccepted", true);
      console.log(userID, "accepted");
    },
    handleUserEnter: function({ userID }) {
      // 建立连接
      this.$store.commit("userJoinMeeting", userID);
      if (this.callStatus === "calling") {
        // 如果是邀请者, 则建立连接
        this.$nextTick(() => {
          // 需要先等远程用户 id 的节点渲染到 dom 上
          this.$store.commit("updateCallStatus", "connected");
        });
      } else {
        // 第n (n >= 3)个人被邀请入会, 并且他不是第 n 个人的邀请人
        this.$nextTick(() => {
          // 需要先等远程用户 id 的节点渲染到 dom 上
          this.$tuiCallEngine.startRemoteView({
            userID: userID,
            videoViewDomID: `video-${userID}`
          });
        });
      }
    },
    handleUserLeave: function({ userID }) {
      if (this.meetingUserIdList.length == 2) {
        this.$store.commit("updateCallStatus", "idle");
      }
      this.$store.commit("userLeaveMeeting", userID);
    },
    handleInviteeReject: async function({ userID }) {
      const response  = await this.$tim.getUserProfile({userIDList: [userID]})
      this.$message.warning(`${response.data[0].nick || userID}拒绝通话`);
      this.dissolveMeetingIfNeed();
    },
    handleInviteeLineBusy: async function({ sponsor, userID }) {
      if (sponsor !== window.sessionStorage.getItem('userId')) {
        return
      }
      const response  = await this.$tim.getUserProfile({userIDList: [userID]})
      this.$message.warning(`${response.data[0].nick || userID}忙线`);
      this.dissolveMeetingIfNeed();
    },
    handleInviterCancel: function() {
      // 邀请被取消
      this.isShowNewInvitationDialog = false;
      this.$message.warning("通话已取消");
      this.dissolveMeetingIfNeed();
    },
    handleKickedOut: function() {
      //重复登陆，被踢出房间
      this.$store.commit("userAccepted", false);
      this.$tuiCallEngine.logout();
      this.$store.commit("userLogoutSuccess");
    },
    // 作为被邀请方会收到，收到该回调说明本次通话超时未应答
    handleCallTimeout: function() {
      this.isShowNewInvitationDialog = false;
      this.hiddenCallEndMessage = true;
      this.$message.warning("通话超时未应答");
      this.dissolveMeetingIfNeed();
    },
    handleCallEnd: function() {
      if (this.hiddenCallEndMessage) {
        this.hiddenCallEndMessage = false;
      }else {
        this.$message.success("通话已结束");
      } 
      this.$tuiCallEngine.hangup();
      this.dissolveMeetingIfNeed();
      this.$router.push("/home");
      this.$store.commit("userAccepted", false);
    },
    handleNoResponse: async function({ userIDList }) {
      this.hiddenCallEndMessage = true;
      const response  = await this.$tim.getUserProfile({userIDList: [userIDList[0]]})
      this.$message.warning(`${response.data[0].nick || userIDList[0]}无应答`);
      this.dissolveMeetingIfNeed();
    },
    handleUserVideoChange: function({ userID, isVideoAvailable }) {
      log(
        `handleUserVideoChange userID, ${userID} isVideoAvailable ${isVideoAvailable}`
      );
      if (isVideoAvailable) {
        const muteUserList = this.muteAudioUserIdList.filter(
          currentID => currentID !== userID
        );
        this.$store.commit("updateMuteVideoUserIdList", muteUserList);
      } else {
        const muteUserList = this.muteAudioUserIdList.concat(userID);
        this.$store.commit("updateMuteVideoUserIdList", muteUserList);
      }
    },
    handleUserAudioChange: function({ userID, isAudioAvailable }) {
      log(
        `handleUserAudioChange userID, ${userID} isAudioAvailable ${isAudioAvailable}`
      );
      if (isAudioAvailable) {
        const muteUserList = this.muteAudioUserIdList.filter(
          currentID => currentID !== userID
        );
        this.$store.commit("updateMuteAudioUserIdList", muteUserList);
      } else {
        const muteUserList = this.muteAudioUserIdList.concat(userID);
        this.$store.commit("updateMuteAudioUserIdList", muteUserList);
      }
    },
    dissolveMeetingIfNeed() {
      this.$store.commit("updateCallStatus", "idle");
      this.isShowNewInvitationDialog = false;
      if (this.meetingUserIdList.length < 2) {
        this.$store.commit("dissolveMeeting");
      }
    },
    handleCallTypeChange({newCallType}) {
      this.$store.commit("updateCallType", newCallType);
    },
    handleDeviceUpdated ({ microphoneList, cameraList, currentMicrophone, currentCamera}) {
      const updateDevices = {
        micList: microphoneList,
        cameraList,
        currentMicrophone,
        currentCamera
      }
      this.$store.commit("updateDeviceList", updateDevices);
    },
  }
};
</script>

<style scoped>
@import url('./styles/common.css');
</style>
