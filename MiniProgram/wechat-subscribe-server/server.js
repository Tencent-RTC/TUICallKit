require('dotenv').config();
const express = require('express');
const axios = require('axios');

const app = express();
app.use(express.json());

/* ---------------- access_token ---------------- */

// access_token 按 AppID 全局唯一，有效期 7200 秒。
// 多实例部署须改为 Redis 等集中缓存，各实例独立刷新会相互失效，
// 导致随机出现 40001。
let tokenCache = { value: '', expireAt: 0 };

async function getAccessToken() {
  if (tokenCache.value && Date.now() < tokenCache.expireAt) {
    return tokenCache.value;
  }

  const { data } = await axios.get('https://api.weixin.qq.com/cgi-bin/token', {
    params: {
      grant_type: 'client_credential',
      appid: process.env.WX_APPID,
      secret: process.env.WX_SECRET,
    },
  });

  if (data.errcode) {
    throw new Error(`获取 access_token 失败：${data.errcode} ${data.errmsg}`);
  }

  // 提前 5 分钟过期，避免边界失效
  tokenCache = {
    value: data.access_token,
    expireAt: Date.now() + (data.expires_in - 300) * 1000,
  };
  return tokenCache.value;
}

/* ---------------- 业务数据 ---------------- */

/**
 * 取接收方 openid
 * 替换为查询自己的用户表（openid 的获取见「前提条件」）
 */
async function getOpenidByUserId(userId) {
  // return await db.user.findOpenid(userId);
  return process.env.DEMO_OPENID || null; // 演示用，便于先跑通流程
}

/**
 * 模板字段
 * 键名须与自己申请的模板完全一致，值需符合格式限制
 */
function buildTemplateData(content) {
  return {
    thing1: { value: sanitize(content, 20) }, // thing：20 个字符以内
    time2: { value: formatTime(new Date()) }, // time：2026年11月5日 14:30
  };
}

/* ---------------- 接口 ---------------- */

// 供端上在 onLoad 阶段提前取得模板 ID
app.get('/api/config', (req, res) => {
  res.json({ code: 0, data: { templateId: process.env.WX_TEMPLATE_ID } });
});

// 小程序登录：用 code 换取 openid，并与业务用户关联存储
app.post(
  '/api/login',
  asyncHandler(async (req, res) => {
    const { code } = req.body;
    if (!code) return res.status(400).json({ code: 400, message: 'code required' });

    const { data } = await axios.get('https://api.weixin.qq.com/sns/jscode2session', {
      params: {
        appid: process.env.WX_APPID,
        secret: process.env.WX_SECRET,
        js_code: code,
        grant_type: 'authorization_code',
      },
    });

    if (data.errcode) {
      console.error('[login] failed', data.errcode, data.errmsg);
      return res.json({ code: data.errcode, message: data.errmsg });
    }

    // 实际业务中应持久化 openid 与业务用户的映射，并返回自有登录态
    // await db.user.saveOpenid(userId, data.openid);
    res.json({ code: 0, data: { hasOpenid: Boolean(data.openid) } });
  })
);

// 下发订阅消息
app.post(
  '/api/notify/send',
  asyncHandler(async (req, res) => {
    const { receiverId, content } = req.body;

    const openid = await getOpenidByUserId(receiverId);
    if (!openid) return res.json({ code: 404, message: 'openid not found' });

    const token = await getAccessToken();
    const { data: result } = await axios.post(
      'https://api.weixin.qq.com/cgi-bin/message/subscribe/send',
      {
        touser: openid,
        template_id: process.env.WX_TEMPLATE_ID,
        page: process.env.WX_NOTIFY_PAGE || 'pages/index/index', // 点击消息后打开的小程序路径
        miniprogram_state: process.env.WX_MINIPROGRAM_STATE,
        lang: 'zh_CN',
        data: buildTemplateData(content || '您有一条新消息'),
      },
      { params: { access_token: token } }
    );

    // errcode 为 0 表示已下发，其余为失败
    if (result.errcode !== 0) {
      console.error('[send] failed', result.errcode, result.errmsg);
    }

    res.json({
      code: 0,
      data: { sent: result.errcode === 0, errcode: result.errcode, errmsg: result.errmsg },
    });
  })
);

/* ---------------- 工具 ---------------- */

// 过滤 emoji 与换行，并截断至模板长度上限
function sanitize(text, max) {
  const clean = String(text)
    // emoji 主区、符号区，以及变体选择符 FE0F（如 ❤️ 的隐藏字符）
    .replace(/[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{20E3}]/gu, '')
    .replace(/\s+/g, ' ') // 换行与连续空格归一
    .trim();
  return clean.slice(0, max) || '新消息';
}

function formatTime(d) {
  return (
    `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日 ` +
    `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`
  );
}

// Express 4 不会自动捕获 async 路由抛出的异常，需包一层，
// 否则失败时返回的是含堆栈的 HTML 错误页而非 JSON
function asyncHandler(fn) {
  return (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);
}

app.use((err, req, res, next) => {
  console.error('[error]', err.message);
  res.status(500).json({ code: 500, message: err.message });
});

const port = Number(process.env.PORT) || 3000;
app.listen(port, () => console.log(`server on http://localhost:${port}`));
