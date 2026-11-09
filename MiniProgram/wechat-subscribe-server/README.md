# 小程序订阅消息服务端 Demo

微信小程序订阅消息下发的最小服务端示例（Node.js + Express）。

> 示例仅供参考，正式上线前需进一步完善，例如服务器负载均衡、接口并发控制、信息持久化存储等。

## 前提条件

- 已在[微信公众平台](https://mp.weixin.qq.com/)「功能 → 订阅消息」完成开通，并在「我的模板」中获得**模板 ID**。
- 记录小程序的 **AppID** 与 **AppSecret**（开发 → 开发管理 → 开发设置）。
- 业务后台域名已加入小程序的 **request 合法域名**；开发阶段可在微信开发者工具勾选「详情 → 本地设置 → 不校验合法域名」。
- 运行环境：Node.js ≥ 22，npm ≥ 6。

## 快速开始

```bash
cd MiniProgram/wechat-subscribe-server
npm install
cp .env.example .env   # 填入 AppID / AppSecret / 模板 ID / DEMO_OPENID
npm start
```

`.env` 字段说明：

| 字段 | 说明 |
| --- | --- |
| `WX_APPID` | 小程序 AppID |
| `WX_SECRET` | 小程序 AppSecret，仅通过环境变量注入，不要写入代码或提交仓库 |
| `WX_TEMPLATE_ID` | 订阅消息模板 ID |
| `WX_MINIPROGRAM_STATE` | `developer` 开发版 / `trial` 体验版 / `formal` 正式版 |
| `WX_NOTIFY_PAGE` | 点击消息后打开的小程序路径，默认 `pages/index/index` |
| `DEMO_OPENID` | 演示用接收方 openid，正式环境请改为查询用户表 |
| `PORT` | 监听端口，默认 3000 |

## 接口

| 接口 | 说明 |
| --- | --- |
| `GET /api/config` | 供小程序端在 `onLoad` 阶段提前取得模板 ID |
| `POST /api/login` | 用 `wx.login` 的 `code` 调用 `auth.code2Session` 换取 `openid`，示例中不落库 |
| `POST /api/notify/send` | 获取 `access_token` 后调用 `subscribeMessage.send` 下发消息 |

下发示例：

```bash
curl -X POST http://localhost:3000/api/notify/send \
  -H "Content-Type: application/json" \
  -d '{"receiverId":"业务用户ID","content":"测试消息"}'
```

返回 `data.errcode` 为 `0` 表示已下发。

## 注意事项

- `data` 的字段名与类型由模板决定，不可自定义：`thing` 限 20 个字符，`time` 须形如 `2026年11月5日 14:30`，所有类型均不支持 emoji 与换行符，不符合时下发接口返回 `47003`。示例中的 `sanitize`、`formatTime` 用于满足该限制。
- `access_token` 按 AppID 全局唯一、有效期 7200 秒。示例使用进程内缓存，多实例部署须改为 Redis 等集中缓存，否则会随机出现 `40001`。
- `miniprogram_state` 为 `developer` 时仅开发版可接收消息；使用体验版或正式版测试需同步改为 `trial` 或 `formal`，否则消息不会送达但下发接口仍返回成功。

## 参考文档

- [订阅消息](https://developers.weixin.qq.com/miniprogram/dev/framework/open-ability/subscribe-message.html)
- [小程序登录](https://developers.weixin.qq.com/miniprogram/dev/framework/open-ability/login.html)
- [auth.code2Session](https://developers.weixin.qq.com/miniprogram/dev/server/API/user-login/api_code2session.html)
- [wx.requestSubscribeMessage](https://developers.weixin.qq.com/miniprogram/dev/api/open-api/subscribe-message/wx.requestSubscribeMessage.html)
- [subscribeMessage.send](https://developers.weixin.qq.com/miniprogram/dev/server/API/mp-message-management/subscribe-message/api_sendmessage.html)
