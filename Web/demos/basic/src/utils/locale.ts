import { createI18n } from "vue-i18n";
import { getLanguage } from "./index";

const i18n = createI18n({
  locale: getLanguage() || "zh-cn",
  legacy: false,
  globalInjection: true,
  global: true,
  fallbackLocale: "en",
  messages: {
    en: {
      "not-login": "Not login",
      "input-SDKAppID": "Please input SDKAppID",
      "input-SecretKey": "Please input SecretKey",
      "input-userID": "Please input userID",
      "login-failed-message": "login failed, please check SDKAppID 与 SecretKey",
      "copy-failed-message": "copy failed, please copy manually",
      "copied": "copied",
      "skip-device-detector": "Skipped device detection ",
      "video-call": "Video Call",
      "voice-call": "Voice Call",
      "minimized-mode": "Minimized Mode",
      "login-other": "Login other",
      "Add to calling list": "Add to calling list",
      "calling-list": "Calling List",
      "call": "Call",
      "alert": "Notes: this Demo is only applicable for debugging. Before official launch, please migrate the UserSig calculation code and key to your backend server to avoid unauthorized traffic use caused by the leakage of encryption key.",
      "view-documents": "View Documents",
      "url": "https://www.tencentcloud.com/document/product/647/35166",
      "login": "login",
      "start-to-detector": "Device Detector"
    },
    "zh-cn": {
      "not-login": "未登录",
      "input-SDKAppID": "请填写 SDKAppID",
      "input-SecretKey": "请填写 SecretKey",
      "input-userID": "请填写 userID",
      "login-failed-message": "登录失败，请检查 SDKAppID 与 SecretKey 是否正确",
      "copy-failed-message": "复制失败，请手动填写",
      "copied": "copied",
      "skip-device-detector": "已跳过设备检测",
      "please-input-param": "请填写正确的 SDKAppID 与 SecretKey 后重试",
      "video-call": "视频通话",
      "voice-call": "语音通话",
      "minimized-mode": "已进入最小化模式",
      "login-other": "登录其他",
      "Add to calling list": "添加到拨打列表",
      "calling-list": "拨打列表",
      "call": "通话",
      "alert": "注意️：本 Debug Panel 仅用于调试，正式上线前请将 UserSig 计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。",
      "view-documents": "查看文档",
      "url": "https://cloud.tencent.com/document/product/647/17275",
      "login": "登录",
      "start-to-detector": "开始设备检测"
    },
  },
});

export default i18n;
