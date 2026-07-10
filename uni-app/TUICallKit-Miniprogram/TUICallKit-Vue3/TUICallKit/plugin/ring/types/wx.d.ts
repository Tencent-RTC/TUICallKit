// WeChat Mini Program global API declaration
declare const wx: {
  createInnerAudioContext: (options?: { useWebAudioImplement?: boolean }) => WechatInnerAudioContext;
  onAudioInterruptionBegin: (callback: () => void) => void;
  onAudioInterruptionEnd: (callback: () => void) => void;
  offAudioInterruptionBegin: (callback: () => void) => void;
  offAudioInterruptionEnd: (callback: () => void) => void;
};

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
