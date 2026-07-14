// WeChat Mini Program audio context types.
// The `wx` global is declared in TUICallKit/global.d.ts as Record<string, any>
// so it already covers all APIs. This file only provides the audio context
// interface shape for internal type safety within the ring plugin.

interface WechatInnerAudioContext {
  src: string;
  loop: boolean;
  play: () => void;
  pause: () => void;
  stop: () => void;
  destroy: () => void;
  onPlay: (callback: () => void) => void;
  onCanplay: (callback: () => void) => void;
  onError: (callback: (err: any) => void) => void;
}
