# Call UIKit for Vue QuickStart

<b> English </b> | <a href="https://github.com/tencentyun/TUICallKit/blob/main/Web/call-uikit-demos/basic-vue3/README-zh_CN.md"> 简体中文 </a>

<img src="https://img.shields.io/badge/Platform-Vue3-orange.svg"><img src="https://img.shields.io/badge/Language-Typescript-orange.svg">

<img src="https://qcloudimg.tencent-cloud.cn/raw/ec034fc6e4cf42cae579d32f5ab434a1.png" align="left" width=120 height=120>TUICallKit is a UIKit component for **audio and video calls** developed by Tencent Cloud. By integrating this component, you can easily add video calling functionality to your app with just a few lines of code. TUICallKit supports features like offline calling and is available on multiple platforms including Android, iOS, Web, and Flutter.

<a href="https://apps.apple.com/cn/app/%E8%85%BE%E8%AE%AF%E4%BA%91%E8%A7%86%E7%AB%8B%E6%96%B9trtc/id1400663224"><img src="https://qcloudimg.tencent-cloud.cn/raw/afe9b8cc4c715346cf3d9feea8a65e33.svg" height=40></a> <a href="https://dldir1.qq.com/hudongzhibo/liteav/TRTCDemo.apk"><img src="https://qcloudimg.tencent-cloud.cn/raw/006d5ed3359640424955baa08dab7c7f.svg" height=40></a> <a href="https://rtcube.cloud.tencent.com/prerelease/internation/homepage/index.html#/detail?scene=callkit"><img src="https://qcloudimg.tencent-cloud.cn/raw/d326e70750f8bbad7245e229c5bd6d2b.svg" height=40></a>


## Before getting started

This section shows you the prerequisites you need for use Tencent Calls for Web Vue3 demo.

#### Requirements

The minimum requirements for Calls SDK for Web Vue3 demo are:

- Node
- npm（or yarn）
- Modern browser, supporting WebRTC APIs.


## Getting started

If you would like to try the demo specifically fit to your usage, you can do so by following the steps below.

#### Create an application

1. Login or Sign-up for an account on [Tencent Dashboard](https://console.trtc.io/app).
2. Create or select a calls-enabled application on the dashboard.
3. Note the `SDKAppID` and `SDKSecretKey` of the application for use at runtime.


#### Install and run the demo

1. Clone this repository

  ```shell
   git clone https://github.com/tencentyun/TUICallKit.git
  ```

2. Install dependencies

  ```shell
   cd ./TUICallKit/Web/call-uikit-demos/basic-vue3
   npm install # or, yarn
  ```

3. Specify the SDKAppID and SDKSecretKey
   Input the SDKAppID and SDKSecretKey into file `Web/call-uikit-demos/basic-vue3/public/debug/GenerateTestUserSig-es.js`
  ```javascript
   const SDKAPPID = 0;
   const SECRETKEY = '';
  ```

4. Run the demo
  ```shell
   npm run serve
  ```


## Making your first call

1. On each device, open a browser and go to the index page of the sample web app. The default URL is `localhost:8080`.
2. Log in to the sample app on the primary device with the user ID set as the `caller`.
3. Log in to the sample app on the secondary device using the ID of the user set as the `callee`.
4. On the primary device, specify the user ID of the `callee` and initiate a call.


## Reference

- If you want to learn more about the product features, you can click on the following [link](https://trtc.io/products).
- If you encounter difficulties, you can refer to [FAQs](https://trtc.io/document/53565), here are the most frequently encountered problems of developers, covering various platforms, I hope you can Help you solve problems quickly.
- For complete API documentation, see [Audio Video Call SDK API Example](https://trtc.io/document/51014): including TUICallKit (with UIKit), TUICallEngine (without UIKit), and call events Callbacks, etc.
