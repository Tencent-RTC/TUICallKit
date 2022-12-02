# API 简介

TUICallKit API 是音视频通话组件的**含 UI 接口**，使用 TUICallKit API，您可以通过简单接口快速实现一个类微信的音视频通话场景，更详细的接入步骤，详见：[快速接入TUICallKit](https://cloud.tencent.com/document/product/647/78731)

## API 概览

- [`<TUICallKit/>`](#tuicallkit-api-详情)：UI 通话组件主体
- [`<TUICallKitMini/>`](#tuicallkitmini-api-详情)：UI 通话悬浮窗，若 `<TUICallKit/>` `allowedMinimized` 设置为 `true`，则 `<TUICallKitMini/>` 必须被放置在页面中
- [`TUICallKitServer`](#tuicallkitserver-api-详情): 通话实例，成员函数：
  - [init](#init) 初始化 TUICallKit 
  - [call](#call) 发起 1v1 通话 
  - [groupCall](#groupcall) 发起群组通话 
  - [destroyed](#destroyed) 销毁 TUICallKit 

----

## `<TUICallKit/>` API 详情

### 属性

| 参数 | 说明 | 类型 | 是否必填 | 默认值 |
| -----|-----|-----|-----|-----|
| allowedMinimized | 是否允许最小化，最小化按钮会隐藏 | boolean | 否 | false | 
| allowedFullScreen | 是否允许全屏，全屏按钮会隐藏 | boolean | 否 | true | 

### 方法 

| 参数 | 说明 | 类型 | 是否必填 | 默认值 |
| -----|-----|-----|-----|-----|
| beforeCalling | 拨打电话前与收到通话邀请前会执行此函数 | function(type, error) | 否 | - | 
| afterCalling | 结束通话后会执行此函数 | function() | 否 | - | 
| onMinimized | 组件切换最小化状态时会执行此函数 | function(oldStatus, newStatus) | 否 | - | 

## `<TUICallKitMini/>` API 详情 

无。

## 示例代码 

```javascript
/**
* beforeCalling 
 * @param { string } type 值为 "invited" ｜ "call" ｜ "groupCall"， 可用于区分是来电还是拨打
 * @param { number } error.code 错误码
 * @param { string } error.type 错误类型
 * @param { string } error.code 错误信息
 */
function beforeCalling(type, error) {
  console.log("通话前 会执行此函数，类型: ", type, error); 
}
function afterCalling() {
  console.log("通话后 会执行此函数");
}
/**
 * onMinimized 
 * @param { boolean } oldStatus 
 * @param { boolean } newStatus 
 */
function onMinimized(oldStatus, newStatus) {
  if (newStatus === true) {
    console.log("TUICallKit 进入最小化状态");
  } else {
    console.log("TUICallKit 退出最小化状态");
  }
}
```

```html
<TUICallKit
  :allowedMinimized="true"
  :allowedFullScreen="true"
  :beforeCalling="beforeCalling"
  :afterCalling="afterCalling"
  :onMinimized="onMinimized"
/>
<TUICallKitMini />
```
## TUICallKitServer API 详情

### init

初始化 TUICallKit，需在 call, groupCall 之前进行。

```javascript
import { TUICallKitServer } from "./components/TUICallKit/Web";
TUICallKitServer.init({
  SDKAppID,
  userID, 
  userSig,
  tim, 
});
```

参数如下表所示：

| 参数 | 类型 | 是否必填 | 含义 |
|-----|-----|-----|-----|
| SDKAppID | Number | 是 | 云通信应用的 SDKAppID  |
| userID | String | 是 | 当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（_） |
| userSig | String | 是 | 腾讯云设计的一种安全保护签名，获取方式请参考 如何计算 [UserSig](https://cloud.tencent.com/document/product/647/17275) |
| TIM 实例 | Any | 否 | tim 参数适用于业务中已存在 TIM 实例，为保证 TIM 实例唯一性 |

### call
拨打电话（1v1通话）。

```javascript
import { TUICallKitServer } from "./components/TUICallKit/Web";
TUICallKitServer.call({
  userID: 'jack',
  type: 1,
});
```

参数如下表所示：

| 参数 | 类型 | 是否必填 | 含义 |
|-----|-----|-----|-----|
| userID | String | 是 | 目标用户的 userId |
| type | Number | 是 | 通话的媒体类型，语音通话(type = 1)、视频通话(type = 2) |
| timeout | Number | 否 | 通话的超时时间，0 为不超时, 单位 s(秒)（选填） - 默认 30s |
| offlinePushInfo | Object | 否 | 自定义离线消息推送（选填）-- 需 tsignaling 版本 >= 0.8.0 |

其中对于 `offlinePushInfo`

| 参数 | 类型 | 是否必填 | 含义 |
|-----|-----|-----|-----|
| offlinePushInfo.title | String | 否 | 离线推送标题（选填） |
| offlinePushInfo.description | String | 否 | 离线推送内容（选填） |
| offlinePushInfo.androidOPPOChannelID | String | 否 | 离线推送设置 OPPO 手机 8.0 系统及以上的渠道 ID（选填） |
| offlinePushInfo.extension | String | 否 | 离线推送透传内容（选填）（tsignaling 版本 >= 0.9.0） |

### groupCall
发起群组通话。

```javascript
import { TUICallKitServer } from "./components/TUICallKit/Web";
TUICallKitServer.groupCall({
  userIDList: ['jack', 'tom'],
  groupID: 'xxx',
  type: 1,
});
```

参数如下表所示：

| 参数 | 类型 | 是否必填 | 含义 |
|-----|-----|-----|-----|
| userIDList | Array<String> | 是 | 邀请列表成员列表 |
| type | Number | 是 | 通话的媒体类型，语音通话(type = 1)、视频通话(type = 2) |
| groupID | String | 是 | 呼叫群组ID |
| timeout | Number | 否 | 通话的超时时间，0 为不超时, 单位 s(秒)（选填） - 默认 30s |
| offlinePushInfo | Object | 否 | 自定义离线消息推送（选填）-- 需 tsignaling 版本 >= 0.8.0 |

其中对于 `offlinePushInfo`, 与 `call` 接口中一致。

### destroyed
销毁 TUICallKit。

```javascript
import { TUICallKitServer } from "./components/TUICallKit/Web";
TUICallKitServer.destroyed();
```
