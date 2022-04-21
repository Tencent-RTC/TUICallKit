
# 实时语音/视频通话

_[English](README.en.md) | 中文_

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
