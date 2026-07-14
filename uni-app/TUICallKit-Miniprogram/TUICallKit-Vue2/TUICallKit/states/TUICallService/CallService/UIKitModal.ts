// The chat UIKitModal component is no longer used in this demo (chat was
// removed). Error / busy notifications now fall through to uni.showToast
// so the user still gets feedback when something goes wrong.

const MINI_MODAL_ERROR_CODES = [
  -1001,
  -1002,
  101002,
  101003,
];

const MINI_MODAL_ERROR_MAP: Record<string, { id: number; content: string }> = {
  '-1001': {
    id: 10001,
    content: '您的应用还未开通音视频通话能力',
  },
  '-1002': {
    id: 10002,
    content: '您暂不支持使用该能力，请前往购买页购买开通',
  },
  '101002': {
    id: 10014,
    content: '发起通话失败，用户 ID 无效，请确认该用户已注册',
  },
  '101003': {
    id: 101003,
    content: '上一通通话还没结束，请稍后再试',
  },
};

function showToastMessage(content: string, type: 'error' | 'info' = 'error') {
  try {
    // @ts-ignore uni is a uniapp runtime global
    uni.showToast({
      title: content,
      icon: type === 'error' ? 'none' : 'none',
      duration: 2500,
    });
  } catch (error) {
    console.warn('[handleModalError] uni.showToast failed', error);
  }
}

export function handleModalError(error: any) {
  if (!error || !error?.code) {
    return;
  }
  if (!MINI_MODAL_ERROR_CODES.includes(error.code)) {
    return;
  }
  const errorInfo = MINI_MODAL_ERROR_MAP[error.code.toString()];
  if (errorInfo) {
    showToastMessage(errorInfo.content, 'error');
  }
}

/**
 * Notify the user that a new call cannot be initiated or accepted because
 * another call is already in progress. Triggered from the logic layer when
 * call status is not IDLE, so the call component itself may not be mounted.
 */
export function notifyBusyCall() {
  const info = MINI_MODAL_ERROR_MAP['101003'];
  if (info) {
    showToastMessage(info.content, 'info');
  }
}
