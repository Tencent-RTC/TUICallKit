import { useI18n } from "vue-i18n";

export default function useLanguage() {
  const { t, locale } = useI18n();

  const changeLanguage = (value: string) => {
    locale.value = value;
  }
  
  return {
    t,
    language: locale,
    changeLanguage,
  }
}
