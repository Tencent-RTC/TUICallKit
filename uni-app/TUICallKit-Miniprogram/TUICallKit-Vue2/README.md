## 简介
本 demo 演示了如何在 uni-app 项目中集成 [TUICallKit](https://www.npmjs.com/package/@trtc/calls-uikit-wx-uniapp) 音视频通话组件。


## 环境准备

- 微信 App iOS 最低版本要求：8.0.40
- 微信 App Android 最低版本要求：8.0.40
- 小程序基础库最低版本要求：2.10.0
- 由于小程序测试号不具备 <live-pusher> 和 <live-player> 的使用权限，请使用企业小程序账号申请相关权限进行开发
- 由于微信开发者工具不支持原生组件（即 <live-pusher> 和 <live-player> 标签），需要在真机上进行运行体验


## 快速跑通
第一步：下载源码，编译运行
1. 克隆或者直接下载此仓库源码。
   ```
   git clone https://github.com/tencentyun/TUICallKit.git
   ```
2. 进入 demo 目录
   ```
   cd ./TUICallKit/uni-app/TUICallKit-Miniprogram/TUICallKit-Vue2
   ```
3. 安装依赖
   ```
   npm install
   ```
   
   mac端
   ```
   mkdir -p ./TUICallKit && cp -r node_modules/@trtc/calls-uikit-wx-uniapp/ ./TUICallKit && cp node_modules/@trtc/call-engine-lite-wx/RTCCallEngine.wasm.br ./static
   ```

   windows端
   ```
   xcopy node_modules\@trtc\calls-uikit-wx-uniapp\ .\TUICallKit /i /e
   xcopy node_modules\@trtc\call-engine-lite-wx\RTCCallEngine.wasm.br .\static
   ```

4. HBuilder 中导入项目
   
   <img src="https://web.sdk.qcloud.com/component/trtccalling/images/miniProgram/hbuilder-vue.png" width="400" align="middle" />

5. 修改 `./TUICallKit/uni-app/TUICallKit-Miniprogram/TUICallKit-Vue2/TUICallKit/debug/GenerateTestUserSig-es.js` 文件 的 SDKAPPID 以及 SECRETKEY（阅读文末 [开通服务](#开通服务)）
   
   <img src="https://qcloudimg.tencent-cloud.cn/raw/49931d68084b2d79f0f69f278894999b.png" width="400" />

6. 运行到【微信开发者工具】，勾选 **【运行时是否压缩代码】**
   
   <img src="https://web.sdk.qcloud.com/component/trtccalling/images/miniProgram/exportWechatTool.png" width="400" align="middle" />

7. 项目导入到微信开发者工具，目录如下图：
   
   <img src="https://qcloudimg.tencent-cloud.cn/raw/a79cd64ac5be8ee099f2d802f1c847c6.png" width="150" align="middle" />


## 示例体验
> **Tips：TUICallKit 通话体验，至少需要两台设备，用户 A、B 代表使用不同的设备。**

**用户 A（userId：111）**
- 步骤 1：在欢迎页，输入用户名（<font color=red>请确保用户名唯一性，不能与其他用户重复</font>）登录，比如：111。
- 步骤 2：根据不同的场景&业务需求，进入不同的场景界面，比如：视频通话。
- 步骤 3：输入要拨打的用户 B 的 userId（例如：222），点击搜索，然后点击呼叫。
  | 步骤1 | 步骤2 | 步骤3 | 
  | :-: | :-: | :-: |
  |<img src="https://qcloudimg.tencent-cloud.cn/raw/13bf844da5636f3640da05020800fff9.jpg" width="240"/>|<img src="https://qcloudimg.tencent-cloud.cn/raw/ceed4039c6ce8f9b8ff48deb89199b6e.jpg" width="240">|<img src="https://qcloudimg.tencent-cloud.cn/raw/dc1984904c9790c8a3355ff1c5dada50.jpg" width="240"/>

**用户 B（userId：222）**
- 步骤 1：在欢迎页，输入用户名（<font color=red>请确保用户名唯一性，不能与其他用户重复</font>）登录，比如：222。
- 步骤 2：进入主页，等待接听来电即可。


## 接入指引
### 步骤一：开通小程序权限
由于 TUICallKit 所使用的小程序标签有更苛刻的权限要求，因此集成 TUICallKit 的第一步就是要开通小程序的类目和标签使用权限，**否则无法使用**，这包括如下步骤：

- 小程序推拉流标签不支持个人小程序，只支持企业类小程序。需要在 [注册](https://developers.weixin.qq.com/community/business/doc/000200772f81508894e94ec965180d) 时填写主体类型为企业，如下图所示：
   <img width="480" height="480" src="https://main.qcloudimg.com/raw/a30f04a8983066fb9fdf179229d3ee31.png">

- 小程序推拉流标签使用权限暂时只开放给有限 [类目](https://developers.weixin.qq.com/miniprogram/dev/component/live-pusher.html)。
- 符合类目要求的小程序，需要在 **[微信公众平台](https://mp.weixin.qq.com/)** > **开发** > **开发管理** > **接口设置**中自助开通该组件权限，如下图所示：
  <img width="480" height="360" src="https://main.qcloudimg.com/raw/dc6d3c9102bd81443cb27b9810c8e981.png">


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
<img width="480" height="360" src="https://qcloudimg.tencent-cloud.cn/raw/a79ca9726309bb1fdabb9ef8961ce147.png">


### 步骤三：开通服务
TUICallKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务并体验 7 天的免费试用服务：

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。
   <img width="360" height="240" src="https://qcloudimg.tencent-cloud.cn/raw/1105c3c339be4f71d72800fe2839b113.png">

2. 单击刚刚创建出的应用，进入**基本配置**页面，并在页面的右下角找到**开通腾讯实时音视频服务**功能区，单击**免费体验**即可开通 TUICallKit 的 7 天免费试用服务。如果需要正式应用上线，可以单击 [**前往加购**](https://buy.cloud.tencent.com/avc) 即可进入购买页面。
   <img width="480" src="https://user-images.githubusercontent.com/72854065/205876830-6c8f119e-8d3c-4f1e-b8d3-0a21788fc47a.png">

   > IM 音视频通话能力针对不同的业务需求提供了差异化的付费版本供您选择，您可以在 [IM 购买页](https://buy.cloud.tencent.com/avc) 了解包含功能并选购您适合的版本。

3. 在同一页面找到 **SDKAppID** 和**密钥**并记录下来
- SDKAppID：IM 的应用 ID，用于业务隔离，即不同的 SDKAppID 的通话彼此不能互通。
- Secretkey：IM 的应用密钥，需要和 SDKAppID 配对使用，用于签出合法使用 IM 服务的鉴权用票据 UserSig。

   <img width="480" src="https://qcloudimg.tencent-cloud.cn/raw/e435332cda8d9ec7fea21bd95f7a0cba.png">

> 即日起至2022年10月01日0点前，购买音视频通话能力包基础版可获赠解锁相同有效期的小程序端通话功能授权。在活动结束前购买的音视频通话能力包在有效期内不受活动结束影响仍可使用小程序通话功能，活动结束后的新购或续期需选择体验版、进阶版、尊享版来获取小程序通话功能授权，基础版亦可单独加购小程序功能授权进行解锁。

> 单击**免费体验**以后，部分之前使用过 [实时音视频 TRTC]
(https://cloud.tencent.com/document/product/647/16788) 服务的用户会提示：
```
[-100013]:TRTC service is  suspended. Please check if the package balance is 0 or the Tencent Cloud accountis in arrears
```
因为新的 IM 音视频通话能力是整合了腾讯云[实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 和 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 两个基础的 PaaS 服务，所以当 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 的免费额度（10000分钟）已经过期或者耗尽，就会导致开通此项服务失败，这里您可以单击 [TRTC 控制台](https://console.cloud.tencent.com/trtc/app)，找到对应 SDKAppID 的应用管理页，示例如图，开通后付费功能后，再次**启用应用**即可正常体验音视频通话能力。

   <img width=600px src="https://qcloudimg.tencent-cloud.cn/raw/f74a13a7170cf8894195a1cae6c2f153.png" />


## 附录
- 如果您想要了解TUiCallKit，请阅读 [组件介绍 TUICallKit](https://cloud.tencent.com/document/product/647/78742)
- 如果您想把我们的功能直接嵌入到您的项目中，请阅读 [快速接入 TUICallKit](https://cloud.tencent.com/document/product/647/78912)
- 如果您想要了解详细 API ，请阅读 [ API 概览](https://cloud.tencent.com/document/product/647/78759)
- 如果你遇到了困难，可以先参阅 [常见问题](https://cloud.tencent.com/document/product/647/78912)；
- 如果发现了示例代码的 bug，欢迎提交 issue；
- 欢迎加入 QQ 群：**646165204**，进行技术交流和反馈~
