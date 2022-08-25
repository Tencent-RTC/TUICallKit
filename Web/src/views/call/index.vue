<template>
  <div class="call-section">
    <div
      class="call-section-header"
    >Welcome {{loginUserInfo && (loginUserInfo.nick || loginUserInfo.userId)}}</div>
    <div>
      <label>userID:</label>
      <span>{{loginUserInfo.userId}}</span>
    </div>
    <div class="call-section-title">{{type === 1? '语音通话' : '视频通话'}}</div>
    <search-user @callUser="handleCallUser" @cancelCallUser="handleCancelCallUser"></search-user>
    <div :class="{ 'conference': true, 'is-show': isShowCall }">
      <div class="conference-header">通话区域</div>
      <div class="conference-list">
        <div
          v-for="userId in meetingUserIdList"
          :key="`call-${userId}`"
          :id="`call-${userId}`"
          :class="{'user-call-container': true, 'is-me': userId === loginUserInfo.userId}"
        >
          <div class="call-item" v-if="callType === 2">
            <div class="user-status">
              <div
                :class="{'user-video-status': true, 'is-mute': isUserMute(muteVideoUserIdList, userId)}"
              ></div>
              <div
                :class="{'user-audio-status': true, 'is-mute': isUserMute(muteAudioUserIdList, userId)}"
              ></div>
            </div>
            <div class="call-item-username">{{userId2User[userId]?.nick || userId2User[userId]?.userID}}{{userId2User[userId]?.self && '(me)'}}</div>
          </div>
          <div class="call-item audio" v-else>
            <div class="user-status">
              <div
                :class="{'user-audio-status': true, 'is-mute': isUserMute(muteAudioUserIdList, userId)}"
              ></div>
            </div>
            <div class="call-item-username">{{userId2User[userId]?.nick || userId2User[userId]?.userID}}{{userId2User[userId]?.self && '(me)'}}</div>
            <div class="call-item-avatar-wrapper">
              <img :src="userId2User[userId]?.avatar" onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'" />
            </div>
          </div>
        </div>
      </div>
      <div>{{showTime}}</div>
      <div class="conference-action">
        <el-button
          class="action-btn"
          type="success"
          @click="switchCallMode"
          v-if="type === 2"
        >视频通话切换语音通话</el-button>
        <el-button
          class="action-btn"
          type="success"
          @click="toggleVideo"
          v-if="type === 2"
        >{{isVideoOn ? '关闭摄像头' : '打开摄像头'}}</el-button>

        <el-button
          class="action-btn"
          type="success"
          @click="toggleAudio"
        >{{isAudioOn ? '关闭麦克风' : '打开麦克风'}}</el-button>

        <el-button class="action-btn" type="danger" @click="handleHangup">挂断</el-button>
      </div>
      <ul class="devices">
        <li class="devices-item" v-if="callType === 2">
          <label>摄像头：</label>
          <el-select :value="devices?.currentCamera?.deviceId" placeholder="请选择" @change="(deviceId)=>{switchDevice('video', deviceId)}">
            <el-option
              v-for="(item, index) in devices.cameraList"
              :key="index"
              :label="item.label"
              :value="item.deviceId">
            </el-option>
          </el-select>
        </li>
        <li class="devices-item">
          <label>麦克风：</label>
          <el-select :value="devices?.currentMicrophone?.deviceId" placeholder="请选择" @change="(deviceId)=>{switchDevice('audio', deviceId)}">
            <el-option
              v-for="(item, index) in devices.micList"
              :key="index"
              :label="item.label"
              :value="item.deviceId">
            </el-option>
          </el-select>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";
