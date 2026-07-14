<template>
  <!-- Group call main container -->
  <div class="TUIGroupCall-container" v-if="selfStatus !== CallStatus.IDLE">
    <!-- Background: default-avatar watermark + dark translucent mask. -->
    <image class="backdrop-image" :src="IMG_DEFAULT_AVATAR" mode="aspectFill" />
    <view class="backdrop-mask" />

    <!-- Top bar: shows call duration in CONNECTED state -->
    <view class="topBar" v-if="selfStatus === CallStatus.CONNECTED">
      <view class="call-duration">
        <text>{{ formatDuration(duration) }}</text>
      </view>
    </view>

    <!-- Waiting overlay: callee side, while in CALLING state. -->
    <view class="waiting-overlay"
      v-if="selfStatus === CallStatus.CALLING && selfRole === CallRole.CALLEE">
      <view class="waiting-mask" />
      <view class="waiting-content">
        <Avatar :avatarStyle="inviterAvatarStyle" :src="inviterAvatar || IMG_DEFAULT_AVATAR" />
        <text class="waiting-nick">{{ inviterDisplayName }}</text>
        <text class="waiting-tip">邀请你加入群通话</text>
        <view class="waiting-count" v-if="participantAvatarList.length > 0">
          <text class="waiting-count-text">{{ participantAvatarList.length }} 人正在通话</text>
          <view class="avatar-group">
            <view v-for="(item, index) in participantAvatarList" :key="item.id || index" class="avatar-item">
              <Avatar :avatarStyle="avatarGroupItemStyle" :src="item.avatarUrl || IMG_DEFAULT_AVATAR" />
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- Media grid: renders all participants (local + remote) as tiles using a
         12-column absolute-positioned layout that mirrors the source
         useGroupCallLayout(). All tiles animate with a 0.3s transition when
         focus changes. -->
    <view :class="mediaGridClassName">
      <!-- Local tile (index 0). -->
      <!-- NOTE: TRTCPusher MUST stay mounted for the entire call to keep the
           room session alive. Use v-show/absolute overlays so the pusher DOM
           is never destroyed while camera is off or media type changes. -->
      <view class="media-tile" :style="tileStyles[0]" @click="toggleFocus(0)">
        <view class="tile-stream">
          <TRTCPusher :key="pusherId" :id="pusherId" v-if="pusherId" />
        </view>
        <!-- Camera-off overlay: custom background image (if configured) or
             the default full-bleed avatar + dark mask. -->
        <view
          class="tile-audio-stream"
          v-show="!isLocalCameraOpen"
        >
          <image v-if="localViewBgImage" :src="localViewBgImage" mode="aspectFill" style="position:absolute;width:100%;height:100%;z-index:1;" />
          <template v-else>
            <Avatar class="tile-bg-avatar" :avatarStyle="tileBgAvatarStyle" :src="selfAvatarUrl" />
            <view class="tile-bg-mask" />
          </template>
        </view>
        <view class="tile-info">
          <text class="tile-name">我</text>
          <image class="mic-icon" :src="isLocalMicrophoneOpen ? IMG_TILE_MIC_ON : IMG_TILE_MIC_OFF" mode="aspectFit" />
        </view>
      </view>

      <!-- Remote tiles (index 1..n). -->
      <!-- NOTE: TRTCPlayer MUST stay mounted while the participant is in the
           call. v-show + absolute overlay keeps the player from being torn
           down when the remote user closes their camera. -->
      <view
        v-for="(participant, index) in allParticipants"
        :key="participant.id || index"
        class="media-tile"
        :style="tileStyles[Number(index) + 1]"
        @click="toggleFocus(Number(index) + 1)"
      >
        <view class="tile-stream">
          <TRTCPlayer v-if="participant.id" :id="participant.id + '_0'" :stream-id="participant.id + '_0'" />
        </view>
        <!-- Camera-off overlay for remote -->
        <view
          class="tile-audio-stream"
          v-show="!participant.isCameraOpened"
        >
          <image v-if="getViewBgImage(participant.id || '')" :src="getViewBgImage(participant.id || '')" mode="aspectFill" style="position:absolute;width:100%;height:100%;z-index:1;" />
          <template v-else>
            <Avatar class="tile-bg-avatar" :avatarStyle="tileBgAvatarStyle" :src="participant.avatarUrl" />
            <view class="tile-bg-mask" />
          </template>
        </view>
        <view class="tile-info">
          <text class="tile-name">{{ participant.name || participant.id || '' }}</text>
          <image class="mic-icon" :src="participant.isMicrophoneOpened ? IMG_TILE_MIC_ON : IMG_TILE_MIC_OFF" mode="aspectFit" />
        </view>
      </view>
    </view>

    <!-- Caller CALLING footer: matches source InitConfig groupCall.[video|audio].calling.
         Uses the same button-panel-container as CONNECTED so it can collapse
         (panelStatus === 'close') when focus is on the local tile, preventing
         the panel from overlapping the media grid.
           open : row1 = mic/speaker/camera, row2 = hangup (padding-top: 6vh)
           close: single row = mic/speaker/camera/hangup -->
    <view :class="videoPanelClassName"
      v-if="selfStatus === CallStatus.CALLING && selfRole === CallRole.CALLER">
      <!-- Toggle button: same open/close affordance as CONNECTED. -->
      <view class="toggle-button-container" @click="togglePanelStatus">
        <image class="toggle-icon" :src="panelStatus === 'close' ? IMG_PANEL_UP : IMG_PANEL_DOWN" mode="aspectFit" />
      </view>

      <view class="button-group">
        <view class="btn-operate">
          <view class="btn-operate-item" @click="microPhoneHandler" v-if="isButtonVisible(FeatureButton.Microphone)">
            <view class="call-operate" :style="micBgColor">
              <image :src="isLocalMicrophoneOpen ? IMG_AUDIO_TRUE : IMG_AUDIO_FALSE" mode="aspectFit" />
            </view>
            <text v-if="panelStatus === 'open'">{{ isLocalMicrophoneOpen ? '麦克风已开启' : '麦克风已关闭' }}</text>
          </view>
          <view class="btn-operate-item" @click="setAudioRoute">
            <view class="call-operate" :style="speakerBgColor">
              <image :src="isSpeakerOpen ? IMG_SPEAKER_TRUE : IMG_SPEAKER_FALSE" mode="aspectFit" />
            </view>
            <text v-if="panelStatus === 'open'">{{ isSpeakerOpen ? '扬声器已开启' : '扬声器已关闭' }}</text>
          </view>
          <view class="btn-operate-item" @click="cameraHandler" v-if="isButtonVisible(FeatureButton.Camera)">
            <view class="call-operate" :style="cameraBgColor">
              <image :src="isLocalCameraOpen ? IMG_CAMERA_TRUE : IMG_CAMERA_FALSE" mode="aspectFit" />
            </view>
            <text v-if="panelStatus === 'open'">{{ isLocalCameraOpen ? '摄像头已开启' : '摄像头已关闭' }}</text>
          </view>
          <!-- Close mode: bring hangup inline as the 4th button. -->
          <view v-if="panelStatus === 'close'" class="btn-operate-item" @click="CallerHangupHandler">
            <view class="call-operate hangup-btn">
              <image v-if="isCallBtnClickable" :src="IMG_HANGUP" mode="aspectFit" />
              <image v-else class="img-loading" :src="IMG_LOADING" mode="aspectFit" />
            </view>
          </view>
        </view>
        <!-- Open mode: hangup on its own row, no label. -->
        <view v-if="panelStatus === 'open'" class="btn-operate hangup-row">
          <view class="btn-operate-item">
            <view class="call-operate hangup-btn" @click="CallerHangupHandler">
              <image v-if="isCallBtnClickable" :src="IMG_HANGUP" mode="aspectFit" />
              <image v-else class="img-loading" :src="IMG_LOADING" mode="aspectFit" />
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- Callee CALLING footer: reject + accept, no button labels -->
    <view class="footer"
      v-if="selfStatus === CallStatus.CALLING && selfRole !== CallRole.CALLER">
      <view class="btn-operate" style="gap: 40px">
        <view class="btn-operate-item">
          <view class="call-operate hangup-btn" @click="reject">
            <image :src="IMG_HANGUP" mode="aspectFit" />
          </view>
        </view>
        <view class="btn-operate-item">
          <view class="call-operate accept-btn" @click="acceptHandler">
            <image v-if="isAcceptBtnClickable" :src="IMG_ACCEPT" mode="aspectFit" />
            <image v-else class="img-loading" :src="IMG_LOADING" mode="aspectFit" />
          </view>
        </view>
      </view>
    </view>

    <!-- Group call CONNECTED footer (audio + video share the same panel).
         Matches source InitConfig groupCall.[video|audio].connected +
         close_connected: supports open/close folding via panelStatus, with
         the toggle button + focus-driven collapse for video calls. -->
    <view :class="videoPanelClassName"
      v-if="selfStatus === CallStatus.CONNECTED">
      <!-- Toggle button: manually collapse / expand the panel. -->
      <view class="toggle-button-container" @click="togglePanelStatus">
        <image class="toggle-icon" :src="panelStatus === 'close' ? IMG_PANEL_UP : IMG_PANEL_DOWN" mode="aspectFit" />
      </view>

      <view class="button-group">
        <view class="btn-operate">
          <view class="btn-operate-item" @click="microPhoneHandler" v-if="isButtonVisible(FeatureButton.Microphone)">
            <view class="call-operate" :style="micBgColor">
              <image :src="isLocalMicrophoneOpen ? IMG_AUDIO_TRUE : IMG_AUDIO_FALSE" mode="aspectFit" />
            </view>
            <text v-if="panelStatus === 'open'">{{ isLocalMicrophoneOpen ? '麦克风已开启' : '麦克风已关闭' }}</text>
          </view>
          <view class="btn-operate-item" @click="setAudioRoute">
            <view class="call-operate" :style="speakerBgColor">
              <image :src="isSpeakerOpen ? IMG_SPEAKER_TRUE : IMG_SPEAKER_FALSE" mode="aspectFit" />
            </view>
            <text v-if="panelStatus === 'open'">{{ isSpeakerOpen ? '扬声器已开启' : '扬声器已关闭' }}</text>
          </view>
          <view class="btn-operate-item" @click="cameraHandler" v-if="isButtonVisible(FeatureButton.Camera)">
            <view class="call-operate" :style="cameraBgColor">
              <image :src="isLocalCameraOpen ? IMG_CAMERA_TRUE : IMG_CAMERA_FALSE" mode="aspectFit" />
            </view>
            <text v-if="panelStatus === 'open'">{{ isLocalCameraOpen ? '摄像头已开启' : '摄像头已关闭' }}</text>
          </view>
          <!-- In "close" mode we bring hangup inline with other buttons; hidden in "open" mode. -->
          <view v-if="panelStatus === 'close'" class="btn-operate-item" @click="hangupHandler">
            <view class="call-operate hangup-btn">
              <image v-if="isHangupBtnClickable" :src="IMG_HANGUP" mode="aspectFit" />
              <image v-else class="img-loading" :src="IMG_LOADING" mode="aspectFit" />
            </view>
          </view>
        </view>
        <!-- Hangup on its own row in open mode with switch-camera button. -->
        <view v-if="panelStatus === 'open'" class="btn-operate hangup-row">
          <view class="btn-operate-item hangup-item">
            <view class="call-operate hangup-btn" @click="hangupHandler">
              <image v-if="isHangupBtnClickable" :src="IMG_HANGUP" mode="aspectFit" />
              <image v-else class="img-loading" :src="IMG_LOADING" mode="aspectFit" />
            </view>
            <!-- Switch-camera: hidden via hideFeatureButton(SwitchCamera);
                 otherwise rendered, disabled when camera is off. -->
            <view
              v-if="isButtonVisible(FeatureButton.SwitchCamera)"
              :class="['switch-camera', { disabled: !isLocalCameraOpen }]"
              @click.stop="switchCameraHandler"
            >
              <image :src="IMG_SWITCH_CAMERA" mode="aspectFit" />
            </view>
          </view>
        </view>
      </view>
    </view>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, watch } from '../../adapter/vue-demi';
