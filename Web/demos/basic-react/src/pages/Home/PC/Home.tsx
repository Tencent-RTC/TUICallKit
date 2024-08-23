import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Typography, Image, Flex, Segmented, Space } from 'antd';
import { useLanguage } from '../../../hooks';
import Container from '.././../../components/Container/Container';
import CallPng from '../../../assets/pages/call.png';
import ArrowSvg from '../../../assets/pages/arrow.svg';
import GroupCallPng from '../../../assets/pages/group-call.png';
import './Home.css';

const { Text } = Typography;

export default function Home() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [callType, setCallType] = useState('video');
  const tabList = [
    { value: 'video', label: t('Video Call') },
    { value: 'audio', label: t('Voice Call') },
  ]

  function renderHomeTitle() {
    const handleSegmentedChange = (value: string) => {
      setCallType(value);
    }
    return (
      <Segmented
        className='home-title'
        options={tabList}
        defaultValue={tabList[0].value}
        onChange={handleSegmentedChange}
      />
    )
  }

  function renderHomeContent() {
    const goCall = () => {
      navigate('/call', { state: {callType} });
    }
    const goGroupCall = () => {
      navigate('/groupCall', {state: {callType}});
    }
    
    return (
      <Space className='pc-home' size='middle'>
        <Flex vertical={true} align='center' justify='center' className='home-card' onClick={goCall}>
          <div className='home-card-title'>
            <span> {t('1v1 Call')} </span>
            <div className='home-arrow'>
              <Image src={ArrowSvg} preview={false} />
            </div>
          </div>
          <Text className='home-card-tip'> {t('the call')} </Text>
          <Image width={183} src={CallPng} preview={false} />
        </Flex>
        <Flex vertical={true} align='center' justify='center' className='home-card' onClick={goGroupCall}>
          <div className='home-card-title'>
            <span> {t('Group Call')} </span>
            <div className='home-arrow'>
              <Image src={ArrowSvg} preview={false} />
            </div>
          </div>
          <Text className='home-card-tip'> {t('the groupCall')} </Text>
          <Image width={183} src={GroupCallPng} preview={false} />
        </Flex>
      </Space>
    )
  }

  return (
    <Container 
      title={renderHomeTitle()}
      body={renderHomeContent()}
    />
  )
}
