// Styles
import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'
import { bg, en } from 'vuetify/locale'

// Vuetify
import { createVuetify } from 'vuetify'
import { VCalendar } from 'vuetify/labs/VCalendar'

export default createVuetify(
  // https://vuetifyjs.com/en/introduction/why-vuetify/#feature-guides
  {
    locale: {
      locale: 'bg',
      fallback: 'en',
      messages: { bg, en },
  },
  components: {
      VCalendar, // Добавя се защото все още не е в прод, а се взима от vuetify/labs
  },
  }
)