import { onUnload } from '@dcloudio/uni-app';
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
import IMG_PANEL_DOWN from '../../assets/call/panel-down.svg';
import IMG_PANEL_UP from '../../assets/call/panel-up.svg';
// Tile-scoped mic icons: compact 28x28 glyphs with built-in circular
// background, meant to overlay directly on top of a stream tile. Distinct
// from the button-panel mic icons which are large monochrome shapes designed
// to sit inside a colored round button.
import IMG_TILE_MIC_ON from '../../assets/call/tile-mic-on.svg';
import IMG_TILE_MIC_OFF from '../../assets/call/tile-mic-off.svg';
import IMG_DEFAULT_AVATAR from '../../assets/base/default-avatar.png';
import IMG_LOADING from '../../assets/call/loading.png';
import { formatDuration } from '../../utils/index';
import { CallMediaType, AudioPlayBackDevice } from '@trtc/call-engine-lite-wx';
import { CallStatus, CallRole } from '../../constants/call';
import { useCallListState, useCallParticipantState, useDeviceState, useUIConfigState } from '../../index';
import { FeatureButton } from '../../states/UIConfigState';

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
  openLocalCamera,
  closeLocalCamera,
  openLocalMicrophone,
  closeLocalMicrophone,
  switchCamera,
  setAudioRoute,
} = useDeviceState();

