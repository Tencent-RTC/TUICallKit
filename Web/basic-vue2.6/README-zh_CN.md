# Call UIKit for Vue QuickStart

<a href="https://github.com/tencentyun/TUICallKit/blob/main/Web/basic-vue2.6/README.md"> English </a> | <b> 简体中文 </b> 

<img src="https://img.shields.io/badge/Platform-Vue2.6-orange.svg"><img src="https://img.shields.io/badge/Language-Typescript-orange.svg">

<img src="https://qcloudimg.tencent-cloud.cn/raw/ec034fc6e4cf42cae579d32f5ab434a1.png" align="left" width=120 height=120>TUICallKit 是 TencentCloud 开发的音频呼叫的 UIKit 组件。 通过集成此组件，您只需几行代码即可轻松地将视频通话功能添加到您的应用程序中。TUICallKit 支持离线通话等功能，可在 Android、iOS、Web 和 Flutter 等多个平台上使用。

<a href="https://apps.apple.com/cn/app/%E8%85%BE%E8%AE%AF%E4%BA%91%E8%A7%86%E7%AB%8B%E6%96%B9trtc/id1400663224"><img src="https://qcloudimg.tencent-cloud.cn/raw/afe9b8cc4c715346cf3d9feea8a65e33.svg" height=40></a> <a href="https://dldir1.qq.com/hudongzhibo/liteav/TRTCDemo.apk"><img src="https://qcloudimg.tencent-cloud.cn/raw/006d5ed3359640424955baa08dab7c7f.svg" height=40></a> <a href="https://rtcube.cloud.tencent.com/prerelease/internation/homepage/index.html#/detail?scene=callkit"><img src="https://qcloudimg.tencent-cloud.cn/raw/d326e70750f8bbad7245e229c5bd6d2b.svg" height=40></a>


## 开始之前

本节向您展示测试腾讯调用 Web Vue2.6 演示所需的先决条件。

#### 条件

Calls SDK for Web Vue2.6 demo 的最低要求是：

- Node
- npm（or yarn）
- Modern browser，supporting WebRTC APIs.


## 开始

如果您想运行该 demo，可以按照以下步骤进行。

#### 创建应用

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击创建新应用，在弹出的对话框中输入您的应用名称，并单击确定。
2. 单击刚刚创建出的应用，进入**应用详情**页面，并在页面的右下角找到含 UI 低代码场景方案功能区，单击免费体验即可开通 TUICallKit 的 7 天免费试用服务。
3. 在同一页面找到 ***SDKAppID*** 和 ***密钥(SecretKey)*** 并保存，在后续步骤中使用。


#### 安装并运行 demo

1. 克隆仓库

  ```shell
   git clone https://github.com/tencentyun/TUICallKit.git
  ```

2. 安装依赖

  ```shell
   cd ./TUICallKit/Web/basic-vue2.6
   npm install
  ```

3. 配置 SDKAppID 和 SDKSecretKey 在 `Web/call-uikit-demos/public/debug/GenerateTestUserSig-es.js` 文件中填写 SDKAppID 和 SecretKey。
  ```javascript
   const SDKAPPID = 0;
   const SECRETKEY = '';
  ```

4. 运行
  ```shell
   npm run serve
  ```

## 开始您的第一次通话

1. 在设备上，打开浏览器并转到 demo 页面。 默认网址是：`localhost:5173`。
2. 分别在两台设备上登录两个用户，一方作为主叫，一方作为被叫。
3. 在主叫方进入通话界面，输入被叫方的 ID，选择媒体类型，发起通话。
4. 被叫方收到通话的请求，点击接听后进行通话。


## 参考

- 如果您想了解更多产品功能，可以点击以下：[链接](https://trtc.io/products)。
- 如果您遇到困难，可以参考：[FAQs](https://trtc.io/document/53565)。这里是开发者最常遇到的问题，涵盖各个平台，希望可以帮助您快速解决问题。
- 有关完整的 API 文档，请参阅 [Audio Video Call SDK API Example](https://trtc.io/document/51014)。包括 TUICallKit（带 UIKit）、TUICallEngine（不带 UIKit）、以及通话事件回调等。

