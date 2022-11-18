/* eslint-disable */
declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}

declare module 'tuicall-engine-webrtc';

declare module '*.svg' {
  const content: any;
  export default content;
}

declare module 'aegis-web-sdk';