const { hiddenButtons, viewBackground } = useUIConfigState();

// Helper: whether a particular feature button should be visible.
const isButtonVisible = (btn: FeatureButton) => !hiddenButtons.value.has(btn);

// Button clickable flags: guard against repeated clicks during async ops.
const isCallBtnClickable = ref((inviterId.value || '').length > 0 ? true : false);
const isAcceptBtnClickable = ref(true);
const isHangupBtnClickable = ref(true);

// Focused tile index (0 = local, 1..n = remote[i-1]). When set, that tile
// is enlarged and the others reflow around it. null = balanced grid layout.
// Video group call defaults to focusing the local stream (index 0), matching
// the source MediaContainer's `focus = callType === VIDEO ? 0 : null` init.
const focusIndex = ref<number | null>(mediaType.value === CallMediaType.VIDEO ? 0 : null);

// Button panel status: 'open' shows the full multi-row panel, 'close' collapses
// the panel to a single-row strip so the media area is not blocked. This is
// automatically toggled by focus, and can also be toggled manually via the
// ToggleButtonPanel button. Video group call starts with focus=0 → close.
const panelStatus = ref<'open' | 'close'>(
  mediaType.value === CallMediaType.VIDEO ? 'close' : 'open',
);

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
const allParticipants = computed(() => {
  const info = callParticipantInfo && callParticipantInfo.value;
  return (info && info.allParticipants) || [];
});

