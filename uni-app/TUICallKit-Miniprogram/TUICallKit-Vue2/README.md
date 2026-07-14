# TUICallKit UniApp 微信小程序 Demo (Vue 2)

本 Demo 是基于 `@trtc/calls-uikit-wx-uniapp` + `@trtc/call-engine-lite-wx` 的微信小程序音视频通话示例，使用 **Vue 2 + @vue/composition-api + unplugin-vue2-script-setup** 技术栈。

> 💡 本项目与 `uniapp-wx-basic-engine`（Vue 3 版本）共享同一套 TUICallKit 源码，通过 UniApp 条件编译实现 Vue 2/Vue 3 双版本兼容。

## 环境要求

- **HBuilderX** >= 3.6.0（支持 Vue 2 + Composition API）
- Node.js >= 14
- 微信开发者工具

## 快速开始

### 步骤1：安装依赖

```bash
npm install
```

### 步骤2：填写鉴权信息

修改 `./debug/GenerateTestUserSig-es.js` 文件中的 `SDKAPPID` 以及 `SECRETKEY`。

### 步骤3：导入 HBuilderX

1. 打开 HBuilderX，选择 **文件 > 导入 > 从本地目录导入**
2. 选择本项目目录
3. 确认 `manifest.json` 中 `"vueVersion": "2"` 已设置

### 步骤4：运行到微信小程序

1. 在 HBuilderX 中选择 **运行 > 运行到小程序模拟器 > 微信开发者工具**
2. 等待编译完成后，在微信开发者工具中预览

## 与 Vue 3 版本的差异

| 项目 | Vue 3 版本 | Vue 2 版本（本项目） |
|------|-----------|---------------------|
| manifest.json `vueVersion` | `"3"` | `"2"` |
| 构建工具 | Vite (`vite.config.ts`) | Webpack (`vue.config.js`) |
| Vue 导入源 | `from 'vue'` | `from '@vue/composition-api'`（通过 adapter 自动处理） |
| `<script setup>` 支持 | Vue 3 原生 | `unplugin-vue2-script-setup`（HBuilderX 内置） |
| 额外依赖 | 无 | `@vue/composition-api` |

## 技术要点

- **Composition API 兼容层**：`TUICallKit/adapter/vue-demi.ts` 使用 UniApp 条件编译 `#ifndef VUE3` / `#ifdef VUE3`，在 Vue 2 环境自动从 `@vue/composition-api` 导出，Vue 3 环境从 `vue` 导出。
- **`<script setup>` 保留**：得益于 `unplugin-vue2-script-setup`（HBuilderX Vue 2 编译器内置），所有组件保留 `<script setup>` 语法无需改写。
- **main.js 双入口**：使用 `#ifndef VUE3` / `#ifdef VUE3` 条件编译实现统一入口。

## Debug 脚本的作用

出于体积和安全双重因素考虑，请在发布前删除项目目录下 `/debug` 文件夹。在开发阶段为了方便开发，项目提供生成本地 UserSig 的脚本文件存放于 `debug` 文件夹中，但这并不安全，该方法中 SECRETKEY 很容易被反编译逆向破解。**该方法仅适合本地跑通 Demo 和功能调试**。

## 联系我们

如遇任何问题，可联系 [官网售后](https://cloud.tencent.com/act/event/connect-service#/) 反馈，享有专业工程师的支持。
