<template>
  <v-expansion-panel value="docs">
    <v-expansion-panel-title>{{
      t("filmCards.panels.docs")
    }}</v-expansion-panel-title>
    <v-expansion-panel-text>
      <checkbox-list
        :items="docs"
        valueProp="id"
        v-model="model.documentIds"
      />
    </v-expansion-panel-text>
  </v-expansion-panel>
</template>

<script lang="ts">
import { defineComponent, computed, PropType } from "vue";
import { useI18n } from "vue-i18n";
import { FilmCard } from "@/models/film";
import { IFilmPackageDocument } from "@/interfaces/film";

import CheckboxList from "@/components/checkbox/checkboxlist.vue";

export default defineComponent({
  name: "FilmCardDocumentsEditPanel",
  components: {
    CheckboxList,
  },
  emits: ["update:filmCardData"],
  props: {
    filmCardData: {
      type: Object as PropType<FilmCard>,
      required: true,
    },
    filmPackageDocs: {
      type: Array as PropType<IFilmPackageDocument[]>,
    },
  },
  setup(props, context) {
    const { t } = useI18n();

    const model = computed({
      get: () => props.filmCardData,
      set: (value) => context.emit("update:filmCardData", value),
    });

    const docs = computed(() => props.filmPackageDocs);

    return {
      t,
      model,
      docs,
    };
  },
});
</script>
