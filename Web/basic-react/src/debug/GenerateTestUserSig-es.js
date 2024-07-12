import LibGenerateTestUserSig from './lib-generate-test-usersig-es.min.js';

let SDKAPPID = 0;
let SECRETKEY = '';

/**
 * Expiration time for the signature, it is recommended not to set it too short.
 * Time unit: seconds
 * Default time: 7 x 24 x 60 x 60 = 604800 = 7 days
 */
const EXPIRETIME = 604800;

export function genTestUserSig({ userID, SDKAppID, SecretKey }) {
  if (SDKAppID) SDKAPPID = SDKAppID;
  if (SecretKey) SECRETKEY = SecretKey;
  const generator = new LibGenerateTestUserSig(SDKAPPID, SECRETKEY, EXPIRETIME);
  const userSig = generator.genTestUserSig(userID);

  return {
    SDKAppID: SDKAPPID,
    SecretKey: SECRETKEY,
    userSig,
  };
}

export default genTestUserSig;