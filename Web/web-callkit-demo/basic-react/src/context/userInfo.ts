import { createContext } from 'react';
import { IUserInfo, IUserInfoContext } from '../interface/index';

const userInfoDefaultValue: IUserInfo = {
  userID: '',
  SDKAppID: 0,
  SecretKey: '',
  userSig: '',
  isLogin: false,
  isCall: false,
  currentPage: 'home',
}
const setUserInfoDefaultValue: React.Dispatch<IUserInfo> = () => {};

const UserInfoContext = createContext<IUserInfoContext>({ userInfo: userInfoDefaultValue, setUserInfo: setUserInfoDefaultValue });

export default UserInfoContext;
