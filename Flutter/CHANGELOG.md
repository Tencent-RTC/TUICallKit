## 1.6.3
### 缺陷修复
- iOS：修复调用 `joinInGroupCall` 后中途加人页面为空的问题。
- iOS：修复调用 `joinInGroupCall` 后用户画面遮挡的问题。

## 1.6.2
### 缺陷修复
- Android：修复调用 `joinInGroupCall` api引起Crash问题 。

## 1.6.1
### 缺陷修复
- Android：修复在 Vivo 特定机型上申请悬浮窗权限时偶现的崩溃问题。
### 依赖说明
- 升级依赖的客户端 SDK 版本：Android LiteAVSDK_Professional: 11.1.0.13111、iOS TXLiteAVSDK_Professional: 11.1.14143。

## 1.6.0

### 新特性
- Android&iOS：增加hangup挂断接口。
- Android&iOS：增加用户自定义字段、增加用户自定义通话超时时长。
- Android&iOS：群组通话增加中途加人页面。
### 功能优化
- Android：优化单人视频通话头像显示。
- Android&iOS：群组通话中，默认支持邀请其他群成员加入通话。
### 缺陷修复
- Android：修复 Android 12及其以上 设备链接蓝牙后无声的问题。
- Android：修复被叫端偶现静音设置不生效问题。
- iOS：修复重新登录后偶现设备接收不到来电邀请的问题。
- iOS：修复 VoIP 推送页面昵称显示错误的问题。

### 依赖说明
- 升级依赖的客户端 SDK 版本：Android LiteAVSDK_Professional: 11.1.0.13111、iOS TXLiteAVSDK_Professional: 11.1.14143。

 ## 1.5.4
 ### 新特性
- iOS：支持 VoIP 消息推送功能，提供更好的通话接听体验。
- Android&iOS：增加 小米、华为、VIVO 离线推送高级参数。
- Android&iOS：支持设置编码分辨率，画面方向等。
- Android&iOS：支持设置渲染方向、渲染模式（自适应、填充）等。
 ### 功能优化
- Android：优化 `onCallEnd`回调中 totaltime 参数单位为毫秒。
 ### 缺陷修复
- Android&iOS：修复`onCallReceived`回调异常问题。
- iOS：修复屏幕旋转时通话页面显示不全的问题。

## 1.5.3
### 缺陷修复
- Android：修复打包失败问题。
- Android&iOS：修复回调方法未实现时抛出异常的问题。
## 1.5.2
### 缺陷修复
- Android：修复 `TUICallDefine.OfflinePushInfo` API变更导致的编译报错。
## 1.5.1
### 缺陷修复
- Android&iOS：修复 `tencent_calls_engine` 版本依赖错误的问题。
## 1.5.0
### 功能优化
- Android：贴耳息屏功能默认关闭。
- Android：升级 gradle 插件及版本。
- Android：优化铃声播放类，支持循环播放。
### 缺陷修复
- Android&iOS：修复被叫接听通话失败，没有 onCallCancel 回调问题。
- Android：修复被叫接听通话失败，主叫异常问题。
- Android：修复首次通话检查权限时，主叫端取消通话，被叫端再次拉起界面问题。
- Android：修复回调上层的网络质量 userId 为空问题。
- iOS：修复 Example 中 Observer 注册时机错误的问题。


## 1.4.2
### 缺陷修复
- Android&iOS：修复 Example 中错误的 Observer 注册时机导致的通话异常问题；
- iOS：修复 `removeObserver` API 偶现设置无效的问题；

## 1.4.1
### 缺陷修复
- Android：修复通话结束后，`OnCallEnd`事件丢失的问题。

## 1.4.0

### 缺陷修复
- Android&iOS：修复主动加入房间（joinInGroupCall）时通话异常结束问题。
- Android：修复在音视频通话接听中退后台，再回到前台时，通话状态异常问题。
- Android：修复同时集成 `tencent_cloud_chat_uikit` 插件时，登录状态导致的通话发起失败问题。
- Android：修复发起群组通话中因为参数检查问题导致的通话发起失败问题。


## 1.3.1
### 新特性
- Android&iOS: 支持通话时自定义离线推送消息。
### 缺陷修复
- Android：修复同时集成 `tencent_cloud_chat_uikit` 插件时，提示`sdkappid is invalid`的问题。

## 1.3.0
### 功能优化
- iOS: 优化 TUICallKit 的 Framework 体积。
### 缺陷修复
- Android&iOS：修复服务端解散房间或踢出用户时，通话界面不消失问题。
- Android：修复A呼叫离线用户B，然后取消；A 再次呼叫 B，B 上线后通话界面不显示问题。
## 1.2.2
### 缺陷修复
- iOS：修复静态库链接导致的编译问题。
## 1.2.0
### 新特性

- 支持1v1 音视频通话、群组音视频通话。
- 支持自定义头像、自定义昵称。
- 支持设置自定义铃音。
- 支持通话过程中开启悬浮窗。
- 支持多平台登录状态下的来电服务。 
