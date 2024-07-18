import { useContext, useMemo } from 'react';
import { Row, Col, Flex, } from 'antd';
import { UserInfoContext } from '../../../context';
import { ClassNames, getClientSize, NAME } from '../../../utils/index';
import LanguageSwitch from '../../LanguageSwitch/LanguageSwitch';
import DisplayUserInfo from '../../DisplayUserInfo/DisplayUserInfo';
import QuickLink from '../../QuickLink/QuickLink';
import Logo from '../../Logo/Logo';
import './Layout.css';

interface ILayoutH5Props {
  children: JSX.Element;
}

export default function Layout(props: ILayoutH5Props) {
  const { children } = props;
  const { userInfo } = useContext(UserInfoContext);

  const isShowBg = useMemo(() => {
    return userInfo?.currentPage === 'login';
  }, [userInfo])

  const isSetFooterMargin = useMemo(() => {
    return getClientSize().height > NAME.smallDeviceHeight;
  }, []);

  return (
    <div className={ClassNames(['h5-layout', { 'h5-layout-bg': isShowBg }])}>
      <Row justify='space-between' align='middle' >
        <Col span={8}> <DisplayUserInfo /> </Col>
        <Col span={8}> <LanguageSwitch /> </Col>
      </Row>
      <Flex align='center' justify='center' style={{marginTop: '67px'}}>
        <Logo />
      </Flex>
      <Flex className='h5-layout-content' align='center'>
        {children}
      </Flex>
      <Flex 
        align='center' 
        justify='center' 
        className={ClassNames([{'h5-layout-footer': isSetFooterMargin, 'h5-layout-footer-small-device': !isSetFooterMargin}])}
      >
        <QuickLink />
      </Flex>
    </div>
  )
}
