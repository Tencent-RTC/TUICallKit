export interface IUserInfo {
  userID: string;
  SDKAppID: number;
  SecretKey: string;
  userSig: string;
  isLogin: boolean;
  currentPage: string;
  isCall: boolean;
  chat: any;
}
export interface IUserInfoContext {
  userInfo: IUserInfo;
  setUserInfo: React.Dispatch<IUserInfo>;
}
