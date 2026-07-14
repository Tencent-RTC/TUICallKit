/**
 * Constants matched against TUICallService's CallStatus / CallRole enums.
 * These are plain strings — no dependency on the host's modules.
 */

export const STATUS_CALLING = 'calling';
export const ROLE_CALLEE = 'callee';

/** Minimal store interface that a plugin can observe. */
export interface ObservableStore {
  watch(storeName: string, options: Record<string, (value: any) => void>): void;
  unwatch(storeName: string, options: Record<string, (value: any) => void>): void;
  getData(storeName: string, key: string): any;
}

/**
 * Named events flowing through the uni global event bus.
 *
 * TUICallService publishes on these channels; the ring plugin listens.
 * Neither side imports from the other — the event name is the contract.
 */
export const CALL_RING_EVENTS = {
  /** Fired when callStatus changes. Payload: string (CallStatus enum value). */
  STATUS_CHANGED: 'callRing:statusChanged',
  /** Fired when callRole changes. Payload: string (CallRole enum value). */
  ROLE_CHANGED: 'callRing:roleChanged',
  /**
   * Fired when the mini program returns to the foreground (App.onShow).
   * The ring plugin uses this to rebuild and resume ring playback, because an
   * InnerAudioContext cannot be operated while backgrounded. No payload.
   */
  APP_SHOW: 'callRing:appShow',
  /**
   * Fired when the mini program goes to the background (App.onHide). The ring
   * plugin marks the background state so it stops issuing audio operations.
   * No payload.
   */
  APP_HIDE: 'callRing:appHide',
} as const;
