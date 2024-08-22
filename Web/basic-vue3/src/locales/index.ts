import { createI18n } from 'vue-i18n';
import en from './en';
import zh_CN from './zh_CN';
import ja from './ja_JP';

// https://stackblitz.com/edit/vue-i18n-get-started?file=main.js
// https://vue-i18n.intlify.dev/guide/essentials/started.html
const i18n = createI18n({
  legacy: false,
  locale: 'en',
  fallbackLocale: 'en',
  messages: {
    en,
    ja,
    zh_CN,
  }
})

export default i18n;

// <p v-html="$t('message.hello')"></p>
// https://vue-i18n.intlify.dev/guide/advanced/composition.html