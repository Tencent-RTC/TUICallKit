# TUICallKit basic demo

<a href="https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic-react/README.md"> English </a> | <b> 简体中文 </b> 

## 简介

本 demo 演示了如何在项目中集成 TUICallKit 音视频通话组件。

- 环境：建议 React ≥ v18.0
- 附有调试面板可快速体验电话互通
- [在线体验](https://web.sdk.qcloud.com/component/TUICallKit/demos/basic-react/index.html)

## 快速跑通

### 第一步：下载源码，编译运行

1. 克隆或者直接下载此仓库源码

```
git clone https://github.com/tencentyun/TUICallKit.git
```

2. 进入 demo 目录

```shell
cd ./TUICallKit/Web/demos/basic-react
```

3. 安装依赖

```shell
npm install
```

4. 运行 demo

```shell
npm run dev
```

### 第二步：示例体验

1. 打开正在运行的页面，在最下方 debug 面板中，填入相关参数（若当前未取得，需阅读文末 [如何获得 SDKAppID 与 SecretKey？](#如何获得-SDKAppID-与-SecretKey？)）：

    - SDKAPPID
    - SECRETKEY
    - UserID: 想要登录的用户 ID，字符串类型，如 `user1`

<div style="margin-left:43px">
<img style="width:300px; max-width: inherit;" src="https://web.sdk.qcloud.com/component/TUICallKit/image/react-debug.png"/>
</div>

2. 然后点击登录，显示 `userId: (user1)`即为登录成功。

<div style="margin-left:43px">
<img style="width:400px; max-width: inherit;" src="https://web.sdk.qcloud.com/component/TUICallKit/image/react-loginuser1.jpg"/>
</div>

3. 扫描右上角的二维码，登录其他 `userId: (user2)`，进行互通。

<div style="margin-left:43px">
<img style="width:400px; max-width: inherit;" src="https://web.sdk.qcloud.com/component/TUICallKit/image/react-h5login.png"/>
</div>
  
4. 呼叫
  
    - 可直接复制或手动输入 `user2` 这个 userID，填入到 `user1` 的搜索框中，添加到拨打列表，点击通话。

    - `user2` 会收到来电，点击接听即可开始通话。

<div style="margin-left:43px">
   <img style="width:400px; max-width: inherit;" src="https://web.sdk.qcloud.com/component/TUICallKit/image/react-call.jpg" />
</div>

## 其他文档

- [TUICallKit 快速接入](https://cloud.tencent.com/document/product/647/102510)
- [TUICallKit API](https://cloud.tencent.com/document/product/647/81015)
- [TUICallKit (Web) 常见问题](https://cloud.tencent.com/document/product/647/78769)
- 欢迎加入腾讯云官方通信社群：[知了-TUICallKit](https://zhiliao.qq.com/s/cWSPGIIM62CC/cEUPGIIM62CE)，进行技术交流和反馈~

## 如何获得 SDKAppID 与 SecretKey？

### 开通服务

TUICallKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务并体验 7 天的免费试用服务：

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。

<img style="width:400px; max-width: inherit; margin-left: 43px;" src="https://web.sdk.qcloud.com/component/TUICallKit/image/service-create.png"/>

2. 单击刚刚创建出的应用，进入**基本配置**页面，并在页面的右下角找到**开通腾讯实时音视频服务**功能区，单击**免费体验**即可开通 TUICallKit 的 7 天免费试用服务。

<img style="width: 500px; max-width: inherit; margin-left: 43px;" src="https://web.sdk.qcloud.com/component/TUICallKit/image/service-experience.png"/>

3. 在同一页面找到 **SDKAppID** 和 **密钥(SecretKey)** 并记录下来，它们会在后续的 [第二步](#第二步：示例体验) 中被用到。

<img style="width: 500px; max-width: inherit; margin-left: 43px;" src="https://web.sdk.qcloud.com/component/TUICallKit/image/service-info.png"/>

> **注意**：
> 单击 **免费体验** 以后，部分之前使用过 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 服务的用户会提示：
>
> ```shell
> TRTC service is suspended. Please check if the package balance is 0 or the Tencent Cloud accountis in arrears
> ```
>
> 因为新的 IM 音视频通话能力是整合了腾讯云 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 和 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 两个基础的 PaaS 服务，所以当 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 的免费额度（10000 分钟）已经过期或者耗尽，就会导致开通此项服务失败，这里您可以单击 [TRTC 控制台](https://console.cloud.tencent.com/trtc/app)，找到对应 SDKAppID 的应用管理页，示例如图，开通后付费功能后，再次 **启用应用** 即可正常体验音视频通话能力。
> <img style="width: 500px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735851-56218484-55c7-4875-999c-1b58691bd744.png"/>
