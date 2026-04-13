import { createI18n } from 'vue-i18n';
import en from './en';
import zh_CN from './zh_CN';
import ja from './ja_JP';

function getBrowserLocale() {
  const navigatorLocale = navigator.language || (navigator as any).userLanguage;
  
  const localeMap: { [key: string]: string } = {
    'zh': 'zh_CN',
    'zh-cn': 'zh_CN',
    'zh-CN': 'zh_CN',
    'ja': 'ja',
    'ja-jp': 'ja',
    'ja-JP': 'ja',
    'en': 'en',
    'en-us': 'en',
    'en-US': 'en',
  };
  
  return localeMap[navigatorLocale] || 'en';
}

const savedLocale = localStorage.getItem('locale') || getBrowserLocale();

const i18n = createI18n({
  legacy: false,
  locale: savedLocale,
  fallbackLocale: 'en',
  messages: {
    en,
    ja,
    zh_CN,
  }
})

export default i18n;