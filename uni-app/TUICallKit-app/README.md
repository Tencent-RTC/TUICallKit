
# Call UIKit for uni-app QuickStart

<img src="https://qcloudimg.tencent-cloud.cn/raw/ec034fc6e4cf42cae579d32f5ab434a1.png" align="left" width=120 height=120>TUICallKit 是 TencentCloud 开发的音频呼叫的 UIKit 组件。 通过集成此组件，您只需几行代码即可轻松地将视频通话功能添加到您的应用程序中。TUICallKit 支持离线通话等功能，可在 Android、iOS、Web 和 Flutter 等多个平台上使用。

<a href="https://apps.apple.com/cn/app/%E8%85%BE%E8%AE%AF%E4%BA%91%E8%A7%86%E7%AB%8B%E6%96%B9trtc/id1400663224"><img src="https://qcloudimg.tencent-cloud.cn/raw/afe9b8cc4c715346cf3d9feea8a65e33.svg" height=40></a> <a href="https://dldir1.qq.com/hudongzhibo/liteav/TRTCDemo.apk"><img src="https://qcloudimg.tencent-cloud.cn/raw/006d5ed3359640424955baa08dab7c7f.svg" height=40></a> <a href="https://rtcube.cloud.tencent.com/prerelease/internation/homepage/index.html#/detail?scene=callkit"><img src="https://qcloudimg.tencent-cloud.cn/raw/d326e70750f8bbad7245e229c5bd6d2b.svg" height=40></a>

## 环境准备
- 建议使用最新的 HBuilderX 编辑器 。
- iOS 9.0 或以上版本且支持音视频的 iOS 设备，暂不支持模拟器。
- Android 版本不低于 4.1 且支持音视频的 Android 设备，暂不支持模拟器。如果为真机，请开启**允许调试**选项。最低兼容 Android 4.1（SDK API Level 16），建议使用 Android 5.0 （SDK API Level 21）及以上版本。
- iOS/Android 设备已经连接到 Internet。

## 快速接入

#### 步骤一：开通服务
1. 登录到 [实时音视频 TRTC 控制台](https://console.cloud.tencent.com/trtc/app)，单击创建新应用，在弹出的对话框中输入您的应用名称，并单击确定。
2. 单击刚刚创建出的应用，进入**应用详情**页面，并在页面的右下角找到含 UI 低代码场景方案功能区，单击免费体验即可开通 TUICallKit 的 7 天免费试用服务。
3. 在同一页面找到 ***SDKAppID*** 和 ***密钥(SecretKey)*** 并保存，在后续步骤中使用。

[](id:step2)
#### 步骤二：下载源码，配置工程
1. 克隆仓库

  ```shell
    git clone https://github.com/Tencent-RTC/TUICallKit.git
  ```

2. 安装依赖

  ```shell
    cd ./TUICallKit/uni-app/TUICallKit-app
    npm install
  ```

3. 配置 SDKAppID 和 SDKSecretKey 在 `uni-app/TUICallKit-app/debug/GenerateTestUserSig-es.js` 文件中填写 SDKAppID 和 SecretKey。
  ```javascript
    let SDKAppID = 0;
    let SecretKey = '';
  ```
#### 步骤三：导入插件 

- 访问 [TencentCloud-TUICallKit 插件](https://ext.dcloud.net.cn/plugin?id=9035) 插件，在插件详情页中购买插件（免费），购买插件时选择对应的 AppID，绑定正确的包名。
- 购买插件后在项目的 `manifest.json` 页面的**App原生插件配置**项下单击**选择云端插件**，选择**TencentCloud-TUICallKit 插件**。

<img width='500' src='https://camo.githubusercontent.com/6a67ecbd35991164dc0132fc1031604023bcd50b4041572e3630bb18163dec77/68747470733a2f2f7765622e73646b2e71636c6f75642e636f6d2f636f6d706f6e656e742f5455494b69742f6173736574732f756e692d6170702f54656e63656e74436c6f75642d54554943616c6c4b69742e706e67' />

#### 步骤四：运行项目
- 制作自定义调试基座，请选择**传统打包**方式进行打包。
<img width='300' height='300' src='https://qcloudimg.tencent-cloud.cn/image/document/c9dc6dd4af9c0c8f7f526cda2fc47e4b.png' />

- 自定义调试基座成功后，使用自定义基座运行项目。
<img width='500' src='https://qcloudimg.tencent-cloud.cn/image/document/d1c9ab1ab79d7cbcd163ff5d8740a1a5.png' />

## 实现音视频通话
- 分别在两台设备上登录两个用户，一方作为主叫，一方作为被叫。
- 在主叫方进入通话界面，输入被叫方的 ID，选择媒体类型，发起通话。
- 被叫方收到通话的请求，点击接听后进行通话。

## 技术咨询
了解更多详情您可 [腾讯云通信官方社群](https://zhiliao.qq.com/s/cWSPGIIM62CC/cEUPGIIM62CE) 进行咨询和反馈。


## 参考文档
- [TencentCloud-TUICallKit 插件](https://ext.dcloud.net.cn/plugin?id=9035) 
- [TUICallKit uni-app(客户端) 快速接入文档](https://cloud.tencent.com/document/product/269/64506)
- [TUICallKit API 文档](https://cloud.tencent.com/document/product/647/78762)