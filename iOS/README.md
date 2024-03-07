# Quick Run of TUICallKit Demo for iOS

_English | [简体中文](README-zh_CN.md)_

This document describes how to quickly run the TUICallKit demo project to make a high-quality audio/video call. For more information on the TUICallKit component connection process, see **[Integrating TUICallKit (iOS)](https://www.tencentcloud.com/document/product/647/46660)**.

## Directory Structure

```
TUICallKit
├─ Example              // Audio/Video call demo project
    ├─ App              // Folder of audio/video call homepage UI code and used images and internationalization string resources
    ├─ Debug            // Folder of the key business code required for project debugging and running
    └─ TXAppBasic       // Dependent basic components of the project
├─ TUICallKit           // Folder of the core business logic code of audio/video call(Objective-C)
├─ TUICallKit-Swift     // Folder of the core business logic code of audio/video call（Swift）
```

## Environment Requirements
- Xcode 13.0 or above
- Operating system: iOS 13.0 or later

## Running the Demo

[](id:ui.step1)
### Step 1. Create a TRTC application
1. Go to the [Application management](https://console.trtc.io/) page in the TRTC console, select **Create Application**, enter an application name such as `TUIKitDemo`, and click **Confirm**.
2. Please record the `SDKAppID` and `SDKSecretKey`.

[](id:ui.step2)
### Step 2. Configure the project
1. Open the demo project `TUICallKitApp.xcworkspace` with Xcode 13.0 or later.
2. Find the `iOS/Example/Debug/GenerateTestUserSig.swift` file in the project.
3. Set parameters in `GenerateTestUserSig.swift`:
<ul style="margin:0"><li/>SDKAPPID: `0` by default. Set it to the SDKAppID that you noted down in step 1.
<li/>SECRETKEY: Left empty by default. Set it to the key information that you noted down in step 1.</ul>

[](id:ui.step3)
### Step 3. Compile and run the application

1. Open Terminal, enter the project directory, run the `pod install` command, and wait for it to complete.
2. Open the demo project `TUICallKit/Example/TUICallKitApp.xcworkspace` with Xcode 11.0 or later and click **Run**.

[](id:ui.step4)
### Step 4. Try out the demo

Note: You need to prepare at least two devices to try out the call feature of TUICallKit. Here, users A and B represent two different devices:

**Device A (userId: 111)**

- Step 1: On the welcome page, enter the username (<font color=red>which must be unique</font>), such as `111`. 
- Step 2: Enter the different scenario pages, such as video call, based on your scenario and requirements.
- Step 3: Enter `userId` of user B to be called, click **Search**, and click **Call**.

**Device B (userId: 222)**

- Step 1: On the welcome page, enter the username (<font color=red>which must be unique</font>), such as `222`.
- Step 2: Enter the homepage and wait for the call.

## Switch to Objective-C version
1. Open the 'Example/Podfile' file and replace 'pod 'TUICallKit-Swift', :path => "../", :subspecs => ["TRTC"]' with 'pod 'TUICallKit', :path => "../", :subspecs => ["TRTC"]'.
1. Run 'pod update' in the console.
1. Open the Example project, select the target -> Build Settings -> search for Swift Compiler - Custom Flags.
1. Expand "Other Swift Flags" and delete "USE_TUICALLKIT_SWIFT" and the corresponding "-D".

## FAQs

### What should I do if the following error messages are still prompted during debugging on a real device when the TUICallKit demo has been configured with a real device certificate?

```
Provisioning profile "XXXXXX" doesn't support the Push Notifications capability.  
Provisioning profile "XXXXXX" doesn't include the aps-environment entitlement.
```

You can delete the `Push Notifications` feature as shown below:

![](https://qcloudimg.tencent-cloud.cn/raw/800bfcdc73e1927e24b5419f09ecef7a.png)


## Have any questions?
Welcome to join our Telegram Group to communicate with our professional engineers! We are more than happy to hear from you~
Click to join: https://t.me/+EPk6TMZEZMM5OGY1
