# TUICallkit 组件接入说明

本文将介绍如何用最短的时间完成 TUICallKit 组件的接入，跟随本文档，您将在一个小时的时间内完成如下几个关键步骤，并最终得到一个包含完备 UI 界面的视频通话功能。

## 环境准备

- 微信 App iOS 最低版本要求：7.0.9
- 微信 App Android 最低版本要求：7.0.8
- 小程序基础库最低版本要求：2.10.0
- 由于小程序测试号不具备 <live-pusher> 和 <live-player> 的使用权限，请使用企业小程序账号申请相关权限进行开发
- 由于微信开发者工具不支持原生组件（即 <live-pusher> 和 <live-player> 标签），需要在真机上进行运行体验

## 特性
- ⚡️ 功能全面 —— 支持单人/多人/音频/视频通话、支持视频转音频通话、支持自由选择通话设备
- 🎨 灵活样式 —— 组件开源，可复用逻辑，自定义 UI 样式
- 🛠 优秀生态 —— 与 TUIKit 协同使用，可以在 TIM 会话中直接发起音视频通话
- 🌍 跨平台 —— 支持 Android、iOS、Web、小程序、Flutter、UniApp 等多个开发平台
- ☁️ 低延迟 —— 腾讯云全球链路资源储备，保证国际链路端到端平均时延 < 300ms
- 🤙🏻 低卡顿 —— 抗丢包率超过 80%、抗网络抖动超过 1000ms，弱网环境仍顺畅稳定
- 🌈 高品质 —— 支持 720P、1080P 高清画质，70% 丢包率仍可正常视频


## 使用指引

为方便您的使用，本组件配套多篇使用指引：