const isLocalMicrophoneOpen = computed(() => {
  const info = callParticipantInfo && callParticipantInfo.value;
  return !!(info && info.selfInfo && info.selfInfo.isMicrophoneOpened);
});
const isLocalCameraOpen = computed(() => {
  const info = callParticipantInfo && callParticipantInfo.value;
  return !!(info && info.selfInfo && info.selfInfo.isCameraOpened);
});
const isSpeakerOpen = computed(() => currentAudioRoute.value !== AudioPlayBackDevice.EAR);

// Pre-computed style objects for :style bindings — Vue 2 template compiler
// does not allow function calls (even plain functions) inside :style.
const micBgColor = computed(() => getButtonBgColor(isLocalMicrophoneOpen.value));
const speakerBgColor = computed(() => getButtonBgColor(isSpeakerOpen.value));
const cameraBgColor = computed(() => getButtonBgColor(isLocalCameraOpen.value));

// Tile count = 1 (local) + remotes
const tileCount = computed(() => 1 + allParticipants.value.length);

// View background image helpers for group call tiles.
const getViewBgImage = (userId: string) => {
  const bg = viewBackground.value;
  return bg[userId] || bg['*'] || '';
};
const localViewBgImage = computed(() => {
  const info = callParticipantInfo && callParticipantInfo.value;
  const selfId = (info && info.selfInfo && info.selfInfo.id) || '';
  return getViewBgImage(selfId);
});

/**
 * 12-column layout generator, ported from the source useGroupCallLayout().
 *
 * Returns a list of { i, x, y, w, h } describing each tile's position and
 * size on a 12x? grid. Rules (mobile):
 * - <= 4 tiles: each is 6x6 (2 columns per row).
 *   - 3 tiles: last one shifts +3 to center it on the second row.
 * - >= 5 tiles: each is 4x4 (3 columns per row).
 * - Focused mode with < 5 tiles: focused tile becomes 12x12 (top), others
 *   become 4x4 stacked below it.
 * - Focused mode with >= 5 tiles: focused tile becomes 8x8, other tiles in
 *   the same row shrink and reflow around it.
 */
function computeLayout(length: number, focusIdx: number | null) {
  if (length <= 0) return [] as Array<{ i: number; x: number; y: number; w: number; h: number }>;

  const size = length <= 4 ? 6 : 4;
  const layout: Array<{ i: number; x: number; y: number; w: number; h: number }> = [
    { i: 0, x: 0, y: 0, w: size, h: size },
  ];
  for (let i = 1; i < length; i++) {
    const isWrap = layout[i - 1].x + size === 12;
    layout[i] = {
      i,
      x: layout[i - 1].x + size === 12 ? 0 : layout[i - 1].x + size,
      y: layout[i - 1].y + (isWrap ? size : 0),
      w: size,
      h: size,
    };
  }
  // 3-tile special case: center the last tile on the second row.
  if (length === 3) {
    layout[length - 1].x += 3;
  }

  if (focusIdx === null || focusIdx === undefined) {
    return layout;
  }

  // Focus mode.
  if (length < 5) {
    // Move focused tile to slot 0 and make it 12x12; others become 4x4 below.
    const focusPos = layout.findIndex(item => item.i === focusIdx);
    if (focusPos !== -1) {
      const temp = layout[0];
      layout[0] = layout[focusPos];
      layout[focusPos] = temp;
      for (let i = 0; i < layout.length; i++) {
        const item = layout[i];
        if (i === 0) {
          item.w = 12;
          item.h = 12;
          item.x = 0;
          item.y = 0;
        } else {
          item.x = (i - 1) * 4;
          item.y = 12;
          item.w = 4;
          item.h = 4;
        }
      }
    }
    return layout;
  }

  // Focus mode with >= 5 tiles.
  const rowIndex = focusIdx % 3;
  const colIndex = Math.floor(focusIdx / 3);
  let focusStyle: { i: number; x: number; y: number; w: number; h: number } | null = null;

  if (rowIndex === 0) {
    if (layout[focusIdx + 1]) layout[focusIdx + 1].x += 4;
    if (layout[focusIdx + 2]) layout[focusIdx + 2].y += 4;
    focusStyle = { i: focusIdx, x: 0, y: colIndex * 4, w: 8, h: 8 };
  } else if (rowIndex === 2) {
    focusStyle = { i: focusIdx, x: 4, y: colIndex * 4, w: 8, h: 8 };
    if (layout[focusIdx - 1]) {
      layout[focusIdx - 1].x = 0;
      layout[focusIdx - 1].y += 4;
    }
  } else if (rowIndex === 1) {
    focusStyle = { i: focusIdx, x: 4, y: colIndex * 4, w: 8, h: 8 };
    if (layout[focusIdx + 1]) {
      layout[focusIdx + 1].x = 0;
      layout[focusIdx + 1].y += 4;
    }
  }
  const start = 3 - rowIndex;
  for (let i = focusIdx + start; i < layout.length; i++) {
    layout[i].y += 4;
  }
  if (focusStyle) {
    layout[focusIdx] = focusStyle;
  }
  return layout;
}

