_English | [简体中文](README-zh_CN.md)_
# Quick Run of TUICallKit Demo for Android

This document describes how to quickly run the TUICallKit demo project to make a high-quality audio/video call. For more information on the TUICalling component connection process, see **[Integrating TUICallKit (Android)](https://www.tencentcloud.com/document/product/647/36066)**.

## Directory Structure

```
├─ app             // Main panel, which is the entry of the audio/video call scenario
├─ debug           // Debugging code
└─ tuicallkit-kt   // Real-time audio/video call business logic
```

## Environment Requirements
- Compatibility with Android 4.2 (SDK API Level 17) or above is required. Android 5.0 (SDK API Level 21) or above is recommended
- Android Studio 3.5 or above

## Run Demo

#### Step 1. Create a TRTC application
1. Go to the [Application management](https://console.trtc.io/) page in the TRTC console, click **Create Application**, enter an application name such as `TUICallKit`, and click **Confirm**.
2. Please record the SDKAppID and SDKSecretKey.

[](id:ui.step2)
#### Step 2. Download the source code and configure the project
1. Clone or directly download the source code in the repository. **Feel free to star our project if you like it.**
2. Find and open the `Android/debug/src/main/java/com/tencent/liteav/debug/GenerateTestUserSig.java` file.
3. Set parameters in `GenerateTestUserSig.java`:
	- SDKAPPID: A placeholder by default. Set it to the `SDKAppID` that you noted down in step 1.
	- SECRETKEY: A placeholder by default. Set it to the key information that you noted down in step 1.

#### Step 3. Compile and run the application
Open the source code directory `TUICalling/Android` in Android Studio, wait for the Android Studio project to be synced, connect to a real device, and then click **Run** to try out the application.

#### Step 4. Try out the demo

Note: You need to prepare at least two devices to try out the call feature of TUICallKit. Here, users A and B represent two different devices:

## Have any questions?
Welcome to join our Telegram Group to communicate with our professional engineers! We are more than happy to hear from you~
Click to join: https://t.me/+EPk6TMZEZMM5OGY1.

