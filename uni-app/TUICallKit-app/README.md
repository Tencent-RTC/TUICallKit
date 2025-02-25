本文将介绍如何用最短的时间完成 TUICallKit 组件的接入，跟随本文档，您将在一个小时的时间内完成如下几个关键步骤，并最终得到一个包含完备 UI 界面的视频通话功能。

## 环境准备
- 建议使用最新的 HBuilderX 编辑器 。
- iOS 9.0 或以上版本且支持音视频的 iOS 设备，暂不支持模拟器。
- Android 版本不低于 4.1 且支持音视频的 Android 设备，暂不支持模拟器。如果为真机，请开启**允许调试**选项。最低兼容 Android 4.1（SDK API Level 16），建议使用 Android 5.0 （SDK API Level 21）及以上版本。
- iOS/Android 设备已经连接到 Internet。

[](id:step1)
## 步骤一：开通服务
1. 登录到 [实时音视频 TRTC 控制台](https://console.cloud.tencent.com/trtc/app)，单击创建新应用，在弹出的对话框中输入您的应用名称，并单击确定。
2. 单击刚刚创建出的应用，进入**应用详情**页面，并在页面的右下角找到含 UI 低代码场景方案功能区，单击免费体验即可开通 TUICallKit 的 7 天免费试用服务。
3. 在同一页面找到 ***SDKAppID*** 和 ***密钥(SecretKey)*** 并保存，在后续步骤中使用。

[](id:step2)
## 步骤二：下载源码，配置工程
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

[](id:step3)
## 步骤三：导入插件 
### 1. 购买 uni-app 原生插件

- 访问 [TencentCloud-TUICallKit 插件](https://ext.dcloud.net.cn/plugin?id=9035) 插件，在插件详情页中购买插件（免费），购买插件时选择对应的 AppID，绑定正确的包名。

- 购买插件后在项目的 `manifest.json` 页面的**App原生插件配置**项下单击**选择云端插件**，选择**TencentCloud-TUICallKit 插件**。

### 2. 制作自定义调试基座 （**请使用真机运行自定义基座**）
- 制作自定义调试基座，请选择传统打包方式进行打包。
- 自定义调试基座成功后，使用自定义基座运行项目。

**注意：**
>- 自定义基座不是正式版，真正发布时，需要再打正式包。使用自定义基座是无法正常升级替换 APK 的。
>- 请尽量不要使用本地插件，插件包超过自定义基座的限制，可能导致调试收费。


## 实现案例

![](https://qcloudimg.tencent-cloud.cn/raw/b65ac3e2fdac99228dcaf0a2b909a156.png)

[Chat-uikit-uniapp Demo](https://github.com/TencentCloud/chat-uikit-uniapp) 是基于腾讯云 IM SDK 的一款 uni-app UI 组件库，它提供了一些通用的 UI 组件，包含会话、聊天、群组等功能。基于 UI 组件您可以像搭积木一样快速搭建起自己的业务逻辑。



## 技术咨询
了解更多详情您可 [腾讯云通信官方社群](https://zhiliao.qq.com/s/cWSPGIIM62CC/cEUPGIIM62CE) 进行咨询和反馈。


## 参考文档
- [TencentCloud-TUICallKit 插件](https://ext.dcloud.net.cn/plugin?id=9035) 
- [TIMPush 离线推送插件集成文档](https://cloud.tencent.com/document/product/647/105867)
- [TUICallKit uni-app(客户端) 快速接入文档](https://cloud.tencent.com/document/product/269/64506)
- [TUICallKit API 文档](https://cloud.tencent.com/document/product/647/78762)
- [Chat + Call 融合接入文档](https://cloud.tencent.com/document/product/269/79111)