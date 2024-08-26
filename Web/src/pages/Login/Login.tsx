import { useEffect, useContext } from 'react';
import { UserInfoContext } from '../../context';
import { isH5, getUrlParams } from '../../utils';
import LoginPC from './PC/Login';
import LoginH5 from './H5/LoginH5';

export default function Login() {
  const { userInfo, setUserInfo } = useContext(UserInfoContext);
  useEffect(() => {
    const { SDKAppID, SecretKey } = getUrlParams();
    setUserInfo({
      ...userInfo,
      SDKAppID: Number(SDKAppID),
      SecretKey,
      currentPage: 'login',
      userID: '',
      isLogin: false,
    });
  }, []);

  return (
    <>
      {
        isH5 ? <LoginH5 /> : <LoginPC />
      }
    </>
  )
}
