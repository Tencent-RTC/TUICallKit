<template>
  <!-- page-meta disables page-level scrolling for both the WeChat and H5 runtimes.
       The login screen is intentionally non-scrollable because its content is
       designed to fit within a single viewport on common phone sizes. -->
  <page-meta :page-style="pageStyle" />
  <view class="container">
    <!-- Login section: input userID to log in to the call service -->
    <view class="login-section" v-if="!isLoggedIn">
      <text class="guide-text">请输入 userID 用于登录</text>
      <input class="input-box" :class="{ focused: userIDFocused }" v-model="userID" :placeholder="userIDFocused ? '' : '请输入您的用户ID'" placeholder-style="color:#BBBBBB;" @focus="userIDFocused = true" @blur="userIDFocused = false" />
      <button class="login-btn" @click="handleLogin">登录</button>
    </view>

    <!-- Call launcher section: type target userID(s), pick call type -->
    <view class="call-section" v-else>
      <text class="guide-text">发起通话</text>
      <text class="sub-guide">在下方输入 userID，多个用英文逗号分隔</text>
      <textarea class="target-input" :class="{ focused: targetInputFocused }" v-model="targetUserIDText" :placeholder="targetInputFocused ? '' : '例如：userA,userB,userC'" placeholder-style="color:#BBBBBB;" @focus="targetInputFocused = true" @blur="targetInputFocused = false" />
      <view class="mode-row">
        <view class="mode-tag" :class="{ active: !isGroup }" @click="isGroup = false">1v1 通话</view>
        <view class="mode-tag" :class="{ active: isGroup }" @click="isGroup = true">群通话</view>
      </view>
      <view class="mode-row">
        <view class="mode-tag" :class="{ active: mediaType === CallMediaType.VIDEO }" @click="mediaType = CallMediaType.VIDEO">视频通话</view>
        <view class="mode-tag" :class="{ active: mediaType === CallMediaType.AUDIO }" @click="mediaType = CallMediaType.AUDIO">语音通话</view>
      </view>
      <!-- The click listener is bound on the wrapper view (not the button)
           so we can always show a toast explaining why the call cannot be
           placed (e.g. the user entered their own userID for a 1v1 call).
           The button itself stays visually enabled and the wrapper routes
           the tap to the click handler. -->
      <view class="start-call-wrapper" @click="handleStartCallClick">
        <button class="start-call-btn">发起通话</button>
      </view>
      <text class="logged-hint">当前 userID：{{ userID }}</text>
    </view>
  </view>
</template>

