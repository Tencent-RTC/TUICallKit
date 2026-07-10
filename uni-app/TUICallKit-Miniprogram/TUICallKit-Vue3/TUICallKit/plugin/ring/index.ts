/**
 * call-ring — Self-observing ring plugin for WeChat Mini Program.
 *
 * The plugin listens to call state changes through the uni global event bus.
 * The host (TUICallService) publishes events on the same bus — neither side
 * imports from the other. The event name convention is the only contract.
 *
 * @example
 * ```ts
 * import { useRingPlugin } from '../plugin/ring';
 * TUICallKitAPI.registerPlugin(useRingPlugin());
 * ```
 */

import DEFAULT_CALLER_BELL_FILEPATH from './assets/phone_dialing.mp3';
import DEFAULT_CALLEE_BELL_FILEPATH from './assets/phone_ringing.mp3';
import { STATUS_CALLING, ROLE_CALLEE, CALL_RING_EVENTS } from './store';
import { RingType } from './types/ring';

export { RingType };
export type { ObservableStore } from './store';
export { CALL_RING_EVENTS } from './store';

// ====================== Audio Engine ======================

let bell: any = null;
// `isPlaying` reflects the actual play state of the InnerAudioContext. It is
// toggled off by any pause/stop path. Do NOT use it to decide whether the ring
// should still be audible — use `shouldRing` (user intent) for that.
let isPlaying = false;
// `shouldRing` reflects the intent: the call is in CALLING state, so a ring is
// expected. It stays true from status→CALLING until status leaves CALLING,
// regardless of temporary interruptions or backgrounding. The interruption /
// app-visibility resume paths check this to decide whether to restart.
let shouldRing = false;
let currentRingType: RingType = RingType.CALLER;
let isStopping = false;
// Tracks whether the mini program is currently in the foreground. WeChat
// forbids operating an InnerAudioContext while in the background (play()/
// pause() fail with "operateAudio:fail jsapi has no permission, runningState=
// background"). We therefore never operate audio in the background; we keep
// the `shouldRing` intent and (re)start playback when App.onShow brings us
// back to the foreground. Assume foreground initially — the plugin is created
// while a page is visible.
let isForeground = true;

function getBellFilePath(type: RingType): string {
  if (type === RingType.CALLEE) {
    return customCalleeBell || DEFAULT_CALLEE_BELL_FILEPATH;
  }
  return DEFAULT_CALLER_BELL_FILEPATH;
}

function initBell(): void {
  if (bell) return;
  try {
    // On iOS, InnerAudioContext obeys the hardware mute switch by default
    // (obeyMuteSwitch=true), which silences the ring when the phone is in
    // silent mode. A call ringtone must be audible regardless, so disable it
    // and force loudspeaker output. Applies globally; set before playing.
    // Note: incompatible with useWebAudioImplement:true, hence we create the
    // context with useWebAudioImplement:false below.
    try {
      (wx as any).setInnerAudioOption({ obeyMuteSwitch: false, speakerOn: true });
    } catch (optErr) {
      console.warn('[call-ring] setInnerAudioOption failed:', optErr);
    }
    bell = (wx as any).createInnerAudioContext({ useWebAudioImplement: false });
    bell.loop = true;
    // Race guard: if the intent flipped between issuing play() and the audio
    // actually starting, stop it immediately. Use `shouldRing` (user intent)
    // rather than `isPlaying` (which is flipped by pause paths and would
    // spuriously stop a legitimate resume).
    bell.onPlay(() => { if (!shouldRing) { bell?.pause(); bell?.stop(); } });
    // onCanplay: the src is ready to play. Calling play() before this event
    // (especially right after (re)creating the context on foreground) can
    // silently no-op on some devices. Re-issue play() here whenever we still
    // intend to ring and are in the foreground. play() is idempotent, so
    // calling it again after the eager play() in playRing() is harmless.
    bell.onCanplay(() => {
      if (shouldRing && isForeground) {
        try { bell?.play(); } catch (e) { console.warn('[call-ring] play on canplay failed:', e); }
      }
    });
    bell.onError((err: any) => { console.warn('[call-ring] bell onError:', err); });
    (wx as any).onAudioInterruptionBegin(handleAudioInterruptionBegin);
    (wx as any).onAudioInterruptionEnd(handleAudioInterruptionEnd);
  } catch (e) {
    console.warn('[call-ring] createInnerAudioContext failed:', e);
    bell = null;
  }
}

