<h1 align="center"> TUICallKit </h1>

<p align="center"> 
<a href="https://github.com/tencentyun/TUICallKit/blob/main/Web/README.en.md"> English </a> | <b> 简体中文 </b>
</p>

<p align="center">Vue3 版本的音视频通话 UI 组件，通过编写几行代码，就可以为您的 Web 应用添加音视频通话功能。Vue2 请参见 <a href="https://www.npmjs.com/package/@tencentcloud/call-uikit-vue2"> @tencentcloud/call-uikit-vue2 </a></p>
<!-- <p>在线演示 | Demo 跑通 | 快速接入 </p> -->

<div align="center">
<img src="https://img.shields.io/npm/v/@tencentcloud/call-uikit-vue">
<img src="https://img.shields.io/badge/Vue-%5E3.0.0-brightgreen">
<img src="https://img.shields.io/badge/support-docs%20%26%20demos-yellow">
<img src="https://img.shields.io/npm/l/@tencentcloud/call-uikit-vue">
<!-- https://shields.io/category/version  - tag: docs/demos, H5, v1.0.3(changelog), 
GitHub Release Date: -->
</div>

<img src="https://user-images.githubusercontent.com/57169560/194707785-6d2e1aca-5ee7-427a-be62-19699578e684.gif" style="width: 1000px; margin: 10px;" align="center">

## 特性

<!-- - 底层使用 腾讯云即时通信与音视频能力，效果媲美微信 -->
<!-- - 📦 开箱即用 —— 未引入除 SDK 外其他 npm 依赖，有效控制代码体积 -->
- ⚡️ 功能全面 —— 支持单人/多人/音频/视频通话、支持视频转音频通话、支持自由选择通话设备
- 🌟 低门槛 —— 仅需 3 行代码即可跑通测试 Demo，6 行代码完成通用能力接入
- 📱 多设备适配 —— 支持 H5 1v1 布局
- 🎨 灵活样式 —— 组件开源，可复用逻辑，自定义 UI 样式
- 🛠 优秀生态 —— 与 [TUIKit](https://cloud.tencent.com/document/product/269/79737) 协同使用，可以在 [TIM](https://cloud.tencent.com/document/product/269) 会话中直接发起音视频通话
- 🔥 先进技术栈 —— `TypeScript` 类型，支持 Vue3 `Composition API`
- 🌍 跨平台 —— 支持 Android、iOS、Web、小程序、Flutter、UniApp 等[多个开发平台](https://cloud.tencent.com/document/product/647/78742)
- ☁️ 低延迟 —— 腾讯云全球链路资源储备，保证国际链路端到端平均时延 < 300ms
- 🤙🏻 低卡顿 —— 抗丢包率超过 80%、抗网络抖动超过 1000ms，弱网环境仍顺畅稳定
- 🌈 高品质 —— 支持 720P、1080P 高清画质，70% 丢包率仍可正常视频

## 使用指引

```text
我们团队即将在 Web 端丰富更多不同的组件，以满足您的开发需求。
希望您能抽出几分钟时间，为您自己的需求投上一票，我们将优先开发！
问卷地址：https://wj.qq.com/s2/11263124/1556/
```

为方便您的使用，本组件配套多篇使用指引：

- 如果您想在线体验通话效果，请访问 [1v1音视频通话体验馆](https://web.sdk.qcloud.com/component/experience-center/index.html#/detail?scene=callkit)

- 如果您想要调试通话效果，请阅读 [Vue3 Demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic-vue3/README.md) 或者 [Vue2 Demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic-vue2/README.md)

- 如果您想把我们的功能直接嵌入到您的项目中，请阅读 [快速接入 TUICallKit](https://cloud.tencent.com/document/product/647/78731)

- 如果您想要修改 UI 界面，请阅读 [TUICallKit 界面定制指引](https://cloud.tencent.com/document/product/647/81014)

## 目录说明

```text
.
├── README.md
├── demos/basic-react/
├── demos/basic-vue3/
├── demos/basic-vue2/
└── TUICallKit/
```

**demos/basic-react/**

- 此文件夹下是 React 基础版 demo，集成了完整的 TUICallKit 组件功能，可以直接搜索用户拨打音视频通话。
- demo 页面下方集成了调试面板，可直接输入您的应用信息，具体流程请参考：[React Demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic-react/README.md)。

**demos/basic-vue3/**

- 此文件夹下是 Vue3 基础版 demo，集成了完整的 TUICallKit 组件功能，可以直接搜索用户拨打音视频通话。
- demo 页面下方集成了调试面板，可直接输入您的应用信息，具体流程请参考：[Vue3 Demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic-vue3/README.md)。

**demos/basic-vue2/**

- 此文件夹下是 Vue2.7 基础版 demo，集成了完整的 TUICallKit 组件功能，可以直接搜索用户拨打音视频通话。
- demo 页面下方集成了调试面板，可直接输入您的应用信息，具体流程请参考：[Vue2 Demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic-vue2/README.md)。

**TUICallKit/** 

- 此文件夹下是 TUICallKit 组件源文件，支持 Vue3 与 Vue2.7+ 的项目直接引入。包含全部 UI 层与逻辑层代码，入口文件为 `index.ts`。
- 推荐直接使用打包方式引入，如 [快速接入 TUICallKit](https://cloud.tencent.com/document/product/647/78731)。可直接复制此文件到您的工程中进行组件的引入，详细的源码接入组件过程请参考 [TUICallKit 界面定制指引](https://cloud.tencent.com/document/product/647/81014)。

## Changelog

版本更新历史请点击 [SDK 发布日志(Web)](https://cloud.tencent.com/document/product/647/80930)。

## 附录

- 如果你遇到了困难，可以先参阅 [常见问题](https://cloud.tencent.com/document/product/647/78769)；
- 如果发现了示例代码的 bug，欢迎提交 issue；
- 欢迎加入 QQ 群：**646165204**，进行技术交流和反馈~

## License

ISC License © 2022-present, [Tencent](https://www.tencent.com/)
