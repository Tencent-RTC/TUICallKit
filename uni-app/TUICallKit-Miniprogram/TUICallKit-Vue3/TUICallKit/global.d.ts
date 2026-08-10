/**
 * Global type declarations for WeChat mini-program environment.
 * Replaces `miniprogram-api-typings` with a loose declaration that
 * also covers custom properties attached by business code (e.g. wx.$chat).
 */

declare const wx: Record<string, any>;

declare namespace WechatMiniprogram {
  interface Wx {
    [key: string]: any;
  }
  interface AuthSetting {
    [key: string]: boolean | undefined;
  }
}
