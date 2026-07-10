<template>
  <!-- Main audio/video call container.
       The dark-gray (#4c515a) background is only shown to the callee on the
       incoming-invite screen. The caller keeps the transparent/video-only
       look so their own local camera preview stays visible during CALLING. -->
  <div
    class="TUICall-container"
    :class="{ 'is-callee-waiting': isCalleeWaiting }"
    v-if="callParticipantInfo?.selfInfo?.status !== CallStatus.IDLE"
  >
    <!-- 顶部菜单栏 -->
    <view class='topBar' v-if="callParticipantInfo?.selfInfo?.status === CallStatus.CONNECTED">
      <view class="call-duration">
        <text>{{ formatDuration(duration) }}</text>
      </view>
    </view>

    <!-- Local avatar overlay: rendered only after the call is CONNECTED and
         the local camera is off. During CALLING the pusher is not yet
         started so isCameraOpen is false; we intentionally skip the overlay
         in that phase so the caller does not see their own avatar plastered
         over the invite screen.
         When a view background image is configured via setLocalViewBackgroundImage,
         it replaces the default avatar overlay entirely. -->
    <view @click="!isLocalStreamMain && toggleViewSize()" :class="isLocalStreamMain ? 'big-overlay' : 'small-overlay'"
      v-if="mediaType === CallMediaType.VIDEO && callParticipantInfo?.selfInfo?.status === CallStatus.CONNECTED && !isCameraOpen">
      <!-- Custom view background image (if configured) -->
      <image v-if="localViewBgImage" :src="localViewBgImage" mode="aspectFill" style="position:absolute;width:100%;height:100%;z-index:1;" />
      <!-- Default avatar overlay (when no custom background is set) -->
      <template v-else>
        <Avatar :avatarStyle="isLocalStreamMain ? bigOverlayAvatarStyle : smallOverlayAvatarStyle"
          :src="callParticipantInfo?.selfInfo.avatarUrl || IMG_DEFAULT_AVATAR" />
        <view :class="isLocalStreamMain ? 'big-overlay-mask' : 'small-overlay-mask'"></view>
        <!-- Centered portrait rendered on top of the blurred cover for both
             the main (big) and thumbnail (small) slots. -->
        <Avatar
          :avatarStyle="isLocalStreamMain ? centeredOverlayAvatarStyle : centeredSmallOverlayAvatarStyle"
          :src="callParticipantInfo?.selfInfo.avatarUrl || IMG_DEFAULT_AVATAR" />
      </template>
    </view>

    <!-- Local stream. Hidden (0x0 via .player-audio) only while the callee is
         still waiting to accept, so the dark-gray invite background is not
         covered by the local video container. The caller keeps their local
         preview visible during CALLING. -->
    <div
      :class="(mediaType === CallMediaType.AUDIO || !isCameraOpen || isCalleeWaiting) ? 'player-audio' : (isLocalStreamMain ? 'big-video' : 'small-video')"
      @click="!isLocalStreamMain && toggleViewSize()">

      <TRTCPusher :key="pusherId" :id="pusherId" v-if="pusherId" />
    </div>

    <!-- Remote avatar overlay: rendered when the remote camera is off in a
         connected 1v1 video call, during an audio call, or while a video
         callee is still waiting to accept.
         When a view background image is configured via setRemoteViewBackgroundImage,
         it replaces the default avatar overlay entirely. -->
    <view :class="(!isLocalStreamMain || isCalleeWaiting) ? 'big-overlay' : 'small-overlay'"
      @click="!isCalleeWaiting && isLocalStreamMain && toggleViewSize()"
      v-if="mediaType === CallMediaType.AUDIO || isCalleeWaiting || (mediaType === CallMediaType.VIDEO && callParticipantInfo?.selfInfo?.status === CallStatus.CONNECTED && !callParticipantInfo?.allParticipants[0]?.isCameraOpened)">
      <!-- Custom view background image for remote (if configured) -->
      <image v-if="remoteViewBgImage" :src="remoteViewBgImage" mode="aspectFill" style="position:absolute;width:100%;height:100%;z-index:1;" />
      <!-- Default avatar overlay (when no custom background is set) -->
      <template v-else>
        <Avatar :avatarStyle="(!isLocalStreamMain || isCalleeWaiting) ? bigOverlayAvatarStyle : smallOverlayAvatarStyle"
          :src="callParticipantInfo?.allParticipants[0]?.avatarUrl || IMG_DEFAULT_AVATAR" />
        <view :class="(!isLocalStreamMain || isCalleeWaiting) ? 'big-overlay-mask' : 'small-overlay-mask'"></view>
        <!-- Centered portrait rendered on top of the blurred cover. Skipped
             whenever the voice-invite-message block is visible (audio calls, or
             any CALLING phase), because that block already renders a centered
             avatar + nickname over this blurred background. -->
        <Avatar
          v-if="!(mediaType === CallMediaType.AUDIO || callParticipantInfo?.selfInfo?.status === CallStatus.CALLING)"
          :avatarStyle="!isLocalStreamMain ? centeredOverlayAvatarStyle : centeredSmallOverlayAvatarStyle"
          :src="callParticipantInfo?.allParticipants[0]?.avatarUrl || IMG_DEFAULT_AVATAR" />
      </template>
    </view>

    <!-- 远端流 -->
    <view
      :class="(mediaType === CallMediaType.AUDIO || callParticipantInfo?.selfInfo?.status === CallStatus.CALLING || !callParticipantInfo?.allParticipants[0]?.isCameraOpened) ? 'player-audio' : (!isLocalStreamMain ? 'big-video' : 'small-video')"
      @click="isLocalStreamMain && toggleViewSize()">
      <TRTCPlayer v-if="callParticipantInfo?.allParticipants[0]?.id"
        :id="`${callParticipantInfo?.allParticipants[0]?.id}_0`" ref="player"
        :stream-id="`${callParticipantInfo?.allParticipants[0]?.id}_0`" />
    </view>

    <!-- 用户信息 -->
    <view v-if="mediaType === CallMediaType.AUDIO || callParticipantInfo?.selfInfo?.status === CallStatus.CALLING"
      class="voice-invite-message">
      <Avatar :avatarStyle="avatarStyle"
        :src="callParticipantInfo?.allParticipants[0]?.avatarUrl || IMG_DEFAULT_AVATAR" />
      <text class="nick-name">
        {{ callParticipantInfo?.allParticipants[0]?.name || callParticipantInfo?.allParticipants[0]?.id }}
      </text>
    </view>

    <!-- 通话状态提示 -->
    <div class="tips">
      <text v-if="showConnectedTip">已接通</text>
      <div v-if="!showConnectedTip && callParticipantInfo.selfInfo.status !== CallStatus.CONNECTED">
        <text v-if="callParticipantInfo?.selfInfo?.role !== CallRole.CALLER">
          {{ mediaType === CallMediaType.AUDIO ? '邀请你语音通话' : '邀请你视频通话' }}
        </text>
        <text v-else>等待对方接受</text>
      </div>
    </div>

    <!-- 主叫呼叫阶段按钮 -->
    <view class="footer"
      v-if="callParticipantInfo?.selfInfo?.status === CallStatus.CALLING && callParticipantInfo?.selfInfo?.role === CallRole.CALLER">
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
      v-if="callParticipantInfo?.selfInfo?.status === CallStatus.CALLING && callParticipantInfo?.selfInfo?.role !== CallRole.CALLER">
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
      v-if="mediaType === CallMediaType.AUDIO && callParticipantInfo?.selfInfo?.status === CallStatus.CONNECTED">
      <view class="btn-operate">
        <view class="btn-operate-item" @click="microPhoneHandler" v-if="isButtonVisible(FeatureButton.Microphone)">
          <view class="call-operate" :style="buttonBgColor(isMicrophoneOpen)">
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
          <view class="call-operate" :style="buttonBgColor(isSpeakerOpen)">
            <image mode="aspectFit" class="btn-image" :src="isSpeakerOpen ? IMG_SPEAKER_TRUE : IMG_SPEAKER_FALSE">
            </image>
          </view>
          <text>{{ isSpeakerOpen ? '扬声器已开启' : '扬声器已关闭' }}</text>
        </view>
      </view>
    </view>

    <!-- 视频通话接听阶段按钮 -->
    <view class="footer"
      v-if="mediaType === CallMediaType.VIDEO && callParticipantInfo?.selfInfo?.status === CallStatus.CONNECTED">
      <view class="btn-operate">
        <view class="btn-operate-item" @click="microPhoneHandler" v-if="isButtonVisible(FeatureButton.Microphone)">
          <view class="call-operate" :style="buttonBgColor(isMicrophoneOpen)">
            <image :src="isMicrophoneOpen ? IMG_AUDIO_TRUE : IMG_AUDIO_FALSE" mode="aspectFit"></image>
          </view>
          <text>{{ isMicrophoneOpen ? '麦克风已开启' : '麦克风已关闭' }}</text>
        </view>
        <view class="btn-operate-item" @click="setAudioRoute">
          <view class="call-operate" :style="buttonBgColor(isSpeakerOpen)">
            <image mode="aspectFit" class="btn-image" :src="isSpeakerOpen ? IMG_SPEAKER_TRUE : IMG_SPEAKER_FALSE">
            </image>
          </view>
          <text>{{ isSpeakerOpen ? '扬声器已开启' : '扬声器已关闭' }}</text>
        </view>
        <view class="btn-operate-item" @click="cameraHandler" v-if="isButtonVisible(FeatureButton.Camera)">
          <view class="call-operate" :style="buttonBgColor(isCameraOpen)">
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
          <!-- Switch-camera: hidden when hideFeatureButton(SwitchCamera) is called;
               otherwise rendered, but disabled when the local camera is off. -->
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
import { ref, watch, computed } from 'vue';
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
  const selfId = callParticipantInfo?.value?.selfInfo?.id || '';
  return viewBackground.value[selfId] || '';
});
const remoteViewBgImage = computed(() => {
  const remoteId = callParticipantInfo?.value?.allParticipants?.[0]?.id || '';
  return viewBackground.value[remoteId] || viewBackground.value['*'] || '';
});
const isMicrophoneOpen = computed(() => callParticipantInfo?.value.selfInfo?.isMicrophoneOpened);
const isCameraOpen = computed(() => callParticipantInfo?.value.selfInfo?.isCameraOpened);
const isSpeakerOpen = computed(() => currentAudioRoute.value !== AudioPlayBackDevice.EAR);
const showConnectedTip = ref(false);
// True while the local user is the callee and has not yet accepted the call.
// Used to gate the dark-gray invite background and hide the local video
// container that would otherwise cover it.
const isCalleeWaiting = computed(() =>
  callParticipantInfo?.value?.selfInfo?.status === CallStatus.CALLING
    && callParticipantInfo?.value?.selfInfo?.role !== CallRole.CALLER,
);
const bigOverlayAvatarStyle = ref({
  position: 'absolute',
  width: '100%',
  height: '100%',
  objectFit: 'cover',
  zIndex: 1,
});

