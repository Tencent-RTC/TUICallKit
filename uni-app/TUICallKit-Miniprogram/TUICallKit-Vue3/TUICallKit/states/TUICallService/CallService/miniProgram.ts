import { CallMediaType } from '@trtc/call-engine-lite-wx';
import { CallStatus } from '../const/index';
import { checkMicrophonePermission, checkCameraPermission, handlePermissionDenied } from '../../../utils/permission';

export function initialUI() {
  // Collapse keyboard
  // @ts-ignore
  wx.hideKeyboard && wx.hideKeyboard({
    complete: () => {},
  });
};
// Check runtime environment; show a tip when running in WeChat DevTools.
export function checkRunPlatform() {
  // @ts-ignore
  const systemInfo = wx.getSystemInfoSync();
  if (systemInfo.platform === 'devtools') {
    // @ts-ignore
    wx.showModal({
      icon: 'none',
      title: '运行环境提醒',
      content: '微信开发者工具不支持原生推拉流组件(即 <live-pusher> 和 <live-player> 标签)，请使用真机调试或者扫码预览。',
      showCancel: false,
    });
  }
};
export function initAndCheckRunEnv() {
  initialUI(); // miniProgram: collapse keyboard, hide tabBar
  checkRunPlatform(); // miniProgram: check runtime environment
}
export async function beforeCall(type: CallMediaType) {
  try {
    initAndCheckRunEnv();
    // Microphone permission is mandatory for calls.
    const micCheck = await checkMicrophonePermission();
    if (!micCheck.granted) {
      await handlePermissionDenied(micCheck);
      return CallStatus.IDLE;
    }
    // Camera permission is mandatory for video calls.
    if (type === CallMediaType.VIDEO) {
      const cameraCheck = await checkCameraPermission();
      if (!cameraCheck.granted) {
        await handlePermissionDenied(cameraCheck);
        return CallStatus.IDLE;
      }
    }
    return CallStatus.CALLING;
  } catch (error) {
    console.debug(error);
    return CallStatus.IDLE;
  }
}
// Package error handling for mini-program (requires at least group call plan).
export function handlePackageError(error) {
  if (error?.code === -1002) {
    // @ts-ignore
    wx.showModal({
      icon: 'none',
      title: 'error',
      content: error?.message || '',
      showCancel: false,
    });
  }
}

export function handleNoPusherCapabilityError(){
  // @ts-ignore
  wx.showModal({
    icon: 'none',
    title: '权限提示',
    content: '当前小程序 appid 不具备 <live-pusher> 和 <live-player> 的使用权限，您将无法正常使用实时通话能力，请使用企业小程序账号申请权限后再进行开发体验',
    showCancel: false,
  });
}
