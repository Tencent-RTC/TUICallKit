# TUICallKit 接入指引

本文将介绍如何用最短的时间完成 TUICallKit 组件的接入，跟随本文档，您将完成如下几个关键步骤，并最终得到一个包含完备 UI 界面的视频通话功能。

## 环境要求

### 1. 对浏览器版本要求

请使用最新版本的 Chrome 浏览器进行体验，本文档中所对接的组件对当前主流的桌面浏览器的支持情况如下：

<table>
<thead><tr><th>操作系统</th><th>浏览器类型</th><th>浏览器最低版本要求</th></tr></thead>
<tbody><tr>
<td>Mac OS</td>
<td>桌面版 Safari 浏览器</td>
<td>11+</td>
</tr><tr>
<td>Mac OS</td>
<td>桌面版 Chrome 浏览器</td>
<td>56+</td>
</tr><tr>
<td>Mac OS</td>
<td>桌面版 Firefox 浏览器</td>
<td>56+</td>
</tr><tr>
<td>Mac OS</td>
<td>桌面版 Edge 浏览器</td>
<td>80+</td>
</tr><tr>
<td>Windows</td>
<td>桌面版 Chrome 浏览器</td>
<td>56+</td>
</tr><tr>
<td>Windows</td>
<td>桌面版 QQ 浏览器（极速内核）</td>
<td>10.4+</td>
</tr><tr>
<td>Windows</td>
<td>桌面版 Firefox 浏览器</td>
<td>56+</td>
</tr><tr>
<td>Windows</td>
<td>桌面版 Edge 浏览器</td>
<td>80+</td>
</tr>
</tbody></table>

