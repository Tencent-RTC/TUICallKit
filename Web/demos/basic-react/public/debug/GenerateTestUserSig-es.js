/* eslint-disable */
import LibGenerateTestUserSig from './lib-generate-test-usersig-es.min.js';

/**
 * Tencent Cloud `SDKAppID`. Set it to the `SDKAppID` of your account.
 *
 * You can view your `SDKAppID` after creating an application in the [TRTC console](https://console.cloud.tencent.com/trtc).
 * `SDKAppID` uniquely identifies a Tencent Cloud account.
*/
const SDKAPPID = 0;


/**
 * Signature validity period, which should not be set too short
 * <p>
 * Unit: second
 * Default value: 604800 (7 days)
*/
const EXPIRETIME = 604800;


/**
 * Follow the steps below to obtain the key required for UserSig calculation.
 *
 * Step 1. Log in to the [TRTC console](https://console.cloud.tencent.com/trtc), and create an application if you don’t have one.
 * Step 2. Find your application, click “Application Info”, and click the “Quick Start” tab.
 * Step 3. Copy and paste the key to the code, as shown below.
 *
 * Note: this method is for testing only. Before commercial launch, please migrate the UserSig calculation code and key to your backend server to prevent key disclosure and traffic stealing.
 * Reference: https://cloud.tencent.com/document/product/647/17275#Server
*/
const SECRETKEY = '';

/**
* Module:   GenerateTestUserSig
*
* Description: generates UserSig for testing. UserSig is a security signature designed by Tencent Cloud for its cloud services.
*           It is calculated based on `SDKAppID`, `UserID`, and `EXPIRETIME` using the HMAC-SHA256 encryption algorithm.
*
* Attention: do not use the code below in your commercial app. This is because:
*
*            The code may be able to calculate UserSig correctly, but it is only for quick testing of the SDK’s basic features, not for commercial apps.
*            `SECRETKEY` in client code can be easily decompiled and reversed, especially on web.
*             Once your key is disclosed, attackers will be able to steal your Tencent Cloud traffic.
*
*            The correct method is to deploy the `UserSig` calculation code and encryption key on your project server so that your app can request from your server a `UserSig` that is calculated whenever one is needed.
*           Given that it is more difficult to hack a server than a client app, server-end calculation can better protect your key.
*
* Reference: https://cloud.tencent.com/document/product/647/17275#Server
*/

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
function genTestUserSig({ userID, SDKAppID, SecretKey, ExpireTime }) {
  if (!userID) {
    console.error("userID parameter missing");
    return;
  }
  if (!SDKAppID) {
    console.error("SDKAppID parameter missing");
    return;
  }
  if (!SecretKey) {
    console.error("SDKSecretKey / SecretKey parameter missing");
    return;
  }

  const sdkAppID = SDKAppID || SDKAPPID;
  const secretKey = SecretKey || SECRETKEY;
  const expireTime = ExpireTime || EXPIRETIME;

  const generator = new LibGenerateTestUserSig(sdkAppID, secretKey, expireTime);
  const userSig = generator.genTestUserSig(userID);

  return {
    userSig,
    SDKAppID: sdkAppID
  };
}

export { genTestUserSig };
