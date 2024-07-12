import { Flex, Layout, Image, Space } from 'antd';
import { useLanguage } from '../../hooks';
import { IContentProps } from '../../interface/index';
import QuickLink from './QuickLink/QuickLink';
import DeviceCheck from '../DeviceCheck/DeviceCheck';
import LanguageSwitch from '../LanguageSwitch/LanguageSwitch';
import Instruction from '../Instruction/Instruction';
import logoEnSrc from '../../assets/layout/logo-en.png';
import logoZhSrc from '../../assets/layout/logo-zh.png';
import './Layout.css';

export default function PageLayout(props: IContentProps) {  
  const { Header, Footer, Content } = Layout;
  const { children } = props;
  const { language } = useLanguage();

  return (
    <Layout>
      <Header>
        <Flex justify="flex-end" align='center'>
          <Space>
            <LanguageSwitch />
            <DeviceCheck />
            {/* <RunGuide /> */}
          </Space>
        </Flex>
      </Header>
      <Content className='layout-middle'>
        <Flex vertical={true} justify='center' align='center'>
           <Layout>
            <Header>
              <Flex justify='center'>
                {
                  language === 'zh' 
                    ? <Image src={logoZhSrc} width={213} preview={false} /> 
                    : <Image src={logoEnSrc} width={213} preview={false} />
                }
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

