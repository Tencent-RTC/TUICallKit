import { defineConfig } from 'vite';
import uni from '@dcloudio/vite-plugin-uni';

// Vite config for uni-app WeChat Mini Program build.
// Goal: force `@trtc/call-engine-lite-wx` to resolve to its mini-program-specific bundle
// (`dist/index.mp.js`, ~32KB minified) instead of the default CJS entry
// (`dist/index.cjs.js`, ~92KB). This reduces the final mp-weixin bundle size.
export default defineConfig({
  plugins: [uni()],
  resolve: {
    // Do NOT use 'miniprogram' condition here — the mp build of call-engine
    // calls native wx APIs (e.g. getTRTCShareInstance) directly, which are
    // not available in UniApp. Use the default ESM build instead.
    conditions: ['import', 'module', 'default'],
    mainFields: ['module', 'jsnext:main', 'jsnext', 'main'],
    dedupe: [
      '@tencentcloud/lite-chat',
      'eventemitter3',
      'vue',
    ],
    // Follow symlinks to their real path so pnpm-linked nested copies are
    // treated as the same module as the hoisted top-level one.
    preserveSymlinks: false,
  },
});
