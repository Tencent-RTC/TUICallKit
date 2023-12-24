/* eslint-disable */
/**
 * 生成临时 UserSig，请不要将如下代码发布或者提交到您的代码仓库中。
 *
 * @param {{userID: string, SDKAppID: number, SecretKey: string, ExpireTime?: number}} options
 * @param {string} options.userID - 用户名
 * @param {string} options.SDKAppID：开发者在控制台注册的应用的 SDKAppID
 * @param {string} options.SecretKey：开发者在控制台注册的应用的 SecretKey
 * @param {number=} options.ExpireTime：签名过期时间，建议不要设置的过短，时间单位：秒，默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
 * 
 * @returns {{userSig: string, SDKAppID: number}} result
 * @returns {string} result.userSig：用户签名
 * @returns {number} result.SDKAppID：SDKAppID
 * 
 * @example
 * const { userSig } = genTestUserSig({ 
 *  userID: "Alice", 
 *  SDKAppID: 0, 
 *  SecretKey: "YOUR_SECRETKEY" 
 * });
 */
declare function genTestUserSig({ userID, SDKAppID, SecretKey, ExpireTime }: {
  userID: string;
  SDKAppID: number;
  SecretKey: string;
  ExpireTime?: number;
}): {
  userSig: string;
  SDKAppID: number;
};

export { genTestUserSig };
