import { useContext, useState } from 'react';
import { Flex, Input, Typography } from 'antd';
import { useNavigate } from 'react-router-dom';
import { TUICallKitServer } from '@tencentcloud/call-uikit-react';
// @ts-ignore
import TencentCloudChat from '@tencentcloud/chat';
// @ts-ignore
import * as GenerateTestUserSig from "../../../debug/GenerateTestUserSig-es";
import { UserInfoContext } from '../../../context/index';
import { useLanguage, useAegis, useMessage } from '../../../hooks';
import { checkUserID, trim, getUrlParams } from '../../../utils/index';
import Container from '../../../components/Container/Container';
import './Login.css';

const { Text } = Typography;

export default function Login() {
  const { messageApi, contextHolder, handleCallError } = useMessage();
  const navigate = useNavigate();
  const { userInfo, setUserInfo } = useContext(UserInfoContext);
  const { t } = useLanguage();
  const [userID, setUserID] = useState('');
  const { reportEvent } = useAegis();
  const handleLogin = async () => {
    reportEvent({ apiName: 'login.start' });
    if (!userID) {
      messageApi.info(t('The userID is empty'));
      setUserID('');
      return;
    }
    if (!checkUserID(userID)) {
      messageApi.info(t('Please input the correct userID'));
      setUserID('');
      return;
    }
    const { SDKAppID, userSig, SecretKey } = GenerateTestUserSig.genTestUserSig({
      userID, 
      SDKAppID: userInfo?.SDKAppID, 
      SecretKey: userInfo?.SecretKey 
    });
    if (!SDKAppID || !SecretKey) {
      messageApi.info(`${t('Please fill SDKAppID and SecretKey:')} 'src/debug/GenerateTestUserSig-es.js'`);
      return;
    }
    try {
      const { isChatTestEnv } = getUrlParams(['isChatTestEnv']);
      const options = { SDKAppID, testEnv: isChatTestEnv === 'true' };
      const chat = TencentCloudChat.create(options);

      await TUICallKitServer.init({ userID, SDKAppID, userSig, tim: chat });
      setUserInfo({
        ...userInfo,
        userID,
        SDKAppID: SDKAppID,
        userSig,
        isLogin: true,
        SecretKey,
      });
      navigate('/home');
      reportEvent({ 
        apiName: 'login.success',
        content: JSON.stringify(userInfo),
      });
    } catch (error) {
      messageApi.info(`${t('Login failed')} ${error}`);
      handleCallError('login', error);
    }
    TUICallKitServer.enableVirtualBackground(true);
  }

  function renderTitle() {
    return (
      <span className='login-title'> {t('Create / Log in')} userID </span>
    )
  }

  function renderLoginContent() {
    const handleInputUserID = (e: any) => {
      setUserID(trim(e.target.value));
    }
    return (
      <div className='pc-login-panel'>
        <Flex vertical={true} >
          <Input
            className='login-input'
            placeholder={t('Please enter the userID you want to create/login')}
            value={userID}
            onChange={handleInputUserID}
            onPressEnter={handleLogin}
          />
          <Text className='login-tip' > 
            {t('userID Limit')}
          </Text>
        </Flex>
        <Flex
          className='login-btn'
          justify='center' 
          align='center' 
          onClick={handleLogin}
        >
          <span> {t('Create / Log in')} </span>
        </Flex>
      </div>
    )
  }

  return (
    <>
      {contextHolder}
      <Container 
        title={renderTitle()} 
        body={renderLoginContent()} 
      />
    </>
  )
}


