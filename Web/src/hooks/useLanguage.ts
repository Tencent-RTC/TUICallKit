import { useTranslation } from "react-i18next";

export function useLanguage() {
  const { i18n, t } = useTranslation();
  const { language, changeLanguage } = i18n;

  return {
    t,
    language,
    changeLanguage,
  }
}

export default useLanguage;