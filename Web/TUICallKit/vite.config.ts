import { resolve } from 'node:path'
import { defineConfig } from 'vite'
import Vue from '@vitejs/plugin-vue'
import cssInjectedByJsPlugin from 'vite-plugin-css-injected-by-js'

export default defineConfig({
  // If our .vue files have a style, it will be compiled as a single `.css` file under /dist.
  plugins: [Vue(), cssInjectedByJsPlugin()],

  build: {
    // Output compiled files to /dist.
    outDir: './dist',
    lib: {
      // Set the entry point (file that contains our components exported).
      entry: resolve(__dirname, 'src/index.ts'),
      // Name of the library.
      name: 'tuicall-uikit-vue',
      // We are building for CJS and ESM, use a function to rename automatically files.
      // Example: my-component-library.esm.js
      fileName: (format) => `${'tuicall-uikit-vue'}.${format}.js`,
    },
    rollupOptions: {
      // Vue is provided by the parent project, don't compile Vue source-code inside our library.
      external: ['vue', "tim-js-sdk", "trtc-js-sdk", "tsignaling", "tuicall-engine-webrtc"],
      output: { globals: { vue: 'Vue', "tim-js-sdk": "TIM_JS_SDK", "trtc-js-sdk": "TRTC_JS_SDK", "tsignaling": "Tsignaling", "tuicall-engine-webrtc": "TUICALL_ENGINE_WEBRTC" } },
    },
  },
})