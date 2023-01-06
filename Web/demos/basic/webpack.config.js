/* eslint-disable @typescript-eslint/no-var-requires */
const VueI18nPlugin = require("@intlify/unplugin-vue-i18n/webpack");

// webpack.config.js
module.exports = {
  /* ... */
  plugins: [
    VueI18nPlugin({ /* options */ })
  ],
};