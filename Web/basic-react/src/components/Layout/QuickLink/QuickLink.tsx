import { Typography } from 'antd';
import { QuickLinkObj } from '../../../utils';
import { useLanguage } from '../../../hooks';
import './QuickLink.css';

const { Link, Text } = Typography;

export default function QuickLink() {
  const { t, language } = useLanguage();

  return (
    <>
      {
        language.includes('zh') ? (
          QuickLinkObj.map((item, index) => (
            <Text key={index} className='footer-link'>
              <Link href={item.zh} target='_blank'>
                {t(item.label)}
              </Link>
              {(index !== QuickLinkObj.length - 1 ) && ' / '}
            </Text>
          ))
        ) : (
          QuickLinkObj.map((item, index) => (
            <Text key={index} className='footer-link'>
              <Link key={index} href={item.en} target='_blank'>
                {t(item.label)}
              </Link>
              {(index !== QuickLinkObj.length - 1 ) && ' / '}
            </Text>
          )
        ))
      }
    </>
  )
}
