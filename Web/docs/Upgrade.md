# Web 升级方案

TUICallKit 是腾讯云推出一款新的音视频通话 UI 组件，是 TRTCCalling 的升级版本，支持群组通话、AI 降噪等更多功能特性、支持全平台间互通呼叫，功能更加稳定，欢迎您使用新的 TUICallKit 组件，在升级前您需要了解到：
- TRTCCalling 和 TUICallKit 支持相互呼叫，升级前后，请保持 SDKAppID 不变，否则会影响相互通信。
- TUICallKit 需要搭配 IM 音视频通话能力套餐，可以单击 [IM 控制台](https://console.cloud.tencent.com/im)，进入对应 SDKAppID 应用的 基本配置 页面，并在页面的右下角找到 开通腾讯实时音视频服务 功能区，单击 免费体验 即可开通 TUICallKit 的 7 天免费试用服务。如果需要正式应用上线，可以单击 [前往加购](https://buy.cloud.tencent.com/avc) 即可进入购买页面。

<img width="568" alt="image" src="https://user-images.githubusercontent.com/57169560/205272999-739dddc9-0415-4c98-a1c5-2f54419a1e32.png">

## 升级概览

TUICallKit 在设计之初就兼顾了 TRTCCalling 客户的升级诉求，仅需要简单几步就可以升级完成，预计花费 20 分钟；
您可以选择两种升级方式：
1. 升级到 [TUICallKit Vue3 UI](https://github.com/tencentyun/TUICallKit/tree/main/Web) 开源组件：只需要编写几行代码就可以为您的 App 添加音视频通话功能，并且支持离线唤起能力。（推荐）
2. 升级到 [TUICallEngine SDK](https://www.npmjs.com/package/tuicall-engine-webrtc)：可直接从旧版本 TRTCCalling 迁移而来，UI 层可沿用已开发版本。
接下来将分别介绍两种方式的升级步骤。

## TUICallKit Vue3 UI 组件升级步骤

TUICallKit Vue3 UI 提供带 UI 的开源组件，节省 90% 开发时间，快速上线音视频通话应用。
- 如果您想要体验并调试通话效果，请阅读 [Demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic/README.md)。
- 如果您想把我们的功能直接嵌入到您的项目中，请阅读 [快速接入 TUICallKit](https://cloud.tencent.com/document/product/647/78731)。
- 如果您想要修改 UI 界面，请阅读 [TUICallKit 界面定制指引](https://cloud.tencent.com/document/product/647/81014)。

## TUICallEngine SDK 1.x 无 UI 升级步骤

本部分将帮助您从 TRTCCalling 1.x 升级到 TUICallEngine 1.x。

### 1. 升级 SDK 包依赖

安装 TUICallEngine SDK 包，并将其他依赖更新到最新版本。

```bash
yarn add tuicall-engine-webrtc # 安装新版本 SDK 
yarn add tim-js-sdk@latest trtc-js-sdk@latest tsignaling@latest # 更新依赖到最新版本
yarn remove trtc-calling-js # 移除旧版本 SDK
# 若您未安装 yarn，可以先运行: npm install -g yarn
# 若您依旧使用 npm 进行依赖管理，可将 "yarn add" 替换为 "npm install"，将 "yarn remove" 替换成 "npm uninstall"
```
### 2. 替换 SDK 引入方式与创建实例方式

在完成上述步骤后，您的工程就无法正常编译了，接下里的步骤将手把手修改其中冲突的几个地方。
1. 首先，替换引入方式。
```javascript
// 旧版本
import TRTCCalling from 'trtc-calling-js';

// 新版本
import { TUICallEngine } from "tuicall-engine-webrtc";
```

2. 修改创建实例方式，示例代码如下，若需详细接口请参考 createInstance()。

```javascript
// 旧版本
new TRTCCalling({ SDKAppID });

// 新版本
TUICallEngine.createInstance({ SDKAppID });
// TUICallEngine.destroyInstance(); // 如需要销毁实例，可调用此接口
```

### 3. 替换监听事件常量

监听事件常量地址由TRTCCalling.EVENT变为TUICallEvent，后者可以从包tuicall-engine-webrtc中引入。
此步骤推荐使用编辑器全局搜索一键替换。

```javascript
// 旧版本
trtcCalling.on(TRTCCalling.EVNET.ERROR, this.handleError);
trtcCalling.on(TRTCCalling.EVNET.INVITED, this.handleNewInvitationReceived);
trtcCalling.on(TRTCCalling.EVNET.USER_ACCEPT, this.handleUserAccept);
...（包含其他监听）

// 新版本
import { TUICallEvent } from "tuicall-engine-webrtc";
tuiCallEngine.on(TUICallEvent.ERROR, this.handleError); // tuiCallEngine 为新实例名称，沿用旧 trtcCalling 无妨
tuiCallEngine.on(TUICallEvent.INVITED, this.handleNewInvitationReceived);
tuiCallEngine.on(TUICallEvent.USER_ACCEPT, this.handleUserAccept);
...（包含其他监听）

```

### 4. 替换通话类型常量

若您之前未使用通话类型常量可跳过本步骤。
通话类型常量地址由TRTCCalling.CALL_TYPE变为TUICallType，后者可以从包tuicall-engine-webrtc中引入。
此步骤推荐使用编辑器全局搜索一键替换。
```javascript
// 旧版本
this.TRTCCalling.CALL_TYPE.AUDIO_CALL // 语音类型
this.TRTCCalling.CALL_TYPE.VIDEO_CALL // 视频类型

// 新版本
import { TUICallType } from "tuicall-engine-webrtc";
TUICallType.AUDIO_CALL // 语音类型
TUICallType.VIDEO_CALL // 视频类型
```

### 5. 其他关键接口变更

| API 含义 | 旧版本 TRTCCalling SDK | 新版本 TUICallEngine SDK | 备注 |
| --- | --- | --- | --- |
| 切换通话类型 | trtcCalling.switchToAudioCall() | tuiCallEngine.[switchCallMediaType()](https://cloud.tencent.com/document/product/647/78757#switchcallmediatype) | 名称变更，通过参数选择切换类型
| 获取麦克风设备列表 | trtcCalling.getMicrophones() | [tuiCallEngine.getDeviceList()](https://cloud.tencent.com/document/product/647/78757#getdevicelist) | 接口合并，通过参数选择设备类型
| 获取摄像头设备列表 | trtcCalling.getCameras() | [tuiCallEngine.getDeviceList()](https://cloud.tencent.com/document/product/647/78757#getdevicelist) | 接口合并，通过参数选择设备类型
| 关闭/打开麦克风 | trtcCalling.setMicMute() | [tuiCallEngine.closeMicrophone()](https://cloud.tencent.com/document/product/647/78757#closemicrophone) | 接口拆分
| 关闭/打开麦克风 | trtcCalling.setMicMute() | [tuiCallEngine.openMicrophone()](https://cloud.tencent.com/document/product/647/78757#openmicrophone) | 接口拆分
| 设置用户昵称和头像 | 无 | [tuiCallEngine.setSelfInfo()](https://cloud.tencent.com/document/product/647/78757#setselfinfo) | 设置用户昵称和头像 |
| 开启/关闭 AI 降噪 | 无 | [tuiCallEngine.enableAIVoice()](https://cloud.tencent.com/document/product/647/78757#c9ace016-0cfa-441e-a7c7-7fd1c8c55a51) | 4.12.1 版本以后支持，具体使用详情请参阅使用 AI 降噪 |

### 6. 补充说明

- 由于 TUICallKit 需要搭配 IM 音视频通话能力套餐，您还可能遇到"The package you purchased does not support this ability."，可以单击 IM 控制台，进入对应 SDKAppID 应用的 基本配置 页面，并在页面的右下角找到 开通腾讯实时音视频服务 功能区，单击 免费体验 即可开通 TUICallKit 的 7 天免费试用服务。如果需要正式应用上线，可以单击 前往加购 即可进入购买页面。
- 升级完上述 API 之后，就可以正常使用 TUICallEngine SDK 了，如果遇到其他 API 接口调用问题，可参阅 SDK API 文档。
- 欢迎加入 QQ 群：646165204，进行技术交流和反馈~
