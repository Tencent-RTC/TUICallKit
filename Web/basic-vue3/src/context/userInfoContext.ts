export const UserInfoContextDefaultValue = {
  userID: '',
  SDKAppID: 0,
  SecretKey: '',
  userSig: '',
  isLogin: false,
  isCall: false,
  currentPage: 'home',
  currentCallType: 'video',
}

export interface IUserInfoContext {
  userID: string;
  SDKAppID: number;
  SecretKey: string;
  userSig: string;
  isLogin: boolean;
  currentPage: string;
  isCall: boolean;
  currentCallType: string;
}

export const UserInfoContextKey = 'UserInfoContextKey';
