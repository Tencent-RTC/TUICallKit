# TUICallKit basic demo

## 简介

本 demo 演示了如何在项目中集成 TUICallKit 音视频通话组件。

- 环境：Vue + Webpack + TypeScript 
- 附有调试面板可快速体验电话互通

<img style="width:800px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/f7dfb3993e61d6e2b8c5e9844e149f8c.png"/> 


## 启动与调试

### 步骤1: clone 仓库到本地
```
git clone https://github.com/tencentyun/TUICallKit
```
### 步骤2: 安装 TUICallKit 依赖与 Demo 依赖
```
cd ./TUICallKit/Web && npm install
cd ./demos/basic && npm install
```
### 步骤3: 启动项目 
```
npm run serve
```

### 步骤4: 在网页中填写应用信息并进行通话

进入[即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击目标应用卡片，进入应用，获取应用ID(SDKAppID)、密钥(SecretKey)，复制填入网页中的调试面板(Debug Panel)。


<img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/480455e5b4a2a1d4d67ffb2e445452a6.png"/>


<img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/f5b0a4788083567b06abd729b121348e.png"/>

### 步骤5: 填入自定义的 UserID 并登陆，打开另一网页登录另一 UserID，即可互相进行音频/视频通话。