<h1 align="center"> TUICallKit </h1>

<p align="center"> 
<b> English </b> | <a href="https://github.com/tencentyun/TUICallKit/blob/main/Web/README.md"> 简体中文 </a>
</p>

<p align="center">  A Vue2 & Vue3 Voice & Video Calling UI Component, easily add calling capabilities to  your web application.Vue2 version <a href="https://www.npmjs.com/package/@tencentcloud/call-uikit-vue2"> @tencentcloud/call-uikit-vue2 </a></p>

<div align="center">
<img src="https://img.shields.io/npm/v/@tencentcloud/call-uikit-vue">
<img src="https://img.shields.io/badge/Vue-%5E3.0.0-brightgreen">
<img src="https://img.shields.io/badge/support-docs%20%26%20demos-yellow">
<img src="https://img.shields.io/npm/l/@tencentcloud/call-uikit-vue">
<!-- https://shields.io/category/version  - tag: docs/demos, H5, v1.0.3(changelog), 
GitHub Release Date: -->
</div>

<img src="https://user-images.githubusercontent.com/57169560/205650396-476e0e20-42a3-493a-8e90-6f7ba50da83e.gif" style="width: 1000px; margin: 10px;" align="center">

## Features

- ⚡️ Supports C2C/Group/Voice/Video calls, switch calling type, select calling devices
- 🌟 3 lines of code to run through the test demo, 6 lines of code to complete the common ability to access
- 📱 Multi-device adaptation, support H5 webview
- 🛠 Ecology system, works with [TUIKit](https://www.tencentcloud.com/document/product/1047/50061) to initiate audio/video calls directly in [TIM](https://www.tencentcloud.com/document/product/1047/33513) sessions
- 🔥 Out-of-the-box TypeScript support, support for Vue3 `Composition API`
- 🌍 Cross-platform, support for Android, iOS, Web, applets, Flutter, uniapp, etc. [multiple development platforms](https://www.tencentcloud.com/document/product/647/35078)
- ☁️ Deploy on Tencent Cloud, end-to-end average latency < 300ms on international links
- 🤙🏻 Low lag, anti-packet loss rate over 80%, anti-network jitter over 1000ms, still smooth and stable in weak network environment
- 🌈 High calling quality, support 720P, 1080P HD quality, 70% packet loss can still running

## How to use

This is a documentation for the TUICallKit project. It provides instructions for using and integrating TUICallKit into your website or application.

Here are a few guidelines for using this component.

- Click [here](https://tcms-demo.tencentcloud.com/exp-center/index.html#/detail?scene=callkit) to try out 1v1 Voice and Video Call online.

- If you want to experience it in your dev mode, please read [Run the Vue3 Demo](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic-vue3/README.en.md) or [Run the Vue2 Demo](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic-vue2/README.en.md)

- If you want to install this component into your project, please read [TUICallKit Getting Started](https://www.tencentcloud.com/document/product/647/50993)

- If you want to modify the CSS Style, please read [UI Customization](https://www.tencentcloud.com/document/product/647/50997)

## Contents

```text
.
├── README.md
├── demos/basic-vue3/
├── demos/basic-vue2/
└── TUICallKit/
```

**demos/basic-vue3/**

- The `demos/basic-vue3/` directory contains the Vue3 basic demo of TUICallKit, which is integrated with all the features of the full TUICallKit component.
- A debug panel is integrated at the bottom of the demo page. You can enter your application information directly, please refer to [Run the Vue3 Demo](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic-vue3/README.en.md).

**demos/basic-vue2/**

- The `demos/basic-vue2/` directory contains the Vue2 basic demo of TUICallKit, which is integrated with all the features of the full TUICallKit component.
- A debug panel is integrated at the bottom of the demo page. You can enter your application information directly, please refer to [Run the Vue2 Demo](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic-vue2/README.en.md).

**TUICallKIt/** 

- The `TUICallKIt` directory contains the source code of TUICallKit. The entry file is `index.ts`.
- It is recommended to use a packaging method to directly import TUICallKit into your project, as outlined in the [TUICallKit Getting Started](https://www.tencentcloud.com/document/product/647/50993)
. You can also copy the files directly into your project for component import. For detailed instructions on how to integrate the source code, please refer to the [UI Customization](https://www.tencentcloud.com/document/product/647/50997).
<!-- - For the changelog of the SDK, see [Release Notes (Web)](https://www.tencentcloud.com/document/product/647/50997). -->

## Contact Us

- If you have questions, see [FAQs](https://www.tencentcloud.com/document/product/647/51024)；
- To report bugs in our sample code, please create an issue.
- Communication & Feedback
Welcome to join our Telegram Group to communicate with our professional engineers! We are more than happy to hear from you~
Click to join: [https://t.me/+EPk6TMZEZMM5OGY1](https://t.me/+EPk6TMZEZMM5OGY1)
Or scan the QR code
  <img src="https://qcloudimg.tencent-cloud.cn/raw/79cbfd13877704ff6e17f30de09002dd.jpg" width="300px">    

## License

ISC License © 2022-present, [Tencent](https://www.tencent.com/)
