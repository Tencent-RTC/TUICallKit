import { Flex, Layout, Space } from 'antd';
import { IContentProps } from '../../../interface/index';
import QuickLink from '../../QuickLink/QuickLink';
import DeviceCheck from '../../DeviceCheck/DeviceCheck';
import LanguageSwitch from '../../LanguageSwitch/LanguageSwitch';
import Instruction from '../../Instruction/Instruction';
import RunGuide from '../../RunGuide/RunGuide';
import Logo from '../../Logo/Logo';
import './Layout.css';

export default function LayoutPC(props: IContentProps) {  
  const { Header, Footer, Content } = Layout;
  const { children } = props;

  return (
    <Layout>
      <Header>
        <Flex justify="flex-end" align='center'>
          <Space size='middle'>
            <LanguageSwitch />
            <DeviceCheck />
            <RunGuide />
          </Space>
        </Flex>
      </Header>
      <Content className='layout-middle'>
        <Flex vertical={true} justify='center' align='center'>
           <Layout>
            <Header>
              <Flex justify='center'>
                <Logo />
              </Flex>
            </Header>
            <Content className='layout-card'>
              {children}
            </Content>
            <Footer>
              <Flex justify='center'>
                <Space>
                  <QuickLink />
                </Space>
              </Flex>
            </Footer>
          </Layout>
        </Flex>
      </Content>
      <Footer className='layout-footer'>
        <Instruction />
      </Footer>
    </Layout>
  )
}

