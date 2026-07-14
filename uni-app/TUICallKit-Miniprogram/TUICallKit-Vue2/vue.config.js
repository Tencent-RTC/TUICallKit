const ScriptSetup = require('unplugin-vue2-script-setup/webpack').default;
module.exports = {
  parallel: false,
  configureWebpack: {
    plugins: [
      ScriptSetup({}),
    ],
    resolve: {
      // Prevent webpack from following pnpm symlinks to their real .pnpm store
      // paths. UniApp's compiler uses the resolved path to generate component
      // references in the output JSON. Without this, it produces unresolvable
      // paths like `node-modules/.pnpm/@tencentcloud+trtc-component-uniapp@.../...`.
      symlinks: false,
    },
  },
  chainWebpack(config) {
    config.plugins.delete('fork-ts-checker');
  },
};