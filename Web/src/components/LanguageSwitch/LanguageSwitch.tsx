import { useMemo } from 'react';
import { Button, Dropdown, Image, Typography } from 'antd';
import { TUICallKitServer } from '@tencentcloud/call-uikit-react';
import type { MenuProps } from 'antd';
import { LanguageType } from '../../interface/index';
import LanguageSwitchSrc from '../../assets/languageSwitch/language-switch.png';
import { useLanguage } from '../../hooks';
import { ClassNames, isH5 } from '../../utils';
import './LanguageSwitch.css';

const { Text } = Typography;

export default function LanguageSwitch() {
  const { changeLanguage, language } = useLanguage();
  const items = [
    { key: 'en', label: "English" },
    { key: 'zh-CN', label: "简体中文" },
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
    // @ts-ignore
    TUICallKitServer.setLanguage(LanguageType[key]);
  };
  
  return (
    <Dropdown
      menu={{ items, onClick, selectable: true, defaultSelectedKeys: [language] }} 
      placement="bottom"
    >
      <Button
        onClick={(e) => e.preventDefault()}
        className={ClassNames({'language-switch-card': isH5, 'header-card-pc': !isH5})}
      >
        <Image src={LanguageSwitchSrc} width={16} preview={false} /> 
        <Text className='header-card-text'> {lang} </Text>
      </Button>
    </Dropdown>
  )
}
