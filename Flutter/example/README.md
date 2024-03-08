# **# Quick Run of TUICallKit Demo for Flutter**
English | [简体中文](https://github.com/tencentyun/TUICallKit/blob/main/Flutter/example/README_zh-CN.md)

This document describes how to quickly run the TUICalling demo project to make a high-quality audio/video call. For more information on [the TUICalling component connection process](https://trtc.io/document/50989).
## Environment Requirements
- **Flutter 3.0or above**
- **Developing for Android:**
  - Android Studio 3.5 or above
  - Devices with Android 4.1 or above
- **Developing for iOS:**
  - Xcode 13.0 or above
  - Your project has a valid developer signature.
  
## Run Example

### 1. Activate audio and video call services

Go to the corresponding console to activate the audio and video call services based on your region:

- For Mainland China, please refer to [the China Station audio and video call service activation document](https://cloud.tencent.com/document/product/647/82985#f3603978-aa95-43b9-8d56-44880636bc6f) to activate the service.
- For non-Mainland China regions, please refer to [the International Station audio and video call service activation document](https://trtc.io/document/54896#step-1.-activate-the-service) to activate the service.


### 2. Configure Example project file

1. Open the [generate\_test\_user\_sig.dart](lib/debug/generate_test_user_sig.dart) file in the lib/debug directory.

2. Configure two parameters in the `generate_test_user_sig.dart` file:

- SDKAPPID: Replace this variable with the SDKAPPID created for your application in the console.
- SECRETKEY: Replace this variable with the secret key corresponding to the SDKAPPID created for your application in the console.

 ![ #900px](https://qcloudimg.tencent-cloud.cn/raw/883a8a9ce075d919b323b955f9523742.png)
> The method for generating `UserSig` described in this document involves configuring `SECRETKEY` in client code. In this method, `SECRETKEY` may be easily decompiled and reversed, and if your key is disclosed, attackers can steal your Tencent Cloud traffic. Therefore, **this method is suitable only for the local execution and debugging**.
>
> The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can send a request to the business server for a dynamic `UserSig`. For more information, please see [How do I calculate UserSig on the server?](https://www.tencentcloud.com/document/product/647/35166).


### 3. Compile and Run the application

#### Android 
**Setp1**：Execute the following command to install Flutter dependencies:

```
flutter pub get
```

**Setp2**：After checking that the device connection is normal, execute the following command to compile and install (select an Android device):

```
flutter run
```
#### iOS
**Setp1**：Execute the following command to install Flutter dependencies:

```
flutter pub get
```
**Setp2**：Navigate to the example/ios directory and execute the following command to install Cocoapods dependencies:

```
pod install
```
**Setp3**：After checking that the device connection is normal, you can open the /ios project in the example directory using Xcode to compile and run, or you can directly execute the following command (select an iOS device):

```
flutter run
```
##Common issues
Q: After updating the SDK version, iOS CocoaPods reports an error during execution?

1. Execute pod repo update.
2. Execute pod update.
3. Recompile and run.

