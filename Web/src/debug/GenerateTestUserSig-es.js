import LibGenerateTestUserSig from './lib-generate-test-usersig-es.min.js';

/**
 * Refer to the READEME.md for the SDKAppID、SecretKey
 */
let SDKAppID = 0;
let SecretKey = '';

/**
 * Expiration time for the signature, it is recommended not to set it too short.
 * Time unit: seconds
 * Default time: 7 x 24 x 60 x 60 = 604800 = 7 days
 */
const EXPIRETIME = 604800;

export function genTestUserSig(params) {
  if (params.SDKAppID) SDKAppID = params.SDKAppID;
  if (params.SecretKey) SecretKey = params.SecretKey;
  const generator = new LibGenerateTestUserSig(SDKAppID, SecretKey, EXPIRETIME);
  const userSig = generator.genTestUserSig(params.userID);

  return {
    SDKAppID,
    SecretKey,
    userSig,
  };
}

export default genTestUserSig;
