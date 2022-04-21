# Quick Run of TUICalling Demo for web

_[中文](README.md) | English_

This document describes how to quickly run the TRTCCalling demo for web, which contains the audio call and video call scenarios:

\- Audio call: Refers to audio-only interaction and supports multi-person interactive audio chat.

\- Video call: Refers to video call used in video communication scenarios such as online customer service.

### Environment requirements
* Use the latest version of Chrome.
* TRTCCalling uses the following ports and domain name for data transfer, which should be added to the allowlist of the firewall. After configuration, please use [Official Demo](https://web.sdk.qcloud.com/component/trtccalling/demo/web/latest/index.html) to check whether the ports work.
  - TCP port: 8687
  - UDP ports: 8000, 8080, 8800, 843, 443, 16285
  - Domain name: qcloud.rtc.qq.com

> 
>- Normally, the demo needs to be deployed on the server and then accessed through `https://domain/xxx`. You can also build a server locally and access the demo through `localhost:port`.
> - Currently, the desktop version of Chrome offers better support for the features of TRTC SDK for desktop browsers; therefore, Chrome is recommended for the demo.

### Prerequisites

You have [signed up for a Tencent Cloud account](https://intl.cloud.tencent.com/document/product/378/17985) and completed [identity verification](https://intl.cloud.tencent.com/document/product/378/3629).

### Using demo UI

<span id="step1"></span>

#### Step 1. Create an application

1. Log in to the TRTC console and select **Development Assistance** > **[Demo Quick Run](https://console.cloud.tencent.com/trtc/quickstart)**.

2. Click **Start Now**, enter an application name such as `TestTRTC`, and click **Create Application**.

<span id="step2"></span>

#### Step 2. Download the SDK and demo source code
2. Hover over the block of the platform you use, click **[GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/Web/TRTCScenesDemo/trtc-calling-web)** (or **[ZIP](https://web.sdk.qcloud.com/trtc/webrtc/download/webrtc_latest.zip)**) to download the SDK and demo source code.
 ![](https://main.qcloudimg.com/raw/0f35fe3bafe9fcdbd7cc73f991984d1a.png)
2. After the download, return to the TRTC console and click **Downloaded and Next** to view your `SDKAppID` and key.

<span id="step3"></span>

#### Step 3. Configure demo project files

1. Decompress the source package downloaded in [step 2](#step2).

2. Find and open the `Web/TRTCScenesDemo/TRTCCalling/public/debug/GenerateTestUserSig.js` file.

3. Set parameters in the `GenerateTestUserSig.js` file:

  <ul><li>SDKAPPID: `0` by default. Set it to the actual `SDKAppID`.</li>

  <li>SECRETKEY: Left empty by default. Set it to the actual key.</li></ul> 

  <img src="https://main.qcloudimg.com/raw/0ae7a197ad22784384f1b6e111eabb22.png">

4. Return to the TRTC console and click **Next**.

5. Click **Return to Overview Page**.

>In this document, the method to obtain UserSig is to configure a SECRETKEY in the client code. In this method, the SECRETKEY is vulnerable to decompilation and reverse engineering. Once your SECRETKEY is leaked, attackers can steal your Tencent Cloud traffic. Therefore, ****this method is only suitable for locally running a demo project and feature debugging****.

>The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can send a request to the business server for a dynamic `UserSig`. For more information, see [How do I calculate `UserSig` during production?](https://intl.cloud.tencent.com/document/product/647/35166).

#### Step 4. Run the demo
>- Sync the dependency: npm install
>- Start the project: npm run serve
>- Visit `http://localhost:8080/` in the browser.

- On the demo landing page:
![](https://main.qcloudimg.com/raw/90118deded971621db7bb14b55073bcc.png)
- Enter your user ID and click **Log In**.
![](https://main.qcloudimg.com/raw/f430fb067cddbb52ba32e4d0660cd331.png)
- Enter the user ID of the callee to start a video call.
![](https://main.qcloudimg.com/raw/66562b4c14690de4eb6f2da58ee6f4df.png)
- Video call
![](https://main.qcloudimg.com/raw/592189d0f18c91c51cdf7184853c6437.png)


### Customizing your own UI
#### Step 1. Integrate the SDK
Integration via npm
> Since version 0.6.0, you need to manually install dependencies [trtc-js-sdk](https://www.npmjs.com/package/trtc-js-sdk), [tim-js-sdk](https://www.npmjs.com/package/tim-js-sdk), and [tsignaling](https://www.npmjs.com/package/tsignaling).
>- To reduce the size of trtc-calling-js.js, and prevent version conflict between trtc-calling-js.js and the already in use trtc-js-sdk, tim-js-sdk or tsignaling, which may stop the latter three from being packaged into the former, you need to manually install the dependencies before use.
```javascript
  npm i trtc-js-sdk --save
  npm i tim-js-sdk --save
  npm i tsignaling --save
  npm i trtc-calling-js --save
 
  // If you use trtc-calling-js via script, you need to manually import trtc.js first in the specified order.
  <script src="./trtc.js"></script>
  
  // tim-js.js
  <script src="./tim-js.js"></script>
  
  // tsignaling.js
  <script src="./tsignaling.js"></script>

  // trtc-calling-js.js
  <script src="./trtc-calling-js.js"></script>
```
Import the module into the project script.
```javascript
import TRTCCalling from 'trtc-calling-js';
```
#### Step 2. Create the `trtcCalling` object
>- sdkAppID: `sdkAppID` assigned by Tencent Cloud
```javascript
let options = {
  SDKAppID: 0 // Replace 0 with the `SDKAppID` of your application when connecting
};
const trtcCalling = new TRTCCalling(options);
```

#### Step 3: Log in to the demo
>- userID: User ID.
>- userSig: User signature. For the calculation method, see [userSig](https://cloud.tencent.com/document/product/647/17275).
```javascript
trtcCalling.login({
  userID,
  userSig
});
```

#### Step 4. Make a one-to-one call
>#### Making a call
>- userID: User ID.
>- type: Call type. Valid values: 0: unknown; 1: audio call; 2: video call.
>- timeout: Invitation timeout period in seconds.
```javascript
trtcCalling.call({
  userID,
  type: 2,
  timeout
});
```
>#### Answering call
>- inviteID: Invitation ID, which identifies an invitation.
>- roomID: Room ID.
>- callType: Valid values: 0: unknown; 1: audio call; 2: video call.
```javascript
trtcCalling.accept({
  inviteID,
  roomID,
  callType
});
```
>#### Turning on local camera
```javascript
trtcCalling.openCamera()
```
>#### Displaying a remote image
>- userID: Remote user ID.
>- videoViewDomID: The user's data will be rendered in this DOM node.
```javascript
trtcCalling.startRemoteView({
  userID,
  videoViewDomID
})
```

>#### Displaying a local image
>- userID: Local user ID.
>- videoViewDomID: The user's data will be rendered in this DOM node.
```javascript
trtcCalling.startLocalView({
  userID,
  videoViewDomID
})
```

>#### Hanging up/Rejecting a call
```javascript
trtcCalling.hangup()
```
>- inviteID: Invitation ID, which identifies an invitation.
>- isBusy: Whether the line is busy. Valid values: 0: unknown; 1: audio call; 2: video call
```javascript
trtcCalling.reject({ 
  inviteID,
  isBusy
  })
```

### Supported platforms

| OS |      Browser (Desktop)      | Minimum Browser Version Requirement |
| :------: | :------------------: | :----------------: |
|  macOS  |     Safari     |        11+         |
|  macOS  |     Chrome     |        56+         |
| Windows  |     Chrome     |        56+         |
| Windows  |   QQ Browser   |        10.4        |

### FAQs

#### 1. There is only information of the public and private keys when I try to view the secret key. How do I get the secret key?
TRTC SDK 6.6 (August 2019) and later versions use the new signature algorithm HMAC-SHA256. If your application was created before August 2019, you need to upgrade the signature algorithm to get a new key. Without upgrading, you can continue to use the old algorithm ECDSA-SHA256. After upgrading, you can switch between the new and old algorithms as needed.

Upgrade/Switch:

1. Log in to the TRTC console.

2. Click **Application Management** on the left sidebar, find your application, and click **Application Info**.

3. Select the **Quick Start** tab and click **Upgrade**, **asymmetric encryption**, or **HMAC-SHA256** in **Step 2: obtain the secret key to issue UserSig**.

- Upgrade

   ![](https://main.qcloudimg.com/raw/69bd0957c99e6a6764368d7f13c6a257.png)

- Switch to the old algorithm ECDSA-SHA256:

   ![](https://main.qcloudimg.com/raw/f89c00f4a98f3493ecc1fe89bea02230.png)

- Switch to the new algorithm HMAC-SHA256:

   ![](https://main.qcloudimg.com/raw/b0412153935704abc9e286868ad8a916.png)

#### 2. What firewall restrictions does the SDK face?

As the SDK uses the UDP protocol for audio/video transmission, it cannot be used in office networks that block UDP. If you encounter such a problem, see [Dealing with Organizational Firewall Restrictions](https://cloud.tencent.com/document/product/647/34399) for assistance.
