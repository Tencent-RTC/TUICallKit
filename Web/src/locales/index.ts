import i18n from 'i18next';
import LanguageDetector from 'i18next-browser-languagedetector';
import { initReactI18next } from 'react-i18next';
import en from './en';
import zh_CN from './zh_CN';
import ja from './ja_JP';

i18n
  .use(initReactI18next)
  .use(LanguageDetector)
  .init({
    resources: {
      "en": {
        translation: en,
      },
      "zh-CN": {
        translation: zh_CN,
      },
      "ja": {
        translation: ja,
      }
    },
    lng: navigator?.language, // en, zh-CN, ja
    fallbackLng: 'en',
  })

export default i18n;