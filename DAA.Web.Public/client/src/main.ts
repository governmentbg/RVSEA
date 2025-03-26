import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import 'vuetify/styles';
import { createVuetify } from 'vuetify';
import * as vuetifyComponents from 'vuetify/components';
import * as vuetifyDirectives from 'vuetify/directives';
import { aliases, mdi } from 'vuetify/lib/iconsets/mdi'
import { fa } from 'vuetify/lib/iconsets/fa'
import { loadFonts } from './plugins/webfontloader';
import { store as appStore, key as appStoreKey } from './store/app';
import { store as userStore, key as userStoreKey } from './store/user';
import { i18n } from './language';
import '@/validation';
import { addDirectives } from '@/directives';
import { systemTheme } from './themes/systemTheme';
import Loader from '@/components/loader/loader.vue';

loadFonts()

const app = createApp(App);
app.component('Loader', Loader);

const vuetify = createVuetify({
  vuetifyComponents,
  vuetifyDirectives,
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: {
      mdi,
      fa,
    }
  },
  theme: {
    defaultTheme: 'systemTheme',
    // variations: {
    //   colors: ['primary', 'secondary'],
    //   lighten: 5,
    //   darken: 4,
    // },
    themes: {
      systemTheme,
      light: {
        primary: '#FFFF00'
      }
    }
  },
});
// //i18n docs https://vue-i18n.intlify.dev/
// const i18n = createI18n({
//   locale: 'bg', // set locale
//   fallbackLocale: 'en', // set fallback locale
//   messages, // set locale messages
//   // If you need to specify other options, you can set other options
//   // ...
// })

app.use(appStore, appStoreKey);
app.use(userStore, userStoreKey);
app.use(router);
app.use(vuetify);
app.use(i18n);

addDirectives(app);

app.mount('#app');