- 如果您想要了解TUiCallKit，请阅读 [组件介绍 TUICallKit](https://cloud.tencent.com/document/product/647/78742)

- 如果您想把我们的功能直接嵌入到您的项目中，请阅读 [快速接入 TUICallKit](https://cloud.tencent.com/document/product/647/78912)

- 如果您想要了解详细 API ，请阅读 [ API 概览](https://cloud.tencent.com/document/product/647/78759)


## 示例体验
`Tips：TUICallKit 通话体验，至少需要两台设备，如果用户A/B分别代表两台不同的设备：`

**用户 A（userId：111）**

- 步骤 1：在欢迎页，输入用户名(<font color=red>请确保用户名唯一性，不能与其他用户重复</font>)，比如111； 

- 步骤 2：根据不同的场景&业务需求，进入不同的场景界面，比如视频通话；

- 步骤 3：输入要拨打的用户B的userId，点击搜索，然后点击呼叫；

  | 步骤1 | 步骤2 | 步骤3 | 
  |---------|---------|---------|
  |<img src="https://qcloudimg.tencent-cloud.cn/raw/1ded4a7bba09e0c1d4d7096bb09cde95.jpg" width="240"/>|<img src="https://qcloudimg.tencent-cloud.cn/raw/305ba8bdee2dd3f99ef4b75675b3a1c9.jpg" width="240">|<img src="https://qcloudimg.tencent-cloud.cn/raw/9f224a47f95bd91f49bd3e4ad91f485d.jpg" width="240"/>

**用户 B（userId：222）**

- 步骤 1：在欢迎页，输入用户名(<font color=red>请确保用户名唯一性，不能与其他用户重复</font>)，比如222；
- 步骤 2：进入主页，等待接听来电即可；


## 接入指引
### 步骤一：开通小程序权限
由于 TUICallKit 所使用的小程序标签有更苛刻的权限要求，因此集成 TUICallKit 的第一步就是要开通小程序的类目和标签使用权限，**否则无法使用**，这包括如下步骤：

- 小程序推拉流标签不支持个人小程序，只支持企业类小程序。需要在 [注册](https://developers.weixin.qq.com/community/business/doc/000200772f81508894e94ec965180d) 时填写主体类型为企业，如下图所示：
  ![img](https://qcloudimg.tencent-cloud.cn/raw/a30f04a8983066fb9fdf179229d3ee31.png)
- 小程序推拉流标签使用权限暂时只开放给有限 [类目](https://developers.weixin.qq.com/miniprogram/dev/component/live-pusher.html)。
- 符合类目要求的小程序，需要在 **[微信公众平台](https://mp.weixin.qq.com/)** > **开发** > **开发管理** > **接口设置**中自助开通该组件权限，如下图所示：
  ![img](https://main.qcloudimg.com/raw/dc6d3c9102bd81443cb27b9810c8e981.png)


### 步骤二：在小程序控制台配置域名
在 **[微信公众平台](https://mp.weixin.qq.com/)** > **开发** > **开发管理** > **开发设置** > **服务器域名**中设置 **request 合法域名** 和 **socket 合法域名**，如下图所示：
- **request 合法域名**：
```javascript
https://official.opensso.tencent-cloud.com
https://yun.tim.qq.com
https://cloud.tencent.com
https://webim.tim.qq.com
https://query.tencent-cloud.com
https://web.sdk.qcloud.com
```
- **socket 合法域名**：
```javascript
wss://wss.im.qcloud.com
wss://wss.tim.qq.com
```
![img](https://qcloudimg.tencent-cloud.cn/raw/a79ca9726309bb1fdabb9ef8961ce147.png)


### 步骤三：开通服务

TUICallKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务并体验 7 天的免费试用服务：

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。

<img width="640" src="https://qcloudimg.tencent-cloud.cn/raw/1105c3c339be4f71d72800fe2839b113.png">

2. 单击刚刚创建出的应用，进入**基本配置**页面，并在页面的右下角找到**开通腾讯实时音视频服务**功能区，单击**免费体验**即可开通 TUICallKit 的 7 天免费试用服务。如果需要正式应用上线，可以单击 [**前往加购**](https://buy.cloud.tencent.com/avc) 即可进入购买页面。

<img width="640" src="https://user-images.githubusercontent.com/72854065/205876830-6c8f119e-8d3c-4f1e-b8d3-0a21788fc47a.png">

> IM 音视频通话能力针对不同的业务需求提供了差异化的付费版本供您选择，您可以在 [IM 购买页](https://buy.cloud.tencent.com/avc) 了解包含功能并选购您适合的版本。

3. 在同一页面找到 **SDKAppID** 和**密钥**并记录下来
- SDKAppID：IM 的应用 ID，用于业务隔离，即不同的 SDKAppID 的通话彼此不能互通。
- Secretkey：IM 的应用密钥，需要和 SDKAppID 配对使用，用于签出合法使用 IM 服务的鉴权用票据 UserSig。

<img width="640" src="https://qcloudimg.tencent-cloud.cn/raw/e435332cda8d9ec7fea21bd95f7a0cba.png">

> 即日起至2022年10月01日0点前，购买音视频通话能力包基础版可获赠解锁相同有效期的小程序端通话功能授权。在活动结束前购买的音视频通话能力包在有效期内不受活动结束影响仍可使用小程序通话功能，活动结束后的新购或续期需选择体验版、进阶版、尊享版来获取小程序通话功能授权，基础版亦可单独加购小程序功能授权进行解锁。


> 单击**免费体验**以后，部分之前使用过 [实时音视频 TRTC]
(https://cloud.tencent.com/document/product/647/16788) 服务的用户会提示：
```
[-100013]:TRTC service is  suspended. Please check if the package balance is 0 or the Tencent Cloud accountis in arrears
```
因为新的 IM 音视频通话能力是整合了腾讯云[实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 和 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 两个基础的 PaaS 服务，所以当 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 的免费额度（10000分钟）已经过期或者耗尽，就会导致开通此项服务失败，这里您可以单击 [TRTC 控制台](https://console.cloud.tencent.com/trtc/app)，找到对应 SDKAppID 的应用管理页，示例如图，开通后付费功能后，再次**启用应用**即可正常体验音视频通话能力。

<img width=800px src="https://qcloudimg.tencent-cloud.cn/raw/f74a13a7170cf8894195a1cae6c2f153.png" />


### 步骤四：下载并导入 TUICallKit 组件
选择克隆/下载代码，将项目中的 wxcomponents 中的 TUICallKit 文件夹复制到自己项目的 wxcomponents 中。

<img width="640" src="https://qcloudimg.tencent-cloud.cn/raw/3409e06c1713d3c0dbf44d26bcffb30d.png">


### 步骤五：创建并初始化 TUICallKit 组件库
1. 创建 TIM 实例 （如果您不需要 TIM 实例，可忽略）
在 app.vue 中，如果您需要使用 tim，请引用 TUICallKit 内部的tim-wx-sdk
```javascript
  // 这里需要使用commonJS来引用
  const TIM = require('./wxcomponents/TUICallKit/lib/tim-wx-sdk')
	onLaunch() {
		// 重点注意： 为了 uni-app 更好地接入使用 tim，快速定位和解决问题，请勿修改 uni.$TUIKit 命名。
		// 如果您已经接入 tim ，请将 uni.tim 修改为 uni.$TUIKit。
		uni.$TUIKit = TIM.create({
			SDKAppID: 0, // 替换为您自己账号下的 SDKAppId
		});
		uni.$TIM = TIM
	};
```


2. **添加组件到需要使用 TUICallKit 的页面**，例如示例代码中的 `pages.json文件`：
```javascript
// 可参考 pages.json文件
{
			"path": "pages/calling/call",
			"style": {
				"navigationBarTitleText": "uni-app",
				"usingComponents": {
					"tuicallkit": "/wxcomponents/TUICallKit/TUICallKit/TUICallKit"
				}
			}
},
```
3. **在需要使用 TUICallKit 的页面中引入组件。**，例如示例代码中的 `pages/calling/call.vue`：
```javascript
// 可参考 pages/calling/call.vue
<tuicallkit ref="TUICallKit"></tuicallkit>
```

4. **在生命周期函数中初始化 TUICallKit**
```javascript
import { nextTick, shallowRef, reactive } from 'vue';
let TUICallKit = shallowRef(null);

onLoad(() => {
    nextTick(() => {
        TUICallKit.value.init({
            sdkAppID: 0, // 替换为您自己账号下的 SDKAppId
            userID: 'jane',   // 填写当前用的 userID
            userSig: 'xxxxxxxxxxxx', // 通过 genTestUserSig(userID) 生成
            tim: uni.$TUIKit,   //  如果您不需要 TIM 实例，可忽略
        })
    })
});
```
init参数
| 参数 | 类型 | 说明 | 是否必传 |
|---------|---------|---------|---------|
| sdkAppID | String | IM 的应用 ID | 是 |
| userId    | String | 当前用户的 ID | 是 |
| userSig | String | 鉴权的票据 | 是 |
| type | Number | 通话的媒体类型 | 否 |
| tim | Any | TIM 实例 | 否 |


 这里详细介绍一下 init 中的几个参数：
- sdkAppID：在步骤三中您已经获取到，这里不再赘述。
- userId：当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（_）。
- userSig：使用步骤三中获取的 SecretKey 对 sdkAppID、userId 等信息进行加密，就可以得到 UserSig，它是一个鉴权用的票据，用于腾讯云识别当前用户是否能够使用 TRTC 的服务，更多信息请参见 [如何计算及使用 UserSig](https://cloud.tencent.com/document/product/647/17275)。
- tim 可以将外部的 tim 实例通过 init 透传给 callkit ，tim 参数适用于业务中已存在 TIM 实例，为保证 TIM 实例唯一性

5. **生命周期函数中监听页面卸载**
```javascript
onUnload() {
	 TUICallKit.value.destroyed();
},
```

### 步骤六：发起视频通话请求
在 JS 逻辑交互例如 `pages/index/index.js` 中填写如下代码，就可以实现一对一视频通话。
```javascript
// 发起1对1视频通话，假设被邀请人的userId为: user1, type 1：语音通话，2：视频通话。
TUICallKit.value.call({ userID: 'user1', type:2 })
```

### 步骤七：更多特性
#### 设置昵称&头像
如果您需要自定义昵称或头像，可以使用如下接口进行更新：
```javascript
TUICallKit.value.setSelfInfo("昵称", "头像 URL");
```


## 附录

- 如果你遇到了困难，可以先参阅 [常见问题](https://cloud.tencent.com/document/product/647/78912)；
- 如果发现了示例代码的 bug，欢迎提交 issue；
- 欢迎加入 QQ 群：**646165204**，进行技术交流和反馈~