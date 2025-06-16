## 1.2.0（2025-03-31）
- 适配出海手机支持 FCM 推送。
## 1.1.0（2024-12-11）
- 大幅减小插件包体积，优化产品体验。
- 兼容 HBuilderX 4.36 的 Breaking changes。如果您需要 vivo/荣耀 的厂商推送，请参考 [文档](https://cloud.tencent.com/document/product/269/103522)，正确配置 `manifestPlaceholders.json` 和 `mcn-services.json`。

## 1.0.0（2024-11-29） 
- 优化和 [TencentCloud-TUICallKit 插件](https://ext.dcloud.net.cn/plugin?id=9035) 融合时的产品体验。
- 新增点击通知栏事件 NOTIFICATION_CLICKED，支持获取推送扩展信息。
- 在线通道支持自定义铃音功能。

## 0.5.1（2024-11-07） 
- 优化和 [@tencentcloud/chat-uikit-uniapp](https://cloud.tencent.com/document/product/269/64507) 融合时的产品体验。
- 优化和 [TencentCloud-TUICallKit 插件](https://ext.dcloud.net.cn/plugin?id=9035) 融合时的产品体验。
- 新增接口 disablePostNotificationInForeground，此接口可实现应用在前台时，开/关通知栏通知（默认开）。
- 新增接口 createNotificationChannel，支持 FCM/OPPO 自定义铃音。

## 0.4.0（2024-10-17）
- 支持与 [TencentCloud-TUICallKit 插件](https://ext.dcloud.net.cn/plugin?id=9035) 融合打包。

## 0.3.0（2024-10-12）
- 新增接口 addPushListener/removePushListener，支持获取在线推送消息，支持推送消息撤回通知。

## 0.2.0（2024-09-18）
- 支持 FCM
- 支持 hihonor

## 0.1.0（2024-09-10）
 - 使用 uts 开发，基于腾讯云推送服务（Push），支持 iOS 和 Android 推送，同时适配各大厂商推送。