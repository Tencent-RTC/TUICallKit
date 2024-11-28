## Step 1: Download the demo
1. Open the terminal and clone the repository.
```bash
git clone https://github.com/Tencent-RTC/TUICallKit.git
```
2. Install dependencies.
```bash
cd ./TUICallKit/ReactNative
yarn install
yarn add @tencentcloud/call-uikit-react-native
```

## Step 2: Configure the demo
[Go to the Activate Service page](https://trtc.io/document/59832?platform=web&product=call&menulabel=web) and get `the SDKAppID and SDKSecretKey`, then fill them in the `TUICallKit/ReactNative/src/debug/GenerateTestUserSig-es.js` file.

## Step 3: Run the demo
```bash
# TUICallKit/ReactNative
yarn start
```
