import { useMemo } from 'react';
import { Button, Dropdown, Image, Typography } from 'antd';
import type { MenuProps } from 'antd';
import LanguageSwitchSrc from '../../assets/languageSwitch/language-switch.png';
import { useLanguage } from '../../hooks';

const { Text } = Typography;

export default function LanguageSwitch() {
  const { changeLanguage, language } = useLanguage();
  const items = [
    { key: 'en', label: "English" },
    { key: 'zh', label: "简体中文" },
    { key: 'ja', label: "日本語" },
  ];
  const lang = useMemo(() => {
    let res = 'English';
    items.map((item) => {
      if (item.key === language) res = item.label;
    })
    return res;
  }, [language]);

  const onClick: MenuProps['onClick'] = ({ key }) => {
    changeLanguage(key);
  };
  
  return (
    <Dropdown menu={{ items, onClick }} placement="bottom">
      <Button onClick={(e) => e.preventDefault()}>
        <Image src={LanguageSwitchSrc} preview={false} /> 
        <Text> {lang} </Text>
      </Button>
    </Dropdown>
  )
}
