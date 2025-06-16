# TencentCloud-Push

## 简介

使用 uts 开发，基于腾讯云推送服务（Push），支持 iOS 和 Android 推送，同时适配各大厂商推送。

腾讯云推送服务（Push）提供一站式 App 推送解决方案，助您轻松提升用户留存和互动活跃度，支持与腾讯云即时通信 IM SDK、实时音视频 TRTC SDK、音视频通话 SDK、直播 SDK等音视频终端产品协同集成，在不同场景联合使用，提升业务整体功能体验。

<img src="https://qcloudimg.tencent-cloud.cn/image/document/60d714484e54b284cfa440adcc885349.png" width="618" height="456">
<img src="https://qcloudimg.tencent-cloud.cn/image/document/864c391ecf6f2724d26e368e4f09e466.png" width="618" height="444">
<img src="https://qcloudimg.tencent-cloud.cn/image/document/6af60f4b20dd46323e8f901a161a80a9.png" width="618" height="454">

#### 数据可视化，辅助运营策略

<img src="https://qcloudimg.tencent-cloud.cn/image/document/6c422f64900053c38a6bf66fe1103b3f.png" width="618" height="334">

#### 支持推送消息全链路问题排查

<img src="https://qcloudimg.tencent-cloud.cn/image/document/156d43ed48971f9bf865ad0c4e2342e3.png" width="618" height="443">

#### 六地服务部署，严守数据安全

提供了中国、东南亚（新加坡、印尼雅加达）、东北亚（韩国首尔）、欧洲（德国法兰克福）以及北美（美国硅谷）数据存储中心供选择，每个数据中心均支持全球接入。如果您的应用在境外上线且用户主要在境外，您可以根据消息传输需求及合规要求，选择适合您业务的境外数据中心，保障您的数据安全。
<img src="https://qcloudimg.tencent-cloud.cn/image/document/2ffc1a103a42d9c01cfb819cd92bbd1d.png" widht="618" height="308">

## 快速跑通

### 步骤1：创建应用

