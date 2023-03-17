const path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
  configureWebpack: {
    externals: {
      'tim-wx-sdk': 'commonjs tim-wx-sdk', // 550KB 左右
    },
    plugins: [
      new CopyWebpackPlugin([
        {
          from: path.join(__dirname, '/node_modules/@tencentcloud/call-uikit-wechat'),
          to: path.join(__dirname, '/unpackage/dist/dev/mp-weixin/node_modules/@tencentcloud/call-uikit-wechat'),
        },
        {
          from: path.join(__dirname, '/node_modules/trtc-wx-sdk'),
          to: path.join(__dirname, '/unpackage/dist/dev/mp-weixin/node_modules/trtc-wx-sdk'),
        },
        {
          from: path.join(__dirname, '/node_modules/tim-wx-sdk'),
          to: path.join(__dirname, '/unpackage/dist/dev/mp-weixin/node_modules/tim-wx-sdk'),
        },
        {
          from: path.join(__dirname, '/node_modules/tsignaling-wx'),
          to: path.join(__dirname, '/unpackage/dist/dev/mp-weixin/node_modules/tsignaling-wx'),
        },
        {
          from: path.join(__dirname, '/node_modules/tuicall-engine-wx'),
          to: path.join(__dirname, '/unpackage/dist/dev/mp-weixin/node_modules/tuicall-engine-wx'),
        },
        {
          from: path.join(__dirname, '/package.json'),
          to: path.join(__dirname, '/unpackage/dist/dev/mp-weixin/package.json'),
        },
      ]),
    ],
  },
};
