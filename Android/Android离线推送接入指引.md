# TUICalling Android 离线推送接入指引

本文档主要介绍如何在TUICalling Demo中快速体验离线推送功能。

TUICalling Demo使用 腾讯云组件 `TUIOfflinePush`，该组件会监听应用的登录状态，自动完成各个厂商的推送服务注册和推送类接口实现。

详情可查看：[离线推送(Android)](https://cloud.tencent.com/document/product/269/44516)。

## 步骤一：前期准备

1、注册应用到厂商推送平台：离线推送功能依赖厂商原始通道，您需要将自己的应用注册到各个厂商的推送平台，得到 APPID 和 APPKEY 等参数。

2、IM 控制台配置：注册厂商通道需要传入自己的包名，各厂商填入的包名需保持一致，用于消息互通。

3、配置离线推送跳转界面

4、配置厂商推送规则

> 具体可参考 [离线推送(Android)](https://cloud.tencent.com/document/product/269/44516) 步骤 1~4。

## 步骤二：修改TUICalling工程配置

1. 修改`app/build.gradle`中的应用包名为自己的包名。
   ```  
   applicationId '您的应用包名'
   ```

2. 打开`app/build.gradle`中的`plugin`注释，设置`ViVo`接入参数`VIVO_APPKEY`和`VIVO_APPID`。
   ```
   manifestPlaceholders = [
      "VIVO_APPKEY": "",
      "VIVO_APPID" : ""
   ]
   ```
3. 检查项目级目录下`build.gradle`中的`Huawei`和`Goole(FCM)`的配置是否打开
    - 在项目级目录下添加华为厂商平台下载的`agconnect-services.json`文件
    - 在项目级目录下替换Google的`google-services.json`文件，该文件中的包名需与您的应用包名保持一致
4. 检查`PrivateConstants`文件中厂商参数是否配置正确。

完成以上步骤，运行`TUICalling`工程，您可以体验`TUICalling`离线唤起功能。

### 其他:

如有其他问题，欢迎加入 `TUI组件交流群:592465424` 一起交流及学习~
