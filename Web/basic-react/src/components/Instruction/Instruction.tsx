import { ConfigProvider, Typography, Image, Tooltip, Flex } from 'antd';
import { useLanguage } from '../../hooks';
import WarningSrc from '../../assets/instruction/warning.svg';
import HelpSrc from '../../assets/instruction/help.svg';
import RightArrowSrc from '../../assets/instruction/right-arrow.svg';
import './Instruction.css';

const { Text, Link } = Typography;

export default function Instruction() {
  const { t, language } = useLanguage();
  return (
    <ConfigProvider
      theme={{
        components: {
          Typography: {
            colorLink: '#1C66E5',
            colorLinkActive: '#1C66E5',
            colorLinkHover: '#1C66E5'
          },
        },
      }}
    >
      <div className='instruction-card'>
        <Image 
          src={WarningSrc} 
          width={16} 
          preview={false} 
        />
        <Text className='instruction-text'>
          {t('Sensitive links/QR')}
        </Text>
      </div>
      <div className='instruction-card' style={{marginLeft: '10px'}}>
        <Image 
          src={HelpSrc} 
          width={16} 
          preview={false} 
        />
        <Flex align='center'>
          <Text  className='instruction-text'> 
            {t('Any problems in running')}
          </Text>
          {
            language.includes('zh') 
              ? (
                  <Tooltip title="腾讯云官方社群: https://zhiliao.qq.com/">
                    <Link 
                      className='instruction-link'
                      href="https://zhiliao.qq.com/" 
                      target='_blank'
                    >
                      {t('Get tech support')}
                      <Image src={RightArrowSrc} width={16} preview={false} />
                    </Link>
                  </Tooltip>
                ) 
              : (
                  <Tooltip title="Telegram: https://t.me/+EPk6TMZEZMM5OGY1">
                    <Link
                      className='instruction-link'
                      href="https://t.me/+EPk6TMZEZMM5OGY1"
                      target='_blank'
                    >
                      {t('Get tech support')}
                      <Image src={RightArrowSrc} width={16} preview={false} />
                    </Link>
                  </Tooltip>
                )
          }
        </Flex>
      </div>
    </ConfigProvider>
  )
}