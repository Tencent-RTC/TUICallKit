import React, { createContext } from 'react';
import { IUserInfo, IUserInfoContext } from '../interface/index';

const userInfoDefaultValue: IUserInfo = {
  userID: '',
  SDKAppID: 0,
  SecretKey: '',
  userSig: '',
  isLogin: false,
  isCall: false,
  currentPage: 'home',
  chat: null,
};

const setUserInfoDefaultValue: React.Dispatch<IUserInfo> = () => {};

export const UserInfoContext = createContext<IUserInfoContext>({ userInfo: userInfoDefaultValue, setUserInfo: setUserInfoDefaultValue });
