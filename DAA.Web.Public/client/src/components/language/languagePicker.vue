<template>
  <v-btn variant="plain" @click="switchLanguage">{{ label }}</v-btn>
</template>
<script lang="ts">
import { computed, defineComponent } from "vue";
import { useI18n } from "vue-i18n";
import { useStore } from "@/store/app";

import { ActionTypes } from "@/store/app/actions";
import { Language } from "@/enums/language";

export default defineComponent({
  name: "LanguagePicker",
  setup() {
    const { t } = useI18n();

    const appStore = useStore();

    const label = computed(() => {
      let languageLabel = "";
      switch (appStore.getters.language) {
        case Language.BG:
          languageLabel = Language.EN;
          break;
        case Language.EN:
          languageLabel = Language.BG;
          break;
      }
      return languageLabel;
    });

    const switchLanguage = () => {
      switch (appStore.getters.language) {
        case Language.BG:
          appStore.dispatch(ActionTypes.SetLanguage, Language.EN);
          break;
        case Language.EN:
          appStore.dispatch(ActionTypes.SetLanguage, Language.BG);
          break;
      }
    };

    return {
      t,
      label,
      switchLanguage,
    };
  },
});
</script>
