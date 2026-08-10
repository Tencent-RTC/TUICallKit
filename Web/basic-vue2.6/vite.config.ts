import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import { createVuePlugin } from 'vite-plugin-vue2';
import ScriptSetup from 'unplugin-vue2-script-setup/vite';
// https://vitejs.dev/config/
export default defineConfig({
  base: "./",
  plugins: [
    createVuePlugin(),
    ScriptSetup({ /* options */ }),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  build: {
    // ------------------------------------------------------------------
    // Rollup CJS interop fix.
    //
    // Symptom (in production build only, dev works fine):
    //Uncaught TypeError: Cannot redefine property: __esModule
    //     at Object.defineProperty (<anonymous>)
    //     at Oq (index.<hash>.js)
    //
    // Root cause:
    //   Some transitive CJS/UMD deps pre-define a NON-CONFIGURABLE
    //   `__esModule` descriptor on their exports object. Specifically,
    //   `trtc-sdk-v5/plugins/whiteboard`, pulled in through
    //     @trtc/calls-uikit-vue2.6 → @trtc/call-engine-lite-js
    //     → trtc-cloud-js-sdk → trtc-sdk-v5/plugins/whiteboard
    //   Rollup's CJS→ESM interop helper then calls
    //     Object.defineProperty(exports, "__esModule", {value: true})
    //   again, which is rejected because the existing property has
    //   `configurable: false`.
    //
    // Selective fix:
    //   - `interop` callback returns 'esModule' ONLY for the offending
    //     modules, so Rollup trusts the incoming __esModule marker and
    //     skips the redefinition attempt.
    //   - All other modules keep the default 'auto' interop, so
    //     e.g. element-ui's `require('vue')` still works correctly.
    // ------------------------------------------------------------------
    commonjsOptions: {
      transformMixedEsModules: true,
    },
    rollupOptions: {
      output: {
        interop: (id) => {
          if (!id) return 'auto';
          if (
            id.includes('trtc-sdk-v5') ||
            id.includes('trtc-cloud-js-sdk') ||
            id.includes('whiteboard')
          ) {
            return 'esModule';
          }
          return 'auto';
        },
      },
    },
  },
  optimizeDeps: {
    // Force esbuild to pre-bundle these packages so Rollup does not need
    // to run its CJS interop helper against their pre-defined __esModule
    // descriptor. This is defence-in-depth on top of the `interop` config
    // above.
    include: [
      'trtc-cloud-js-sdk',
      'trtc-sdk-v5',
    ],
  },
})