import SearchUser from "../../components/search-user";
import { formateTime } from "../../utils"
import { aegisReportEvent } from "../../utils/aegis"
export default {
  name: "Call",
  components: {
    SearchUser
  },
  computed: {
    ...mapState({
      loginUserInfo: state => state.loginUserInfo,
      callStatus: state => state.callStatus,
      isInviter: state => state.isInviter,
      meetingUserIdList: state => state.meetingUserIdList,
      muteVideoUserIdList: state => state.muteVideoUserIdList,
      muteAudioUserIdList: state => state.muteAudioUserIdList,
      callType: state => state.callType,
      devices: state => state.devices,
    }),
    showTime: function() {
      return formateTime(this.chatTime);
    },
  },
  data() {
    return {
      type: 1,
      isShowCall: false,
      isVideoOn: true,
      isAudioOn: true,
      userId2User: {},
      timer: 0,
      chatTime: 0,
      micList: [],
      cameraList: [],
      currentMicDeviceID: '',
      currentcameraDeviceID: ''
    };
  },
  mounted() {
    if (this.callStatus === "connected" && !this.isInviter) {
      aegisReportEvent("call", "call-1v1");
      this.$nextTick(()=>{
        this.updateUserId2Name(this.meetingUserIdList);
        this.startMeeting();
        this.showChatTime();
        this.getDevicesList();
      })
    }
    this.type = this.$route.query.type;
    this.$store.commit("updateCallType", this.type);
  },
  destroyed() {
    this.$store.commit("updateMuteVideoUserIdList", []);
    this.$store.commit("updateMuteAudioUserIdList", []);
    if (this.callStatus === "connected") {
      this.$tuiCallEngine.hangup();
      this.$store.commit("updateCallStatus", "idle");
    }
    this.timer && clearInterval(this.timer);
  },
  watch: {
    callStatus(newStatus, oldStatus) {
      // 作为被邀请者, 建立通话连接
      if (newStatus !== oldStatus && newStatus === "connected") {
        this.updateUserId2Name(this.meetingUserIdList);
        this.startMeeting();
        this.showChatTime();
        this.getDevicesList();
        aegisReportEvent("call", "call-1v1");
      }
    },
    meetingUserIdList(newList, oldList) {
      if (newList !== oldList || newList.length !== oldList) {
        this.updateUserId2Name(newList);
      }
    },
    callType(newStatus) {
      const query = JSON.parse(JSON.stringify(this.$route.query));
      query.type = newStatus;
      this.$router.push({ path: this.$route.path, query });
      this.type = newStatus;
    },
  },
  methods: {
    showChatTime() {
      this.timer = setInterval(() => {
        this.chatTime += 1;
      }, 1000)
    },
    handleCallUser: function({ userId }) {
      // 可设置超时
      this.$tuiCallEngine.call({
        userID: userId,
        type: this.type
      }).then(()=> {
        this.$store.commit("userJoinMeeting", this.loginUserInfo.userId);
        this.$store.commit("updateCallStatus", "calling");
        this.$store.commit("updateIsInviter", true);
      }).catch((error)=> {
        this.$message.error(error);
      })

    },
    handleCancelCallUser: function() {
      this.$tuiCallEngine.hangup();
      this.$store.commit("dissolveMeeting");
      this.$store.commit("updateCallStatus", "idle");
    },
    startMeeting: function() {
      if (this.meetingUserIdList.length >= 3) {
        // 多人通话
        const lastJoinUser = this.meetingUserIdList[
          this.meetingUserIdList.length - 1
        ];
        this.$tuiCallEngine.startRemoteView({
          userID: lastJoinUser,
          videoViewDomID: `call-${lastJoinUser}`,
          options: {
            objectFit: 'contain'
          }
        });
        return;
      }
      this.isShowCall = true;
      this.$tuiCallEngine.startLocalView({
        userID: this.loginUserInfo.userId,
        videoViewDomID: `call-${this.loginUserInfo.userId}`,
        options: {
          objectFit: 'contain'
        }
      });
      const otherParticipants = this.meetingUserIdList.filter(
        userId => userId !== this.loginUserInfo.userId
      );
      otherParticipants.forEach(userId => {
        this.$tuiCallEngine.startRemoteView({
          userID: userId,
          videoViewDomID: `call-${userId}`,
          options: {
            objectFit: 'contain'
          }
        });
      });
    },
    handleHangup: function() {
      this.$tuiCallEngine.hangup();
      this.isShowCall = false;
      this.$store.commit("updateCallStatus", "idle");
      this.$router.push("/home");
    },
    toggleVideo: function() {
      this.isVideoOn = !this.isVideoOn;
      if (this.isVideoOn) {
        this.$tuiCallEngine.openCamera();
        const muteUserList = this.muteVideoUserIdList.filter(
          userId => userId !== this.loginUserInfo.userId
        );
        this.$store.commit("updateMuteVideoUserIdList", muteUserList);
      } else {
        this.$tuiCallEngine.closeCamera();
        const muteUserList = this.muteVideoUserIdList.concat(
          this.loginUserInfo.userId
        );
        this.$store.commit("updateMuteVideoUserIdList", muteUserList);
      }
    },
    async toggleAudio() {
      this.isAudioOn = !this.isAudioOn;
      if (this.isAudioOn) {
        await this.$tuiCallEngine.openMicrophone();
        const muteUserList = this.muteAudioUserIdList.filter(
          userId => userId !== this.loginUserInfo.userId
        );
        this.$store.commit("updateMuteAudioUserIdList", muteUserList);
      } else {
        await this.$tuiCallEngine.closeMicrophone();
        const muteUserList = this.muteAudioUserIdList.concat(
          this.loginUserInfo.userId
        );
        this.$store.commit("updateMuteAudioUserIdList", muteUserList);
      }
    },
    isUserMute: function(muteUserList, userId) {
      return muteUserList.indexOf(userId) !== -1;
    },
    updateUserId2Name: async function(userIdList) {
      let userId2UserInfo = {};
      let loginUserId = this.loginUserInfo.userId;
      const response  = await this.$tim.getUserProfile({userIDList: userIdList})
      response.data.map((item)=> {
        userId2UserInfo[item.userID] = item;
        if (loginUserId === item.userID) {
          userId2UserInfo[item.userID].self = true;
        }
        return item;
      })
      this.userId2User = {
        ...this.userId2User,
        ...userId2UserInfo
      };
    },
    goto: function(path) {
      this.$router.push(path);
    },
    async switchCallMode() {
      await this.$tuiCallEngine.switchCallMediaType(1);
    },
    switchDevice(type, deviceId) {
      const options = {
        deviceType: type, 
        deviceId:  deviceId
      };
      this.$tuiCallEngine.switchDevice(options);
    },
    async getDevicesList() {
      const updateDevices = {
        micList: [],
        cameraList: [],
        currentMicrophone: {},
        currentCamera: {}
      }
      updateDevices.micList = await this.$tuiCallEngine.getDeviceList('microphones');
      updateDevices.currentMicrophone = updateDevices.micList[0];
      if (this.callType === this.TUICallType.VIDEO_CALL) {
        updateDevices.cameraList = await this.$tuiCallEngine.getDeviceList('camera');
        updateDevices.currentCamera = updateDevices.cameraList[0];
      }
      this.$store.commit("updateDeviceList", updateDevices);
    },
  }
};
</script>

