import { DefaultSdkAppId, DefaultSecretKey } from '@/constants';
import LibGenerateTestUserSig from './lib-generate-test-usersig.min';

const genTestUserSig = function (userID: string) {
  /**
   * 腾讯云 SDKAppId，需要替换为您自己账号下的 SDKAppId。
   *
   * 进入腾讯云实时音视频[控制台](https://console.cloud.tencent.com/rav ) 创建应用，即可看到 SDKAppId，
   * 它是腾讯云用于区分客户的唯一标识。
   */

  const SDKAPPID = DefaultSdkAppId;

  /**
   * 签名过期时间，建议不要设置的过短
   * <p>
   * 时间单位：秒
   * 默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
   */
  const EXPIRETIME = 604800;


  /**
   * 计算签名用的加密密钥，获取步骤如下：
   *
   * step1. 进入腾讯云实时音视频[控制台](https://console.cloud.tencent.com/rav )，如果还没有应用就创建一个，
   * step2. 单击“应用配置”进入基础配置页面，并进一步找到“帐号体系集成”部分。
   * step3. 点击“查看密钥”按钮，就可以看到计算 UserSig 使用的加密的密钥了，请将其拷贝并复制到如下的变量中
   *
   * 注意：该方案仅适用于调试Demo，正式上线前请将 UserSig 计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
   * 文档：https://cloud.tencent.com/document/product/647/17275#Server
   */
  const SECRETKEY = DefaultSecretKey;

  if (SDKAPPID === '' || SECRETKEY === '') {
    const msg = '请先配置好您的账号信息： SDKAPPID 及 SECRETKEY，配置文件位置：assets/debug/gen-test-user-sig.ts';
    console && console.error(msg);
    alert && alert(msg);
  }

  /*
   * 混流接口功能实现需要补齐此账号信息。
   * 获取途径：腾讯云网页控制台->搜索“实时音视频”->应用管理->选择需要的应用，点击“应用信息”->旁路直播信息部分获取 appid 和 bizid
   *
   * CDN直播地址：开启旁路直播时，需要配置CDN直播域名
   * 获取途径：腾讯云网页控制台->搜索“云直播”->域名管理->根据域名信息，构建云播放地址，格式为：https://播放域名/live/[streamId].flv
   */
  const APPID = 0;
  const BIZID = 0;
  const LIVE_DOMAIN = '';

  const generator = new LibGenerateTestUserSig(SDKAPPID, SECRETKEY, EXPIRETIME);
  const userSig = generator.genTestUserSig(userID);

  return {
    sdkAppId: SDKAPPID,
    userSig,
    appId: APPID,
    bizId: BIZID,
    liveDomain: LIVE_DOMAIN,
  };
};

export default genTestUserSig;
