# TUICallEngine web 示例工程快速跑通

本文主要介绍如何快速跑通 Web 版本的 TUICallEngine Demo，Demo 中包括语音通话和视频通话场景：

\- 语音通话：纯语音交互，支持多人互动语音聊天。

\- 视频通话：视频通话，面向在线客服等需要面对面交流的沟通场景。
## 环境要求
请使用最新版本的 Chrome 浏览器。目前桌面端 Chrome 浏览器支持 TRTC Web SDK 的相关特性比较完整，因此建议使用 Chrome 浏览器进行体验。

TUICallEngine 依赖以下端口进行数据传输，请将其加入防火墙白名单。

- **TCP 端口**：8687
- **UDP 端口**：8000，8080，8800，843，443，16285
- **域名**：qcloud.rtc.qq.com，具体请参见 [应对防火墙限制相关](https://cloud.tencent.com/document/product/647/34399)。
- **平台支持**：目前该方案支持如下平台


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

- **URL 域名协议限制**：
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

## 前提条件

###  开通服务

TUICallKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务并体验 7 天的免费试用服务：

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。
![](https://qcloudimg.tencent-cloud.cn/raw/1105c3c339be4f71d72800fe2839b113.png)
2. 单击刚刚创建出的应用，进入**基本配置**页面，并在页面的右下角找到**开通腾讯实时音视频服务**功能区，单击**免费体验**即可开通 TUICallKit 的 7 天免费试用服务。
![](https://qcloudimg.tencent-cloud.cn/raw/667633f7addfd0c589bb086b1fc17d30.png)
1. 在同一页面找到 **SDKAppID** 和**密钥**并记录下来，它们会在后续中被用到。
![](https://qcloudimg.tencent-cloud.cn/raw/e435332cda8d9ec7fea21bd95f7a0cba.png)
    - SDKAppID：IM 的应用 ID，用于业务隔离，即不同的 SDKAppID 的通话彼此不能互通；
    - Secretkey：IM 的应用密钥，需要和 SDKAppID 配对使用，用于签出合法使用 IM 服务的鉴权用票据 UserSig，我们会在接下来的步骤五中用到这个 Key。

### 复用 Demo 的 UI 界面


<span id="step1"></span>

#### 步骤1：下载 SDK 和 Demo 源码
  点击【[Github](https://github.com/tencentyun/TUICalling)】跳转至 Github，下载 Demo 源码。

<span id="step2"></span>

#### 步骤2：配置 Demo 工程文件

1. 找到并打开`Web/public/debug/GenerateTestUserSig.js`和 `Web/src/config/index.js` 文件。

2. 设置`GenerateTestUserSig.js`和`config/index.js` 文件中的相关参数：

  <ul><li>SDKAPPID：默认为0，请设置为实际的 SDKAppID。</li>

  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul> 

  <img src="https://main.qcloudimg.com/raw/0ae7a197ad22784384f1b6e111eabb22.png">


>本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此****该方法仅适合本地跑通 Demo 和功能调试****。

>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

<span id="step3"></span>

#### 步骤3：运行 Demo
>- 同步依赖： npm install
>- 启动项目： npm run serve
>- 浏览器中打开链接：http://localhost:8080/

### 实现自定义 UI 界面
#### 步骤1：集成 SDK
NPM 集成
>- 为了减小 tuicall-engine-webrtc.js 的体积，避免和接入侧已使用的 trtc-js-sdk 和 tim-js-sdk 以及 tsignaling 发生版本冲突，trtc-js-sdk、 tim-js-sdk 、tsignaling 和 tuicall-engine-webrtc.js，在使用前您需要手动安装依赖。
```javascript
  npm i trtc-js-sdk --save
  npm i tim-js-sdk --save
  npm i tsignaling --save
  npm i tuicall-engine-webrtc --save

  import { TUICallEngine, TUICallEvent, TUICAllType } from "tuicall-engine-webrtc"

Script 集成 
  如果您通过 script 方式使用 tuicall-engine-webrtc，需要按顺序先手动引入 trtc.js、tim-js.js、tsignaling.js、tuicall-engine-webrtc.js
  <script src="./trtc.js"></script>
  <script src="./tim-js.js"></script>
  <script src="./tsignaling.js"></script>s
  <script src="./trtc-calling-js.js"></script>
  const { TUICallEngine, TUICallEvent, TUICAllType } = window['tuicall-engine-webrtc']
```

#### 步骤2：创建 TUICallEngine 实例
>- sdkAppID: 您从腾讯云申请的 sdkAppID
```javascript
let options = {
  SDKAppID: 0, // 接入时需要将 0 替换为您的云通信应用的 SDKAppID
  tim: tim     // tim 参数适用于业务中已存在 TIM 实例，为保证 TIM 实例唯一性
};
let tuiCallEngine = TUICallEngine.createInstance(options);
```
**参数说明**：
- SDKAppID：在步骤一中的最后一步中您已经获取到，这里不再赘述。
- tim：非必填项，若您没有，将会由内部代码自动创建。

#### 步骤3：登录
>- userID: 用户 ID
>- userSig: 用户签名，计算方式参见[如何计算 userSig](https://cloud.tencent.com/document/product/647/17275)
```javascript
tuiCallEngine.login({  // 登陆事件
    userID,
    userSig,
}).then( res => {
    // success
}).catch( error => {
    console.warn('login error:', error);
});
```

#### 步骤4：事件监听

```javascript
function initListener() {       // 绑定事件
    // 呼叫远端用户
    tuiCallEngine.on(TUICallEvent.INVITED, this.handleNewInvitationReceived);
    // 远端用户接听
    tuiCallEngine.on(TUICallEvent.USER_ACCEPT, this.handleUserAccept);
    // 远端用户拒绝
    tuiCallEngine.on(TUICallEvent.REJECT, this.handleInviteeReject);
    // ...
}
function removeListener() {     // 取消绑定事件
    tuiCallEngine.off(TUICallEvent.INVITED, this.handleNewInvitationReceived);
    tuiCallEngine.off(TUICallEvent.USER_ACCEPT, this.handleUserAccept);
    tuiCallEngine.off(TUICallEvent.REJECT, this.handleInviteeReject);
    // ...
}
async function handleNewInvitationReceived(payload) { }
function handleUserAccept() { }
function handleInviteeReject() { }
```

#### 步骤5：实现 1v1 通话
- 主叫方：呼叫某个用户
    ```javascript
    tuiCallEngine.call({
        userID,  //用户 ID
        type: 2, //通话类型，0-未知， 1-语音通话，2-视频通话
    }).then( res => {
        // success
    }).catch( error => {
        console.warn('call error:', error);
    });
    ```
    | 参数 | 类型 | 含义 |
    |-----|-----|-----|
    | userID | String | 被邀请方 userID|
    | type | Number | 0-未知， 1-语音通话，2-视频通话|


- 被叫方：接听新的呼叫
    ```javascript
    // 接听通话
    tuiCallEngine.accept().then( res => {
        // success
    }).catch( error => {
        console.warn('accept error:', error);
    });
    // 拒绝通话
    tuiCallEngine.reject().then( res => {
        // success
    }).catch( error => {
        console.warn('reject error:', error);
    });
    ```
- 展示远端的视频画面
    ```javascript
    tuiCallEngine.startRemoteView({
        userID, //远端用户 ID
        videoViewDomID //该用户数据将渲染到该 DOM ID 节点里
    }).then( res => {
        // success
    }).catch( error => {
        console.warn('startRemoteView error:', error);
    });
    ```
    | 参数 | 类型 | 含义 |
    |-----|-----|-----|
    | userID | String | 远端用户 ID|
    | videoViewDomID | String | 该用户数据将渲染到该 DOM ID 节点里|

- 展示本地的预览画面
    ```javascript
    tuiCallEngine.startLocalView({
        userID, //本地用户 ID
        videoViewDomID //该用户数据将渲染到该 DOM ID 节点里
    }).then( res => {
        // success
    }).catch( error => {
        console.warn('startLocalView error:', error);
    });
    ```
    | 参数 | 类型 | 含义 |
    |-----|-----|-----|
    | userID | String | 本地用户 ID|
    | videoViewDomID | String | 该用户数据将渲染到该 DOM ID 节点里|

- 挂断
    ```javascript
    tuiCallEngine.hangup().then( res => {
        // success
    }).catch( error => {
        console.warn('hangup error:', error);
    });
    ```


#### 步骤6：更多特性

### 一. 设置昵称&头像
如果您需要自定义昵称或头像，可以使用该接口进行更新。
```javascript
tuiCallEngine.setSelfInfo({
  nickName: 'video', 
  avatar:'http(s)://url/to/image.jpg'
}).then( res => {
    // success
}).catch( error => {
    console.warn('setSelfInfo error:', error);
});
```
| 参数 | 类型 | 含义 |
|-----|-----|-----|
| nickName | String | 要设置的用户昵称 |
| avatar | String | 头像链接 |

### 二. 群组通话
如果您想要实现群组通话，可通过该接接口以 C2C 的方式实现群组通话。
```javascript
tuiCallEngine.groupCall({
  userIDList: ['user1', 'user2'], 
  type: 1, 
  groupID: 'IM群组 ID', 
}).then( res => {
    // success
}).catch( error => {
    console.warn('groupCall error:', error);
});
```

| 参数 | 类型 | 含义 |
|-----|-----|-----|
| userIDList | Array | 邀请列表 |
| type | Number | 0-未知， 1-语音通话，2-视频通话 |
| groupID | String | IM 群组 ID (选填) |

>? 
>1. 群组的创建详见：[ IM 群组管理](https://cloud.tencent.com/document/product/269/75394#.E5.88.9B.E5.BB.BA.E7.BE.A4.E7.BB.84) ，或者您也可以直接使用 [IM TUIKit](https://cloud.tencent.com/document/product/269/37059)，一站式集成聊天、通话等场景。
>2. TUICallKit 目前还不支持发起非群组的多人视频通话，如果您有此类需求，欢迎反馈： [TUICallEngine 需求收集表]()。

### 三、切换摄像头和麦克风设备
如果您需要切换摄像头（麦克风）为外接摄像头或其他，可通过该接口实现。
```javascript
tuiCallEngine.switchDevice({
  deviceType: 'video', 
  deviceId: cameras[0].deviceId
}).then( res => {
    // success
}).catch( error => {
    console.warn('switchDevice error:', error);
});
```
| 参数 | 类型 | 含义 |
|-----|-----|-----|
| deviceType | string | 需要切换的设备类型|
| deviceId | string | 需要切换的设备ID|


### 四、设置视频质量
如果您需要设置视频质量，使视频更加流畅，可通过该接口实现。
```javascript
const profile = '720p';
tuiCallEngine.setVideoQuality(profile)
.then( res => {
    // success
}).catch( error => {
    console.warn('setVideoQuality error:', error);
});
```
|视频 Profile | 分辨率（宽 x 高）|
|-----|-----|
|480p|640 x 480|
|720p|1280 x 720|
|1080p|1920 x 1080|

## 文档链接
- [TUICallEngine API 概览](https://tcloud-doc.isd.com/document/product/647/78756)
- [常见问题](https://tcloud-doc.isd.com/document/product/647/78769)