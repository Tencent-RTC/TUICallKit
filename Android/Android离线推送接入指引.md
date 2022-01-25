本文档主要介绍Android离线推送TPNS接入常见问题。
## 前提条件
Android端移动推送TPNS接入需要进行以下步骤：
### 1. 创建产品和应用
请参考：[创建产品和应用](https://cloud.tencent.com/document/product/548/37241)
### 2. 厂商接入
请参考：[厂商通道接入指南](https://cloud.tencent.com/document/product/548/45909)

## TPNS接入
如需使用音视频通话demo离线推送功能，请先阅读下方链接了解TPNS接入方式，了解消息的分发和处理。
>
[移动推送TPNS-Android快速接入](https://cloud.tencent.com/document/product/548/43211)  
[SDK集成](https://cloud.tencent.com/document/product/548/36652)

1. 找到并打开`TUICalling/Debug/src/main/java/com/tencent/liteav/debug/GenerateTestUserSig.java`文件，设置文件中的相关参数：
<ul style="margin:0"><li/>SDKAPPID：默认为占位符（PLACEHOLDER），请设置为实际的 SDKAppID。
<li/>SECRETKEY：默认为占位符（PLACEHOLDER），请设置为实际的密钥信息。</ul>

 ![#600px](https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/sdkappid_secretkey.png)

2. 在TPNS控制台点击快速接入，下载`tpns-config.json`文件，替换工程中的同名文件
  ![#600px](https://qcloudimg.tencent-cloud.cn/raw/77a1fdbb89d0c93595441a2380ab2bb3.png)

3. 修改应用包名为自己的包名   

TUICalling/ App/build.gradle 修改包名为腾讯云控制台注册的应用包名。
```
applicationId '应用包名'
```
4. 修改TPNS接入的`XG_ACCESS_ID`和`XG_ACCESS_KEY`。  
   这两个值在上述第2步下载的`tpns-config.json`中获取。
```
TUICalling/ App/build.gradle
manifestPlaceholders = [
        // TPNS 推送服务 accessId、accessKey
        XG_ACCESS_ID : "",
        XG_ACCESS_KEY: ""
]
```
## 常见问题
### 遇到问题请先查阅以下文档   
[Android 常见问题](https://cloud.tencent.com/document/product/548/36674)    
[Android 错误码](https://cloud.tencent.com/document/product/548/36660)

### 收不到通知
前提：用厂商控制台进行推送测试，能成功说明厂商通道没有问题。再检查`TPNS`控制台厂商参数配置是否正确，按要求进行填写。（经测试：vivo x9必须配置消息类别）。
1. 部分手机收到通知会放到`不重要的通知`中，请下拉状态栏，检查是否归纳到`不重要的通知`中
2. TPNS注册失败 -- 错误码 :  -502
```
TPNSPushSetting: tpush register failed errCode:-502，errorMsg:mqtt connect error
```
首先，请检查SDKAPPID输入正确
> SDKAPPID是绑定的IM应用的账号，查看IM账号信息：[IM应用](https://console.cloud.tencent.com/im)

如果没有该应用，请在TRTC控制台注册腾讯云账号，并创建相关TRTC应用(即IM应用，注册TRTC应用后会同时生成IM应用)。
其次，TPNS应用需要和IM应用绑定。进入[TPNS配置界面](https://console.cloud.tencent.com/tpns/service-auth)，点击授权。
![#600px](https://qcloudimg.tencent-cloud.cn/raw/cf49adc442289e6e086136545a93c366.png)
![#600px](https://qcloudimg.tencent-cloud.cn/raw/4f3114ec889c0cefd0b593bc9669e4ff.png)
最后，从log排查SDKAPPID是否异常
```
2021-12-14 19:46:49.652 8830-8909/com.tencent.trtc E/imsdk: TIM: |-login.cpp:380                           HandleA2D2OnlineResponse                |error_code:70014|error_message:The requested SDKAppID(1400590001) does not match the Usersig(1400188366). You can run a self-checking with the assistant tool on the console.
```

3. IM证书异常 -- 错误码 : -2201
 ```
com.tencent.trtc D/ThirdPushTokenMgr: setOfflinePushToken failed errorCode = 22001 ， errorMsg = No offline-push certificates have been uploaded.
```
首先，检查SDKAPPID是否正确    
其次，检查域名配置是否正确    
最后，检查TPNS是否绑定IM应用
![#600px](https://qcloudimg.tencent-cloud.cn/raw/62f5102b2ad4d25e8813a21a22b5eba8.png)

在工程App目录下的`AndroidManifest.xml`文件中，配置同样的域名(其他地区域名请参考官网文档 [SDK集成](https://cloud.tencent.com/document/product/548/36652))。
```
<meta-data
        android:name="XG_SERVER_SUFFIX"
        android:value="tpns.sh.tencent.com" />
```
### 能收到通知，但是点击通知拉不起界面
检查TPNS控制台厂商配置是否正常

例如：在TPNS控制台点击 小米配置，出现以下界面，配置打开指定界面，填入在App的`AndroidManifest.xml`中配置的界面
>若配置界面没有channelID选项，请联系TPNS后台开启相关权限
>
![#600px](https://qcloudimg.tencent-cloud.cn/raw/23f9ee882464629f5b82fb8a20835b2b.png)
```
<activity
    android:name="应用包名.MainActivity"
    android:launchMode="singleTask"
    android:screenOrientation="portrait">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <data
            android:host="com.tencent.qcloud"
            android:path="/detail"
            android:scheme="pushscheme" />
    </intent-filter>
</activity>
```
### 应用在后台时拉不起界面

请检查应用权限，不同厂商，甚至同一厂商不同Android版本，对应用的开放权限不一致，导致在后台时拉不起界面，请手动开启应用权限。

例如：小米6只需`后台弹出界面`权限，但是红米需要同时打开`后台弹出界面`和`显示悬浮窗`权限。

>如遇到该问题，需要做兼容处理


### 锁屏时无法点亮屏幕
请检查应用权限，不同厂商，甚至同一厂商不同Android版本，对应用的开放权限不一致，导致在锁屏时拉不起界面。
1. 确认打开厂商锁屏下通知权限
   部分厂商统一做了约束，例如小米锁屏下离线通知到达时未亮屏：在设置-锁屏里，点击开关“锁屏来通知时亮屏”，打开开关。
   
2. 确认打开应用锁屏通知权限
   例如：小米 需要锁屏显示权限。  

>如遇到该问题，需要做兼容处理
### 自定义铃声
目前厂商只有小米和华为支持自定义铃声。
先检查是否开启通知铃声权限，各厂商对权限的约束不一致。如遇该问题，需做兼容处理。
1. 小米
   在小米控制台申请通知channelID，填写自定义铃声链接。在Android8.0及以上的版本可支持自定义铃声。低版本经测试，暂不支持。

### 其他问题:
如有其他问题，欢迎加入 `TUI组件交流群:592465424` 一起交流及学习~。