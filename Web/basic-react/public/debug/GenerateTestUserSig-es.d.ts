/**
 * Generate a temporary UserSig. Please do not publish or submit the following code to your code repository.
 *
 * @param {{userID: string, SDKAppID: number, SecretKey: string, ExpireTime?: number}} options
 * @param {string} options.userID - userID
 * @param {string} options.SDKAppID：SDKAppID of the application registered by the developer in the console.
 * @param {string} options.SecretKey：SecretKey of the application registered by the developer in the console.
 * @param {number=} options.ExpireTime：Signature validity period, which should not be set too short，Unit: second，Default value：7 x 24 x 60 x 60 = 604800 = 7 days
 * 
 * @returns {{userSig: string, SDKAppID: number}} result
 * @returns {string} result.userSig：User Signature
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
