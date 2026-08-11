import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue2 from '@vitejs/plugin-vue2'

// https://vitejs.dev/config/
export default defineConfig({
  base: "./",
  plugins: [
    vue2(),
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
    // Symptom (production build only, dev works fine):
    //   Uncaught TypeError: Cannot redefine property: __esModule
    //     at Object.defineProperty (<anonymous>)
    //
    // Root cause:
    //   `trtc-cloud-js-sdk.esm.js` accidentally re-exports the CJS marker
    //   as a real ESM binding: `export const __esModule = !0;`.
    //   Pulled in transitively through:
    //     @trtc/calls-uikit-vue2 → @trtc/call-engine-lite-js
    //     → trtc-cloud-js-sdk
    //   Rollup's interop helper first `defineProperty(ns, "__esModule",
    //   {value: true})` (non-configurable) and then iterates keys of the
    //   source module, which contains the same `__esModule` key, causing
    //   a second `defineProperty` and the redefinition error.
    //
    // Defence in depth:
    //   1. Package-level fix: strip `export const __esModule=!0;` from
    //      `trtc-cloud-js-sdk.esm.js` (via pnpm patch).
    //   2. Bundler-level fallback: mark the offending modules as
    //      pre-ESM through `output.interop` so Rollup trusts the incoming
    //      marker and skips the redefinition attempt.
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
})
