
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
### Version 9.5 @ 2022.01.24
#### 功能新增
- Android&iOS：Demo工程增加多人通话场景，完善多人通话功能，优化UI展示；
- Android&iOS：最新接入腾讯云推送服务[TPNS](https://cloud.tencent.com/document/product/548)，优化离线推送相关逻辑；
#### 问题修复
- Android：视频通话】发起视频通话邀请后，切换到语音通话，声音外放问题；
- iOS：修复`shouldShowOnCallView`接口处理逻辑错误问题；
#### 功能优化
- Android&iOS：优化提示策略，让提示更友好；
#### 特别说明
- Android：优化代码目录结构，主要包含如下两处变更：
  - 将原有的TUICallingManager重命名为TUICallingImpl，并迁移至`com.tencent.liteav.trtccalling`下；
  - 将原有的TUICalling迁移至`com.tencent.liteav.trtccalling`下；

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

| iOS                           | Android                       | 小程序                         |
| ----------------------------- | ----------------------------- | ----------------------------- |
| ![](https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/app_download_ios.png) | ![](https://qcloudimg.tencent-cloud.cn/raw/1027a02e38ae4aeb1ec9ef17ac1a953d.png) | ![](https://qcloudimg.tencent-cloud.cn/raw/d45617eb310ec3af51436e6b5ecbaa51.jpg) |

## 文档资源

| iOS                           | Android                       | 小程序                         |
| ----------------------------- | ----------------------------- | ----------------------------- |
| [实时视频通话（iOS）](https://cloud.tencent.com/document/product/647/42044) | [实时视频通话（Android）](https://cloud.tencent.com/document/product/647/42045) |  [实时视频通话（小程序）](https://cloud.tencent.com/document/product/647/49379) |
| [实时语音通话（iOS）](https://cloud.tencent.com/document/product/647/42046) | [实时语音通话（Android）](https://cloud.tencent.com/document/product/647/42047) | [实时语音通话（小程序）](https://cloud.tencent.com/document/product/647/49363) |

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