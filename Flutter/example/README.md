English | [简体中文](https://github.com/tencentyun/TUICallKit/blob/main/Flutter/example/README.zh_CN.md)


# Call UIKit for Flutter Quickstart

[![Platform](https://img.shields.io/badge/platform-flutter-blue)](https://flutter.dev/)
[![Language](https://img.shields.io/badge/language-dart-blue)](https://dart.dev/)


<img src="https://qcloudimg.tencent-cloud.cn/raw/ec034fc6e4cf42cae579d32f5ab434a1.png" align="left" width=120 height=120>TUICallKit is a UIKit about **audio&video calls** launched by Tencent Cloud. By integrating this component, you can write a few lines of code to use the video calling function, TUICallKit support offline calling and multiple  platforms such as Android, iOS, Web, Flutter, etc.

<a href="https://apps.apple.com/cn/app/%E8%85%BE%E8%AE%AF%E4%BA%91%E8%A7%86%E7%AB%8B%E6%96%B9trtc/id1400663224"><img src="https://qcloudimg.tencent-cloud.cn/raw/afe9b8cc4c715346cf3d9feea8a65e33.svg" height=40></a> <a href="https://dldir1.qq.com/hudongzhibo/liteav/TRTCDemo.apk"><img src="https://qcloudimg.tencent-cloud.cn/raw/006d5ed3359640424955baa08dab7c7f.svg" height=40></a> <a href="https://web.sdk.qcloud.com/trtc/webrtc/demo/api-sample/login.html"><img src="https://qcloudimg.tencent-cloud.cn/raw/d326e70750f8bbad7245e229c5bd6d2b.svg" height=40></a>

## Before getting started

This section shows you the prerequisites you need for testing TUICallKit for flutter example app.


### Requirements
- **Flutter 3.0 or above**
- **Developing for Android:**
  - Android Studio 3.5 or above
  - Devices with Android 4.1 or above
- **Developing for iOS:**
  - Xcode 13.0 or above
  - Your project has a valid developer signature.

For more details on installing and configuring the TUICallKit for Flutter, refer to [TUICallKit for Flutter doc](https://trtc.io/document/50989).


## Getting started
#### Create an application

1. Login or Sign-up for an account on [Tencent RTC console](https://console.trtc.io).

2. Create or select a calls-enabled application on the console.

3. Note your application **SDKAppId** and **SDKSecretKey** for future reference.

#### Build and run the example app

1. Clone this repository.

  ```
  git clone https://github.com/tencentyun/TUICallKit.git
  ```

2. Specify the SDKAppID and SDKSecretKey.
 
 To run the example, you need to configure the application's `SDKAppID` and `SDKSecretKey`. Fill in the SDKAppID and SDKSecretKey in the [generate\_test\_user\_sig.dart](lib/debug/generate_test_user_sig.dart) file in the `TUICallKit/Flutter/example/lib/debug` directory.
 

  ```
class GenerateTestUserSig {
    ...
    static int sdkAppId = SDKAppID;
    static String secretKey = 'SDKSecretKey';
    ...
}
  ```
	
3. Build and run the example application on Android or iOS devices. 
 
  Go to the `TUICallKit/Flutter/example` directory and execute the `flutter run` command in the command line to compile and install the application. 
  
4. Install the application on at least two separate devices.

5. If there are not two available devices, you can use an emulator to run the application.

For more detailed information on how to build and run Flutter applications, please refer to [the Flutter documentation](https://flutter.cn/docs/development/tools/devtools/cli).

## Making your first call
1. Log in with different user IDs on two devices;

2.  On one device, enter the single-user call page, fill in the user ID of the other device, select the call type, and make the call;

3. The called party receives the call invitation and clicks to accept to proceed with the call.

## Reference

- If you want to learn more about the product features, you can click on the following [link](https://trtc.io/products/call).

- If you encounter difficulties, you can refer to [FAQs](https://trtc.io/document/53565), here are the most frequently encountered problems of developers, covering various platforms, I hope it can Help you solve problems quickly.

- For complete API documentation, see [Audio Video Call SDK API Example](https://trtc.io/document/54905): including TUICallKit (with UIKit), TUICallEngine (without UIKit), and call events Callbacks, etc.
