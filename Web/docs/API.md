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

初始化 TUICallKit。

```javascript
import { TUICallKitServer } from 'tuicall-kit-webrtc';
TUICallKitServer.init();
```

### call
拨打电话（1v1通话）。

```javascript
TUICallKitServer.call({
  userID: 'jack',
  type: 1,
})
```

参数如下表所示：

| 参数 | 类型 | 含义 |
|-----|-----|-----|
| userID | String | 目标用户的 userId |
| type | Number | 通话的媒体类型，语音通话(type = 1)、视频通话(type = 2) |

### groupCall
发起群组通话。

```javascript
TUICallKitServer.groupCall({
  userIDList: ['jack', 'tom'],
  groupID: 'xxx',
  type: 1,
})
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
TUICallKitServer.destroyed()
```