## [2.9.1]（2025-02-24）

#### 修复
- Android: 修复 HBuilderX 4.45 版本下 2.9.0 插件自定义基座构建失败问题。

## [2.9.0]（2025-02-19）

#### 新增
- Android&iOS：新增 [calls](https://cloud.tencent.com/document/product/647/78763#calls) 接口，支持发起单人通话或多人通话，更加灵活的通话成员管理，支持更强大的 REST API，欢迎使用。
- Android&iOS：新增 [join](https://cloud.tencent.com/document/product/647/78763#calls) 接口，配合 calls 接口、支持加入已有通话。
- Android&iOS：支持来电震动。

#### 修复
- Android： 修复悬浮窗导致的内存泄露问题。

## [2.7.0]（2024-11-29）

#### 新增
- Android&iOS：新增繁体中文支持，优化使用体验。

#### 修复
- Android：修复收到 FCM 推送消息无法弹出通知的问题。
- Android：修复中途加入语音通话，无法拉取已开摄像头的用户的画面问题。
- iOS： 修复主叫在接听前进入悬浮窗，接听后对端画面异常的问题。
- iOS： 修复在等待接听页面关闭摄像头以后，接听后摄像头状态不一致的问题。

## [2.6.0]（2024-10-12）

#### 优化
- Android：大屏设备支持横屏布局，增强使用体验。
- iOS：适配 iOS 16 以上的版本，支持应用外悬浮窗。
- Android：有悬浮窗权限时，应用直接退后台，显示应用外悬浮窗。

#### 修复
- Android&iOS：修复 hangup 接口回调两次问题。
- Android&iOS：修复极少场景下，发起通话后无回调问题。
- iOS：修复 VOIP 使用过程中，切换音频播放设备不可用问题。
- iOS：修复后台活跃转态收到来电后，进入 APP 后铃声不响问题。
- Android：SDKAppID 只支持传 int 类型，不支持 String 类型。


## [2.5.0]（2024-08-09）
#### 优化
- Android：优化中途加入的逻辑，避免内存泄露。

#### 修复
- Android&iOS：修复发送群通话邀请给未登录 web 端用户，web 用户登录后收不到通话邀请的问题。
- Android：修复群组通话中，A 语音呼叫 B，B 收到通知后点击拉起界面，显示是扬声器而不是听筒问题。


## [2.4.0]（2024-06-21）
#### 优化
- Android&iOS：弱网时提示用户，增强用户使用体验。
- Android：优化被叫端的锁屏时的来电策略。

#### 修复
- Android&iOS：修复主动加入通话界面显示异常问题。
- iOS：修复群通话内存异常增长问题。


## [2.3.3]（2024-06-06）
#### 修复
* iOS：修复传入 CallParams 字段时，roomID、strRoomID 不传值导致的通话拨打失败问题。


## [2.3.2]（2024-06-03）
#### 新增
* Android&iOS：新增对[离线推送](https://cloud.tencent.com/document/product/647/90338#OfflinePushInfo)字段的支持。
* Android&iOS：新增对 [userData](https://cloud.tencent.com/document/product/647/90338#CallParams) 字段的支持。


## [2.3.0]（2024-04-18）
#### 新增
* Android&iOS：新增视频通话背景虚化功能。
* Android&iOS：新增 TUIChat 群组顶部显示通话状态，并允许群成员主动加入通话功能。

#### 优化
* Android&iOS：优化来电弹出逻辑，默认展示横幅接听框。

#### 修复
* Android：修复通话记录编辑界面中，点击删除按钮无响应的问题。
* iOS：修复在群通话中点击成员视图时，切换过程中出现重影的问题 。
* iOS：修复音视频界面特定场景下不显示的问题。
* Android&iOS：修复在呼叫忙线中的用户时，通话结束后缺少提示的问题。


## [2.2.1]（2024-03-05）
#### 修复
* Android ：修复因为 kotlin 版本不一致导致的 uni-app 云打包编译问题；
* iOS：修复因为 Swift 编译导致的uni-app 云打包编译问题；


## [2.2.0]（2024-02-28）
#### 优化
* Android&iOS：全新的 UI 视效，功能更清晰，体验更好。


## [2.1.0] (2024-01-02)
#### 优化
* Android：优化未登录时调用 TUICallKit 接口异常的提示。
* Android： 优化针对 Android 14平台(API 34) 的兼容性，详见：[Android 14 行为变更](https://developer.android.com/about/versions/14/behavior-changes-all?hl=zh-cn)。
* Android&iOS：优化用户昵称的显示，按照如下顺序显示：用户备注 --> 用户昵称 --> 用户 Id，默认为 userId。

#### 修复
* iOS：修复群通话头像显示重叠问题。
* iOS：修复视频通话时开启悬浮窗发消息再回到通话界面键盘无法收起问题。
* iOS：修复视频通话中，先切换摄像头、关闭摄像头，再切换回原摄像头并重新打开时，无法切换和移动摄像头的问题。
* Android：修复在阿拉伯语等从右至左布局模式(RTL模式)下单人视频通话的小窗口无法移动的问题。


## [1.9.0] (2023-10-13)
#### 优化
* Android&iOS：支持阿拉伯语言。
* Android&iOS：优化不同分辨率下的默认码率，高分辨率下画面更清晰，详见 [Resolution](https://cloud.tencent.com/document//product/647/85388#setVideoEncoderParams)。
* Android&iOS：调整视频通话的默认码率为600kbps。
* Android&iOS：优化铃声播放逻辑，主叫端跟随音频设备播放，被叫端默认以扬声器播放。

#### 修复
* Android&iOS：对黑名单用户发起通话，通话拒绝提示与发送单聊消息拒绝提示不一致。
* iOS：4人群视频通话界面，一名成员拒绝接听，发起人视频位置画面异常。


## [1.7.0] (2023-06-02)
#### 新增
* Android&iOS：新增 call、groupCall 支持自定义房间号。
* Android&iOS：TUICallEngine 新增 accept 方法可以用来自动接听。

## [1.4.0] (2023-01-09)

#### 新增
* Android&iOS：增加 TUICallEngine 文件，提供 [hangup](https://cloud.tencent.com/document/product/647/85388#hangup) 方法用来挂断通话。
* Android&iOS：增加 TUICallEngine 文件，提供 [setVideoRenderParams](https://cloud.tencent.com/document/product/647/85388#setVideoRenderParams) 方法用来设置用户视频画面的渲染模式。

#### 修复
* Android&iOS：修复主动加入房间 [joinInGroupCall](https://cloud.tencent.com/document/product/647/78763#joiningroupcall) 时通话异常结束问题。
* Android：修复在音视频通话接听中退后台，再回到前台时，通话状态异常问题。


## [1.3.0] (2022-12-19)
#### 修复
* Android&iOS：修复服务端解散房间或踢出用户时，通话界面不消失问题。
* Android：修复A呼叫离线用户B，然后取消；A 再次呼叫 B，B 上线后通话界面不显示问题。


## [1.2.0] (2022-11-26)
#### 优化
* Android&iOS：优化部分 TUICallObserver 回调异常问题。
* Android&iOS：优化视频切语音功能，支持离线状态下切换。
* Android&iOS：完善 TUICallKit 的错误码及错误提示。

#### 修复
* Android&iOS：修复重新登录账号后，仍会收到之前已拒绝的来电问题。
* Android：修复单聊中收到群聊邀请，通话异常挂断问题。
* Android：多场景退出直播间无法发起通话异常问题。
* Android：修复 A 呼叫 B，同时 B 呼叫 C，C 概率性进入 A 的房间问题。

