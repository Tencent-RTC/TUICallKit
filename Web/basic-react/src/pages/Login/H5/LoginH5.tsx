import { useContext, useState } from 'react';
import { Flex, Input, Typography, message } from 'antd';
import { useNavigate } from 'react-router-dom';
import { TUICallKitServer } from '@tencentcloud/call-uikit-react';
// @ts-ignore
import * as GenerateTestUserSig from "../../../debug/GenerateTestUserSig-es";
import { UserInfoContext } from '../../../context/index';
import { useLanguage, useAegis } from '../../../hooks';
import { checkUserID, trim } from '../../../utils/index';
import Layout from '../../../components/Layout/Layout';
import './LoginH5.css';

const { Text } = Typography;

export default function LoginH5() {
  const [messageApi, contextHolder] = message.useMessage();
  const navigate = useNavigate();
  const { userInfo, setUserInfo } = useContext(UserInfoContext);
  const { t } = useLanguage();
  const [userID, setUserID] = useState('');
  const { reportEvent, reportError } = useAegis();

  const handleLogin = async () => {
    reportEvent({
      apiName: 'login.start',
      content: JSON.stringify(userInfo),
    })
    if (!userID) {
      messageApi.info(t('The userID is empty'));
      setUserID('');
      return ;
    }
    if (!checkUserID(userID)) {
      messageApi.info(t('Please input the correct userID'));
      setUserID('');
      return ;
    }
    
    const { SDKAppID, userSig, SecretKey } = GenerateTestUserSig.genTestUserSig({
      userID, 
      SDKAppID: userInfo?.SDKAppID, 
      SecretKey: userInfo?.SecretKey 
    });
    if (!SDKAppID || !SecretKey) {
      messageApi.info(`${t('Please fill SDKAppID and SecretKey:')} 'src/debug/GenerateTestUserSig-es.js'`);
      return ;
    }
    try {
      await TUICallKitServer.init({ userID, SDKAppID, userSig });
      setUserInfo({
        ...userInfo,
        userID,
        SDKAppID: SDKAppID,
        userSig,
        isLogin: true,
        SecretKey,
      });
      reportEvent({
        apiName: 'login.success',
        content: JSON.stringify(userInfo),
      })
      navigate('/home');
    } catch (error) {
      messageApi.info(`${t('Login failed')} ${error}`);
      console.error(error);
      reportError({
        apiName: 'login.error',
        content: JSON.stringify(error),
      })
    }
  }

  const handleInputUserID = (e: any) => {
    setUserID(trim(e.target.value));
  }

  return (
   <Layout>
      <>
        {contextHolder}
        <Flex vertical={true} className="h5-login-panel">
          <Input
            className="h5-login-input"
            placeholder={t('Please enter the userID you want to create/login')}
            value={userID} 
            onChange={handleInputUserID}
            onPressEnter={handleLogin}
          />
          <Text className='h5-login-tip' > 
            {t('userID Limit')}
          </Text>
          <div className="h5-login-btn" onClick={handleLogin} > {t('Create / Log in')} </div>
        </Flex>
      </>
   </Layout>
  )
}