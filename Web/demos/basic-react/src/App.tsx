import { useState, useMemo, useEffect } from "react";
import { RouterProvider } from "react-router-dom";
import { ConfigProvider } from 'antd';
import { TUICallKit } from '@tencentcloud/call-uikit-react';
import router from './routes/index.tsx';
import { UserInfoContext } from './context/index.ts';
import { useLanguage, useAegis } from './hooks/index.ts';
import { checkLocation, AntdConfig, isH5, ClassNames, initViewport } from './utils/index.ts';
import Layout from "./components/Layout/Layout.tsx";
import './App.css';

export default function App() {
  const { t } = useLanguage();
  const [userInfo, setUserInfo] = useState({
    userID: '',
    SDKAppID: 0,
    SecretKey: '',
    userSig: '',
    isLogin: false,
    currentPage: 'home',
    isCall: false,
  })
  const UserInfoContextValue = useMemo(() => ({
    userInfo,
    setUserInfo,
  }), [userInfo, setUserInfo]);
  const { reportEvent } = useAegis();
  
  useEffect(() => {
    reportEvent({ apiName: 'run.call.start' });
    isH5 && initViewport();
    if (!checkLocation()) {
      alert(t('localhost protocol / HTTPS protocol'));
    }
  }, []);

  const handleAfterCalling = () => {
    setUserInfo({
      ...userInfo,
      isCall: false,
    });
  }
  return (
    <ConfigProvider
      theme={AntdConfig}
    >
      <UserInfoContext.Provider value={UserInfoContextValue}>
        <TUICallKit
          className={ClassNames([{'call-uikit-mobile': isH5}, {'call-uikit-pc': !isH5 }])}
          afterCalling={handleAfterCalling}
        />
        {
          isH5 
            ? <RouterProvider router={router} />
            : (<Layout>
                <RouterProvider router={router} />
              </Layout>)
        }
      </UserInfoContext.Provider>
    </ConfigProvider>
  )
}

