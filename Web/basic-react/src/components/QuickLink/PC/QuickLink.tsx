import { ConfigProvider, Typography } from 'antd';
import { QuickLinkObj } from '../../../utils';
import { useLanguage } from '../../../hooks';
import './QuickLink.css';

const { Link, Text } = Typography;

export default function QuickLink() {
  const { t, language } = useLanguage();

  return (
    <ConfigProvider
      theme={{
        components: {
          Typography: {
            colorLink: '#596B91',
            colorLinkActive: '#596B91',
            colorLinkHover: '#596B91',
          },
        },
      }}
    >
      {
        language.includes('zh') 
          ? (
            QuickLinkObj.map((item, index) => (
              <Text key={index}>
                <Link
                  className='footer-link-text'
                  href={item.zh} 
                  target='_blank'
                >
                  {t(item.label)}
                </Link>
                {
                  (index !== QuickLinkObj.length - 1 ) 
                  && <Text className='footer-link-line'> / </Text>
                }
              </Text>
            ))
          ) 
          : (
            QuickLinkObj.map((item, index) => (
              <Text key={index}>
                <Link
                  className='footer-link-text'
                  href={item.en} 
                  target='_blank'
                >
                  {t(item.label)}
                </Link>
                {
                  (index !== QuickLinkObj.length - 1 ) 
                    && <Text className='footer-link-line'> / </Text>
                }
              </Text>
            )
          ))
      }
    </ConfigProvider>
  )
}
