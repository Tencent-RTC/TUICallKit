import { useContext, useEffect, useState } from 'react';
import { Flex, Input, Typography, message } from 'antd';
import { useNavigate } from 'react-router-dom';
import { TUICallKitServer } from '@tencentcloud/call-uikit-react';
// @ts-ignore
import * as GenerateTestUserSig from "../../debug/GenerateTestUserSig-es";
import { UserInfoContext } from '../../context/index';
import { useLanguage } from '../../hooks';
import { checkUserID, trim, getUrlParams } from '../../utils/index';
import Container from '../../components/Container/Container';
import './Login.css';

const { Text } = Typography;

export default function Login() {
  const [messageApi, contextHolder] = message.useMessage();
  const navigate = useNavigate();
  const { userInfo, setUserInfo } = useContext(UserInfoContext);
  const { t } = useLanguage();
  const [userID, setUserID] = useState('');

  useEffect(() => {
    const { SDKAppID, SecretKey } = getUrlParams();
    setUserInfo({
      ...userInfo,
      SDKAppID: Number(SDKAppID),
      SecretKey,
      currentPage: 'login',
    });
  }, []);

  const handleLogin = async () => {
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
      navigate('/home');
    } catch (error) {
      messageApi.info(t('Login failed'));
      console.error(error);
    }
  }

  function renderTitle() {
    return (
      <span className='login-title'> {t('Create / Log in')} userID </span>
    )
  }

  function renderLoginContent() {
    const handleInputUserID = (e: any) => {
      !userInfo?.isLogin && setUserID(trim(e.target.value));
    }
    return (
      <>
        <Flex vertical={true} >
          <Input
            className='login-input'
            placeholder="please input userID"
            value={userID}
            onChange={handleInputUserID} 
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
      </>
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