/**
 * Compute per-tile inline style. Uses vw as the base unit so tiles are always
 * square-shaped (1/12 of viewport width per grid unit), which matches the
 * source project's mobile behavior.
 */
function _computeTileStyle(index: number): string {
  const layout = computeLayout(tileCount.value, focusIndex.value);
  const target = layout.find(item => item.i === index);
  // Never fully unmount a tile via display:none, because the tile contains a
  // TRTCPusher / TRTCPlayer whose lifecycle must span the whole call. When a
  // tile has no layout slot (e.g. transient race conditions), keep it in the
  // DOM but hide it via visibility so the underlying stream keeps running.
  //
  // NOTE: returns a CSS string (not an object). The uni-app Vue 2 mini-program
  // build does not normalize object `:style` bindings referenced via a
  // variable, so an object would render as "[object Object]" and the tiles
  // would lose all positioning. A string renders identically on Vue 2/Vue 3.
  if (!target) {
    return 'position: absolute; width: 0; height: 0; left: 0; top: 0; visibility: hidden;';
  }
  const unit = 100 / 12; // 1 grid cell in vw
  return `position: absolute; width: ${target.w * unit}vw; height: ${target.h * unit}vw; left: ${target.x * unit}vw; top: ${target.y * unit}vw;`;
}

// Pre-computed tile style array — Vue 2 template compiler does not allow
// function calls inside :style bindings.
const tileStyles = computed(() => {
  const styles: string[] = [];
  for (let i = 0; i < tileCount.value; i++) {
    styles.push(_computeTileStyle(i));
  }
  return styles;
});

// Callee waiting overlay: derive inviter info from the authoritative
// CALLER_USER_INFO (callerInfo), mirroring the official Waiting.vue which reads
// callerUserInfo rather than scanning the remote list. This is immune to the
// async ordering / mutations of allParticipants, so the big inviter avatar and
// name always reflect the real caller.
const inviterAvatar = computed(() => {
  const info = callParticipantInfo && callParticipantInfo.value;
  const caller = info && info.callerInfo;
  return (caller && caller.avatarUrl) || '';
});
const inviterDisplayName = computed(() => {
  const info = callParticipantInfo && callParticipantInfo.value;
  const caller = info && info.callerInfo;
  return (caller && caller.name) || (caller && caller.id) || inviterId.value || '';
});
const participantAvatarList = computed(() => allParticipants.value);


// Class name for the media grid container. Matches the source project's
// mobile MediaContainer behavior: default margin-top is 5.5vh, but for the
// special "two-layout" case (2 tiles without focus) the top margin grows to
// ~15vh so the two tiles sit lower on the screen.
const mediaGridClassName = computed(() => {
  const classes = ['media-grid'];
  if (tileCount.value === 2 && focusIndex.value === null) {
    classes.push('two-layout');
  }
  return classes.join(' ');
});

// Class name for the video-connected footer: applies open/close state and a
// "showBackGround" flag that darkens the panel when a tile is focused (matches
// the source ButtonPanel behavior for groupCall + mobile + focused).
const videoPanelClassName = computed(() => {
  const classes = ['button-panel-container'];
  classes.push(panelStatus.value === 'open' ? 'panel-open' : 'panel-close');
  if (focusIndex.value !== null) {
    classes.push('show-background');
  }
  return classes.join(' ');
});

function toggleFocus(index: number) {
  // Focus toggling is available at any call phase for both audio and video
  // group calls, matching source MediaContainer's `enableFocus = !isPC`.
  // For audio calls, enlarging a tile still makes sense - the tile shows a
  // full-bleed avatar which acts as a visual anchor for the speaker.
  focusIndex.value = focusIndex.value === index ? null : index;
  // Auto-collapse the button panel when a tile is focused so the enlarged
  // media view is not covered; auto-expand on unfocus.
  panelStatus.value = focusIndex.value !== null ? 'close' : 'open';
}

