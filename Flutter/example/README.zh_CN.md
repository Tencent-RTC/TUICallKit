# TUICallKit Flutter 示例工程快速跑通
_[English](https://github.com/tencentyun/TUICallKit/blob/main/Flutter/example/README.md) | 简体中文_

本文档主要介绍如何快速跑通 TUICallKit 示例工程，体验高质量视频/语音通话，更详细的 TUICallKit 组件接入流程，请点击腾讯云官网文档： [TUICallKit 组件 Flutter 接入说明](https://cloud.tencent.com/document/product/647/78742) ...

## 环境准备
- Flutter 3.0 及以上版本。
- **Android 端开发：**
  - Android Studio 3.5及以上版本。
  - Android 4.1 及以上版本的 Android 设备。
- **iOS & macOS 端开发：**
  - Xcode 13.0及以上版本。
  - macOS 系统版本要求 12.4 及以上版本
  - 请确保您的项目已设置有效的开发者签名。
  
## 运行示例

### 1. 开通音视频通话服务

根据您的所在的地区前往对应的控制台开通应视频通话服务：

- 中国大陆地区，请参考 [中国站音视频通话服务开通文档](https://cloud.tencent.com/document/product/647/82985#f3603978-aa95-43b9-8d56-44880636bc6f) 开通服务。
- 非中国大陆地区，请参考 [国际站音视频通话服务开通文档](https://trtc.io/document/54896#step-1.-activate-the-service) 开通服务。

### 2. 配置 Demo 工程文件

1. 打开 lib/debug 目录下的 [generate\_test\_user\_sig.dart](lib/debug/generate_test_user_sig.dart) 文件。
2. 配置`generate_test_user_sig.dart`文件中的两个参数：
  
- SDKAPPID：替换该变量值为在控制台创建应用的SDKAPPID。
- SECRETKEY：替换该变量值为在控制台创建应用的SDKAPPID对应的密钥。
  
 ![ #900px](https://qcloudimg.tencent-cloud.cn/raw/883a8a9ce075d919b323b955f9523742.png)

> 本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。

> 正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。


### 3. 编译运行

#### Android 
**Setp1**：执行以下命令，安装 Flutter 依赖：


```
flutter pub get
```

**Setp2**：在检查设备连接正常后，执行如下命令，进行编译安装（需要选择 android 设备）：

```
flutter run
```

#### iOS
**Setp1**：执行以下命令，安装 Flutter 依赖：

```
flutter pub get
```

**Setp2**：进入到 `example/ios` 目录下执行以下命令，安装 Cocoapods 依赖：

```
pod install
```

**Setp3**：在检查设备连接正常后，可以使用 XCode 打开 example 目录下的 /ios工程，编译运行，也可以直接执行以下命令运行（需要选择 ios 设备）：

```
flutter run
```

## 常见问题
**Q：更新 SDK 版本后，iOS CocoaPods 运行报错？**

1. 执行 `pod repo update`。
2. 执行 `pod update`。
3. 重新编译运行。

更多常见问题点击[这里](https://cloud.tencent.com/document/product/647/51623)...
