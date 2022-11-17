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

### 1. 前提条件
您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。


### 2. 申请 SDKAPPID 和 SECRETKEY

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击创建新应用，在弹出的对话框中输入您的应用名称，并单击确定。
![](https://qcloudimg.tencent-cloud.cn/raw/20c5e8bea7c7cf720ee400ed13fc4b92.png) 
2. 单击刚刚创建出的应用，进入基本配置页面，并在页面的右下角找到开通腾讯实时音视频服务功能区，单击免费体验即可开通 TUICallKit 的 7 天免费试用服务。如果需要正式应用上线，可以单击 前往加购 即可进入购买页面。
![](https://qcloudimg.tencent-cloud.cn/raw/73a270a50c9e5a7b8d9a7f8525921eea.png)
3. 在同一页面找到 SDKAppID 和密钥并记录下来，将在配置Demo工程文件中被使用。
![](https://qcloudimg.tencent-cloud.cn/raw/399b62b163a3146681cccc913cb5c7a0.png)

### 3. 配置 Demo 工程文件

1. 打开 lib/debug 目录下的 [generate_test_user_sig.dart](lib/debug/generate_test_user_sig.dart) 文件。
2. 配置`generate_test_user_sig.dart`文件中的两个参数：
  - SDKAPPID：替换该变量值为上一步骤中在页面上看到的 SDKAppID。
  - SECRETKEY：替换该变量值为上一步骤中在页面上看到的密钥。
 ![ #900px](https://qcloudimg.tencent-cloud.cn/raw/883a8a9ce075d919b323b955f9523742.png)
3. 返回实时音视频控制台，单击【粘贴完成，下一步】。
4. 单击【关闭指引，进入控制台管理应用】。

> 本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。

> 正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。


### 4. 编译运行

#### Android 
**Setp1**：安装依赖
```
flutter pub get
```

**Setp2**：在检查设备连接正常后，执行如下命令，进行编译安装：
```
flutter run
```
#### iOS
**Setp1**：安装依赖
```
flutter pub get
```
**Setp2**：在检查设备连接正常后，执行如下命令，进行编译安装：
```
cd ios
pod install
```
**Setp3**：使用 XCode（13.0及以上的版本）打开 example 目录下的 /ios工程，编译并运行 Demo 工程即可。


## 常见问题
**Q：更新 SDK 版本后，iOS CocoaPods 运行报错？**
1. 删除 iOS 目录下 `Podfile.lock` 文件。
2. 执行 `pod repo update`。
3. 执行 `pod install`。
4. 重新运行。

更多常见问题点击[这里](https://cloud.tencent.com/document/product/647/51623)...