进入 [控制台](https://console.cloud.tencent.com/im) ，单击创建应用，填写应用名称，选择数据中心，单击确定，完成应用创建。

![](https://qcloudimg.tencent-cloud.cn/image/document/e2761226f7d2bbdfb0a301192316c7d3.png)

### 步骤2：开通推送服务 Push

进入 [推送服务 Push](https://console.cloud.tencent.com/im/push-plugin-push-identifier)，单击立即购买或免费试用 。（每个应用可免费试用一次，有效期7天）

![](https://qcloudimg.tencent-cloud.cn/image/document/a7e1f3847c91a807ec9be3a586f1290f.png)

### 步骤3：下载腾讯云推送服务（Push）并复制 Push SDK 到您的项目中

1. 下载腾讯云推送服务（Push）。
```
npm install @tencentcloud/uni-app-push
```

2. 复制 Push SDK 到您的项目中。

【macOS 端】

``` bash
mkdir -p ./uni_modules/TencentCloud-Push && rsync -av ./node_modules/@tencentcloud/uni-app-push/ ./uni_modules/TencentCloud-Push
```
【Window 端】

``` bash
xcopy .\node_modules\@tencentcloud\uni-app-push .\uni_modules\TencentCloud-Push /i /e
```

### 步骤4：在 App.vue 中引入并注册腾讯云推送服务（Push）

将 SDKAppID 和 appKey 替换为您在IM 控制台 - 推送服务 Push - 接入设置页面 获取的应用的信息。如图所示：

![](https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/assets/push/push.png)

```ts
// 集成 TencentCloud-Push
import * as Push from '@/uni_modules/TencentCloud-Push';
const SDKAppID = 0; // 您的 SDKAppID
const appKey = ''; // 客户端密钥
Push.registerPush(SDKAppID, appKey, (data) => {
        console.log('registerPush ok', data);
        Push.getRegistrationID((registrationID) => {
            console.log('getRegistrationID ok', registrationID);
        });
    }, (errCode, errMsg) => {
        console.error('registerPush failed', errCode, errMsg);
    }
);

// 监听通知栏点击事件，获取推送扩展信息
Push.addPushListener(Push.EVENT.NOTIFICATION_CLICKED, (res) => {
    // res 为推送扩展信息
    console.log('notification clicked', res);
});

// 监听在线推送
Push.addPushListener(Push.EVENT.MESSAGE_RECEIVED, (res) => {
    // res 为消息内容
    console.log('message received', res);
});

// 监听在线推送被撤回
Push.addPushListener(Push.EVENT.MESSAGE_REVOKED, (res) => {
    // res 为被撤回的消息 ID
    console.log('message revoked', res);
});
```

### <span id="step5">步骤5：测试推送（测试前请务必打开手机通知权限，允许应用通知。）</span>

单击 HBuilderX 的 【运行 > 运行到手机或模拟器 > 制作自定义调试基座】，使用云端证书制作 Android 或 iOS 自定义调试基座。

![](https://qcloudimg.tencent-cloud.cn/image/document/742b7c05364e8ff9a16d5d5601aa038b.png)

自定义调试基座打好后，安装到手机运行。

[登录](https://console.cloud.tencent.com/im/push-plugin-push-check) 控制台，使用测试工具进行在线推送测试。
![](https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/assets/push/test-online-push.png)

## 厂商推送配置
> - 请注意！HBuilderX 4.36 发布了不向下兼容的更新，如果您使用的是 HBuilderX 4.36 或者更高版本，且需要 vivo/荣耀 的厂商推送，
请升级推送版本到 1.1.0 或更高版本，并参考文档正确配置 `manifestPlaceholders.json` 和 `mcs-services.json`。
> - 请在 `nativeResources` 目录下进行推送配置。若项目根目录尚未创建该文件夹，请新建一个名为 `nativeResources` 的文件夹。
> - 离线推送厂商配置完成后，需要打包自定义基座。参考：[[快速跑通]>[步骤5：测试推送（测试前请务必打开手机通知权限，允许应用通知。）]](#user-content-step5)

### 【Android】

1. 新建 nativeResources/android/assets 目录。

2. 在 [推送服务 Push > 接入设置 > 一键式快速配置](https://console.cloud.tencent.com/im/push-plugin-push-identifier) 下载 `timpush-configs.json` 文件，配置到 nativeResources/android/assets 目录下。

3. For 华为：

    配置 `agconnect-services.json` （此文件获取详见 [厂商配置 > uniapp > 华为 > 步骤4：获取应用信息](https://cloud.tencent.com/document/product/269/103769)）到 nativeResources/android 目录下。

4. For Google FCM：

    4.1. 编辑 uni_modules/TencentCloud-Push/utssdk/app-android/config.json 的 `project.plugins`，添加 `"com.google.gms.google-services"`，如下：
    ```
    {
      ...
      "project": {
        "plugins": [
          ...
          "com.google.gms.google-services"
        ]
      }
    }
    ```

    4.2. 配置 `google-services.json` 文件到 nativeResources/android/ 目录。

5. For 荣耀：

    5.1. 编辑 uni_modules/TencentCloud-Push/utssdk/app-android/config.json 的 `dependencies`，添加 `"com.tencent.timpush:honor:8.3.6498"`，如下：
    ```
    {
      ...
      "dependencies": [
        ...
        "com.tencent.timpush:honor:8.3.6498"
      ]
    }
    ```

    5.2. 配置 `mcs-services.json` 文件到 nativeResources/android 目录下。

    5.3. 配置 `appID` 到 nativeResources/android/manifestPlaceholders.json 中的 `"HONOR_APPID"`，如下：
    ```
    {
      "HONOR_APPID": ""
    }
    ```

6. For vivo：

    6.1. 编辑 uni_modules/TencentCloud-Push/utssdk/app-android/config.json 的 `dependencies`，添加 `"com.tencent.timpush:vivo:8.3.6498"`，如下：
    ```
    {
      ...
      "dependencies": [
        ...
        "com.tencent.timpush:vivo:8.3.6498"
      ]
    }
    ```

    6.2. 配置 `appID` 和 `appKey` 到 nativeResources/android/manifestPlaceholders.json 中的 `VIVO_APPKEY` 和 `VIVO_APPID`，如下：
    ```
    {
      "VIVO_APPKEY": "",
      "VIVO_APPID": "",
    }
    ```

### 【iOS】

1. 新建 nativeResources/ios/Resources 目录。

2. 在 nativeResources/ios/Resources 中**新建 timpush-configs.json 文件**。

3. 并将在 [IM控制台 > 推送服务 Push > 接入设置](https://console.cloud.tencent.com/im/push-plugin-push-identifier) 获取的证书ID，补充到  timpush-configs.json 文件中。

   ```
   {
       "businessID":"xxx" 
   }
   ```

## 接口

| API | 描述|
|----|---|
| registerPush | 注册推送服务 (必须在 App 用户同意了隐私政策，并且允许为 App 用户提供推送服务后，再调用该接口使用推送服务)。<br>首次注册成功后，TencentCloud-Push SDK 生成该设备的标识 - RegistrationID。<br> 业务侧可以把这个 RegistrationID 保存到业务服务器。业务侧根据 RegistrationID 向设备推送消息或者通知。|
| unRegisterPush | 反注册关闭推送服务。|
| setRegistrationID | 设置注册推送服务使用的推送 ID 标识，即 RegistrationID。<br/>如果业务侧期望业务账号 ID 和推送 ID 一致，方便使用，可使用此接口，此时需注意，此接口需在 registerPush（注册推送服务）之前调用。|
| getRegistrationID | 注册推送服务成功后，获取推送 ID 标识，即 RegistrationID。|
| getNotificationExtInfo | 获取推送扩展信息。|
| getNotificationExtInfo | 收到离线推送时，点击通知栏拉起 app，调用此接口可获取推送扩展信息。|
| addPushListener | 添加 Push 监听器。|
| removePushListener | 移除 Push 监听器。|
| disablePostNotificationInForeground | 应用在前台时，开/关通知栏通知。|
| createNotificationChannel | 创建客户端通知 channel。|


```ts
registerPush(SDKAppID: number, appKey: string, onSuccess: (data: string) => void, onError?: (errCode: number, errMsg: string) => void);
```

|属性|类型|必填|说明|
|----|---|----|----|
|SDKAppID|number|是|推送（Push）应用 ID|
|appKey|string|是|推送（Push）应用客户端密钥|
|onSuccess|function|是|接口调用成功的回调函数|
|onError|function|否|接口调用失败的回调函数|

```ts
unRegisterPush(onSuccess: () => void, onError?: (errCode: number, errMsg: string) => void): void;
```

|属性|类型|必填|说明|
|----|---|----|----|
|onSuccess|function|是|接口调用成功的回调函数|
|onError|function|否|接口调用失败的回调函数|

```ts
setRegistrationID(registrationID: string,  onSuccess: () => void): void;
```

|属性|类型|必填|说明|
|----|---|----|----|
|registrationID|string|是|设备的推送标识 ID，卸载重装会改变。|
|onSuccess|function|是|接口调用成功的回调函数|


```ts
getRegistrationID(onSuccess: (registrationID: string) => void): void;
```

|属性|类型|必填|说明|
|----|---|----|----|
|onSuccess|function|是|接口调用成功的回调函数|

```ts
getNotificationExtInfo(onSuccess: (extInfo: string) => void): void;
```

|属性|类型|必填|说明|
|----|---|----|----|
|onSuccess|function|是|接口调用成功的回调函数|

```ts
addPushListener(eventName: string, listener: (data: any) => void);
```

|属性|类型|必填|说明|
|----|---|----|----|
|eventName|string|是|推送事件类型|
|listener|function|是|推送事件处理方法|

```ts
removePushListener(eventName: string, listener?: (data: any) => void);
```

|属性|类型|必填|说明|
|----|---|----|----|
|eventName|string|是|推送事件类型|
|listener|function|否|推送事件处理方法|

```ts
disablePostNotificationInForeground(disable: boolean);
```

|属性|类型|必填|说明|
|----|---|----|----|
|disable|boolean|是|应用在前台时，开/关通知栏通知，默认开<br/> - true: 应用在前台时，关闭通知栏通知。<br/> - false: 应用在前台时，开启通知栏通知。|

```ts
createNotificationChannel(options: any, listener: (data: any) => void);
```

|属性|类型|必填|说明|
|----|---|----|----|
|options.channelID|string|是|自定义 channel 的 ID|
|options.channelName|string|是|自定义 channel 的名称|
|options.channelDesc|string|否|自定义 channel 的描述|
|options.channelSound|string|否|自定义 channel 的铃音，音频文件名，不带后缀，音频文件需要放到 xxx/nativeResources/android/res/raw 中。<br/> 例如：<br/> `options.channelSound = private_ring`，即设置 `xxx/nativeResources/android/res/raw/private_ring.mp3` 为自定义铃音|
|listener|function|是|接口调用成功的回调函数|
