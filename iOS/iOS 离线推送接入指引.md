## 操作场景

本文档主要指导您如何接入移动推送。

## 前提条件

1. 登录 [移动推送 TPNS 控制台](https://console.cloud.tencent.com/tpns)，单击左侧菜单栏【产品管理】。
2. 进入产品管理页面，单击【新增产品】。
3. 进入新增产品页面，填写产品名称、产品详情、选择产品分类和服务接入点，服务接入点说明参见文档 [全球化部署](https://cloud.tencent.com/document/product/548/41761) 。

![](https://qcloudimg.tencent-cloud.cn/raw/307ac9a0ffb6173395d0fbdc7ad79a86.png)

## 开始配置iOS TUICalling离线推送

如想要接收 APNs 离线消息通知，需要遵从如下几个步骤：

1. [申请 APNs 证书](#ApplyForCertificate)。
2. [为您的 App 添加功能](#AddPushCapability)。
3. [上传证书到 TPNS 控制台](#UploadCertificate)。
4. 在 App 每次登录时，向苹果获取 [deviceToken](#DeviceToken)。
5. 调用 [setAPNS](https://im.sdk.qcloud.com/doc/zh-cn/categoryV2TIMManager_07APNS_08.html#a73bf19c0c019e5e27ec441bc753daa9e) 接口将其上报到 IM 后台。

配置过 APNs 的 App ，当其切到后台或者被用户 Kill 之后，腾讯云就可以通过苹果的 APNs 后台对该设备进行离线消息推送，详细推送原理请参见 [Apple Push Notification Service](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html#//apple_ref/doc/uid/TP40008194-CH8-SW1)。
>!对于已经退出登录（主动登出或者被踢下线）的用户，不会收到任何消息通知。

[](id:ApplyForCertificate)

### 步骤1：申请 APNs 证书

申请 APNs 证书的具体操作步骤请参考官方文档  [开发者帐户帮助](https://help.apple.com/developer-account/#/deveedc0daa0)。

[](id:AddPushCapability)

### 步骤2：为您的 App 添加功能

您可以使用项目编辑器的“Signing & Capabilities”(签名和功能) 面板来为 app 添加推送功能。

1. 在主窗口的项目导航器中，选择所需项目 (名称与您的 app 相同的根组)，然后在右侧显示的项目编辑器中选择所需目标。从“Project/Targets”(项目/目标) 弹出式菜单或大纲视图的“Targets”(目标) 部分中，选取 app 的目标。然后，点按项目编辑器中的“Signing & Capabilities”(签名和功能) 标签。
2. 点按构建配置左侧的“+ Capability”(+ 功能) 或选取“Editor”(编辑器) >“Add Capability”(添加功能)
3. 在资源库中双击 “Push  Notification” 功能，或将这项功能从资源库拖到“Signing & Capabilities”(签名和功能) 面板上。

示例如下图所示。
![](https://qcloudimg.tencent-cloud.cn/raw/adbcc4d951f171837febc131eaa27c3e.png)

[](id:UploadCertificate)

### 步骤3：上传推送证书到TPNS控制台

1. 登录 [移动推送 TPNS 控制台](https://console.cloud.tencent.com/tpns)，找到对应产品，点击【立即配置】。
2. 单击【iOS应用】展开应用详情，找到【应用信息】，单击【渠道配置】。
![](https://qcloudimg.tencent-cloud.cn/raw/fd2cc7e3a416f729378cc1f4d834d6b7.png)
3. 输入 iOS 平台 BundleID，单击【保存】，即可完成基本配置。
4. 进入配置管理页面，单击【上传证书】栏目，输入推送证书密码并选择证书。
5. 单击【上传】，将您的 iOS 推送证书上传至管理台，即可完成 iOS 应用配置。
	 ![](https://main.qcloudimg.com/raw/753b994fe6f8a5ee59724469967b0258.jpg)

>!
>-  BundleID 必须是真实有效的ID
>- 上传证书名最好使用全英文（尤其不能使用括号等特殊字符）。
>- 上传证书需要设置密码，无密码收不到推送。
>- 发布 App Store 的证书需要设置为生产环境，否则无法收到推送。
>- 上传的 p12 证书必须是自己申请的真实有效的证书。

[](id:ConfigDemo)

### 步骤4：App 向苹果后台请求 DeviceToken

您可以在您的 App 中添加如下代码，用来向苹果的后台服务器获取 DeviceToken：

```
// MARK: - 注册远程推送 DeviceToken
func registerRemoteNotifications(with application: UIApplication) {
    if #available(iOS 10, *) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert,.badge,.sound]) { (isGrand, error) in
            // 在此处理回调结果
        }
    } else {
        UIApplication.shared.registerUserNotificationSettings(.init(types:[.alert,.badge,.sound], categories:nil))
    }
        
    // 注册远程通知，获得device Token
    UIApplication.shared.registerForRemoteNotifications()
}

// MARK: 在 AppDelegate 的回调中会返回 DeviceToken，需要在登录后上报给腾讯云后台
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("didRegisterForRemoteNotificationsWithDeviceToken success")
    // 存储 deviceToken
    AppUtils.shared.deviceToken = deviceToken
}
```

[](id:uploadDeviceToken)

### 步骤5：登录 IM SDK 后上传 Token 到腾讯云

在 IM SDK 登录成功后，就可以调用 setAPNS 接口，将 [步骤3](#DeviceToken) 中获取的 DeviceToken 上传到腾讯云后台，实例代码如下：

```
TUILogin.initWithSdkAppID(HttpLogicRequest.sdkAppId)
TUILogin.login(userModel.userId, userSig: userModel.userSig) {
    debugPrint("login success")
    
    // IM登录成功后，处理离线推送相关
    let config = V2TIMAPNSConfig()
    // 苹果后台请求的 deviceToken
    config.token = AppUtils.shared.deviceToken
    
    V2TIMManager.sharedInstance()?.setAPNS(config, succ: {
        debugPrint("setAPNS success")
    }, fail: { code, msg in
        debugPrint("setAPNS error code:\(code), error: \(msg ?? "nil")")
    })
    
    ……
}
```

## 推送格式 

推送格式示例如下图所示。![](https://qcloudimg.tencent-cloud.cn/raw/878ca68919f6f8a24a352f61573dc211.jpeg)

### 多 App 互通

如果将多个 App 中的 `SDKAppID` 设置为相同值，则可以实现多 App 互通。不同 App 需要使用不同的推送证书，您需要为每一个 App [申请 APNs 证书](https://cloud.tencent.com/document/product/269/3898) 并完成 [离线推送配置](#配置推送)。

## 自定义角标
- 默认情况下，当 APP 进入后台后，IMSDK 会将当前 IM 未读消息总数设置为角标。
- 如果想自定义角标，可按照如下步骤设置：
 1. App 调用 `- (void)setAPNSListener:(id<V2TIMAPNSListener>)apnsListener` 接口设置监听。
 2. App 实现 `- (uint32_t)onSetAPPUnreadCount` 接口，并在内部返回需要自定义的角标。
- 如果 App 接入了离线推送，当接收到新的离线推送时，App 角标会在基准角标（默认是 IM 未读消息总数，如果自定义了角标，则以自定义角标为准）的基础上加 1 逐条递增。
```
// MARK: 设置监听
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 监听推送
    V2TIMManager.sharedInstance().setAPNSListener(self)
    // 监听会话的未读数
    V2TIMManager.sharedInstance().addConversationListener(listener: self)
    ……
    return true;
}

// MARK: 未读数发生变化后回调
extension AppDelegate: V2TIMConversationListener {
    func onTotalUnreadMessageCountChanged(_ totalUnreadCount: UInt64) {
        // 自定义操作处理
        ……
    }
}

// MARK: APP 进后台后，自定义 APP 的未读数，如果不处理，APP 未读数默认为所有会话未读数之和
extension AppDelegate: V2TIMAPNSListener {
    func onSetAPPUnreadCount() -> UInt32 {
        // 自定义未读数
        return 100
    }
}
```

## 自定义 iOS 推送提示音

请在调用  [sendMessage](https://im.sdk.qcloud.com/doc/zh-cn/categoryV2TIMManager_07Message_08.html#a3694cd507a21c7cfdf7dfafdb0959e56) 发送消息的时候设置 [offlinePushInfo](https://im.sdk.qcloud.com/doc/zh-cn/interfaceV2TIMOfflinePushInfo.html) 的`iOSSound`字段， `iOSSound` 传语音文件名（带后缀），语音文件需要链接进 Xcode 工程。

## 自定义离线推送展示

请在调用  [sendMessage](https://im.sdk.qcloud.com/doc/zh-cn/categoryV2TIMManager_07Message_08.html#a3694cd507a21c7cfdf7dfafdb0959e56) 发送消息的时候设置  [offlinePushInfo](https://im.sdk.qcloud.com/doc/zh-cn/interfaceV2TIMOfflinePushInfo.html) 的`title` 和 `desc`字段，其中 `title` 设置后，会在默认的推送内容上多展示 `title` 内容，`desc` 设置后，推送内容会变成 `desc` 内容。
