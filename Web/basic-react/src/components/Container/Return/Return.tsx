import { useContext } from 'react';
import { Link } from "react-router-dom";
import { Typography, Image } from 'antd';
import { UserInfoContext } from '../../../context/index';
import { useLanguage } from '../../../hooks/index';
import leftArrowSvg from '../../../assets/container/left-arrow.svg';
import './Return.css';

const { Text } = Typography;

export default function Return() {
  const { userInfo } = useContext(UserInfoContext);
  const { t } = useLanguage();
  return (
    (userInfo.currentPage === 'call' || userInfo.currentPage === 'groupCall') 
    && (
      <Link to={'/home'} className='return-link'>
        <Image src={leftArrowSvg} preview={false} />
        <Text className='return-text'> {t('Call Back')} </Text>
      </Link>
    )
  )
}
