<template>
  <!-- Main audio/video call container.
       The dark-gray (#4c515a) background is only shown to the callee on the
       incoming-invite screen. The caller keeps the transparent/video-only
       look so their own local camera preview stays visible during CALLING. -->
  <div
    class="TUICall-container"
    :class="{ 'is-callee-waiting': isCalleeWaiting }"
    v-if="selfStatus !== CallStatus.IDLE"
  >
    <!-- 顶部菜单栏 -->
    <view class='topBar' v-if="selfStatus === CallStatus.CONNECTED">
      <view class="call-duration">
        <text>{{ formatDuration(duration) }}</text>
      </view>
    </view>

    <!-- Local avatar overlay -->
    <view @click="!isLocalStreamMain && toggleViewSize()" :class="isLocalStreamMain ? 'big-overlay' : 'small-overlay'"
      v-if="mediaType === CallMediaType.VIDEO && selfStatus === CallStatus.CONNECTED && !isCameraOpen">
      <image v-if="localViewBgImage" :src="localViewBgImage" mode="aspectFill" style="position:absolute;width:100%;height:100%;z-index:1;" />
      <template v-else>
        <Avatar :avatarStyle="isLocalStreamMain ? bigOverlayAvatarStyle : smallOverlayAvatarStyle"
          :src="selfAvatarUrl || IMG_DEFAULT_AVATAR" />
        <view :class="isLocalStreamMain ? 'big-overlay-mask' : 'small-overlay-mask'"></view>
        <Avatar
          :avatarStyle="isLocalStreamMain ? centeredOverlayAvatarStyle : centeredSmallOverlayAvatarStyle"
          :src="selfAvatarUrl || IMG_DEFAULT_AVATAR" />
      </template>
    </view>

    <!-- Local stream -->
    <div
      :class="(mediaType === CallMediaType.AUDIO || !isCameraOpen || isCalleeWaiting) ? 'player-audio' : (isLocalStreamMain ? 'big-video' : 'small-video')"
      @click="!isLocalStreamMain && toggleViewSize()">

      <TRTCPusher :key="pusherId" :id="pusherId" v-if="pusherId" />
    </div>

    <!-- Remote avatar overlay -->
    <view :class="(!isLocalStreamMain || isCalleeWaiting) ? 'big-overlay' : 'small-overlay'"
      @click="!isCalleeWaiting && isLocalStreamMain && toggleViewSize()"
      v-if="mediaType === CallMediaType.AUDIO || isCalleeWaiting || (mediaType === CallMediaType.VIDEO && selfStatus === CallStatus.CONNECTED && !remoteIsCameraOpened)">
      <image v-if="remoteViewBgImage" :src="remoteViewBgImage" mode="aspectFill" style="position:absolute;width:100%;height:100%;z-index:1;" />
      <template v-else>
        <Avatar :avatarStyle="(!isLocalStreamMain || isCalleeWaiting) ? bigOverlayAvatarStyle : smallOverlayAvatarStyle"
          :src="remoteAvatarUrl || IMG_DEFAULT_AVATAR" />
        <view :class="(!isLocalStreamMain || isCalleeWaiting) ? 'big-overlay-mask' : 'small-overlay-mask'"></view>
        <Avatar
          v-if="!(mediaType === CallMediaType.AUDIO || selfStatus === CallStatus.CALLING)"
          :avatarStyle="!isLocalStreamMain ? centeredOverlayAvatarStyle : centeredSmallOverlayAvatarStyle"
          :src="remoteAvatarUrl || IMG_DEFAULT_AVATAR" />
      </template>
    </view>

    <!-- 远端流 -->
    <view
      :class="(mediaType === CallMediaType.AUDIO || selfStatus === CallStatus.CALLING || !remoteIsCameraOpened) ? 'player-audio' : (!isLocalStreamMain ? 'big-video' : 'small-video')"
      @click="isLocalStreamMain && toggleViewSize()">
      <TRTCPlayer v-if="remoteUserId"
        :id="remoteUserId + '_0'" ref="player"
        :stream-id="remoteUserId + '_0'" />
    </view>

    <!-- 用户信息 -->
    <view v-if="mediaType === CallMediaType.AUDIO || selfStatus === CallStatus.CALLING"
      class="voice-invite-message">
      <Avatar :avatarStyle="avatarStyle"
        :src="remoteAvatarUrl || IMG_DEFAULT_AVATAR" />
      <text class="nick-name">
        {{ remoteDisplayName }}
      </text>
    </view>

    <!-- 通话状态提示 -->
    <div class="tips">
      <text v-if="showConnectedTip">已接通</text>
      <div v-if="!showConnectedTip && selfStatus !== CallStatus.CONNECTED">
        <text v-if="selfRole !== CallRole.CALLER">
          {{ mediaType === CallMediaType.AUDIO ? '邀请你语音通话' : '邀请你视频通话' }}
        </text>
        <text v-else>等待对方接受</text>
      </div>
    </div>

    <!-- 主叫呼叫阶段按钮 -->
    <view class="footer"
      v-if="selfStatus === CallStatus.CALLING && selfRole === CallRole.CALLER">
      <view class="btn-operate">
        <view class="btn-operate-item">
          <view class="call-operate" style="background-color: #ED4651;" @click="CallerHangupHandler">
            <image v-if="isCallBtnClickable" :src="IMG_HANGUP" mode="aspectFit" />
            <image v-else class="img-loading" :src="IMG_LOADING" mode="aspectFit"></image>
          </view>
          <text>挂断</text>
        </view>
      </view>
    </view>

    <!-- 被叫呼叫阶段按钮 -->
    <view class="footer"
      v-if="selfStatus === CallStatus.CALLING && selfRole !== CallRole.CALLER">
      <view class="btn-operate" style="gap: 40px">
        <view class="btn-operate-item">
          <view class="call-operate" style="background-color: #ED4651;" @click="reject">
            <image :src="IMG_HANGUP" mode="aspectFit" />
          </view>
          <text>挂断</text>
        </view>
        <view class="btn-operate-item">
          <view class="call-operate" style="background-color: #51C271;" @click="acceptHandler">
            <image v-if="isAcceptBtnClickable" :src="IMG_ACCEPT" mode="aspectFit" />
            <image v-else class="img-loading" :src="IMG_LOADING" mode="aspectFit"></image>
          </view>
          <text>接听</text>
        </view>
      </view>
    </view>

    <!-- 语音通话接听阶段按钮 -->
    <view class="footer"
      v-if="mediaType === CallMediaType.AUDIO && selfStatus === CallStatus.CONNECTED">
      <view class="btn-operate">
        <view class="btn-operate-item" @click="microPhoneHandler" v-if="isButtonVisible(FeatureButton.Microphone)">
          <view class="call-operate" :style="micBgColor">
            <image :src="isMicrophoneOpen ? IMG_AUDIO_TRUE : IMG_AUDIO_FALSE" mode="aspectFit"></image>
          </view>
          <text>{{ isMicrophoneOpen ? '麦克风已开启' : '麦克风已关闭' }}</text>
        </view>
        <view class="btn-operate-item">
          <view class="call-operate" style="background-color: #ED4651;" @click="hangupHandler">
            <image mode="aspectFit" v-if="isHangupBtnClickable" :src="IMG_HANGUP" />
            <image mode="aspectFit" v-else class="img-loading" :src="IMG_LOADING"></image>
          </view>
          <text>挂断</text>
        </view>
        <view class="btn-operate-item" @click="setAudioRoute">
          <view class="call-operate" :style="speakerBgColor">
            <image mode="aspectFit" class="btn-image" :src="isSpeakerOpen ? IMG_SPEAKER_TRUE : IMG_SPEAKER_FALSE">
            </image>
          </view>
          <text>{{ isSpeakerOpen ? '扬声器已开启' : '扬声器已关闭' }}</text>
        </view>
      </view>
    </view>

    <!-- 视频通话接听阶段按钮 -->
    <view class="footer"
      v-if="mediaType === CallMediaType.VIDEO && selfStatus === CallStatus.CONNECTED">
      <view class="btn-operate">
        <view class="btn-operate-item" @click="microPhoneHandler" v-if="isButtonVisible(FeatureButton.Microphone)">
          <view class="call-operate" :style="micBgColor">
            <image :src="isMicrophoneOpen ? IMG_AUDIO_TRUE : IMG_AUDIO_FALSE" mode="aspectFit"></image>
          </view>
          <text>{{ isMicrophoneOpen ? '麦克风已开启' : '麦克风已关闭' }}</text>
        </view>
        <view class="btn-operate-item" @click="setAudioRoute">
          <view class="call-operate" :style="speakerBgColor">
            <image mode="aspectFit" class="btn-image" :src="isSpeakerOpen ? IMG_SPEAKER_TRUE : IMG_SPEAKER_FALSE">
            </image>
          </view>
          <text>{{ isSpeakerOpen ? '扬声器已开启' : '扬声器已关闭' }}</text>
        </view>
        <view class="btn-operate-item" @click="cameraHandler" v-if="isButtonVisible(FeatureButton.Camera)">
          <view class="call-operate" :style="cameraBgColor">
            <image mode="aspectFit" class="btn-image" :src="isCameraOpen ? IMG_CAMERA_TRUE : IMG_CAMERA_FALSE"></image>
          </view>
          <text>{{ isCameraOpen ? '摄像头已开启' : '摄像头已关闭' }}</text>
        </view>
      </view>
      <view class="btn-operate">
        <view class="btn-operate-item">
          <view class="call-operate" style="background-color: #ED4651;" @click="hangupHandler">
            <image v-if="isHangupBtnClickable" :src="IMG_HANGUP" mode="aspectFit" />
            <image v-else class="img-loading" :src="IMG_LOADING" mode="aspectFit"></image>
          </view>
          <!-- Switch-camera -->
          <view v-if="isButtonVisible(FeatureButton.SwitchCamera)" :class="['switch-camera', { disabled: !isCameraOpen }]" @click.stop="switchCameraHandler">
            <image :src="IMG_SWITCH_CAMERA" mode="aspectFit"/>
          </view>
          <text>挂断</text>
        </view>
      </view>
    </view>
  </div>
</template>

<script lang="ts" setup>
import { ref, watch, computed } from '../../adapter/vue-demi';
import { onHide, onUnload } from '@dcloudio/uni-app'
import Avatar from '../Avatar/Avatar.vue';
import TRTCPusher from '@tencentcloud/trtc-component-uniapp/src/components/TRTCPusher.vue';
import TRTCPlayer from '@tencentcloud/trtc-component-uniapp/src/components/TRTCPlayer.vue';
import IMG_HANGUP from '../../assets/call/hangup.svg';
import IMG_ACCEPT from '../../assets/call/accept.svg';
import IMG_AUDIO_TRUE from '../../assets/call/microphone-open.svg';
import IMG_AUDIO_FALSE from '../../assets/call/microphone-close.svg';
import IMG_SPEAKER_TRUE from '../../assets/call/speaker-open.svg';
import IMG_SPEAKER_FALSE from '../../assets/call/speaker-close.svg';
import IMG_CAMERA_TRUE from '../../assets/call/camera-open.svg';
import IMG_CAMERA_FALSE from '../../assets/call/camera-close.svg';
import IMG_SWITCH_CAMERA from '../../assets/call/switch-camera.svg';
import IMG_DEFAULT_AVATAR from '../../assets/base/default-avatar.png';
import IMG_LOADING from '../../assets/call/loading.png';
import { formatDuration } from '../../utils/index';
import { CallMediaType, AudioPlayBackDevice } from '@trtc/call-engine-lite-wx';
import { CallStatus, CallRole } from '../../constants/call';
import { useCallListState, useCallParticipantState, useDeviceState, useUIConfigState } from '../../index';
import { FeatureButton, LayoutMode } from '../../states/UIConfigState';

const {
  inviterId,
  mediaType,
  duration,
  pusherId,
  accept,
  reject,
  hangup,
} = useCallListState();
const { callParticipantInfo } = useCallParticipantState();

const {
  currentAudioRoute,
  openLocalCamera, closeLocalCamera,
  openLocalMicrophone, closeLocalMicrophone,
  switchCamera, setAudioRoute,
} = useDeviceState();

const { hiddenButtons, layoutMode, viewBackground } = useUIConfigState();

const isCallBtnClickable = ref((inviterId.value || '').length > 0 ? true : false);
const isAcceptBtnClickable = ref(true);
const isHangupBtnClickable = ref(true);
// Layout mode controls the initial large-view assignment:
// RemoteInLargeView → local is the small thumbnail (isLocalStreamMain=false for video)
// LocalInLargeView  → local is the large view (isLocalStreamMain=true)
const isLocalStreamMain = ref(
  mediaType.value === CallMediaType.AUDIO
    ? false
    : layoutMode.value === LayoutMode.LocalInLargeView,
);

// Helper: whether a particular feature button should be visible.
const isButtonVisible = (btn: FeatureButton) => !hiddenButtons.value.has(btn);

// View background images for local / remote overlays.
const localViewBgImage = computed(() => {
  const info = callParticipantInfo && callParticipantInfo.value;
  const selfId = (info && info.selfInfo && info.selfInfo.id) || '';
  return viewBackground.value[selfId] || '';
});
const remoteViewBgImage = computed(() => {
  const rId = remoteUserId.value;
  return viewBackground.value[rId] || viewBackground.value['*'] || '';
});
// Vue 2-safe computed properties that avoid optional chaining in template expressions.
const selfStatus = computed(() => {
  const info = callParticipantInfo && callParticipantInfo.value;
  return (info && info.selfInfo && info.selfInfo.status) || CallStatus.IDLE;
});
const selfRole = computed(() => {
  const info = callParticipantInfo && callParticipantInfo.value;
  return (info && info.selfInfo && info.selfInfo.role) || '';
});
const selfAvatarUrl = computed(() => {
  const info = callParticipantInfo && callParticipantInfo.value;
  return (info && info.selfInfo && info.selfInfo.avatarUrl) || '';
});
const remoteUser = computed((): any => {
  const info = callParticipantInfo && callParticipantInfo.value;
  const participants = info && info.allParticipants;
  return (participants && participants[0]) || {};
});
const remoteUserId = computed(() => remoteUser.value.id || '');
const remoteAvatarUrl = computed(() => remoteUser.value.avatarUrl || '');
const remoteDisplayName = computed(() => remoteUser.value.name || remoteUser.value.id || '');
const remoteIsCameraOpened = computed(() => !!remoteUser.value.isCameraOpened);

const isMicrophoneOpen = computed(() => {
  const info = callParticipantInfo && callParticipantInfo.value;
  return !!(info && info.selfInfo && info.selfInfo.isMicrophoneOpened);
});
const isCameraOpen = computed(() => {
  const info = callParticipantInfo && callParticipantInfo.value;
  return !!(info && info.selfInfo && info.selfInfo.isCameraOpened);
});
const isSpeakerOpen = computed(() => currentAudioRoute.value !== AudioPlayBackDevice.EAR);

// Pre-computed style objects for :style bindings — Vue 2 template compiler
// does not allow function calls (even plain functions) inside :style.
const micBgColor = computed(() => getButtonBgColor(isMicrophoneOpen.value));
const speakerBgColor = computed(() => getButtonBgColor(isSpeakerOpen.value));
const cameraBgColor = computed(() => getButtonBgColor(isCameraOpen.value));
const showConnectedTip = ref(false);
// True while the local user is the callee and has not yet accepted the call.
const isCalleeWaiting = computed(() =>
  selfStatus.value === CallStatus.CALLING && selfRole.value !== CallRole.CALLER,
);
// NOTE: Avatar style values MUST be CSS strings (not objects). In the uni-app
// Vue 2 mini-program build, a `:style` bound to a variable is compiled to
// `style="{{expr}}"` without object normalization, so an object would render
// as "[object Object]" and be ignored. CSS strings render identically on both
// Vue 2 and Vue 3, keeping the UI aligned across frameworks.
const bigOverlayAvatarStyle = 'position: absolute; width: 100%; height: 100%; object-fit: cover; z-index: 1;';

// Centered rounded-square avatar rendered on top of the blurred big-overlay
// background, shown in the main stream slot when the participant's camera
// is off. Provides a clear focal portrait in addition to the blurred cover.
const centeredOverlayAvatarStyle = 'position: absolute; top: 50%; left: 50%; width: 100px; height: 100px; transform: translate(-50%, -50%); border-radius: 12px; z-index: 3;';

// Smaller centered avatar for the small-overlay (thumbnail) slot, so a
// participant with the camera off still shows a recognisable portrait in
// the picture-in-picture tile.
const centeredSmallOverlayAvatarStyle = 'position: absolute; top: 50%; left: 50%; width: 48px; height: 48px; transform: translate(-50%, -50%); border-radius: 8px; z-index: 101;';

const smallOverlayAvatarStyle = 'position: absolute; width: 100%; height: 100%; object-fit: cover; z-index: 99;';

const avatarStyle = 'width: 100px; height: 100px; border-radius: 12px; display: block; margin: 140px auto 15px;';

function toggleViewSize() {
  if (mediaType.value === CallMediaType.VIDEO) {
    isLocalStreamMain.value = !isLocalStreamMain.value
  }
}

async function cameraHandler() {
  if (isCameraOpen.value) {
    await closeLocalCamera();
  } else {
    await openLocalCamera();
  }
}

async function microPhoneHandler() {
  if (isMicrophoneOpen.value) {
    await closeLocalMicrophone();
  } else {
    await openLocalMicrophone();
  }
}

// Switch-camera is gated on the local camera being open. When the camera is
// off the button is rendered in a disabled state and clicks are swallowed here.
async function switchCameraHandler() {
  if (!isCameraOpen.value) return;
  await switchCamera();
}

async function CallerHangupHandler() {
  try {
    if (!isCallBtnClickable.value) return;

    await hangup();
  } catch (error) {
    isCallBtnClickable.value = true;
  }
}

async function acceptHandler() {
  try {
    if (!isAcceptBtnClickable.value) {
      console.warn(`previous accept is ongoing, please avoid repeat accept`);
      return;
    }
    isAcceptBtnClickable.value = false;
    await accept();
    isAcceptBtnClickable.value = true;
  } catch (error) {
    isAcceptBtnClickable.value = true;
  }
}

async function hangupHandler() {
  try {
    if (!isHangupBtnClickable.value) {
      console.warn(`previous hangup is ongoing, please avoid repeat hangup`);
      return;
    }
    isHangupBtnClickable.value = false;
    await hangup();
    isHangupBtnClickable.value = true;
  } catch (error) {
    isHangupBtnClickable.value = true;
  }
}

// Returns a CSS string (not an object): the uni-app Vue 2 mini-program build
// does not normalize object `:style` bindings referenced via a variable, so an
// object would render as "[object Object]". A string works on both Vue 2/Vue 3.
function getButtonBgColor(isActive: boolean) {
  return isActive
    ? 'background-color: #FFFFFF;'
    : 'background-color: #22262E; opacity: 0.5;';
}

watch(() => callParticipantInfo.value && callParticipantInfo.value.selfInfo, (newObj, oldObj) => {
  const newStatus = newObj && newObj.status;

  if (mediaType.value === CallMediaType.VIDEO) {
    // During CALLING the caller sees their own stream large (matches original);
    // on CONNECTED, respect the configured layoutMode.
    isLocalStreamMain.value = newStatus === CallStatus.CALLING
      ? true
      : layoutMode.value === LayoutMode.LocalInLargeView;
  }

  if (mediaType.value === CallMediaType.AUDIO) {
    isLocalStreamMain.value = false;
  }

  if (newStatus === CallStatus.CONNECTED && oldObj && oldObj.status === CallStatus.CALLING) {
    showConnectedTip.value = true;
    setTimeout(() => {
      showConnectedTip.value = false;
    }, 1000);
  } else {
    showConnectedTip.value = false;
  }

  if (newStatus === CallStatus.IDLE) {
    isHangupBtnClickable.value = false;
    isAcceptBtnClickable.value = true;
    isHangupBtnClickable.value = true;
  }
});

watch(inviterId, (newVal, oldVal) => {
  isCallBtnClickable.value = (newVal || '').length > 0 ? true : false;
});

onUnload(() => {
  const info = callParticipantInfo.value && callParticipantInfo.value.selfInfo;
  const callStatus = info && info.status;
  const callRole = info && info.role;

  if (callStatus === CallStatus.IDLE) return;
  if (callStatus === CallStatus.CALLING) {
    if (callRole === CallRole.CALLER) {
      hangup();
    } else {
      reject();
    }
  }
  if (callStatus === CallStatus.CONNECTED) {
    hangup();
  }
});

</script>

<style scoped lang="scss">
.TUICall-container {
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  position: relative;
  bottom: 0;
  left: 0;
  margin: 0;
  /* Default root background is black so a caller's local video preview does
     not have an unexpected gray flash before frames arrive. The dark-gray
     invite background is opt-in via the .is-callee-waiting modifier below. */
  background-color: #000;

  /* Callee-only invite background aligned with the design mock: dark-gray
     shown while waiting to accept an incoming 1v1 call. */
  &.is-callee-waiting {
    background-color: #4c515a;
  }

  .topBar {
    position: fixed;
    top: 2vh;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    justify-content: center;
    width: 100%;
    /* Above the blurred avatar overlay (.big-overlay z-index: 20) so the call
       duration stays visible after connecting in audio calls and in video
       calls where the remote camera is off. */
    z-index: 101;

    .call-duration {
      text-align: center;
      font-family: PingFang SC;
      font-weight: 500;
      font-size: 16px;
      color: #FFFFFF;
    }
  }

  .big-video {
    position: absolute;
    width: 100%;
    height: 100%;
    z-index: 10;
    /* Transparent background so the dark-gray container background shows
       through before the video pusher/player renders its first frame,
       instead of a solid black flash. */
    background-color: transparent;
  }

  .big-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    /* Kept above .big-video (10) so the overlay (blurred avatar cover +
       centered portrait) is always visible when the camera is off. */
    z-index: 20;

    .big-overlay-avatar {
      position: absolute;
      width: 100%;
      height: 100%;
      object-fit: cover;
      z-index: 1;
    }

    .big-overlay-mask {
      background-color: rgba(0, 0, 0, 0.5);
      position: absolute;
      width: 100%;
      height: 100%;
      object-fit: cover;
      z-index: 2;
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
    }
  }

  /* Rounded corners on the picture-in-picture thumbnail (both the video
     surface and its avatar overlay). overflow:hidden clips DOM children;
     native pusher/player also honor border-radius on their host element. */
  .small-video {
    position: absolute;
    right: 16px;
    top: 100px;
    width: 100px;
    height: 178px;
    z-index: 100;
    border-radius: 12px;
    overflow: hidden;
  }

  .small-overlay {
    position: absolute;
    right: 16px;
    top: 100px;
    width: 100px;
    height: 178px;
    z-index: 98;
    border-radius: 12px;
    overflow: hidden;

    .small-overlay-avatar {
      position: absolute;
      width: 100%;
      height: 100%;
      object-fit: cover;
      z-index: 99;
    }

    .small-overlay-mask {
      position: absolute;
      background-color: rgba(0, 0, 0, 0.5);
      width: 100%;
      height: 100%;
      object-fit: cover;
      z-index: 100;
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
    }
  }

  .player-audio {
    width: 0;
    height: 0;
  }

  .voice-invite-message {
    position: fixed;
    top: 30%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 100%;
    text-align: center;
    font-family: PingFang SC;
    color: #D5E0F2;
    font-weight: 500;
    z-index: 100;

    .nick-name {
      font-size: 18px;
      text-align: center;
    }
  }

  .tips {
    height: 14px;
    position: fixed;
    top: 70%;
    left: 50%;
    font-size: 14px;
    font-family: PingFang SC;
    transform: translate(-50%, -50%);
    color: #D5E0F2;
    font-weight: 500;
    z-index: 100;
  }

  .footer {
    position: absolute;
    bottom: 5vh;
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    font-size: 14px;
    color: #f0e9e9;
    font-weight: 400;
    z-index: 100;

    .btn-operate {
      display: flex;
      flex-direction: initial;
      text-align: center;
      align-items: center;
      justify-content: center;
    }

    .btn-operate-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      margin-bottom: 20px;

      text {
        font-family: PingFang SC;
        font-weight: 400;
        font-size: 12px;
        color: #D5E0F2;
      }

      .switch-camera {
        position: absolute;
        right: 104px;
        width: 22px;
        top: 60%;
        margin-left: 60px;
        height: 22px;
        transition: opacity 0.2s ease-in;

        image {
          width: 100%;
          height: 100%;
        }

        /* Disabled state when the local camera is off: dimmed and clicks are
           ignored (the @click handler also guards against switching). */
        &.disabled {
          opacity: 0.4;
          pointer-events: none;
        }
      }

      .call-operate {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        margin: 10px 10vw;
        box-sizing: border-box;
        display: flex;
        justify-content: center;
        align-items: center;

        image {
          width: 30px;
          height: 30px;
          background: none;
        }

        .img-loading {
          animation: rotate 1.5s linear infinite;
          width: 30px;
          height: 30px
        }

        @keyframes rotate {
          from {
            transform: rotate(0deg);
          }

          to {
            transform: rotate(360deg);
          }
        }

        text {
          font-family: PingFang SC;
          font-weight: 400;
          font-size: 12px;
          color: #D5E0F2;
        }
      }
    }
  }
}
</style>
