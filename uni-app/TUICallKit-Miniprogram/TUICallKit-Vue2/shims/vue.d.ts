// Module declarations for .vue single-file components.
// Allows TypeScript to resolve `import Foo from './Foo.vue'` without
// reporting TS2307.

declare module '*.vue' {
  const component: any;
  export default component;
}

// External component packages that lack their own type declarations.
declare module '@tencentcloud/trtc-component-uniapp/src/components/TRTCPusher.vue' {
  const component: any;
  export default component;
}

declare module '@tencentcloud/trtc-component-uniapp/src/components/TRTCPlayer.vue' {
  const component: any;
  export default component;
}

// UniApp lifecycle hooks — @dcloudio/uni-app may not ship types for all builds.
declare module '@dcloudio/uni-app' {
  export function onLoad(callback: (query?: any) => void): void;
  export function onShow(callback: () => void): void;
  export function onHide(callback: () => void): void;
  export function onUnload(callback: () => void): void;
  export function onReady(callback: () => void): void;
  export function onPullDownRefresh(callback: () => void): void;
  export function onReachBottom(callback: () => void): void;
}
