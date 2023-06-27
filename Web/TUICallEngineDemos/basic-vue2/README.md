# TUICallEngine api example demo

## 简介

本 demo 演示了如何在vue2项目中使用[tuicall-engine-webrtc](https://www.npmjs.com/package/tuicall-engine-webrtc)的api搭建一套音视频通话应用。

## 环境
Vue2.7 + vite + TypeScript

## 快速跑通

### 第一步：下载源码，编译运行

1. 克隆或者直接下载此仓库源码

```
git clone https://github.com/tencentyun/TUICallKit.git
```

2. 进入 examples 目录

```shell
cd ./TUICallKit/Web/TUICallEngineDemos/basic-vue2
```

3. 安装依赖

```shell
npm install
```

4. 修改sdkAppId

打开src/constants/call.ts文件，修改DefaultSdkAppId为自己应用的sdkAppId

5. 运行 demo

```shell
npm run dev
```

### 第二步：示例体验

1. 打开正在运行的页面，登录框中输入userID，例如user_A，点击登录，再打开同样地址的页面，输入user_B，并登录；

<div align="center">
<img style="width:450px; max-width: inherit;" src="https://web.sdk.qcloud.com/trtc/call/test/call-engine-demo/assets/WX20230619-170647%402x.png"/>
</div>

2. 选择单人通话或者群组通话。

  <div align="center">
    <img style="width:450px; max-width: inherit;" src="https://web.sdk.qcloud.com/trtc/call/test/call-engine-demo/assets/WX20230619-170533%402x.png"/>
  </div>
  
3. 进入呼叫配置页
  
- 用户id输入框内输入user_B，并可在媒体类型选择音频通话或者视频通话
    
- `user_B` 会收到来电，点击接听即可开始通话。

<div align="center">

<img style="width:800px; max-width: inherit;" src="https://web.sdk.qcloud.com/trtc/call/test/call-engine-demo/assets/calldemo1.gif"/>

</div>
4. 视频设置
  
- 通话建立后，可以在视频设置中调节分辨率，通话类型（仅1v1且视频通话），填充模式，摄像头等

<div align="center">
<img style="width:800px; max-width: inherit;" src="https://web.sdk.qcloud.com/trtc/call/test/call-engine-demo/assets/2023-06-19%2019.04.19.gif"/>

</div>

5. 设置昵称，头像
- 基本设置中，输入昵称，或者头像地址点击右侧设置，即可设置成功。
<div align="center">
<img style="width:800px; max-width: inherit;" src="https://web.sdk.qcloud.com/trtc/call/test/call-engine-demo/assets/2023-06-19%2019.10.48.gif"/>

</div>

## 目录结构
```shell
.            
├── src/
│   ├── components/     # 公共组件和业务组件
│   ├── assets/         # 静态资源存放
│   ├── constants/      # 常量
│   ├── hooks/          # Hook 相关，公共逻辑
│   ├── router/         # 业务路由
│   ├── utils/          # 公共工具方法
│   ├── stores/         # 状态管理相关
│   ├── main.ts         
│   └── App.vue
├── README.md
├── package.json
```

## 其他文档
- [TUICallEngine API](https://cloud.tencent.com/document/product/647/78757)
- [TUICallKit 快速接入](https://cloud.tencent.com/document/product/647/78731)
- [TUICallKit (Web) 常见问题](https://cloud.tencent.com/document/product/647/78769)
- 欢迎加入 QQ 群：**646165204**，进行技术交流和反馈~

## 如何获得 SDKAppID 与 SecretKey？

### 开通服务

TUICallKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务并体验 7 天的免费试用服务：

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。

<div align="center">
<img style="width:600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735745-f52e6645-aad4-430c-a93c-c6b2c2e2f19e.png"/>
</div>

2. 单击刚刚创建出的应用，进入**基本配置**页面，并在页面的右下角找到**开通腾讯实时音视频服务**功能区，单击**免费体验**即可开通 TUICallKit 的 7 天免费试用服务。

<div align="center">
<img style="width: 600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735812-cd66873d-583a-4433-bbca-38968432925f.png"/>
</div>

3. 在同一页面找到 **SDKAppID** 和 **密钥(SecretKey)** 并记录下来，它们会在后续的 [第二步](#第二步：示例体验) 中被用到。

<div align="center">
<img style="width: 600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735831-72fb9498-c596-4289-beb8-e2633b52b4ad.png"/>
</div>

> **注意**：
> 单击 **免费体验** 以后，部分之前使用过 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 服务的用户会提示：
>
> ```shell
> TRTC service is suspended. Please check if the package balance is 0 or the Tencent Cloud accountis in arrears
> ```
>
> 因为新的 IM 音视频通话能力是整合了腾讯云 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 和 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 两个基础的 PaaS 服务，所以当 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 的免费额度（10000 分钟）已经过期或者耗尽，就会导致开通此项服务失败，这里您可以单击 [TRTC 控制台](https://console.cloud.tencent.com/trtc/app)，找到对应 SDKAppID 的应用管理页，示例如图，开通后付费功能后，再次 **启用应用** 即可正常体验音视频通话能力。
> <div align="center"> <img style="width: 600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735851-56218484-55c7-4875-999c-1b58691bd744.png"/></div>
