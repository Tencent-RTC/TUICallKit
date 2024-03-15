<h1 align="center">TUICallKit</h1>

<p align="center">React 版本的音视频通话 UI 组件，通过编写几行代码，就可以为您的 Web 应用添加音视频通话功能。

<div align="center">
<img src="https://img.shields.io/badge/Platform-React-green">
<img src="https://img.shields.io/npm/v/@tencentcloud/call-uikit-react">
<img src="https://img.shields.io/badge/support-docs%20%26%20demos-yellow">
<img src="https://img.shields.io/npm/l/@tencentcloud/call-uikit-react">

[Demo](https://web.sdk.qcloud.com/component/TUICallKit/demos/basic-react/index.html) · [Report Bug](https://github.com/tencentyun/TUICallKit/issues) · [English](https://github.com/tencentyun/TUICallKit/blob/main/Web/README.md) · 中文
</div>

![](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)


## Demo 演示

- 桌面端

<img src="https://web.sdk.qcloud.com/trtc/call/pope-test/react-doc/Background-pc.png" style="width: 800px; margin: 10px;" align="center">

- 移动端

<img src="https://web.sdk.qcloud.com/trtc/call/pope-test/react-doc/en/Background-mobile.png" style="width: 1000px; margin: 10px;" align="center">

- 群通话

<img src="https://web.sdk.qcloud.com/trtc/call/pope-test/react-doc/Background-group-mobile.png" style="width: 1000px; margin: 10px;" align="center">

## 特性

- ⚡️ 功能全面 —— 支持单人/多人/音频/视频通话、支持视频转音频通话、支持自由选择通话设备
- 🌟 低门槛 —— 仅需 3 行代码即可跑通测试 Demo，6 行代码完成通用能力接入
- 📱 多设备适配 —— 支持 H5 1v1 通话、群组通话 布局
- 🛠 优秀生态 —— 与 [TUIKit](https://cloud.tencent.com/document/product/269/79737) 协同使用，可以在 [TIM](https://cloud.tencent.com/document/product/269) 会话中直接发起音视频通话
- ☁️ 低延迟 —— 腾讯云全球链路资源储备，保证国际链路端到端平均时延 < 300ms
- 🤙🏻 低卡顿 —— 抗丢包率超过 80%、抗网络抖动超过 1000ms，弱网环境仍顺畅稳定
- 🌈 高品质 —— 支持 720P、1080P 高清画质，70% 丢包率仍可正常视频
- 🌍 国际化 —— 支持中/英/日三种语言


## 使用指引

为方便您的使用，本组件配套多篇使用指引：

- 如果您想在线体验通话效果，请访问 [React 音视频通话 demo](https://web.sdk.qcloud.com/component/TUICallKit/demos/basic-react/index.html)。 [Vue 音视频通话 demo](https://rtcube.cloud.tencent.com/prerelease/component/experience-center/index.html#/detail?scene=callkit)

- 如果您想要调试通话效果，请阅读 [React Demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic-react)。 [Vue Demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/call-uikit-demos/basic-vue3)。

- 如果您想把我们的功能直接嵌入到您的项目中，请阅读 [快速接入 TUICallKit](https://cloud.tencent.com/document/product/647/102510)。


## 目录内容

```text
.
├── call-engine-demo-vue2
├── call-engine-demo-vue3
├── call-uikit-demos
  ├── basic-react
  ├── basic-vue2.6
  ├── basic-vue2.7
  ├── basic-vue3
├── README-zh_CN.md
├── README.md 
```

**call-engine-demo-vue2/**
- 此文件夹下是 TUICallEngine 的 vue2 demo，集成了完整的 TUICallEngine 功能.

**call-engine-demo-vue3/**
- 此文件夹下是 TUICallEngine 的 vue3 demo，集成了完整的 TUICallEngine 功能.

**call-uikit-demos/basic-react/**
- 此文件夹下是 React 基础版 demo，集成了完整的 TUICallKit 组件功能，可以直接搜索用户拨打音视频通话。

**call-uikit-demos/basic-vue3/**
- 此文件夹下是 Vue3 基础版 demo，集成了完整的 TUICallKit 组件功能，可以直接搜索用户拨打音视频通话。

**call-uikit-demos/basic-vue2.7/**
- 此文件夹下是 Vue2.7 基础版 demo，集成了完整的 TUICallKit 组件功能，可以直接搜索用户拨打音视频通话。

**call-uikit-demos/basic-vue2.6/**
- 此文件夹下是 Vue2.6 基础版 demo，集成了完整的 TUICallKit 组件功能，可以直接搜索用户拨打音视频通话。


## 联系我们
- 如果你遇到了困难，可以先参阅 [常见问题](https://cloud.tencent.com/document/product/647/78769)；
- 有任何问题可以在[腾讯云通讯官方社群](https://zhiliao.qq.com/)中的 TUICallKit 板块中提出；
- 如果发现了示例代码的 bug，欢迎提交 issue；


## License

ISC License © 2022-present, [Tencent](https://www.tencent.com/)
