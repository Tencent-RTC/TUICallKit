import { useState, useMemo, useEffect } from "react";
import { RouterProvider } from "react-router-dom";
import { ConfigProvider } from 'antd';
import { TUICallKit } from '@tencentcloud/call-uikit-react';
import router from './routes/index.tsx';
import { UserInfoContext } from './context/index.ts';
import { useLanguage } from './hooks/index.ts';
import { checkLocation, AntdConfig } from './utils/index.ts';
import PageLayout from "./components/Layout/Layout.tsx";
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

  useEffect(() => {
    if (!checkLocation()) {
      alert(t('localhost protocol / HTTPS protocol'));
    }
  }, []);

  function renderTUICallKit() {
    const handleAfterCalling = () => {
      setUserInfo({
        ...userInfo,
        isCall: false,
      });
    }
    return (
      <div className="call-uikit">
        <TUICallKit
          afterCalling={handleAfterCalling}
        />
      </div>
    )
  }

  return (
    <ConfigProvider
      theme={AntdConfig}
    >
      <UserInfoContext.Provider value={UserInfoContextValue}>
        {renderTUICallKit()}
        <PageLayout>
          <RouterProvider router={router} />
        </PageLayout>
      </UserInfoContext.Provider>
    </ConfigProvider>
  )
}
