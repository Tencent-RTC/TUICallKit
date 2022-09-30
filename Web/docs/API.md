## TUICallKit API 简介

TUICallKit API 是音视频通话组件的**含 UI 接口**，使用 TUICallKit API，您可以通过简单接口快速实现一个类微信的音视频通话场景，更详细的接入步骤，详见：[快速接入TUICallKit](https://cloud.tencent.com/document/product/647/78731)

[](id:TUICallKit)
## API 概览


| API | 描述 |
|-----|-----|
| [init](#init) | 初始化 TUICallKit |
| [call](#call) | 发起 1v1 通话 |
| [groupCall](#groupcall) | 发起群组通话 |
| [destroyed](#destroyed) | 销毁 TUICallKit |

[](id:TUICallEngine)
## API 详情

### init

初始化 TUICallKit，需在 call, groupCall 之前进行。

```javascript
import { TUICallKitServer } from "./src/components/TUICallKit/Web";
TUICallKitServer.init({
  SDKAppID,
  userID, 
  userSig,
  tim, 
});
```

参数如下表所示：

| 参数 | 类型 | 含义 |
|-----|-----|-----|
| SDKAppID | Number | 云通信应用的 SDKAppID  |
| userID | String | 当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（_） |
| userSig | String |腾讯云设计的一种安全保护签名，获取方式请参考 如何计算 [UserSig](https://cloud.tencent.com/document/product/647/17275) |
| TIM 实例 | Any | （选填）tim 参数适用于业务中已存在 TIM 实例，为保证 TIM 实例唯一性 |


### call
拨打电话（1v1通话）。

```javascript
import { TUICallKitServer } from "./src/components/TUICallKit/Web";
TUICallKitServer.call({
  userID: 'jack',
  type: 1,
});
```

参数如下表所示：

| 参数 | 类型 | 含义 |
|-----|-----|-----|
| userID | String | 目标用户的 userId |
| type | Number | 通话的媒体类型，语音通话(type = 1)、视频通话(type = 2) |

### groupCall
发起群组通话。

```javascript
import { TUICallKitServer } from "./src/components/TUICallKit/Web";
TUICallKitServer.groupCall({
  userIDList: ['jack', 'tom'],
  groupID: 'xxx',
  type: 1,
});
```

参数如下表所示：

| 参数 | 类型 | 含义 |
|-----|-----|-----|
| userIDList | Array<String> | 邀请列表成员列表 |
| groupID | String | 呼叫群组ID |
| type | Number | 通话的媒体类型，语音通话(type = 1)、视频通话(type = 2) |

### destroyed
销毁 TUICallKit。

```javascript
import { TUICallKitServer } from "./src/components/TUICallKit/Web";
TUICallKitServer.destroyed();
```