// Toggle button panel manually.
function togglePanelStatus() {
  panelStatus.value = panelStatus.value === 'close' ? 'open' : 'close';
}

// Inviter avatar: 100x100 to match source OverlayStream avatarSize=100 on mobile.
// Uses a 12px rounded-square corner to stay consistent with the 1v1 CallView
// caller avatar (avatarStyle borderRadius: 12px).
// NOTE: all avatar style values below are CSS strings (not objects). In the
// uni-app Vue 2 mini-program build a `:style` bound to a variable is compiled
// to `style="{{expr}}"` without object normalization, so an object would
// render as "[object Object]" and be ignored. Strings render identically on
// both Vue 2 and Vue 3, keeping the UI aligned across frameworks.
const inviterAvatarStyle = 'width: 100px; height: 100px; border-radius: 12px; display: block; margin: 0 auto 12px;';

// Full-bleed background avatar for a media tile when the camera is off.
// Absolutely positioned to cover the whole tile (aspectFill via Avatar).
const tileBgAvatarStyle = 'position: absolute; top: 0; left: 0; width: 100%; height: 100%;';

// Participant avatar tiles in the "N people in the call" grid: 10vw square,
// matching source Waiting.vue .avatar-item { width: 10vw; height: 10vw }.
const avatarGroupItemStyle = 'width: 10vw; height: 10vw; border-radius: 50%; display: block;';

// Toggle button background: white when active (mic/camera/speaker on) and
// muted grey-blue (#6b758a4d = ~30% opacity gray-blue) when closed. Colors
// match source DefaultUI (basicConfig color: '#FFFFFF', closedConfig color:
// '#6b758a4d').
// Returns a CSS string (not an object): the uni-app Vue 2 mini-program build
// does not normalize object `:style` bindings referenced via a variable, so an
// object would render as "[object Object]". A string works on both Vue 2/Vue 3.
function getButtonBgColor(isActive: boolean) {
  return isActive
    ? 'background-color: #FFFFFF;'
    : 'background-color: #6b758a4d;';
}

async function cameraHandler() {
  if (isLocalCameraOpen.value) {
    await closeLocalCamera();
  } else {
    await openLocalCamera();
  }
}

// Switch-camera is gated on the local camera being open. If the camera is
// off the button is rendered in a disabled visual state and clicks are
// swallowed here.
async function switchCameraHandler() {
  if (!isLocalCameraOpen.value) return;
  await switchCamera();
}

async function microPhoneHandler() {
  if (isLocalMicrophoneOpen.value) {
    await closeLocalMicrophone();
  } else {
    await openLocalMicrophone();
  }
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
      console.warn('previous accept is ongoing, please avoid repeat accept');
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
      console.warn('previous hangup is ongoing, please avoid repeat hangup');
      return;
    }
    isHangupBtnClickable.value = false;
    await hangup();
    isHangupBtnClickable.value = true;
  } catch (error) {
    isHangupBtnClickable.value = true;
  }
}

// Watch call status: reset focus and button-clickable flags on IDLE.
watch(() => callParticipantInfo.value && callParticipantInfo.value.selfInfo, (newObj) => {
  const newStatus = newObj && newObj.status;

  if (newStatus === CallStatus.IDLE) {
    isAcceptBtnClickable.value = true;
    isHangupBtnClickable.value = true;
    focusIndex.value = null;
    panelStatus.value = 'open';
  }
});

watch(inviterId, (newVal) => {
  isCallBtnClickable.value = (newVal || '').length > 0;
});

