# TUICallKit basic demo

<b> English </b> | <a href="https://github.com/tencentyun/TUICallKit/blob/main/Web/demos/basic-react/README.zh-CN.md"> 简体中文 </a>

## Overview

This the basic demo shows how to integrate TUICallKit voice/video calling component in your project.

- Environment: React ≥ v18.0  is recommended
- With debug panel to quickly experience calling
- [Live Demo](https://web.sdk.qcloud.com/component/TUICallKit/demos/basic-react/index.html)

## Getting Started

### Installation

1. clone the repository

```
git clone https://github.com/tencentyun/TUICallKit.git
```

2. enter the demo directory

```shell
cd ./TUICallKit/Web/demos/basic-react
```

3. install dependencies

```shell
npm install
```

4. run the demo

```shell
npm run dev
```
### How to use

1. Open the running page, fill in the parameters in the bottom debug panel (if not currently available, read the [hint](#How-to-get-SDKAppID-and-SecretKey？) first).

    - SDKAPPID
    - SECRETKEY
    - UserID: such as `user1`

<div style="margin-left:43px">
<img style="width:300px; max-width: inherit;" src="https://web.sdk.qcloud.com/component/TUICallKit/image/react-debug.png"/>
</div>


2. Then click on the login button, and if you see `userId: (user1)`, it means you have successfully logged in.

<div style="margin-left:43px">
<img style="width:400px; max-width: inherit;" src="https://web.sdk.qcloud.com/component/TUICallKit/image/react-loginuser1.jpg"/>
</div>
  
3. Scan the QR code in the top right corner, log in with another `userId: (user2)`, to enable communication between them.

<div style="margin-left:43px">
<img style="width:400px; max-width: inherit;" src="https://web.sdk.qcloud.com/component/TUICallKit/image/react-h5login.png"/>
</div>
  
3. Calling
  
    - Enter `user2` into `user1`'s calling list, click to call
        
    - `user2` will be invited, click accept to start the call

<div style="margin-left:43px">
   <img style="width:400px; max-width: inherit;" src="https://web.sdk.qcloud.com/component/TUICallKit/image/react-call.jpg" />
</div>

## Read more

- [TUICallKit Getting Started](https://www.tencentcloud.com/document/product/647/50993)
- [TUICallKit API](https://www.tencentcloud.com/document/product/647/51015)
- [TUICallKit (Web) FAQs](https://www.tencentcloud.com/document/product/647/51024)

## How to get SDKAppID and SecretKey？

### Activate the service

`TUICallKit` is an audio/video call component developed based on two paid PaaS services: [IM](https://www.tencentcloud.com/document/product/1047/35448) and [TRTC](https://www.tencentcloud.com/document/product/647/35078). You can activate the services and enjoy a 60-day free trial as follows:
1. Log in to the [IM console](https://console.tencentcloud.com/im) and click **Create Application**. In the pop-up window, enter your application name and click **OK**.

<img style="width:500px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/205657194-b70e5de2-e49c-4e57-9371-fe71bd1792d0.png"/>

2. Click the application you just created to enter the **Basic Configuration page**. In the **Tencent Real-Time Communication** area at the bottom right of the page, click **Try now**. In the pop-up window, click **Activate now** to activate a **60-day free trial** of TUICallKit.

<img style="width:500px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/205658037-9ebb754d-d32f-4dea-90ec-60e9332592c1.png"/>

3. On the same page, find and record the **SDKAppID** and **Key**(also called SecretKey), which will be used in subsequent steps.

<img style="width:500px; max-width: inherit;" src="https://user-images.githubusercontent.com/57169560/205658322-067476bd-164e-4ed2-bc15-ec253321f2a7.png"/>

- `SDKAppID`: The IM application ID, which is used for business isolation; that is, calls with different `SDKAppID` values cannot be interconnected.
- `SecretKey`: The IM application key, which needs to be used together with `SDKAppID` to generate the authentication credential `UserSig` for authorized use of IM. It will be used in step 5.
