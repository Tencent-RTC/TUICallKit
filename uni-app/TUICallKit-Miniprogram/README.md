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

## 附录

- 如果你遇到了困难，可以先参阅 [常见问题](https://cloud.tencent.com/document/product/647/78912)；
- 如果发现了示例代码的 bug，欢迎提交 issue；