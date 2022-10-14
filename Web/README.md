# TUICallKit
   
<!-- 分仓后加入：https://shields.io/category/version  - tag: docs/demos, H5, v1.0.3(changelog),  -->

本仓库是 Vue3 版本的 TUICallKit 音视频通话 UI 组件，通过集成该组件，您只需要编写几行代码，就可以为您的 Web 应用添加音视频通话功能。

<div align="center">

![Oct-08-2022 20-21-07](https://user-images.githubusercontent.com/57169560/194707785-6d2e1aca-5ee7-427a-be62-19699578e684.gif)

</div>

## 特性

<!-- - 支持 H5 响应式布局 -->
<!-- - 底层使用 腾讯云即时通信与音视频能力，效果媲美微信 -->
- ⚡️ 功能全面 —— 支持单人/多人/音频/视频通话、支持视频转音频通话、支持自由选择通话设备
- 🌟 低门槛 —— 仅需 3 行代码即可跑通测试 Demo，6 行代码完成通用能力接入
- 📦 集成无负担 —— 未引入除 SDK 外其他 npm 依赖，有效控制代码体积
- 🎨 灵活样式 —— 组件开源，可复用逻辑，自定义 UI 样式
- 🛠 优秀生态 —— 与 [TUIKit](https://cloud.tencent.com/document/product/269/79737) 协同使用，可以在 [TIM](https://cloud.tencent.com/document/product/269) 会话中直接发起音视频通话
- 🔥 先进技术栈 —— `TypeScript` 类型，支持 Vue3 `Composition API`
- 🌍 跨平台 —— 支持 Android、iOS、Web、小程序、Flutter、UniApp 等[多个开发平台](https://cloud.tencent.com/document/product/647/78742)
- ☁️ 低延迟 —— 腾讯云全球链路资源储备，保证国际链路端到端平均时延 < 300ms
- 🤙🏻 低卡顿 —— 抗丢包率超过 80%、抗网络抖动超过 1000ms，弱网环境仍顺畅稳定
- 🌈 高品质 —— 支持 720P、1080P 高清画质，70% 丢包率仍可正常视频

## 使用指引

为方便您的使用，本组件配套多篇使用指引：

- 如果您想要体验并调试通话效果，请阅读 [Demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic/README.md)

- 如果您想把我们的功能直接嵌入到您的项目中，请阅读 [快速接入 TUICallKit](https://cloud.tencent.com/document/product/647/78731)

- 如果您想要修改 UI 界面，请阅读 [TUICallKit 界面定制指引](https://cloud.tencent.com/document/product/647/81014)

## 目录说明

```
.
├── README.md
├── demos/basic/
├── docs/
└── src/
```

**demos/basic/**

- 此文件夹下是基础版 demo，集成了完整的 TUICallKit 组件功能，可以直接搜索用户拨打音视频通话。
- demo 页面下方集成了调试面板，可直接输入您的应用信息，具体流程请参考：[Demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic/README.md)。

**docs/**

- 包含 TUICallKit 接口文档 (API.md), 接入指引 (Guide.md), 界面定制指引 (UI Customization)。


**src/** 

- 此文件夹下是 TUICallKit 组件源文件，包含全部 UI 层与逻辑层代码，入口文件为 `index.ts`。
- 可直接复制此文件到您的工程中进行组件的引入，如 `import { TUICallKit, TUICallKitServer } from './src/index'`, 其中 `src` 可重命名，引入路径做相应的修改即可，更详细的接入组件过程请参考 [快速接入 TUICallKit](https://cloud.tencent.com/document/product/647/78731)。


## 附录

- 如果你遇到了困难，可以先参阅 [常见问题](https://cloud.tencent.com/document/product/647/78769)；
- 如果发现了示例代码的 bug，欢迎提交 issue；
- 欢迎加入 QQ 群：**646165204**，进行技术交流和反馈~
