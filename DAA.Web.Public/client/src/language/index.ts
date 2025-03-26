import { createI18n } from 'vue-i18n';

import bg from './bg/bg';
import en from './en/en';

export default {
    bg,
    en
}

//i18n docs https://vue-i18n.intlify.dev/
export const i18n = createI18n({
    locale: 'bg', // set locale
    fallbackLocale: 'en', // set fallback locale
    messages: {
        bg,
        en
    }, // set locale messages
    // If you need to specify other options, you can set other options
    // ...
  })
  