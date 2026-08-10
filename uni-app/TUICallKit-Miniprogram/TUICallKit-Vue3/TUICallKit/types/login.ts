export interface LoginParams {
  userId: string;
  userSig: string;
  sdkAppId: number;
  [key: string]: any;
}

export interface LoginUserInfo {
  userId: string;
  userName: string;
  avatarUrl: string;
  customInfo?: Record<string, any>;
}

export interface SetSelfInfoParams {
  userName?: string;
  avatarUrl?: string;
  customInfo?: Record<string, any>;
}
