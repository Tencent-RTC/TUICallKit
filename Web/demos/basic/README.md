# TUICallKit basic demo

## 简介

本 demo 演示了如何在项目中集成 TUICallKit 音视频通话组件。

- 环境：Vue + Webpack + TypeScript 
- 附有调试面板可快速体验电话互通

<img style="width:800px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/f7dfb3993e61d6e2b8c5e9844e149f8c.png"/> 

## 快速跑通
### 第一步：开通服务
TUICallKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务并体验 7 天的免费试用服务：

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。

<img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/1105c3c339be4f71d72800fe2839b113.png"/>

2. 单击刚刚创建出的应用，进入**基本配置**页面，并在页面的右下角找到**开通腾讯实时音视频服务**功能区，单击**免费体验**即可开通 TUICallKit 的 7 天免费试用服务。

<img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/667633f7addfd0c589bb086b1fc17d30.png"/>

3. 在同一页面找到 **SDKAppID** 和 **密钥(SecretKey)** 并记录下来，它们会在后续的 [第三步](#第三步：示例体验) 中被用到。

<img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/e435332cda8d9ec7fea21bd95f7a0cba.png"/>

> **注意**：
> 单击 **免费体验** 以后，部分之前使用过 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 服务的用户会提示：
> ```shell
> TRTC service is suspended. Please check if the package balance is 0 or the Tencent Cloud accountis in arrears
> ```
> 因为新的 IM 音视频通话能力是整合了腾讯云 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 和 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 两个基础的 PaaS 服务，所以当 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 的免费额度（10000分钟）已经过期或者耗尽，就会导致开通此项服务失败，这里您可以单击 [TRTC 控制台](https://console.cloud.tencent.com/trtc/app)，找到对应 SDKAppID 的应用管理页，示例如图，开通后付费功能后，再次 **启用应用** 即可正常体验音视频通话能力。
> <img width=800px src="https://qcloudimg.tencent-cloud.cn/raw/f74a13a7170cf8894195a1cae6c2f153.png" />


### 第二步：下载源码，编译运行

1. 克隆或者直接下载此仓库源码，**欢迎 Star**，感谢~~

```
git clone https://github.com/tencentyun/TUICallKit.git
```

2. 打开源码目录 `TUICallKit/Web` 安装 TUICallKit 依赖

```
yarn  // 若当前环境未安装 yarn 包管理工具，可使用 npm install -g yarn 进行安装
```

3. 打开示例工程目录 `TUICallKit/Web/demos/basic`，安装依赖并运行

```
yarn
yarn serve
```

### 第三步：示例体验

`Tips：TUICallKit 通话体验，至少需要开启两个网页，如果用户A/B分别代表两台不同的网页登录的 userID：`

1.打开两份启动调试的网页，在页面最下方 debug 面板中，填入相关参数

- SDKAPPID：请设置为 [第一步](#第一步：开通服务) 中记录下的 SDKAppID。
- SECRETKEY：请设置为 [第一步](#第一步：开通服务) 中记录下的密钥(SecretKey)信息。

<img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/f5b0a4788083567b06abd729b121348e.png"/>

2.登录

- 对于 A 网页：填入用户名 userID，如 `A`，点击登录，显示`目前 userID: (A)`即为登录成功
- 对于 B 网页：填入**不同的** userID，如 `B`，点击登录，显示`目前 userID: (B)`即为登录成功

3.呼叫

- 对于 A 网页：登录成功后，等待接听来电即可；
- 对于 B 网页：在搜索框中输入 `A`，点击添加到拨打列表，点击通话按钮即可。

## 其他文档

- [TUICallKit 快速接入](https://cloud.tencent.com/document/product/647/78731)
- [TUICallKit API](https://github.com/tencentyun/TUICallKit/blob/main/Web/docs/API.md)
- [TUICallKit 界面定制指引](https://github.com/tencentyun/TUICallKit/blob/main/Web/docs/UI%20Customization.md)
- [TUICallKit (Web) 常见问题](https://cloud.tencent.com/document/product/647/78769)
- 欢迎加入 QQ 群：**646165204**，进行技术交流和反馈~