<style scoped>
.call-section {
  padding-top: 50px;
  width: 800px;
  margin: 0 auto;
}
.call-section-header {
  font-size: 24px;
}
.call-section-title {
  margin-top: 30px;
  font-size: 20px;
}
.conference {
  display: none;
  margin-top: 20px;
}
.conference.is-show {
  display: block;
}

.conference-list {
  display: flex;
  flex-direction: row;
  justify-content: center;
  margin: 10px;
}

.user-call-container {
  position: relative;
  text-align: left;
  width: 360px;
  height: 240px;
  margin-right: 10px;
  background: black;
}

.user-video-status {
  position: absolute;
  right: 50px;
  bottom: 20px;
  width: 24px;
  height: 27px;
  z-index: 10;
  background-image: url("../../assets/camera-on.png");
  background-size: cover;
}
.user-video-status.is-mute {
  background-image: url("../../assets/camera-off.png");
}

.user-audio-status {
  position: absolute;
  right: 20px;
  bottom: 20px;
  width: 22px;
  height: 27px;
  z-index: 10;
  background-image: url("../../assets/mic-on.png");
  background-size: cover;
}

.user-audio-status.is-mute {
  background-image: url("../../assets/mic-off.png");
}

.conference-action {
  margin-top: 10px;
}

.call-item-username {
  position: absolute;
  top: 20px;
  left: 20px;
  z-index: 10;
  color: #ffffff;
}

.audio .user-audio-status {
  position: absolute;
  right: 20px;
  bottom: 20px;
  width: 22px;
  height: 27px;
  z-index: 10;
  background-image: url("../../assets/mic-on.png");
  background-size: cover;
}

.audio .call-item-avatar-wrapper {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translateX(-50%) translateY(-50%);
  width: 80px;
  height: 80px;
  z-index: 20;
}

.audio .call-item-avatar-wrapper img {
  width: 80px;
  height: 80px;
}

.audio .user-audio-status.is-mute {
  background-image: url("../../assets/mic-off.png");
}

.audio .call-item-username {
  position: absolute;
  top: 20px;
  left: 20px;
  z-index: 10;
  color: #ffffff;
}

.devices{
  display: flex;
}

.devices-item{
  list-style: none;
  display: flex;
  align-items: center;
  padding: 10px 20px;
}

@media screen and (max-width: 767px) {
  .call-section {
    width: 100%;
  }
  .conference-list {
    margin: 0;
    padding: 10px;
  }
  .user-call-container {
    margin: 5px;
  }
  .devices{
    flex-direction: column;
  }
}

</style>
