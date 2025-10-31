import React, {createContext} from 'react';
import type {IUserInfo, IUserInfoContext} from '../interface/index';

const userInfoDefaultValue: IUserInfo = {
  userID: '',
  SDKAppID: 0,
  SecretKey: '',
  userSig: '',
  isLogin: false,
  isCall: false,
  currentPage: 'Login',
};

const setUserInfoDefaultValue: React.Dispatch<React.SetStateAction<IUserInfo>> =
    () => {};

export const UserInfoContext = createContext<IUserInfoContext>(
    {userInfo: userInfoDefaultValue, setUserInfo: setUserInfoDefaultValue});