// Centered rounded-square avatar rendered on top of the blurred big-overlay
// background, shown in the main stream slot when the participant's camera
// is off. Provides a clear focal portrait in addition to the blurred cover.
const centeredOverlayAvatarStyle = ref({
  position: 'absolute',
  top: '50%',
  left: '50%',
  width: '100px',
  height: '100px',
  transform: 'translate(-50%, -50%)',
  borderRadius: '12px',
  zIndex: 3,
});

// Smaller centered avatar for the small-overlay (thumbnail) slot, so a
// participant with the camera off still shows a recognisable portrait in
// the picture-in-picture tile.
const centeredSmallOverlayAvatarStyle = ref({
  position: 'absolute',
  top: '50%',
  left: '50%',
  width: '48px',
  height: '48px',
  transform: 'translate(-50%, -50%)',
  borderRadius: '8px',
  zIndex: 101,
});

const smallOverlayAvatarStyle = ref({
  position: 'absolute',
  width: '100%',
  height: '100%',
  objectFit: 'cover',
  zIndex: 99
});

const avatarStyle = ref({
  width: '100px',
  height: '100px',
  borderRadius: '12px',
  display: 'block',
  margin: '140px auto 15px'
});

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

const buttonBgColor = computed(() => (isActive: boolean) => {
  return isActive ? { backgroundColor: '#FFFFFF', } : {
    backgroundColor: '#22262E',
    opacity: '0.5'
  };
})

watch(() => callParticipantInfo?.value?.selfInfo, (newObj, oldObj) => {
  const newStatus = newObj?.status;

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

  if (newStatus === CallStatus.CONNECTED && oldObj?.status === CallStatus.CALLING) {
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
  const callStatus = callParticipantInfo?.value?.selfInfo?.status;
  const callRole = callParticipantInfo?.value?.selfInfo?.role;

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
