本文将介绍如何用最短的时间完成 TUICallKit 组件的接入，跟随本文档，您将在一个小时的时间内完成如下几个关键步骤，并最终得到一个包含完备 UI 界面的视频通话功能。

## 环境准备
- 建议使用最新的 HBuilderX 编辑器 。
- iOS 9.0 或以上版本且支持音视频的 iOS 设备，暂不支持模拟器。
- Android 版本不低于 4.1 且支持音视频的 Android 设备，暂不支持模拟器。如果为真机，请开启**允许调试**选项。最低兼容 Android 4.1（SDK API Level 16），建议使用 Android 5.0 （SDK API Level 21）及以上版本。
- iOS/Android 设备已经连接到 Internet。

[](id:step1)
## 步骤一：开通服务
TUICallKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务并体验 7 天的免费试用服务。

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。

    <img width="300" src="https://qcloudimg.tencent-cloud.cn/image/document/61a2068cf73ee1fc911ab3bb31d978df.png">

2. 单击刚刚创建出的应用，进入**基本配置**页面，并在页面的右下角找到**开通腾讯实时音视频服务**功能区，单击**免费体验**即可开通 TUICallKit 的 7 天免费试用服务。如果需要正式应用上线，可以单击 [**前往加购**](https://buy.cloud.tencent.com/avc) 即可进入购买页面。

    <img width="300" height="300" src="https://qcloudimg.tencent-cloud.cn/raw/99a6a70e64f6877bad9406705cbf7be1.png">


3. 在同一页面找到 **SDKAppID** 和**密钥**并记录下来，它们会在后续的 [步骤三：下载源码 配置工程](#step3) 中被用到。

    <img width="300" height="300" src="https://qcloudimg.tencent-cloud.cn/raw/e435332cda8d9ec7fea21bd95f7a0cba.png">

> 单击**免费体验**以后，部分之前使用过 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 服务的用户会提示：
> ```
> [-100013]:TRTC service is  suspended. Please check if the package balance is 0 or the Tencent Cloud accountis in arrears
> ```
> 这是因为当 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 的免费额度（10000分钟）已经过期或者耗尽，就会导致开通此项服务失败，这里您可以单击 [TRTC 控制台](https://console.cloud.tencent.com/trtc/app)，找到对应 SDKAppID 的应用管理页，开通后付费功能后，再次**启用应用**即可正常体验音视频通话能力。

[](id:step2)
## 步骤二：导入插件 
1. **购买 uni-app 原生插件**
登录 uni 原生插件市场，并访问 [TencentCloud-TUICallKit 插件](https://ext.dcloud.net.cn/plugin?id=9035)，在插件详情页中购买（免费插件也可以在插件市场0元购）。购买后才能够云端打包使用插件。**购买插件时请选择正确的 appid，以及绑定正确包名**。

    <img width="200" src="https://qcloudimg.tencent-cloud.cn/raw/d270d9298975ee829ae9c8c405530765.png">

2. 使用自定义基座打包 uni 原生插件 （**请使用真机运行自定义基座**）
使用 uni 原生插件必须先提交云端打包才能生效，购买插件后在应用的 `manifest.json` 页面的 **App原生插件配置**项下单击**选择云端插件**，选择**腾讯云原生音视频插件**。

    <img width="400" src="https://web.sdk.qcloud.com/component/TUIKit/assets/uni-app/TencentCloud-TUICallKit.png">

>**直接云端打包后无法打 log，无法排查问题，需要自定义基座调试原生插件。**
>- 自定义基座不是正式版，真正发布时，需要再打正式包。使用自定义基座是无法正常升级替换 APK 的。
>- 请尽量不要使用本地插件，插件包超过自定义基座的限制，可能导致调试收费。

[](id:step3)
## 步骤三：下载源码，配置工程
1. 克隆或者直接下载此仓库源码，欢迎 Star，感谢~~
2. 找到并打开 `uni-app/debug/GenerateTestUserSig.js` 文件。
3. 配置 `GenerateTestUserSig.js` 文件中的 `SDKAPPID`、`SECRETKEY` 参数。
  - SDKAPPID：值为 number 类型，请设置为步骤一中记录下的 SDKAppID。
  - SECRETKEY：值为 string 类型，请设置为步骤一中记录下的密钥(SecretKey)信息。

## 实现案例
我们提供了**在线客服场景**的相关源码，可以通过下载 [Github Demo](https://github.com/TencentCloud/chat-uikit-uniapp) 集成体验。该场景提供了示例客服群 + 示例好友的基础模板，实现功能包括：
- 支持发送文本消息、图片消息、语音消息、视频消息等常见消息。
- 支持双人语音、视频通话功能
- 支持创建群聊会话、群成员管理等。

## 技术咨询
了解更多详情您可通过官方社群咨询：[腾讯云通信官方社群](https://zhiliao.qq.com/s/cWSPGIIM62CC/cEUPGIIM62CE)

## 相关文档
- [一分钟跑通 Demo (uni-app)](https://cloud.tencent.com/document/product/269/64506)
- [快速集成 uni-app TUIKit](https://cloud.tencent.com/document/product/269/64507)
- [TencentCloud-TUICallKit 插件](https://ext.dcloud.net.cn/plugin?id=9035)
