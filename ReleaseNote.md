## 发布日志

### Version 9.9 @ 2022.05.05
  
#### 问题修复
- Android：修复被叫端接听后，被叫端无法显示主叫端视频画面问题。
  
#### 功能优化
- Android：去除tuicore源码依赖，tuicore通过aar方式引入，不再提供源码目录。
- Android：优化保活机制：通话开始时开启保活，通话结束时关闭保活。
- Android：扬声器和麦克风切换权限`MODIFY_AUDIO_SETTINGS`移植到组件tuicalling下。

### Version 9.6 @ 2022.03.24

#### 编译修复
Android：更新悬浮窗功能调用接口，`FloatCallView.java`和`BaseCallActivity.java`类中 ，`TXCGLSurfaceView`不再支持调用，变更为 `TextureView`


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
