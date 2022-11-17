# **# Quick Run of TUICallKit Demo for Flutter**
English | [简体中文](https://github.com/tencentyun/TUICallKit/blob/main/Flutter/example/README_zh-CN.md)

This document describes how to quickly run the TUICalling demo project to make a high-quality audio/video call. For more information on the TUICalling component connection process.
## Environment Requirements
- **Flutter 3.0or above**
- **Developing for Android:**
  - Android Studio 3.5 or above
  - Devices with Android 4.1 or above
- **Developing for iOS:**
  - Xcode 13.0 or above
  - Your project has a valid developer signature.
  
## Run Example

### 1. Prerequisites
You have registered [ Tencent Cloud](https://www.tencentcloud.com/document/product/378/17985) account and completed [Verified](https://www.tencentcloud.com/document/product/378/3629).

### 2. Apply SDKAPPID and SECRETKEY

1. Log in to [Instant Messaging Console](https://console.tencentcloud.com/im), click Create New Application, enter your application name in the pop-up dialog box, and click OK.
![](https://qcloudimg.tencent-cloud.cn/raw/a14ea709384cbff7228bef12443769b1.png)

2. Click the newly created application to enter the basic configuration page,  and find the function area of activating Tencent Real-Time Communication service in the lower right corner of the page,  then click Free Trial to activate the 60-day free trial service of TUICallKit. If you need to launch the official application, you can click Go to Add Purchase to enter the purchase page.
![](https://qcloudimg.tencent-cloud.cn/raw/fd8b152a82875cb0bdae1721452346a1.png)

3. Find the SDKAppID and key on the same page and record them, which will be used in configuring the Demo project file.
![](https://qcloudimg.tencent-cloud.cn/raw/64f4d25acc14a909c2e51d025d3765ec.png)

### 3. Configure Example project file

1. Open the [generate_test_user_sig.dart](lib/debug/generate_test_user_sig.dart) file in the lib/debug directory.
2. Configure two parameters in the `generate_test_user_sig.dart` file:
  - SDKAPPID: Replace this variable with the SDKAppID you saw on the page in the previous step.
  - SECRETKEY: Replace this variable with the key you saw on the page in the previous step.
 ![ #900px](https://qcloudimg.tencent-cloud.cn/raw/883a8a9ce075d919b323b955f9523742.png)
> The method for generating `UserSig` described in this document involves configuring `SECRETKEY` in client code. In this method, `SECRETKEY` may be easily decompiled and reversed, and if your key is disclosed, attackers can steal your Tencent Cloud traffic. Therefore, **this method is suitable only for the local execution and debugging**.
>
> The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can send a request to the business server for a dynamic `UserSig`. For more information, please see [How do I calculate UserSig on the server?](https://www.tencentcloud.com/document/product/647/35166).


### 4. Compile and Run the application

#### Android 
**Setp1**：Install dependencies.

```
flutter pub get
```

**Setp2**：After checking that the device is connected normally, execute the following command to compile and installing.

```
flutter run
```
#### iOS
**Setp1**：Install dependencies

```
flutter pub get
```
**Setp2**：After checking that the device is connected normally, execute the following command to compile and installing.

```
cd ios
pod install
```
**Setp3**：Use XCode (version 13.0 and above) to open the `example/` iOS Project ,  then compile and run the example project.
