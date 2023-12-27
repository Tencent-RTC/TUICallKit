# userSig 工具包

UserSig 是腾讯云为其云服务设计的一种安全保护签名，是一种登录凭证，由 SDKAppID 与 SecretKey 等信息组合加密得到。

本文件夹为前端调试时使用的 userSig 工具包。

## 如何使用？

> 此方式是在前端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通功能调试**，正式环境请在服务端部署。

为方便初期调试，我们提供了可以生成 userSig 的工具包，可以 [点击此处下载](https://web.sdk.qcloud.com/component/debug.zip)。将其放入您的工程，引入后可临时使用 `GenerateTestUserSig-es.js` 中 `genTestUserSig(params)` 函数来计算签名：

### import 引入

```javascript
import { genTestUserSig } from "./debug/GenerateTestUserSig-es.js";
const { userSig } = genTestUserSig({ userID: "Alice", SDKAppID: 0, SecretKey: "YOUR_SECRETKEY" });
```

### script 引入

```html
<script type="module">
  import { genTestUserSig } from "../debug/GenerateTestUserSig-es.js";
  window.genTestUserSig = genTestUserSig;
</script>
```

## 其他生成方式

### 控制台获取，参考 [获取临时 userSig](https://console.cloud.tencent.com/trtc/usersigtool)

### 正式环境使用

正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向项目的接口，在需要 UserSig 时由您的项目向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig)。