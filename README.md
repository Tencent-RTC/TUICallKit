
# 实时语音/视频通话

## 概述

**TUI组件化解决方案**是腾讯云TRTC针对直播、语聊、视频通话等推出的低代码解决方案，依托腾讯在音视频&通信领域的技术积累，帮助开发者快速实现相关业务场景，聚焦核心业务，助力业务起飞！

- [视频互动直播-TUILiveRoom](https://github.com/tencentyun/TUILiveRoom/)
- [多人音视频互动-TUIRoom](https://github.com/tencentyun/TUIRoom/)
- [语音聊天室-TUIVoiceRoom](https://github.com/tencentyun/TUIVoiceRoom/)
- [语音沙龙-TUIChatSalon](https://github.com/tencentyun/TUIChatSalon/)
- [Karaoke-TUIKaraoke](https://github.com/tencentyun/TUIKaraoke/)
- [一起合唱-TUIChorus](https://github.com/tencentyun/TUIChorus/)

更多组件化方案，敬请期待，也欢迎加入我们的QQ交流群：592465424，期待一起交流&学习！

## 发布日志
### Version 9.5 @ 2022.03.07
#### 功能新增
- Android & iOS：增加悬浮窗功能
#### 问题修复
- Android：本地及网络铃声播放异常问题；
#### 功能优化
- Android：优化代码结构，主要包含以下变动
  - 将BrandUtil和PermissionUtil迁移至com.tencent.liteav.trtccalling.model.utils下；
  - 将TRTCCallAudioActivity和TRTCCallVideoActivity合并为BaseCallActivity；  
- iOS：优化设置铃声功能，支持在线资源。

更早期的版本更新历史请点击  [More](./ReleaseNote.md)...
## 效果演示

### 实时视频通话

<table>
<tr>
   <th>主动呼叫</th>
   <th>被叫接听</th>
 </tr>
<tr>
<td><img src="video1.gif" width="300px" height="640px"/></td>
<td><img src="video2.gif" width="300px" height="640px"/></td>
</tr>
</table>

## Demo 体验

| iOS                           | Android                       | 小程序                         |   Web                         |
| ----------------------------- | ----------------------------- | ----------------------------- | ----------------------------- |
| ![](https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/app_download_ios.png) | ![](https://qcloudimg.tencent-cloud.cn/raw/1027a02e38ae4aeb1ec9ef17ac1a953d.png) | ![](https://web.sdk.qcloud.com/component/miniApp/QRcode/tencentTRTC.jpg) |  [1v1音视频通话](https://web.sdk.qcloud.com/component/trtccalling/demo/web/latest/index.html#/login) |

## 文档资源

| iOS                           | Android                       | 小程序                         |   Web                         |
| ----------------------------- | ----------------------------- | ----------------------------- | ----------------------------- |
| [实时视频通话（iOS）](https://cloud.tencent.com/document/product/647/42044) | [实时视频通话（Android）](https://cloud.tencent.com/document/product/647/42045) |  [实时视频通话（小程序）](https://cloud.tencent.com/document/product/647/49379) |  [实时视频通话（Web）](https://cloud.tencent.com/document/product/647/49789) |
| [实时语音通话（iOS）](https://cloud.tencent.com/document/product/647/42046) | [实时语音通话（Android）](https://cloud.tencent.com/document/product/647/42047) | [实时语音通话（小程序）](https://cloud.tencent.com/document/product/647/49363) |  [实时语音通话（Web）](https://cloud.tencent.com/document/product/647/49795) |

## 其他

### 交流&反馈

欢迎加入QQ群进行技术交流和反馈问题，QQ群：592465424

![image-20210622142449407](https://main.qcloudimg.com/raw/1ea3ab1ff36d37c889f4140499585a4a.png)

### 更多信息

访问 Github 较慢的客户可以考虑使用国内下载地址，腾讯云提供有全平台等解决方案，更多信息详见[腾讯云TRTC - SDK 下载](https://cloud.tencent.com/document/product/647/32689) 。

| 所属平台 | Zip下载 | SDK集成指引 | API 列表 |
|:---------:| :--------:|:--------:|:--------:|
| iOS | [下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_iOS_latest.zip)|[DOC](https://cloud.tencent.com/document/product/647/32173) | [API](https://cloud.tencent.com/document/product/647/32258) |
| Android | [下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Android_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32175) | [API](https://cloud.tencent.com/document/product/647/32267) |
| Win(C++)| [下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Win_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32178) | [API](https://cloud.tencent.com/document/product/647/32268) |
| Win(C#)| [下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Win_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32178) | [API](https://cloud.tencent.com/document/product/647/36776) |
| Mac| [下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Mac_latest.tar.bz2)| [DOC](https://cloud.tencent.com/document/product/647/32176) |[API](https://cloud.tencent.com/document/product/647/32258) |
| Web | [下载](https://web.sdk.qcloud.com/trtc/webrtc/download/webrtc_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/16863) |[API](https://cloud.tencent.com/document/product/647/17249) |
| Electron | [下载](https://web.sdk.qcloud.com/trtc/electron/download/TXLiteAVSDK_TRTC_Electron_latest.zip) | [DOC](https://cloud.tencent.com/document/product/647/38549) |[API](https://cloud.tencent.com/document/product/647/38551) |
| 微信小程序 | [下载](https://web.sdk.qcloud.com/component/trtccalling/download/trtc-calling-miniapp.zip) | [DOC](https://cloud.tencent.com/document/product/647/32183) |[API](https://cloud.tencent.com/document/product/647/17018) |