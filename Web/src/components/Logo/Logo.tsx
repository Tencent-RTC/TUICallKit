import { Image } from 'antd';
import { useLanguage } from '../../hooks';
import LogoEnSrc from '../../assets/layout/logo-en.png';
import LogoZhSrc from '../../assets/layout/logo-zh.png';

export default function Logo() {
  const { language } = useLanguage();

  return (
    <>
      {
        language === 'zh'
          ? <Image src={LogoZhSrc} width={213} preview={false} />
          : <Image src={LogoEnSrc} width={213} preview={false} />
      }
    </>
  )
}
