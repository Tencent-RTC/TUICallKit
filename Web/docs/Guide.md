# TUICallKit 组件快速接入

本文将介绍如何用最短的时间完成 TUICallKit 组件的接入，跟随本文档，您将完成如下几个关键步骤，并最终得到一个包含完备 UI 界面的视频通话功能。

若您想体验组件效果，可参考[TUICallKit demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic/README.md)。

在接入前请检查您的桌面浏览器是否支持音视频服务，详细要求可参考[环境要求](#3-环境要求)。

## 目录
* [步骤一：开通服务](#步骤一：开通服务)
* [步骤二：引入 TUICallKit 组件](步骤二：引入-TUICallKit-组件)
* [步骤三：生成 UserSig](#步骤三：生成-UserSig)
* [步骤四：调用 TUICallKit 组件](#步骤四：调用-TUICallKit-组件)
* [其他文档](#其他文档)
* [常见问题](#常见问题)
  + [1. 如何生成 UserSig？](#1-如何生成-UserSig？)
  + [2. vite 引入问题](#2-vite-引入问题)
  + [3. 环境要求](#3-环境要求)
    - [(1) 对浏览器版本要求](#(1)-对浏览器版本要求)
    - [(2) 对网络环境的要求](#(2)-对网络环境的要求)
    - [(3) 对网站域名协议的要求](#(3)-对网站域名协议的要求)

## 步骤一：开通服务

TUICallKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务并体验 7 天的免费试用服务：

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。

<!-- <img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/1105c3c339be4f71d72800fe2839b113.png"/>  -->

<div align="center">

<img style="width:600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194734917-3173e280-6f94-4cdb-92e4-9b8c8905abfd.png"/> 

</div>

2. 单击刚刚创建出的应用，进入**基本配置**页面，并在页面的右下角找到**开通腾讯实时音视频服务**功能区，单击**免费体验**即可开通 TUICallKit 的 7 天免费试用服务。

<div align="center">
<!-- <img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/667633f7addfd0c589bb086b1fc17d30.png"/>  -->

<img style="width:600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194734939-f649f891-e45b-4efc-aaa3-d063e382d466.png"/> 
</div>

3. 在同一页面找到 **SDKAppID** 和**密钥**并记录下来，它们会在后续中被用到。

<!-- <img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/e435332cda8d9ec7fea21bd95f7a0cba.png"/>  -->

<div align="center">

<img style="width:600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735234-8a3cc361-accb-41e4-8066-c8d7c88d2927.png"/> 
</div>

- SDKAppID：IM 的应用 ID，用于业务隔离，即不同的 SDKAppID 的通话彼此不能互通；
- Secretkey：IM 的应用密钥，需要和 SDKAppID 配对使用，用于签出合法使用 IM 服务的鉴权用票据 UserSig，我们会在接下来的步骤五中用到这个 Key。

## 步骤二：引入 TUICallKit 组件

1. 从 [GitHub 下载](https://github.com/tencentyun/TUICallKit/tree/main/Web) TUICallKit 源码。复制 `TUICallKit/Web` 文件夹放置到自己到工程的 `src/components` 文件夹中，例如：

<!-- <img style="width:300px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/e4699aaa507aa4618034463225f72cb2.png"/>  -->

<div align="center">

<img style="width:300px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735247-3cbe30c6-37ab-43a4-97f0-27b8e40140cf.png"/> 
</div>

2. 进入此文件夹中，安装运行所需依赖
```shell
cd ./src/components/TUICallKit/Web 
yarn         # 如果你没装过 yarn, 可以先运行: npm install -g yarn
```

## 步骤三：生成 UserSig

若已生成 UserSig，可跳过本步骤至 [步骤四](#步骤四：调用-TUICallKit-组件)

1. 设置初始化的相关参数，其中 SDKAppID 和密钥等信息，可通过 [即时通信 IM 控制台](https://console.cloud.tencent.com/im) 获取，单击目标应用卡片，进入应用的基础配置页面。例如：

<!-- <img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/480455e5b4a2a1d4d67ffb2e445452a6.png"/> -->

<div align="center">
<img style="width:600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735288-d96dd384-7bb3-479b-aff0-171888a9e15a.png"/>
</div>

2. 在基本信息区域，单击显示密钥，复制并保存密钥信息至 `TUICallKit/Web/demos/basic/public/debug/GenerateTestUserSig.js` 文件。 

<!-- <img style="width:600px; max-width: inherit;" src="https://qcloudimg.tencent-cloud.cn/raw/bbb093bfc7343a626dd8bc6f3d4cabf7.png"/>  -->
<div align="center">

<img style="width:600px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/194735315-ae423867-b4cf-49c9-b542-761f6525882a.png"/> 
</div>

3. 在步骤四中，即可使用 `GenerateTestUserSig.js` 中 `genTestUserSig(userID)` 函数来计算 userSig，例如：

```javascript
import * as GenerateTestUserSig from "../public/debug/GenerateTestUserSig.js";
const { userSig } = GenerateTestUserSig.genTestUserSig(userID);
```

4. 若您使用 vite 作为启动工具，还需注意 [vite 引入问题](#2-vite-引入问题)

> 发布前请务必删除此文件，本文提到的获取 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通功能调试**。 正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig)。

## 步骤四：调用 TUICallKit 组件

在需要展示的页面，调用 TUICallKit 的组件即可展示通话页面。

1. TUICallKit UI 引入，例如：

```js
<script lang="ts" setup>
import { TUICallKit } from "./src/components/TUICallKit/Web";
</script>
  
<template>
  <TUICallKit />
</template>
```

2. 登录用户与拨打电话

若您已使用 [TUIKit](https://cloud.tencent.com/document/product/269/79737) 套件，则需引入下方代码，声明 TUICallKit 为插件；若未使用，则不需要引入下方代码

```javascript
import { TUICallKit } from './src/components/TUICallKit/Web/src/index';
TUIKit.use(TUICallKit); 
```

之后，可以在需要登录的地方，执行：

```javascript
import { TUICallKitServer } from './src/components/TUICallKit/Web/src/index';
TUICallKitServer.init({ SDKAppID, userID, userSig }); 
```
>  userSig 可在[步骤三](#步骤三：生成-UserSig)中获取

在需要拨打电话的地方，执行：

```javascript
import { TUICallKitServer } from './src/components/TUICallKit/Web/src/index';
TUICallKitServer.call({ userID, type }); // 双人通话
TUICallKitServer.groupCall({ userIDList, groupID, type }); // 多人通话
```

之后就可以成功拨打您的第一通电话了～更详解接口参数可参考[接口文档](https://cloud.tencent.com/document/product/647/81015)

3. 进阶接口

本组件提供了 `beforeCalling` 和 `afterCalling` 两个回调，可以用于通知业务侧当前通话状态，

- `beforeCalling`: 通话前会执行
- `afterCalling`: 通话后执行

例如可用来进行 `<TUICallKit />` 组件的展开与折叠，如[示例 demo](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic/src/App.vue)。

```javascript
function beforeCalling() {
  console.log("通话前 会执行此函数");
}
function afterCalling() {
  console.log("通话后 会执行此函数");
}
```

```html
<TUICallKit :beforeCalling="beforeCalling" :afterCalling="afterCalling"/>
```

## 其他文档

- [TUICallKit API](https://cloud.tencent.com/document/product/647/81015)
- [TUICallKit demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic/README.md)
- [TUICallKit 界面定制指引](https://cloud.tencent.com/document/product/647/81014)
- [TUICallKit (Web) 常见问题](https://cloud.tencent.com/document/product/647/78769)
- 欢迎加入 QQ 群：**646165204**，进行技术交流和反馈~

## 常见问题
### 1. 如何生成 UserSig？

UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向项目的接口，在需要 UserSig 时由您的项目向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig)。

### 2. vite 引入问题

如果您的项目由 vite 创建，由于文件打包差异，需要在 `index.html` 中引入 `lib-generate-test-usersig.min.js`

```javascript
// index.html
<script src="/public/debug/lib-generate-test-usersig.min.js"> </script>
```

并将原来 `GenerateTestUserSig.js` 中 import 引入的方式注释

```javascript
// import * as LibGenerateTestUserSig from './lib-generate-test-usersig.min.js'
```

### 3. 环境要求

#### (1) 对浏览器版本要求

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

#### (2) 对网络环境的要求

在使用 TUICallKit 时，用户可能因防火墙限制导致无法正常进行音视频通话，请参考 [应对防火墙限制相关](https://cloud.tencent.com/document/product/647/34399) 将相应端口及域名添加至防火墙白名单中。

#### (3) 对网站域名协议的要求

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


