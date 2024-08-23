import { useState } from "react";
import { useNavigate } from 'react-router-dom'
import { Flex, Segmented, Image } from 'antd';
import { useLanguage } from "../../../hooks";
import Layout from "../../../components/Layout/Layout";
import CallSvg from '../../../assets/pages/h5-call.svg';
import GroupCallSvg from '../../../assets/pages/h5-groupcall.svg';
import './Home.css';

export default function Home() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [callType, setCallType] = useState('video');
  const tabList = [
    { value: 'video', label: t('Video Call') },
    { value: 'audio', label: t('Voice Call') },
  ]

  const goCall = () => {
    navigate('/call', { state: { callType } });
  }
  const goGroupCall = () => {
    navigate('/groupCall', {state: { callType }});
  }

  function renderCallType() {
    const handleSegmentedChange = (value: string) => {
      setCallType(value);
    }
    return (
      <Segmented
        className='h5-home-title'
        options={tabList}
        defaultValue={tabList[0].value}
        onChange={handleSegmentedChange}
      />
    )
  }
  return (
    <Layout>
      <Flex vertical={true} justify="center" align="center" className="h5-home-panel">
        {renderCallType()}
        <Flex justify="center" align="center" className="h5-home-btn" onClick={goCall}>
          <Image src={CallSvg} preview={false} />
          <span className="h5-home-btn-text"> {t('1v1 Call')} </span>
        </Flex>
        <Flex justify="center" align="center" className="h5-home-btn" onClick={goGroupCall}>
          <Image src={GroupCallSvg} preview={false} />
          <span className="h5-home-btn-text">  {t('Group Call')} </span>
        </Flex>
      </Flex>
    </Layout>
  )
}