<script lang="ts" setup>
  import { ref, computed, onBeforeUnmount } from '../../TUICallKit/adapter/vue-demi';
  import { CallMediaType, TUICallEvent } from '@trtc/call-engine-lite-wx';
  import { useLoginState } from '../../TUICallKit/states/LoginState';
  import { useCallListState } from '../../TUICallKit/states/CallListState';
  import { TUICallKitAPI } from '../../TUICallKit/states/TUICallService/index';
  import { genTestUserSig, SDKAPPID as SDKAppID } from '../../debug/GenerateTestUserSig-es.js';

  const userID = ref('');
  const targetUserIDText = ref('');
  const isLoggedIn = ref(false);
  const isGroup = ref(false);
  const mediaType = ref<number>(CallMediaType.VIDEO);
  // Track input focus so we can render a "selected" border/glow style. WeChat
  // mini-program's native <input> does not honor CSS :focus reliably, so we
  // drive the focused class via @focus / @blur events.
  const userIDFocused = ref(false);
  const targetInputFocused = ref(false);
  // Force the page root to be non-scrollable by overriding overflow on the body.
  // We pass this through <page-meta page-style> so it applies to the native
  // page container, which a scoped style on this component cannot reach.
  const pageStyle = 'overflow: hidden; height: 100vh;';

  const { login } = useLoginState();
  const { calls } = useCallListState();

  // Max participants allowed in a group call, including the caller (self).
  const GROUP_CALL_MAX_MEMBERS = 9;

  // Listened-once function reference, so the matching `off` call in
  // onBeforeUnmount removes exactly this handler instead of any other
  // registrations the engine may have (CallService registers its own
  // handler internally for state-machine updates).
  const onKickedOut = () => {
    // The account has been kicked offline (e.g. another device logged in with
    // the same userID and multi-end login is disabled). Reset local UI state
    // and surface a toast so the user knows to re-enter their userID.
    isLoggedIn.value = false;
    userID.value = '';
    targetUserIDText.value = '';
    uni.showToast({ title: '账号已在其他端登录，请重新登录', icon: 'none' });
  };

  const canStartCall = computed(() => {
    // Exclude self so a user cannot place a call to themselves.
    const ids = parseUserIDList(targetUserIDText.value).filter(
      (id) => id !== userID.value
    );
    if (ids.length === 0) return false;
    // 1v1 call: exactly one userID
    if (!isGroup.value && ids.length !== 1) return false;
    // Group call: total members (targets + self) must not exceed the limit.
    if (isGroup.value && ids.length + 1 > GROUP_CALL_MAX_MEMBERS) return false;
    return true;
  });

  function parseUserIDList(text: string): string[] {
    return (text || '')
      .split(/[,\s]+/)
      .map((s) => s.trim())
      .filter((s) => !!s);
  }

  const handleLogin = async () => {
    if (!userID.value) {
      uni.showToast({ title: '请输入 userID', icon: 'none' });
      return;
    }
    const { userSig } = genTestUserSig({ userID: userID.value });

    // Register the ring plugin before login so it is listening on the event bus
    // by the time the first call state change is published.

    await login({
      userId: userID.value,
      userSig,
      sdkAppId: SDKAppID,
    });
    TUICallKitAPI.enableMultiDeviceAbility(true);
    // Pages the call-service router navigates to when call status changes.
    // The single-call page hosts the 1v1 view; the group-call page hosts the
    // multi-tile grid.
    wx.$globalCallPagePath = 'TUICallKit/components/CallView/CallView';
    wx.$globalGroupCallPagePath = 'TUICallKit/components/GroupCallView/GroupCallView';

    // Subscribe to the KICKED_OUT engine event so this page can drop the
    // local user back to the login form when the same account is signed in
    // on another device (multi-end login disabled).
    const callEngine = TUICallKitAPI.getTUICallEngineInstance?.();
    callEngine?.on?.(TUICallEvent.KICKED_OUT, onKickedOut);

    isLoggedIn.value = true;
  };

  // Wrapper click handler. We route taps through here (instead of binding
  // @click directly on the button) because WeChat/uni-app suppress click
  // events on disabled buttons, which would otherwise swallow the toast we
  // want to show when validation fails.
  const handleStartCallClick = () => {
    if (canStartCall.value) {
      startCall();
      return;
    }
    // Explain exactly why the call cannot be placed. We re-run the same
    // checks the computed property uses so the message matches the visible
    // disabled state.
    const rawList = parseUserIDList(targetUserIDText.value);
    if (rawList.length === 0) {
      uni.showToast({ title: '请输入目标 userID', icon: 'none' });
      return;
    }
    if (new Set(rawList).size !== rawList.length) {
      uni.showToast({ title: 'userID 不能重复', icon: 'none' });
      return;
    }
    if (rawList.includes(userID.value)) {
      uni.showToast({ title: '不能向自己发起呼叫', icon: 'none' });
      return;
    }
    if (!isGroup.value && rawList.length !== 1) {
      uni.showToast({ title: '1v1 通话只能输入一个 userID', icon: 'none' });
      return;
    }
    if (isGroup.value && rawList.length + 1 > GROUP_CALL_MAX_MEMBERS) {
      uni.showToast({ title: '群通话人数不能超过9人', icon: 'none' });
    }
  };

  // Always unregister the KICKED_OUT listener when the page is torn down so
  // the call engine does not keep a stale callback pointing at this view.
  onBeforeUnmount(() => {
    const callEngine = TUICallKitAPI.getTUICallEngineInstance?.();
    callEngine?.off?.(TUICallEvent.KICKED_OUT, onKickedOut);
  });

  const startCall = async () => {
    const rawList = parseUserIDList(targetUserIDText.value);
    // Reject duplicate userIDs in the target list. The check runs before
    // anything else so the user gets a clear error even when duplicates
    // would also collide with the self-check or the 1v1 / group limits.
    if (new Set(rawList).size !== rawList.length) {
      uni.showToast({ title: 'userID 不能重复', icon: 'none' });
      return;
    }
    // Reject placing a call to yourself.
    if (rawList.includes(userID.value)) {
      uni.showToast({ title: '不能向自己发起呼叫', icon: 'none' });
      return;
    }
    const userIDList = rawList.filter((id) => id !== userID.value);
    if (userIDList.length === 0) return;
    if (!isGroup.value && userIDList.length !== 1) {
      uni.showToast({ title: '1v1 通话只能输入一个 userID', icon: 'none' });
      return;
    }
    // Group call: total members (targets + self) must not exceed the limit.
    if (isGroup.value && userIDList.length + 1 > GROUP_CALL_MAX_MEMBERS) {
      uni.showToast({ title: '群通话人数不能超过9人', icon: 'none' });
      return;
    }
    try {
      await calls({
        userIDList,
        type: mediaType.value,
      });
    } catch (error) {
      console.error('[login startCall] failed', error);
    }
  };