// Audio interruption (incoming system call / alarm / etc). Pause the context
// but keep `shouldRing` intact so we can resume once the interruption ends.
// Do NOT go through stopRing() here — resume is handled in onAudioInterruptionEnd.
const handleAudioInterruptionBegin = () => {
  try {
    if (bell && isPlaying) {
      bell.pause();
    }
    isPlaying = false;
  } catch (e) {
    console.warn('[call-ring] onAudioInterruptionBegin handling failed:', e);
  }
};

const handleAudioInterruptionEnd = () => {
  if (shouldRing) {
    playRing(currentRingType);
  }
};

// App visibility handlers — WeChat pauses InnerAudioContext playback in the
// background and rejects audio operations there. The host bridges App.onShow /
// App.onHide (the only lifecycle guaranteed to fire under uni-app + mini
// program) onto the uni event bus; we listen there and (re)start playback when
// we return to the foreground.
const handleAppShow = () => {
  isForeground = true;
  if (!shouldRing) return;
  // Destroy synchronously (this also unbinds the old context's callbacks so
  // they can't fire spuriously), then start a fresh play. Avoid the async
  // stopRing() chain here — its timing races with the freshly created
  // context's callbacks and can leave the ring silent after foregrounding.
  destroyAudio();
  playRing(currentRingType);
};

const handleAppHide = () => {
  // Going to the background: mark the state so playRing() stops issuing audio
  // operations (WeChat rejects them with no-permission in the background). We
  // deliberately do NOT call bell.pause()/stop() here, because those are also
  // audio operations that fail in the background; WeChat pauses the underlying
  // playback automatically. The `shouldRing` intent is preserved so App.onShow
  // can resume.
  isForeground = false;
  isPlaying = false;
};

export async function playRing(type: RingType = RingType.CALLER): Promise<void> {
  try {
    // Remember the desired ring type regardless of foreground state so that
    // App.onShow can start the correct ring when we come back to foreground.
    currentRingType = type;
    if (type === RingType.CALLEE && muted) return;
    // Never operate the audio context in the background — WeChat rejects it.
    // The `shouldRing` intent is already set by the caller (handleStatusChange),
    // so App.onShow will start playback once we return to the foreground.
    if (!isForeground) return;
    if (!bell) initBell();
    if (!bell) return;
    if (isPlaying || isStopping) return;
    const src = getBellFilePath(type);
    // Guard against an invalid/empty src — assigning '' or undefined triggers
    // WeChat's "Failed to set src, the src is invalid." error.
    if (!src) {
      console.warn('[call-ring] playRing aborted: empty src for type', type);
      return;
    }
    isPlaying = true;
    bell.src = src;
    bell.play();
  } catch (e) {
    console.warn('[call-ring] play failed:', e);
    isPlaying = false;
  }
}

export async function stopRing(): Promise<void> {
  try {
    isPlaying = false;
    isStopping = true;
    if (!bell) { isStopping = false; return; }
    bell.pause();
    await delay(80);
    bell.stop();
    // NOTE: Do NOT set `bell.src = ''` here. WeChat's InnerAudioContext rejects
    // an empty-string src with "Failed to set src, the src is invalid.", which
    // surfaces via onError and can leave the context in a bad state. Pausing +
    // stopping is enough; the next playRing() assigns a fresh valid src.
    await delay(80);
  } catch (e) {
    console.warn('[call-ring] stop failed:', e);
  } finally {
    isStopping = false;
  }
}

// Tear down the underlying audio context without touching the `shouldRing`
// intent flag. Called both from the plugin's public destroy() (full teardown)
// and from handleAppShow (rebuild on foreground). In the latter case the
// intent must be preserved so the caller can immediately restart playback.
export function destroyAudio(): void {
  isPlaying = false;
  isStopping = false;
  if (bell) {
    try {
      (wx as any).offAudioInterruptionBegin(handleAudioInterruptionBegin);
      (wx as any).offAudioInterruptionEnd(handleAudioInterruptionEnd);
    } catch (e) {
      console.warn('[call-ring] offAudioInterruption failed:', e);
    }
    try {
      bell.destroy();
    } catch (e) {
      console.warn('[call-ring] bell.destroy failed:', e);
    }
    bell = null;
  }
}

function delay(ms: number): Promise<void> { return new Promise(r => setTimeout(r, ms)); }

// ====================== Plugin State ======================

let muted = false;
let customCalleeBell: string | null = null;

/** Latest callStatus received, tracked locally so role changes can check it. */
let currentCallStatus = '';

/** Latest callRole received, tracked locally so status changes can check it. */
let currentCallRole = '';

// ====================== Uni Event Handlers ======================