// Auto-cleanup: hangup / reject on page unload if still active.
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
.TUIGroupCall-container {
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  position: relative;
  /* Background: solid dark base with a large centered default-avatar watermark
     layer covered by an 85% opaque dark mask (#22262ed9), matching the source
     project's BackGround.vue (Overlay bgColor="#22262ed9" bgImage=defaultAvatar). */
  background-color: #22262e;

  /* Default-avatar watermark, rendered behind everything else. */
  .backdrop-image {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    z-index: 0;
    object-fit: cover;
    opacity: 0.15; /* let the mask below dominate; avatar just softens the bg */
  }

  /* Dark translucent mask covering the whole viewport. */
  .backdrop-mask {
    position: absolute;
    inset: 0;
    background-color: rgba(34, 38, 46, 0.85);
    z-index: 0;
  }

  /* Top bar with call duration. Matches source Timer defaults:
       color: #FFF, font-size: 16px, no background chip, no padding.
     Centered horizontally at ~2vh from the top. */
  .topBar {
    position: fixed;
    top: 2vh;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    justify-content: center;
    width: 100%;
    z-index: 20;

    .call-duration {
      text-align: center;
      font-family: PingFang SC;
      font-weight: 500;
      font-size: 16px;
      color: #FFFFFF;
    }
  }

  /* Callee waiting overlay: full-screen mask over the media grid. Matches
     source Waiting.vue - covers the entire viewport at z-index: 2, with the
     footer floating above via z-index: 100 (so accept/reject remain visible
     and interactive). Content is anchored at top ~26%. */
  .waiting-overlay {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    z-index: 2;

    .waiting-mask {
      position: absolute;
      inset: 0;
      background-color: rgba(34, 38, 46, 0.85);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
    }

    .waiting-content {
      position: absolute;
      top: 26%;
      left: 0;
      right: 0;
      display: flex;
      flex-direction: column;
      align-items: center;
      color: #FFFFFF;

      /* Nickname: 20px matching source OverlayStream mobile font-size. */
      .waiting-nick {
        font-family: PingFang SC;
        font-size: 20px;
        font-weight: 500;
        color: #FFFFFF;
        max-width: 200px;
        overflow: hidden;
        white-space: nowrap;
        text-overflow: ellipsis;
      }

      /* Tip text: sits 12px below the nickname (matches source
         .overlay-stream-tip margin-top: 12px). */
      .waiting-tip {
        margin-top: 12px;
        font-family: PingFang SC;
        font-size: 14px;
        color: #FFFFFF;
      }

      /* Participant count + avatar grid group. margin-top: 24px matches
         source .groupcall-info { margin-top: 24px }. */
      .waiting-count {
        margin-top: 24px;
        display: flex;
        flex-direction: column;
        align-items: center;
        width: 100%;

        .waiting-count-text {
          font-size: 14px;
          color: #FFFFFF;
        }

        .avatar-group {
          margin-top: 12px;
          display: flex;
          flex-wrap: wrap;
          align-items: center;
          justify-content: center;
          max-width: 70%;

          .avatar-item {
            width: 10vw;
            height: 10vw;
            margin-left: 10px;
            margin-top: 10px;
          }
        }
      }
    }
  }

  /* Media grid area: fills the region between topBar and footer. */
  /* Media grid area: a 12-column absolute-positioned container. Tiles are
     positioned via inline style (see tileStyle()), sized in vw so each grid
     cell is a perfect square. The container itself has margin-top ~= 5.5vh
     to mirror the source project's mobile MediaContainer offset. */
  .media-grid {
    position: absolute;
    top: 5.5vh;
    left: 0;
    right: 0;
    bottom: 0;
    z-index: 1;
    transition-property: top;
    transition-duration: 0.3s;
    transition-timing-function: ease-in;

    /* Two-tile layout: shift both tiles further down (matches the source
       .two-layout { margin-top: 15vh } behavior). */
    &.two-layout {
      top: 15vh;
    }
  }

  .media-tile {
    position: absolute;
    /* Solid Pusher-container background (#4c515a), matches source
       Pusher.vue's .pusher-container background. */
    background-color: #4c515a;
    box-sizing: border-box;
    overflow: hidden;
    /* Match GridItem's 0.3s ease-in transition on width/height/left/top so
       layout changes (participant join/leave, focus toggle) animate smoothly. */
    transition-property: width, height, left, top;
    transition-duration: 0.3s;
    transition-timing-function: ease-in;

    .tile-stream {
      width: 100%;
      height: 100%;
    }

    /* Audio-only / camera-off placeholder: full-bleed avatar as background +
       dark translucent mask on top. Matches source AudioStream behavior in
       group call (showAvatar=false, bgImage=avatar, bgColor="rgba(0,0,0,0.5)"). */
    .tile-audio-stream {
      position: absolute;
      inset: 0;
      z-index: 2;

      .tile-bg-avatar {
        position: absolute;
        inset: 0;
        width: 100%;
        height: 100%;
        object-fit: cover;
      }

      .tile-bg-mask {
        position: absolute;
        inset: 0;
        background-color: rgba(0, 0, 0, 0.5);
      }
    }

    /* Bottom-left info strip: nickname + mic icon, no background chip.
       Directly overlays the stream in white text, matching the source
       StreamInfoMobile Row with padding 2px 5px, left-aligned. */
    .tile-info {
      position: absolute;
      left: 0;
      right: 0;
      bottom: 0;
      padding: 2px 5px 8px 5px;
      display: flex;
      align-items: center;
      justify-content: flex-start;
      z-index: 3;

      .tile-name {
        font-family: PingFang SC;
        font-size: 14px;
        color: #FFFFFF;
        max-width: 100px;
        overflow: hidden;
        white-space: nowrap;
        text-overflow: ellipsis;
        margin-right: 4px;
      }

      .mic-icon {
        width: 24px;
        height: 24px;
        flex-shrink: 0;
      }
    }
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

      /* Hangup row: pushed down from the operations row by ~6vh to match
         the source InitConfig's `paddingTop: '6vh'` on the hangup slot. */
      &.hangup-row {
        padding-top: 6vh;
      }
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
          height: 30px;
        }

        @keyframes rotate {
          from {
            transform: rotate(0deg);
          }
          to {
            transform: rotate(360deg);
          }
        }
      }

      .hangup-btn {
        background-color: #ED4651;
      }

      .accept-btn {
        background-color: #51C271;
      }
    }
  }

  /* Video CONNECTED footer with open/close animation. */
  .button-panel-container {
    position: absolute;
    left: 0;
    right: 0;
    bottom: 0;
    display: flex;
    justify-content: center;
    align-items: flex-start;
    width: 100%;
    box-sizing: border-box;
    z-index: 100;
    /* Smooth transition when the panel folds / unfolds. */
    transition-property: height, background-color;
    transition-duration: 0.3s;
    transition-timing-function: ease-in;

    /* Focus mode: darken the panel background to visually separate from the
       enlarged focused tile, matching the source ButtonPanel behavior. */
    &.show-background {
      background-color: #4F586B;
    }

    /* Open state: full multi-row panel occupying ~27% of the viewport,
       hangup button lives on its own row. */
    &.panel-open {
      height: 27vh;

      .button-group {
        position: absolute;
        width: 72%;
        top: 2vh;
        height: 80%;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: flex-start;
      }

      .toggle-button-container {
        bottom: 6vh;
      }
    }

    /* Close state: collapse into a single-row strip so the media grid gets
       more space. Layout matches the source project's Grid 12-col system:
       - button-group is 72% wide, right-anchored at 6.2vw
       - 4 buttons occupy 4 equal cells (12/4 = 3 units each = 25% each)
       - Each cell horizontally centers its button (GridItem's
         `justify-content: center`)
       - Buttons: 40x40 circle with a 20x20 icon (source `iconSize: 20`) */
    &.panel-close {
      height: 14vh;
      align-items: center;

      .button-group {
        position: absolute;
        width: 72%;
        right: 6.2vw;
        height: 40px;
        top: auto;
        bottom: auto;
      }

      .btn-operate {
        /* 4 equal-width cells, each centering its button. */
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        align-items: center;
        justify-items: center;
        width: 100%;
        height: 100%;
      }

      .btn-operate-item {
        margin: 0;

        .call-operate {
          width: 40px;
          height: 40px;
          margin: 0;

          /* Icon size 20px matches source ClosedPanelUI `iconSize: 20`. */
          image {
            width: 20px;
            height: 20px;
          }
        }
      }
    }

    .btn-operate {
      display: flex;
      flex-direction: row;
      align-items: center;
      justify-content: center;
      width: 100%;

      &.hangup-row {
        margin-top: 12px;
      }
    }

    .btn-operate-item {
      display: flex;
      flex-direction: column;
      align-items: center;

      text {
        font-family: PingFang SC;
        font-weight: 400;
        font-size: 12px;
        color: #D5E0F2;
        margin-top: 4px;
      }

      .call-operate {
        width: 56px;
        height: 56px;
        border-radius: 50%;
        margin: 0 6vw;
        box-sizing: border-box;
        display: flex;
        justify-content: center;
        align-items: center;

        image {
          width: 28px;
          height: 28px;
        }

        .img-loading {
          animation: rotate 1.5s linear infinite;
          width: 28px;
          height: 28px;
        }
      }

      .hangup-btn {
        background-color: #ED4651;
      }

      /* Switch-camera button: sits to the RIGHT of the hangup button and is
         vertically centered against it. .hangup-item is set to
         position: relative so absolute-positioned .switch-camera anchors to
         the button item's box. */
      &.hangup-item {
        position: relative;
      }

      .switch-camera {
        position: absolute;
        top: 50%;
        /* Sit just outside the hangup button's right edge, with a small gap. */
        left: calc(50% + 40px);
        transform: translateY(-50%);
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background-color: rgba(34, 38, 46, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        transition: opacity 0.2s ease-in;

        image {
          width: 18px;
          height: 18px;
        }

        /* Disabled state when local camera is off. Visually dimmed and
           click events are ignored (see @click handler guard). */
        &.disabled {
          opacity: 0.4;
          pointer-events: none;
        }
      }
    }

    /* Toggle button: sits on the left side of the panel, follows open/close. */
    .toggle-button-container {
      position: absolute;
      left: 8.2vw;
      width: 40px;
      height: 40px;
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 2;
      transition-property: bottom, top;
      transition-duration: 0.3s;
      transition-timing-function: ease-in;

      .toggle-icon {
        width: 40px;
        height: 40px;
      }
    }
  }
}
</style>