</script>

<style scoped>
  .container {
    padding: 40px;
    height: 100vh;
    display: flex;
    flex-direction: column;
    /* Disable scrolling for the login screen so the layout stays fixed even
     when the keyboard or device rotation would otherwise cause overflow. */
    overflow: hidden;
  }

  .login-section,
  .call-section {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-top: 80px;
  }

  .guide-text {
    font-weight: 600;
    font-size: 22px;
    color: rgb(47, 46, 46);
    margin-bottom: 16px;
  }

  .sub-guide {
    font-size: 13px;
    color: #888;
    margin-bottom: 24px;
  }

  .input-box,
  .target-input {
    width: 80%;
    border: 1px solid #DDDDDD;
    border-radius: 8px;
    padding: 12px 15px;
    margin-bottom: 20px;
    font-size: 16px;
    box-sizing: border-box;
    background-color: #fff;
    color: #222;
    /* Smooth transition for the focus outline/border so tapping into the
     input feels responsive. */
    transition: border-color 0.2s, box-shadow 0.2s;
  }

  /* Single-line userID input: give it the same visual height as the primary
   button (50px) so the form has a consistent baseline. */
  .input-box {
    height: 50px;
    line-height: 26px;
  }

  /* Focus (selected) state: highlight border in brand blue with a soft glow.
   Class-based .focused is used for the WeChat runtime (native <input> does
   not honor :focus consistently); :focus is kept for the H5 runtime. */
  .input-box.focused,
  .target-input.focused,
  .input-box:focus,
  .target-input:focus {
    border-color: #006EFF;
    box-shadow: 0 0 0 2px rgba(0, 110, 255, 0.15);
    outline: none;
  }

  .target-input {
    height: 100px;
    resize: none;
  }

  /* Wrapper around the disabled-capable button so we can still receive click
   events on the button itself when validation fails. The wrapper keeps the
   same width as the button so the visual layout is unchanged. */
  .start-call-wrapper {
    width: 80%;
    display: flex;
  }

  .login-btn,
  .start-call-btn {
    width: 80%;
    height: 50px;
    color: white;
    border-radius: 8px;
    font-size: 16px;
    line-height: 50px;
    margin-top: 12px;
  }

  .login-btn {
    background-color: #006EFF;
  }

  .start-call-btn {
    background-color: #006EFF;
  }

  .mode-row {
    display: flex;
    justify-content: center;
    width: 80%;
    margin-bottom: 16px;
    gap: 16px;
  }

  .mode-tag {
    flex: 1;
    height: 44px;
    line-height: 44px;
    text-align: center;
    font-size: 15px;
    color: #444;
    border: 1px solid #DDDDDD;
    border-radius: 8px;
    background-color: #fff;
    transition: background-color 0.2s, color 0.2s, border-color 0.2s;
  }

  .mode-tag.active {
    background-color: #006EFF;
    color: #fff;
    border-color: #006EFF;
  }

  .logged-hint {
    margin-top: 20px;
    font-size: 12px;
    color: #aaa;
  }
</style>