function handleStatusChange(callStatus: string): void {
  try {
    currentCallStatus = callStatus;
    if (callStatus === STATUS_CALLING) {
      const type = currentCallRole === ROLE_CALLEE ? RingType.CALLEE : RingType.CALLER;
      // Set the intent first so any subsequent interruption / app-show handler
      // knows we still want to ring.
      shouldRing = true;

      if (isPlaying || isStopping) {
        // Previous ring is still active or stopping: restart with correct type
        stopRing().then(() => {
          if (currentCallStatus !== STATUS_CALLING) return;
          playRing(type);
        }).catch((e) => { console.warn('[call-ring] restart ring failed:', e); });
      } else {
        playRing(type);
      }
    } else {
      shouldRing = false;
      if (!isPlaying && !isStopping) return;
      stopRing();
    }
  } catch (e) {
    console.warn('[call-ring] handleStatusChange error:', e);
  }
}

function handleRoleChange(callRole: string): void {
  try {
    currentCallRole = callRole;
    if (!isPlaying) return;
    if (currentCallStatus !== STATUS_CALLING) return;
    const targetType = callRole === ROLE_CALLEE ? RingType.CALLEE : RingType.CALLER;
    stopRing().then(() => {
      if (currentCallStatus !== STATUS_CALLING) return;
      playRing(targetType);
    }).catch((e) => { console.warn('[call-ring] role switch failed:', e); });
  } catch (e) {
    console.warn('[call-ring] handleRoleChange error:', e);
  }
}

// Wrapped callbacks stored so we can unregister them later.
let _onStatus: ((v: any) => void) | null = null;
let _onRole: ((v: any) => void) | null = null;
// App visibility handlers are registered on the uni event bus (bridged by the
// host from App.onShow / App.onHide) and must be off'd on destroy — capture
// the references so we can pass them back to uni.$off.
let _onAppShow: (() => void) | null = null;
let _onAppHide: (() => void) | null = null;

// ====================== Plugin Factory ======================

let _instance: Record<string, any> | null = null;

/**
 * Create a ring plugin instance (singleton).
 *
 * The plugin connects to the uni global event bus internally — no arguments
 * required. TUICallService publishes call state changes on the same bus;
 * neither side imports anything from the other.
 *
 * @returns A plugin object to pass to {@code TUICallKitAPI.registerPlugin()}.
 *          The host MUST NOT call any methods on the returned object.
 */
export function useRingPlugin(): Record<string, any> {
  if (_instance) {
    console.warn('[call-ring] useRingPlugin was already called, returning existing instance');
    return _instance;
  }

  _onStatus = (v: any) => handleStatusChange(v);
  _onRole = (v: any) => handleRoleChange(v);
  _onAppShow = () => handleAppShow();
  _onAppHide = () => handleAppHide();

  uni.$on(CALL_RING_EVENTS.STATUS_CHANGED, _onStatus);
  uni.$on(CALL_RING_EVENTS.ROLE_CHANGED, _onRole);
  // Listen for app-visibility events bridged by the host from App.onShow /
  // App.onHide so the ring can survive a background→foreground round-trip
  // while a call is still in CALLING state.
  uni.$on(CALL_RING_EVENTS.APP_SHOW, _onAppShow);
  uni.$on(CALL_RING_EVENTS.APP_HIDE, _onAppHide);
  currentCallStatus = '';
  currentCallRole = '';

  return _instance = {
    destroy() {
      if (_onStatus) uni.$off(CALL_RING_EVENTS.STATUS_CHANGED, _onStatus);
      if (_onRole) uni.$off(CALL_RING_EVENTS.ROLE_CHANGED, _onRole);
      if (_onAppShow) uni.$off(CALL_RING_EVENTS.APP_SHOW, _onAppShow);
      if (_onAppHide) uni.$off(CALL_RING_EVENTS.APP_HIDE, _onAppHide);
      _onStatus = null;
      _onRole = null;
      _onAppShow = null;
      _onAppHide = null;
      _instance = null;
      muted = false;
      customCalleeBell = null;
      currentCallStatus = '';
      currentCallRole = '';
      // Full plugin teardown: clear intent last so any in-flight callbacks read
      // a consistent final state (shouldRing=false, no bell).
      shouldRing = false;
      isForeground = true;
      stopRing();
      destroyAudio();
    },

    enableMuteMode(enable: boolean) {
      muted = enable;
      if (enable && isPlaying && currentRingType === RingType.CALLEE) {
        stopRing();
      }
    },

    setCallingBell(filePath?: string) {
      customCalleeBell = filePath || null;
      if (isPlaying && currentRingType === RingType.CALLEE) {
        stopRing().then(() => playRing(RingType.CALLEE));
      }
    },
  };
}
