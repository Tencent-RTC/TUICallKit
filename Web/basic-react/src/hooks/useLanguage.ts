import { useTranslation } from "react-i18next";
import { getBrowserLanguage } from '../utils/index';
import { useEffect } from "react";

export function useLanguage() {
  const { i18n, t } = useTranslation();
  const { language, changeLanguage } = i18n;
  const browserLang = getBrowserLanguage();

  const setItemLang = () => {
    browserLang.includes('zh')
      ? changeLanguage('zh')
      : changeLanguage(browserLang);
  }

  useEffect(() => {
    setItemLang();
  }, []);

  return {
    t,
    language,
    changeLanguage,
  }
}

export default useLanguage;