_[English](https://github.com/tencentyun/TUICallKit/blob/main/Flutter/example/README.md) | 简体中文_

# Call UIKit Flutter 示例工程快速跑通

[![Platform](https://img.shields.io/badge/platform-flutter-blue)](https://flutter.dev/)
[![Language](https://img.shields.io/badge/language-dart-blue)](https://dart.dev/)


<img src="https://qcloudimg.tencent-cloud.cn/raw/ec034fc6e4cf42cae579d32f5ab434a1.png" align="left" width=120 height=120>TUICallKit 是腾讯云推出一款音视频通话的含 UI 组件，通过集成该组件，您只需要编写几行代码就可以为您的 App 添加音视频通话功能，并且支持离线唤起能力。TUICallKit 支持 Android、iOS、Web、小程序、Flutter、UniApp 等多个开发平台。

<a href="https://apps.apple.com/cn/app/%E8%85%BE%E8%AE%AF%E4%BA%91%E8%A7%86%E7%AB%8B%E6%96%B9trtc/id1400663224"><img src="https://qcloudimg.tencent-cloud.cn/raw/afe9b8cc4c715346cf3d9feea8a65e33.svg" height=40></a> <a href="https://dldir1.qq.com/hudongzhibo/liteav/TRTCDemo.apk"><img src="https://qcloudimg.tencent-cloud.cn/raw/006d5ed3359640424955baa08dab7c7f.svg" height=40></a> <a href="https://web.sdk.qcloud.com/trtc/webrtc/demo/api-sample/login.html"><img src="https://qcloudimg.tencent-cloud.cn/raw/d326e70750f8bbad7245e229c5bd6d2b.svg" height=40></a>

## 准备工作

#### 环境要求
- Flutter 3.0 及以上版本。
- **Android 端开发：**
  - Android Studio 3.5及以上版本。
  - Android 4.1 及以上版本的 Android 设备。
- **iOS & macOS 端开发：**
  - Xcode 13.0及以上版本。
  - macOS 系统版本要求 12.4 及以上版本
  - 请确保您的项目已设置有效的开发者签名。
 
想要了解更多关于 TUICallKit Flutter SDK 的使用信息，请参考 [TUICallKit Flutter 文档](https://cloud.tencent.com/document/product/647/78742)。


## 运行示例

#### 创建项目

1. 注册并登录[腾讯云IM控制台](https://console.cloud.tencent.com/im)；

2. 创建或者选择一个已开通音视频通话的项目；

3. 记录项目的 SDKAppId 和 SDKSecretKey。


#### 编译运行

1. 克隆仓库。

  ```
  git clone https://github.com/tencentyun/TUICallKit.git
  ```
  
2.  配置 SDKAppID 和 SDKSecretKey
   运行示例工程需要配置项目的 SDKAppID 和 SDKSecretKey，在 `TUICallKit/Flutter/example/lib/debug` 目录下的 [generate\_test\_user\_sig.dart](lib/debug/generate_test_user_sig.dart) 文件中填写 SDKAppID 和 SDKSecretKey。

  ```
class GenerateTestUserSig {
    ...
    static int sdkAppId = SDKAppID;
    static String secretKey =  'SDKSecretKey';
    ...
}
  ```

3. 在 Android 或 iOS 设备上构建并运行示例应用程序。

  进入到 `TUICallKit/Flutter/example` 目录下，在命令行执行 `flutter run` 命令编译安装应用程序。

4. 将应用程序安装到两个单独的设备上。

5. 如果没有两个可用设备，您可以使用模拟器来运行应用程序。

有关如何构建和运行 Flutter 应用程序的更多详细信息，请参阅 [Flutter 文档](https://flutter.cn/docs/development/tools/devtools/cli)。

## 拨打第一通电话
1.  分别在两台设备上登录不同的用户 ID；

2. 一台设备进入单人通话页面，填入另一台设备登录的用户 ID ，选择通话类型并拨打通话；

3. 被叫端接收到通话邀请，点击同意进行通话。

## 参考
- 如果您想了解更多产品功能，请点击[链接](https://cloud.tencent.com/document/product/647/78742)。

- 如果您遇到困难，可以参考[常见问题](https://cloud.tencent.com/document/product/647/84363)，这里有开发者最常遇到的问题，覆盖各个平台，希望可以帮助您快速解决问题。

- 完整的API文档请参见[音视频通话 SDK API 示例](https://cloud.tencent.com/document/product/647/83052)：包括 TUICallKit（含UI）、TUICallEngine（不含UI）、以及通话回调事件等。
