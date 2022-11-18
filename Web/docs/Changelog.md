
## Version 1.3.0 @2022.11.14

**注意**

- 升级至该版本需注意：[升级指引](./Updated%20Guidline.md)。

**新增**

- 支持手机 H5 使用时，自动切换为竖屏样式。
- 支持在拨打电话时预览本地摄像头。
- basic demo 增加拨打电话前的设备检测。

**修复**

- 修复调用 `TUICallKitServer.destroy()` 之后 tim 实例未完全退出的问题。
- 修复对方忙线时显示无应答的问题。
- 修复 vite 环境下 typescript 类型未成功打包的问题。

**接口变更**

- 主动调用 `TUICallKitServer.call()` 或 `TUICallKitServer.groupCall()` 时，如果遇到报错，不会再调用 `beforeCalling` 回调。请直接使用 try catch 捕获错误。

## Version 1.2.0 @2022.11.03

**新增**

- 适配新版本 TUICallEngine SDK。

## Version 1.1.0 @2022.10.21

**新增**

- 通话过程中，通话页面可以全屏。
- 通话过程中，可以使用 `<TUICallKitMini/>` 进行最小化。

**修复**

- 修复已知问题，提升稳定性。

## Version 1.0.3 @2022.10.14

**新增**

- basic demo 增加快捷复制 UserID、一键打开新窗口。

## Version 1.0.2 @2022.09.30

**新增**

- 优化接入文档，增加演示图片和详细指引。

**修复**

- 修复首次进入房间时，设备状态位失效的问题。
- 修复在 webpack 工具打包时，图标偶现加载失败的问题。
- 修复已知样式问题。

## Version 1.0.1 @2022.09.26

**新增**

- 在拨打电话时，隐藏对方麦克风图标。

**修复**

- 修复 basic demo SDKAppID 输入框应为数字的问题。

## Version 1.0.0 @2022.09.23

- [TUICallKit demo 快速跑通](https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic/README.md)
- [TUICallKit 快速接入](https://cloud.tencent.com/document/product/647/78731)
- [TUICallKit API](https://cloud.tencent.com/document/product/647/81015)
- [TUICallKit 界面定制指引](https://cloud.tencent.com/document/product/647/81014)
- [TUICallKit (Web) 常见问题](https://cloud.tencent.com/document/product/647/78769)


