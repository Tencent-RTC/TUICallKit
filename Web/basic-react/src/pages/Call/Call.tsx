import { useContext, useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Typography, Image, Flex, QRCode, Input, message } from 'antd';
import { TUICallKitServer, TUICallType } from '@tencentcloud/call-uikit-react';
import { getUrl, BASE_URL, checkUserID, trim } from '../../utils';
import { UserInfoContext } from '../../context';
import { useLanguage } from '../../hooks';
import Container from '../../components/Container/Container';
import ShareSvg from '../../assets/pages/share.svg';
import QRCodeSvg from '../../assets/pages/qr.svg';
import './Call.css';

export default function Call() {
  const { Text, Link } = Typography;
  const navigate = useNavigate();
  const { state } = useLocation();
  const { userInfo, setUserInfo } = useContext(UserInfoContext);
  const { t } = useLanguage();
  const [calleeUserID, setCalleeUserID] = useState('');
  const [messageApi, contextHolder] = message.useMessage();
  const [isShowQr, setIsShowQr] = useState(false);

  useEffect(() => {
    setUserInfo({
      ...userInfo,
      currentPage: 'call',
    })
    if (!userInfo?.isLogin) {
      navigate('/login');
    }
  }, []);

  const handleCall = async () => {
    if (!checkUserID(calleeUserID)) {
      messageApi.info(t('Please input the correct userID'));
      setCalleeUserID('');
      return ;
    }
    if (calleeUserID === userInfo.userID) {
      messageApi.info(t('You cannot make a call to yourself'));
      setCalleeUserID('');
      return ;
    }
    setUserInfo({
      ...userInfo,
      isCall: true,
    });

    try {
      await TUICallKitServer.call({
        userID: calleeUserID,
        type: state.callType === 'video' ? TUICallType.VIDEO_CALL : TUICallType.AUDIO_CALL,
      })
      setCalleeUserID('')
    } catch (error: any) {
      setUserInfo({
        ...userInfo,
        isCall: false,
      });
      if (String(error)?.includes('Invalid')) {
        messageApi.warning(`${t('The userID you dialed does not exist, please create one')}: ${getUrl()}`);
      }
      console.error('call uikit', error);
    }
  }
  function renderQRCode() {
    return (
      <Flex vertical={true} className='qr-code'>
        <QRCode
          value={`${BASE_URL}?SDKAppID=${userInfo.SDKAppID}&SecretKey=${userInfo.SecretKey}`}
          size={160}
        />
      </Flex>
    )
  }
  function renderCallPanel() {
    const openNewWindow = () => {
      window.open(getUrl());
    }
    const handleCallUserID = (event: any) => {
      const userID = trim(event.target.value);
      setCalleeUserID(userID);
    }
    return (
      <div className='call-card'>
        <div>
          <Link onClick={openNewWindow}>
            {t('Create a New userID')}
            <Image src={ShareSvg} preview={false} />
          </Link>
          <div className='call-input'>
            <Input placeholder={t('input the userID to Call')} value={calleeUserID} onChange={handleCallUserID} />
            <div className='call-btn' onClick={handleCall}> 
              {t('Initiate Call')} 
            </div>
          </div>
        </div>
        
        <Flex justify='center' align='center' className='call-qr'>
          <Text style={{margin: '0 2px'}}>
            {t('Scanning QR Code')}
          </Text>
          {isShowQr && renderQRCode()}
          <Image style={{cursor: 'pointer'}} src={QRCodeSvg} preview={false} onClick={() => setIsShowQr(!isShowQr)}/>
        </Flex>
      </div>
    )
  }

  return (
    <>
      {contextHolder}
      <Container
        className='modify-container'
        body={renderCallPanel()}
      />
    </>
  )
}
