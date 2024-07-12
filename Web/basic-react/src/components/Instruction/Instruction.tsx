import { Typography, Image, Tooltip, Space, Flex } from 'antd';
import { useLanguage } from '../../hooks';
import WarningSrc from '../../assets/instruction/warning.svg';
import HelpSrc from '../../assets/instruction/help.svg';
import './Instruction.css';

const { Text, Link } = Typography;

export default function Instruction() {
  const { t, language } = useLanguage();
  return (
    <Space>
      <div className='instruction-card'>
        <Image 
          src={WarningSrc} 
          width={16} 
          preview={false} 
          className='instruction-img'
        />
        <Text className='instruction-text'>
          {t('Sensitive links/QR')}
        </Text>
      </div>
      <div className='instruction-card'>
        <Image 
          src={HelpSrc} 
          width={16} 
          preview={false} 
          className='instruction-img'
        />
        <Flex align='center'>
          <Text  className='instruction-text'> 
            {t('Any problems in running')}
          </Text>
          {
            language.includes('zh') 
              ? (
                  <Tooltip title="腾讯云官方社群: https://zhiliao.qq.com/">
                    <Link href="https://zhiliao.qq.com/" target='_blank'>
                      {t('Get tech support')}{`>`}
                    </Link>
                  </Tooltip>
                ) : (
                  <Tooltip title="Telegram: https://t.me/+EPk6TMZEZMM5OGY1">
                    <Link href="https://t.me/+EPk6TMZEZMM5OGY1" target='_blank'>
                      {t('Get tech support')}{`>`}
                    </Link>
                  </Tooltip>
                )
          }
        </Flex>
      </div>
    </Space>
  )
}