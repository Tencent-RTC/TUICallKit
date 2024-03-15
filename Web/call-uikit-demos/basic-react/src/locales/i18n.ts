import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import { resources } from "./resources";

const getLanguage = () => {
  // @ts-ignore
  const lang = (navigator?.language || navigator?.userLanguage || "").substr(
    0,
    2
  );
  let language = "en";
  switch (lang) {
    case "zh":
      language = "zh";
      break;
    case "ja":
      language = "jp";
      break;
    default:
      language = "en";
  }
  return language;
};

i18n
  .use(initReactI18next)
  // https://www.i18next.com/overview/configuration-options
  .init({
    resources,
    fallbackLng: getLanguage(),
    lng: getLanguage(),
    debug: true,
    interpolation: {
      escapeValue: false, // not needed for react as it escapes by default
    },
  });

export default i18n;
