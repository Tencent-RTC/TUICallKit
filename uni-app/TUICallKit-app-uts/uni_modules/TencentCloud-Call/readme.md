# TencentCloud-Call
本文将介绍如何快速体验音视频通话功能，您将在10分钟内完成以下关键步骤，并最终获得一个具有全面用户界面的视频通话功能。
## 环境准备

> **说明：**
> 

> Hbuilder x 4.64 和 4.65 版本对 uts 插件打包存在兼容性问题，建议使用最新版本。
> 

- [HBuilder X](https://www.dcloud.io/hbuilderx.html)

- 两个移动设备： Android 5.0 以上的设备 / iOS 13.0 及以上设备。


## 步骤一 : 下载 Demo
1. 从 github 下载 [TUICallKit Demo](https://github.com/Tencent-RTC/TUICallKit/tree/main) 源码，或者直接在命令行运行以下命令：

   ``` bash
     git clone https://github.com/Tencent-RTC/TUICallKit.git
   ```
2. 通过 HbuiderX 打开 TUICallKit **uni-app/TUICallKit-uts** 项目：

   ![](https://write-document-release-1258344699.cos.ap-guangzhou.tencentcos.cn/100028028022/a22b1d4c4a8011f0930e525400bf7822.png)


## 步骤二 : 配置 Demo
1. [点击进入开通服务页面](https://trtc.io/document/59832?platform=android&product=call)，获取`SDKAppID、SecretKey`**。**

2. 填写 'TUICallKit/uni-app/TUICallKit-uts/debug/GenerateTestUserSig-es.js' 文件下的 `SDKAPPID、SecretKey`。

   ![](https://write-document-release-1258344699.cos.ap-guangzhou.tencentcos.cn/100028028022/d2570fba3aa711f0b95f5254005ef0f7.png)


## 步骤三 : 跑通 Demo
1. 制作自定义调试基座，请选择**传统打包**方式进行打包。

   ![](https://write-document-release-1258344699.cos.ap-guangzhou.tencentcos.cn/100028028022/aff32b2e3ac311f0aa9f5254001c06ec.png)


   ![](https://write-document-release-1258344699.cos.ap-guangzhou.tencentcos.cn/100028028022/f5a5b2f73ac611f0b0ce5254007c27c5.png)

2. 自定义调试基座成功后，**使用自定义基座运行**项目。

   ![](https://write-document-release-1258344699.cos.ap-guangzhou.tencentcos.cn/100028028022/dedf295d3ac711f0aa9f5254001c06ec.png)


## 步骤四：拨打第一通电话

> **注意：**
> 

> 为了使您可以体验完整的音视频通话流程，请将 Demo 分别在两台设备上登录两个用户，一方作为主叫，一方作为被叫。
> 

1. 登录/注册 userID（由您定义）。


   ![](https://write-document-release-1258344699.cos.ap-guangzhou.tencentcos.cn/100028028022/5c554cdb3ac811f09bbe525400454e06.png)
   

   > **注意：**
   > 

   > 尽量避免使您的 UserID 被设置成“1”、“123”、“111”等简单字符串，由于 TRTC 不支持同一个 UserID 多端登录，所以在多人协作开发时，形如 “1”、“123”、“111” 这样的 UserID 很容易被您的同事占用，导致登录失败，因此我们建议您在调试的时候设置一些辨识度高的 UserID。
   > 

2. 拨打电话


   ![](https://write-document-release-1258344699.cos.ap-guangzhou.tencentcos.cn/100028028022/43d567ad3ac911f09bbe525400454e06.png)
