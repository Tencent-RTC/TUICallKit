import { defineConfig } from 'vite';
import uni from '@dcloudio/vite-plugin-uni';

// Vite config for uni-app WeChat Mini Program build.
// Goal: force `@trtc/call-engine-lite-wx` to resolve to its mini-program-specific bundle
// (`dist/index.mp.js`, ~32KB minified) instead of the default CJS entry
// (`dist/index.cjs.js`, ~92KB). This reduces the final mp-weixin bundle size.
export default defineConfig({
  plugins: [uni()],
  resolve: {
    // Prefer the `miniprogram` / `wx` fields declared by `@trtc/call-engine-lite-wx`
    // package.json `exports` map; fall back to standard fields otherwise.
    mainFields: ['miniprogram', 'wx', 'module', 'jsnext:main', 'jsnext', 'main'],
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
