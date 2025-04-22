# TUICallkit 组件接入说明

## 简介
本 demo 演示了如何在项目中集成 TUICallKit 音视频通话组件。


## 环境准备

- 微信 App iOS 最低版本要求：7.0.9
- 微信 App Android 最低版本要求：7.0.8
- 小程序基础库最低版本要求：2.10.0
- 由于小程序测试号不具备 [live-pusher](https://developers.weixin.qq.com/miniprogram/dev/component/live-pusher.html) 和 [live-player](https://developers.weixin.qq.com/miniprogram/dev/component/live-player.html) 的使用权限，请使用企业小程序账号申请相关权限进行开发
- 由于微信开发者工具不支持原生组件（即 [live-pusher](https://developers.weixin.qq.com/miniprogram/dev/component/live-pusher.html) 和 [live-player](https://developers.weixin.qq.com/miniprogram/dev/component/live-player.html) 标签），需要在真机上进行运行体验


## 快速跑通
第一步：下载源码，编译运行
1. 克隆或者直接下载此仓库源码。
   ```
   git clone https://github.com/tencentyun/TUICallKit.git
   ```
2. 进入 demo 目录
   ```
   cd ./TUICallKit/MiniProgram/wechat-callkit-demo
   ```
3. 安装依赖
   ```
   npm install
   ```
   
   mac端
   ```
   mkdir -p ./TUICallKit && cp -r node_modules/@tencentcloud/call-uikit-wx/ ./TUICallKit && cp node_modules/@tencentcloud/call-engine-wx/RTCCallEngine.wasm.br ./static/
   ```

   windows端
   ```
   xcopy node_modules\@tencentcloud\call-uikit-wx\ .\TUICallKit /i /e
   xcopy node_modules\@tencentcloud\call-engine-wx\RTCCallEngine.wasm.br .\static\

   ```

4. 项目导入到微信开发者工具，构建 npm。微信开发者工具【工具】->【构建 npm】。具体如下图：
   
   <img src="https://web.sdk.qcloud.com/component/trtccalling/images/miniProgram/build-npm.png" width="400" height="600" align="middle" />

5. 修改 `./TUICallKit/MiniProgram/TUICalling/debug/GenerateTestUserSig.js` 文件 的 SDKAPPID 以及 SECRETKEY（阅读文末 [如何获得SDKAppID与SecretKey？](#如何获得-SDKAppID-与-SecretKey？)）
   
   <img src="https://user-images.githubusercontent.com/72854065/226269630-7d33a694-aad4-414e-bfea-19919fcacb48.png"/>

6. 在微信开发者工具编译运行。
   
   <img src="https://web.sdk.qcloud.com/component/trtccalling/images/miniProgram/build.png" align="middle" />


## 示例体验
> **Tips：TUICallKit 通话体验，至少需要两台设备，用户 A、B 代表使用不同的设备。**

**用户 A（userId：111）**
- 步骤 1：在欢迎页，输入用户名（<font color=red>请确保用户名唯一性，不能与其他用户重复</font>）登录，比如：111。
- 步骤 2：根据不同的场景&业务需求，进入不同的场景界面，比如：视频通话。
- 步骤 3：输入要拨打的用户 B 的 userId（例如：222），点击搜索，然后点击呼叫。
  | 步骤1 | 步骤2 | 步骤3 | 
  | :-: | :-: | :-: |
  |<img src="https://qcloudimg.tencent-cloud.cn/raw/13bf844da5636f3640da05020800fff9.jpg" width="240"/>|<img src="https://qcloudimg.tencent-cloud.cn/raw/ceed4039c6ce8f9b8ff48deb89199b6e.jpg" width="240">|<img src="https://qcloudimg.tencent-cloud.cn/raw/dc1984904c9790c8a3355ff1c5dada50.jpg" width="240"/>

**用户 B（userId：222）**
- 步骤 1：在欢迎页，输入用户名（<font color=red>请确保用户名唯一性，不能与其他用户重复</font>）登录，比如：222。
- 步骤 2：进入主页，等待接听来电即可。


## 如何获得SDKAppID与SecretKey？

### 开通服务

TUICallKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务并体验 7 天的免费试用服务。

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。
   
   <img style="width:600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735745-f52e6645-aad4-430c-a93c-c6b2c2e2f19e.png"/>

2. 单击刚刚创建出的应用，进入**基本配置**页面，并在页面的右下角找到**开通腾讯实时音视频服务**功能区，单击**免费体验**即可开通 TUICallKit 的 7 天免费试用服务。
   
   <img style="width: 600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735812-cd66873d-583a-4433-bbca-38968432925f.png"/>

3. 在同一页面找到 **SDKAppID** 和 **密钥（SecretKey）** 并记录下来。
   
   <img style="width: 600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735831-72fb9498-c596-4289-beb8-e2633b52b4ad.png"/>

> **注意**：
> 单击 **免费体验** 以后，部分之前使用过 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 服务的用户会提示：
>
> ```shell
> TRTC service is suspended. Please check if the package balance is 0 or the Tencent Cloud accountis in arrears
> ```
>
> 因为新的 IM 音视频通话能力是整合了腾讯云 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 和 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 两个基础的 PaaS 服务，所以当 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 的免费额度（10000 分钟）已经过期或者耗尽，就会导致开通此项服务失败，这里您可以单击 [TRTC 控制台](https://console.cloud.tencent.com/trtc/app)，找到对应 SDKAppID 的应用管理页，示例如图，开通后付费功能后，再次 **启用应用** 即可正常体验音视频通话能力。
> <img style="width: 600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735851-56218484-55c7-4875-999c-1b58691bd744.png"/>


## 其他文档
- 如果您想要了解 TUICallKit，请阅读 [组件介绍 TUICallKit](https://cloud.tencent.com/document/product/647/78742)。
- 如果您想把我们的功能直接嵌入到您的项目中，请阅读 [快速接入 TUICallKit](https://cloud.tencent.com/document/product/647/78733)。
- 如果您想要了解详细 API ，请阅读 [ API 概览](https://cloud.tencent.com/document/product/647/78759)。
- [TUICallKit (小程序) 常见问题](https://cloud.tencent.com/document/product/647/78770)。


## 附录
- 如果你遇到了困难，可以先参阅 [常见问题](https://cloud.tencent.com/document/product/647/78733)。
- 如果发现了示例代码的 bug，欢迎提交 issue。
- 欢迎加入 QQ 群：**646165204**，进行技术交流和反馈~
  