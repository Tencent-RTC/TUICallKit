/**
 * WeChat mini-program permission utility.
 *
 * Distinguishes two levels of permission denial:
 * 1. Mini-program level: the user has rejected the scope in this mini-program.
 *    Fix: call wx.openSetting to let the user toggle it.
 * 2. System level: WeChat itself lacks the OS-level permission (Settings >
 *    Privacy > Microphone / Camera on iOS, App Permissions on Android).
 *    Fix: guide the user to the system settings page (cannot be opened
 *    programmatically).
 */

// ── Permission Scope Constants ──
export const PermissionScope = {
  RECORD: 'scope.record',
  CAMERA: 'scope.camera',
} as const;

// ── Result Types ──
export interface PermissionCheckResult {
  /** Whether the permission is granted. */
  granted: boolean;
  /** Human-readable tip shown to the user. */
  tip: string;
  /**
   * Denial level:
   * - 'mini-program': rejected within this mini-program → wx.openSetting works.
   * - 'system': WeChat lacks the OS permission → user must go to system settings.
   * - 'granted': already authorized.
   */
  level: 'granted' | 'mini-program' | 'system';
}

// ── Helpers ──

/**
 * Get the raw authSetting snapshot from WeChat.
 */
function getAuthSetting(): Promise<WechatMiniprogram.AuthSetting> {
  return new Promise((resolve) => {
    wx.getSetting({
      success(res) {
        resolve(res.authSetting);
      },
      fail() {
        resolve({});
      },
    });
  });
}

/**
 * Attempt to authorize a scope via wx.authorize.
 */
function authorizeScope(
  scope: string,
): Promise<{ success: boolean; errMsg: string }> {
  return new Promise((resolve) => {
    wx.authorize({
      scope,
      success() {
        resolve({ success: true, errMsg: '' });
      },
      fail(err) {
        resolve({ success: false, errMsg: err.errMsg || '' });
      },
    });
  });
}

/**
 * Check whether a scope has been explicitly denied by the user at the
 * mini-program level (authSetting returns false for that key).
 */
function isMiniProgramDenied(authSetting: WechatMiniprogram.AuthSetting, scope: string): boolean {
  return authSetting[scope] === false;
}

// ── Public API ──

/**
 * Check and request microphone permission.
 *
 * - No camera permission → calls can still proceed (video call falls back to audio).
 * - No microphone permission → calls MUST be blocked; user is guided to settings.
 *
 * The result's `level` field tells you whether the permission is already
 * granted, denied at the mini-program level (wx.openSetting can fix it),
 * or denied at the system level (user must go to OS settings manually).
 */
export async function checkMicrophonePermission(): Promise<PermissionCheckResult> {
  const authSetting = await getAuthSetting();

  // Already granted
  if (authSetting[PermissionScope.RECORD] === true) {
    return {
      granted: true,
      tip: '',
      level: 'granted',
    };
  }

  // Mini-program level: user has explicitly rejected the scope before.
  if (isMiniProgramDenied(authSetting, PermissionScope.RECORD)) {
    return {
      granted: false,
      tip: '您已拒绝麦克风权限，请前往小程序设置页面开启麦克风权限后重试',
      level: 'mini-program',
    };
  }

  // Scope is undefined — never requested. Try to authorize.
  const result = await authorizeScope(PermissionScope.RECORD);

  if (result.success) {
    return { granted: true, tip: '', level: 'granted' };
  }

  // Authorization failed.
  // If the native permission dialog was never shown (user actively cancelled
  // or system-level block), errMsg typically contains "auth deny".
  // When the OS-level permission is off, wx.authorize fails immediately
  // without showing the dialog — we treat this as a system-level issue.
  const isSystemLevelDenial =
    !result.errMsg.includes('cancel') &&
    !result.errMsg.includes('deny');

  // Heuristic: if the error message suggests the dialog did NOT appear,
  // it is very likely a system-level block.
  if (isSystemLevelDenial || result.errMsg.includes('system')) {
    return {
      granted: false,
      tip: '您的微信没有麦克风权限，请前往手机系统设置 > 微信，开启麦克风权限后重试',
      level: 'system',
    };
  }

  // User dismissed the native dialog or denied it → mini-program level.
  return {
    granted: false,
    tip: '您拒绝了麦克风权限，请前往小程序设置页面开启麦克风权限后重试',
    level: 'mini-program',
  };
}

/**
 * Check camera permission.
 *
 * Camera permission is REQUIRED for video calls — a denial MUST block the
 * call (both for initiating and for answering). For audio calls this check
 * is irrelevant and should be skipped by the caller.
 *
 * Tip wording here reflects the blocking policy: it tells the user that
 * video calls cannot proceed without camera permission, and points them to
 * the appropriate settings page (mini-program vs. system level).
 */
export async function checkCameraPermission(): Promise<PermissionCheckResult> {
  const authSetting = await getAuthSetting();

  if (authSetting[PermissionScope.CAMERA] === true) {
    return { granted: true, tip: '', level: 'granted' };
  }

  if (isMiniProgramDenied(authSetting, PermissionScope.CAMERA)) {
    return {
      granted: false,
      tip: '您已拒绝摄像头权限，无法发起或接听视频通话，请前往小程序设置页面开启摄像头权限后重试',
      level: 'mini-program',
    };
  }

  const result = await authorizeScope(PermissionScope.CAMERA);

  if (result.success) {
    return { granted: true, tip: '', level: 'granted' };
  }

  const isSystemLevelDenial =
    !result.errMsg.includes('cancel') &&
    !result.errMsg.includes('deny');

  if (isSystemLevelDenial || result.errMsg.includes('system')) {
    return {
      granted: false,
      tip: '您的微信没有摄像头权限，无法发起或接听视频通话，请前往手机系统设置 > 微信，开启摄像头权限后重试',
      level: 'system',
    };
  }

  return {
    granted: false,
    tip: '您拒绝了摄像头权限，无法发起或接听视频通话，请前往小程序设置页面开启摄像头权限后重试',
    level: 'mini-program',
  };
}

/**
 * Handle a failed permission check by showing the appropriate dialog and
 * optionally navigating to the settings page.
 *
 * Resolves with `{ confirm }` describing the user's choice:
 * - confirm === true : the user clicked the primary button (前往设置 for the
 *   mini-program level, or 我知道了 for the system level).
 * - confirm === false: the user cancelled the dialog (only possible for the
 *   mini-program level, which shows a 取消 button).
 *
 * Callers can use this to decide follow-up behavior, e.g. a callee rejecting
 * the incoming call when the user cancels the mandatory permission dialog.
 */
export function handlePermissionDenied(result: PermissionCheckResult): Promise<{ confirm: boolean }> {
  return new Promise((resolve) => {
    if (result.level === 'mini-program') {
      // Mini-program level: open the mini-program settings page.
      wx.showModal({
        title: '权限提示',
        content: result.tip,
        confirmText: '前往设置',
        cancelText: '取消',
        success(modalRes) {
          if (modalRes.confirm) {
            wx.openSetting({
              complete() {
                resolve({ confirm: true });
              },
            });
          } else {
            resolve({ confirm: false });
          }
        },
        fail() {
          resolve({ confirm: false });
        },
      });
    } else {
      // System level: can only guide the user, cannot open system settings.
      wx.showModal({
        title: '权限提示',
        content: result.tip,
        showCancel: false,
        confirmText: '我知道了',
        success() {
          resolve({ confirm: true });
        },
        fail() {
          resolve({ confirm: false });
        },
      });
    }
  });
}
