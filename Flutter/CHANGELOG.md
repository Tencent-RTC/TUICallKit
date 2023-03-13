
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
