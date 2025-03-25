<template>
  <v-expansion-panel value="copies">
    <v-expansion-panel-title>{{
      t("filmCards.panels.copies")
    }}</v-expansion-panel-title>
    <v-expansion-panel-text>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldFramesCount"
            :label="t('filmCards.columns.framesCount')"
            v-model="model.framesCount"
            validation="numeric"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldSize"
            :label="t('filmCards.columns.size')"
            v-model="formattedSize"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldMicrofilmNegativeCount"
            :label="t('filmCards.columns.microfilmNegativeCount')"
            v-model="model.microfilmNegativeCount"
            validation="numeric"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldMicrofilmPositiveCount"
            :label="t('filmCards.columns.microfilmPositiveCount')"
            v-model="model.microfilmPositiveCount"
            validation="numeric"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldPhotoCopy"
            :label="t('filmCards.columns.photoCopy')"
            v-model="model.photoCopy"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldDigitalCopy"
            :label="t('filmCards.columns.digitalCopy')"
            v-model="model.digitalCopy"
          />
        </v-col>
      </v-row>

      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldDocumentsFormat"
            :label="t('filmCards.columns.documentsFormat')"
            v-model="model.documentsFormat"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldOther"
            :label="t('filmCards.columns.other')"
            v-model="model.other"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-area-field
            name="fldNotes"
            :label="t('filmCards.columns.notes')"
            v-model="model.notes"
          />
        </v-col>
        <v-col class="col-6">
          <text-area-field
            name="fldDocumentsCharacteristics"
            :label="t('filmCards.columns.documentsCharacteristics')"
            v-model="model.documentsCharacteristics"
          />
        </v-col>
      </v-row>
    </v-expansion-panel-text>
  </v-expansion-panel>
</template>

<script lang="ts">
import { defineComponent, computed, PropType } from "vue";
import { useI18n } from "vue-i18n";
import { FilmCard } from "@/models/film";

import TextField from "@/components/field/text.field.vue";
import TextAreaField from "@/components/field/textarea.field.vue";
import { formatBytes } from "@/helpers/format.helper";

export default defineComponent({
  name: "FilmCardCopiesDataEditPanel",
  components: {
    TextField,
    TextAreaField,
  },
  emits: ["update:filmCardData"],
  props: {
    filmCardData: {
      type: Object as PropType<FilmCard>,
      required: true,
    },
  },
  setup(props, context) {
    const { t } = useI18n();

    const model = computed({
      get: () => props.filmCardData,
      set: (value) => context.emit("update:filmCardData", value),
    });

    const formattedSize = computed(() => model.value.size ? formatBytes(Number(model.value.size)) : '');

    return {
      t,
      model,
      formattedSize,
    };
  },
});
</script>
