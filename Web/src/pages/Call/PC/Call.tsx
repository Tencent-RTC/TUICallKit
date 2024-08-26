import { useContext, useState } from 'react';
import {  useLocation } from 'react-router-dom';
import { Typography, Image, Flex, QRCode, Input } from 'antd';
import { TUICallKitServer, TUICallType } from '@tencentcloud/call-uikit-react';
import { getUrl, BASE_URL, checkUserID, trim } from '../../../utils';
import { UserInfoContext } from '../../../context';
import { useLanguage, useAegis, useMessage } from '../../../hooks';
import Container from '../../../components/Container/Container';
import ShareSvg from '../../../assets/pages/share.svg';
import QRCodeSvg from '../../../assets/pages/qr.svg';
import './Call.css';

export default function Call() {
  const { Text, Link } = Typography;
  const { state } = useLocation();
  const { userInfo, setUserInfo } = useContext(UserInfoContext);
  const { t } = useLanguage();
  const [calleeUserID, setCalleeUserID] = useState('');
  const { messageApi, contextHolder, handleCallError } = useMessage();
  const [isShowQr, setIsShowQr] = useState(false);
  const { reportEvent } = useAegis();

  const handleCall = async () => {
    reportEvent({ apiName: 'call.start' });
    if (!checkUserID(calleeUserID)) {
      messageApi.info(t('Please input the correct userID'));
      setCalleeUserID('');
      return;
    }
    if (calleeUserID === userInfo.userID) {
      messageApi.info(t('You cannot make a call to yourself'));
      setCalleeUserID('');
      return;
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
      reportEvent({ apiName: 'call.success' });
      setCalleeUserID('');
    } catch (error: any) {
      setUserInfo({
        ...userInfo,
        isCall: false,
      });
      handleCallError('call', error);
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
      reportEvent({ apiName: 'openNewWindow.start' });
      window.open(getUrl());
    }
    const handleCallUserID = (event: any) => {
      const userID = trim(event.target.value);
      setCalleeUserID(userID);
    }
    return (
      <div className='pc-call-card'>
        <div>
          <Link onClick={openNewWindow}>
            {t('Create a New userID')}
            <Image src={ShareSvg} preview={false} />
          </Link>
          <div className='pc-call-input-box'>
            <Input
              className='pc-call-input' 
              placeholder={t('input the userID to Call')} 
              value={calleeUserID}
              onChange={handleCallUserID}
              onPressEnter={handleCall}
            />
            <div 
              className='pc-call-btn'
              onClick={handleCall}
            > 
              {t('Initiate Call')} 
            </div>
          </div>
        </div>
        
        <Flex justify='center' align='center' className='qr-code-box'>
          <Text className='qr-code-text'>
            {t('Scanning QR Code')}
          </Text>
          {isShowQr && renderQRCode()}
          <Image 
            style={{cursor: 'pointer'}} 
            src={QRCodeSvg} 
            preview={false} 
            onClick={() => setIsShowQr(!isShowQr)}
          />
        </Flex>
      </div>
    )
  }

  return (
    <>
      {contextHolder}
      <Container
        body={renderCallPanel()}
      />
    </>
  )
}
