# 快速跑通iOS示例工程

_[English](README.md) | 简体中文_

<img src="https://qcloudimg.tencent-cloud.cn/raw/ec034fc6e4cf42cae579d32f5ab434a1.png" align="left" width=120 height=120>TUICallKit 是腾讯云推出一款音视频通话的含 UI 组件，通过集成该组件，您只需要编写几行代码就可以为您的 App 添加音视频通话功能，并且支持离线唤起能力。TUICallKit 支持 Android、iOS、Web、小程序、Flutter、UniApp 等多个开发平台。

<a href="https://apps.apple.com/cn/app/%E8%85%BE%E8%AE%AF%E4%BA%91%E8%A7%86%E7%AB%8B%E6%96%B9trtc/id1400663224"><img src="https://qcloudimg.tencent-cloud.cn/raw/afe9b8cc4c715346cf3d9feea8a65e33.svg" height=40></a> <a href="https://dldir1.qq.com/hudongzhibo/liteav/TRTCDemo.apk"><img src="https://qcloudimg.tencent-cloud.cn/raw/006d5ed3359640424955baa08dab7c7f.svg" height=40></a> <a href="https://web.sdk.qcloud.com/trtc/webrtc/demo/api-sample/login.html"><img src="https://qcloudimg.tencent-cloud.cn/raw/d326e70750f8bbad7245e229c5bd6d2b.svg" height=40></a>

## 环境准备

- Xcode 13 及以上
- iOS 13.0 及以上

## 跑通示例工程

按照以下步骤，运行示例工程。

### 创建应用

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击创建新应用，在弹出的对话框中输入您的应用名称，并单击确定；
2. 选择刚刚创建出的应用，进入应用详情页面，并在页面的右下角找到含 UI 低代码场景方案功能区，单击免费体验即可开通 TUICallKit 的 7 天免费试用服务；
3. 在同一页面中找到并记录应用的`SDKAppID`和`SDKSecretKey`以供后续使用。

### 构建并运行示例工程

#### 1. 下载代码

```
$ git clone git@github.com:tencentyun/TUICallKit.git
```

#### 2. 加载依赖库

```
$ cd TUICallKit/iOS/Example
$ pod install
```

#### 3. 配置 SDKAppID 和 SDKSecretKey

你需要在 `GenerateTestUserSig.swift`文件中，配置应用的`SDKAppID` 和 `SDKSecretKey`。

```
let SDKAPPID: Int = 0
let SECRETKEY = ""
```

#### 4. 编译、运行示例工程，并在两台 iOS 设备上安装 APP

## 体验 App

1. 分别在两台设备上登录两个用户，一方作为主叫，一方作为被叫;
2. 在主叫方进入通话界面，输入被叫方的 ID，选择媒体类型，发起通话;
3. 被叫方收到通话的邀请后，点击接听进行通话。

## 参考

- 如果您想了解更多产品功能，请点击[链接](https://cloud.tencent.com/document/product/647/78742)。
- 如果您遇到困难，可以参考[常见问题](https://cloud.tencent.com/document/product/647/84363)，这里有开发者最常遇到的问题，覆盖各个平台，希望可以帮助您快速解决问题。
- 完整的API文档请参见[音视频通话 SDK API 示例](https://cloud.tencent.com/document/product/647/78752)：包括 TUICallKit（含UI）、TUICallEngine（不含UI）、以及通话回调事件等。
- 欢迎加入 QQ 群：**605115878**，进行技术交流和反馈~
