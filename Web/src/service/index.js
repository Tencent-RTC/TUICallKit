import {getUserLoginInfo} from '../utils';

export async function getUserDetailInfoByUserid() {
  const loginInfo = getUserLoginInfo();
  return loginInfo;
}