>? 详细兼容性查询，具体请参见 [浏览器支持情况](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/tutorial-05-info-browser.html)。同时，您可通过 [TRTC 检测页面](https://web.sdk.qcloud.com/trtc/webrtc/demo/detect/index.html) 在线检测。

### 2. 对网络环境的要求

在使用 TUICallKit 时，用户可能因防火墙限制导致无法正常进行音视频通话，请参考 [应对防火墙限制相关](https://cloud.tencent.com/document/product/647/34399) 将相应端口及域名添加至防火墙白名单中。

### 3. 对网站域名协议的要求

出于对用户安全、隐私等问题的考虑，浏览器限制网页在 HTTPS 协议下才能正常使用本文档中所对接组件的全部功能。为确保生产环境中的用户能够顺畅体验产品功能，请将您的网站部署在 https:// 协议的域名下。

<table>
<thead><tr><th>应用场景</th><th>协议</th><th>接收（播放）</th><th>发送（上麦）</th><th>屏幕分享</th><th>备注</th></tr></thead>
<tbody><tr>
<td>生产环境</td>
<td>HTTPS 协议</td>
<td>支持</td>
<td>支持</td>
<td>支持</td>
<td>推荐</td>
</tr><tr>
<td>生产环境</td>
<td>HTTP 协议</td>
<td>支持</td>
<td>不支持</td>
<td>不支持</td>
<td>-</td>
</tr><tr>
<td>本地开发环境</td>
<td>http://localhost</td>
<td>支持</td>
<td>支持</td>
<td>支持</td>
<td>推荐</td>
</tr><tr>
<td>本地开发环境</td>
<td>http://127.0.0.1</td>
<td>支持</td>
<td>支持</td>
<td>支持</td>
<td>-</td>
</tr><tr>
<td>本地开发环境</td>
<td>http://[本机IP]</td>
<td>支持</td>
<td>不支持</td>
<td>不支持</td>
<td>-</td>
</tr><tr>
<td>本地开发环境</td>
<td align="left">file:///</td>
<td>支持</td>
<td>支持</td>
<td>支持</td>
<td>-</td>
</tr>
</tbody></table>


## 步骤一：开通服务

TUICallKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务并体验 7 天的免费试用服务：

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。

<img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/1105c3c339be4f71d72800fe2839b113.png"/> 

2. 单击刚刚创建出的应用，进入**基本配置**页面，并在页面的右下角找到**开通腾讯实时音视频服务**功能区，单击**免费体验**即可开通 TUICallKit 的 7 天免费试用服务。

<img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/667633f7addfd0c589bb086b1fc17d30.png"/> 

3. 在同一页面找到 **SDKAppID** 和**密钥**并记录下来，它们会在后续中被用到。

<img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/e435332cda8d9ec7fea21bd95f7a0cba.png"/> 

- SDKAppID：IM 的应用 ID，用于业务隔离，即不同的 SDKAppID 的通话彼此不能互通；
- Secretkey：IM 的应用密钥，需要和 SDKAppID 配对使用，用于签出合法使用 IM 服务的鉴权用票据 UserSig，我们会在接下来的步骤五中用到这个 Key。

## 步骤二：创建项目

使用 vite 创建 Vue3 + TypeScript 项目。

```shell
yarn create vite
```

## 步骤三：下载 TUICallKit 组件

从 [GitHub 下载](https://github.com/tencentyun/TUICallKit/tree/main/Web) TUICallKit 源码。复制 TUICallKit 文件夹放置到自己到工程的 src/components 文件夹中，例如：

<img style="width:300px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/5e8f3f59976fe14bdfd6e5da163b3316.png"/> 

## 步骤四：生成 UserSig

1. 从 [GitHub 下载](https://github.com/TencentCloud/TIMSDK/tree/master/Web/Demo) `GenerateTestUserSig` 工具包，并复制到项目中，例如：

<img style="width:300px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/e979e5fee4995de7326504b3c1fcb0b2.png"/>

2. 在 `index.html` 中引入 `lib-generate-test-usersig.min.js`

```javascript
<script src="/public/debug/lib-generate-test-usersig.min.js"> </script>
```

3. 设置 `GenerateTestUserSig` 文件中的相关参数，其中 SDKAppID 和密钥等信息，可通过 [即时通信 IM 控制台](https://console.cloud.tencent.com/im) 获取，单击目标应用卡片，进入应用的基础配置页面。例如：

<img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/480455e5b4a2a1d4d67ffb2e445452a6.png"/>


4. 在基本信息区域，单击显示密钥，复制并保存密钥信息至 `GenerateTestUserSig` 文件。 

<img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/bbb093bfc7343a626dd8bc6f3d4cabf7.png"/> 

> 本文提到的获取 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通功能调试**。 正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig)。

## 步骤五：下载 TUICallKit 组件依赖

```shell
cd src/components/TUICallKit
yarn
```

## 步骤六：调用 TUICallKit 组件
在需要展示的页面，调用 TUICallKit 的组件即可展示通话页面。
例如：在 App.vue 页面中，配置简单的登录账户后，便可拨打通话。

```javascript
<script lang="ts" setup>
import { onMounted, ref, nextTick } from "vue";
import { TUICallKit, TUICallKitServer } from "./components/TUICallKit";
import { genTestUserSig, SDKAPPID as SDKAppID } from "../public/debug";

const loginStatus = ref("未登录");

async function login(userID: string) {
  await nextTick();
  const { userSig } = genTestUserSig(userID);
  await TUICallKitServer.init({ SDKAppID, userID, userSig });
  loginStatus.value = userID;
}

async function startCall(userID: string, type: number) {
  await TUICallKitServer.call({ userID, type });
};

</script>
  
<template>
  <span>已登陆账户：({{ loginStatus }}) </span>
  <button v-if="loginStatus === '未登录'" @click="login('sample_1')"> 登录 sample_1 </button>
  <button v-if="loginStatus === '未登录'" @click="login('sample_2')"> 登录 sample_2 </button>
  <button v-if="loginStatus !== '未登录'"> <a href="/" target="_blank"> 打开新窗口登录其他账号 </a></button>
  <br>
  <button @click="startCall('sample_1', 2)" v-if="loginStatus !== 'sample_1'"> 给(sample_1)拨打视频电话 </button>
  <button @click="startCall('sample_2', 2)" v-if="loginStatus !== 'sample_2'"> 给(sample_2)拨打视频电话 </button>

  <div class="call-kit-container">
    <TUICallKit />
  </div>
</template>
  
<style scoped>
.call-kit-container {
  width: 50rem;
  height: 35rem;
  border-radius: 16px;
  box-shadow: rgba(0, 0, 0, 0.16) 0px 3px 6px, rgba(0, 0, 0, 0.23) 0px 3px 6px;
}
</style>
```

## 步骤七：启动项目
```shell
yarn dev
```

## 常见问题
### 1. 如何生成 UserSig？

UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向项目的接口，在需要 UserSig 时由您的项目向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig)。

