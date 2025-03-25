<template>
  <v-expansion-panel value="general">
    <v-expansion-panel-title>{{
      t("filmCards.panels.general")
    }}</v-expansion-panel-title>
    <v-expansion-panel-text>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldCountry"
            :label="t('filmCards.columns.country')"
            v-model="model.countryName"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldCity"
            :label="t('filmCards.columns.city')"
            v-model="model.city"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-12">
          <text-field
            name="fldArchiveOriginals"
            :label="t('filmCards.columns.archiveOriginals')"
            v-model="model.archiveOriginals"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-12">
          <text-area-field
            name="fldDocumentsCypher"
            :label="t('filmCards.columns.documentsCypher')"
            v-model="model.documentsCypher"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-12">
          <text-area-field
            name="fldTitle"
            :label="t('filmCards.columns.title')"
            v-model="model.title"
            :readonly="true"
          />
        </v-col>
      </v-row>

      <v-divider></v-divider>
      <v-list-subheader>
          {{ t('filmCards.panels.dates') }}
      </v-list-subheader>
      <v-divider></v-divider>

      <v-row>
        <v-col class="col-12 col-lg-2">
          <label>{{ t("filmCards.columns.startDate") }}</label>
          <text-field
            name="fldStartDateDay"
            :label="t('filmCards.columns.day')"
            v-model="model.startDateDay"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-12 col-lg-2">
          <label></label>
          <text-field
            name="fldStartDateMonth"
            :label="t('filmCards.columns.month')"
            v-model="model.startDateMonth"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-12 col-lg-2">
          <label></label>
          <text-field
            name="fldStartDateYear"
            :label="t('filmCards.columns.year')"
            v-model="model.startDateYear"
            :readonly="true"
          />
        </v-col>

        <v-col class="col-12 col-lg-2">
          <label>{{ t("filmCards.columns.endDate") }}</label>
          <text-field
            name="fldEndDateDay"
            :label="t('filmCards.columns.day')"
            v-model="model.endDateDay"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-12 col-lg-2">
          <label></label>
          <text-field
            name="fldEndDateMonth"
            :label="t('filmCards.columns.month')"
            v-model="model.endDateMonth"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-12 col-lg-2">
          <label></label>
          <text-field
            name="fldEndDateYear"
            :label="t('filmCards.columns.year')"
            v-model="model.endDateYear"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-12">
          <text-field
            name="fldAproximateDate"
            :label="t('filmCards.columns.aproximateDate')"
            v-model="model.aproximateDate"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldLanguage"
            :label="t('filmCards.columns.language')"
            v-model="model.languageText"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldFilmingExtent"
            :label="t('filmCards.columns.filmingExtent')"
            v-model="model.filmingExtentName"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldSource"
            :label="t('filmCards.columns.source')"
            v-model="model.source"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldArchiveCopies"
            :label="t('filmCards.columns.archiveCopies')"
            v-model="model.archiveName"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldKMFNumber"
            :label="t('filmCards.columns.KMFNumber')"
            v-model="model.countryCode"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldNumber"
            :label="t('filmCards.columns.inventoryNumber')"
            v-model="model.inventoryNumber"
            :readonly="true"
          />
        </v-col>
      </v-row>

      <v-divider></v-divider>
      <v-list-subheader>
          {{ t('filmCards.panels.copies') }}
      </v-list-subheader>
      <v-divider></v-divider>


      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldFramesCount"
            :label="t('filmCards.columns.framesCount')"
            v-model="model.framesCount"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldSize"
            :label="t('filmCards.columns.size')"
            v-model="model.size"
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
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldMicrofilmPositiveCount"
            :label="t('filmCards.columns.microfilmPositiveCount')"
            v-model="model.microfilmPositiveCount"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldPhotoCopy"
            :label="t('filmCards.columns.photoCopy')"
            v-model="model.photoCopy"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldDigitalCopy"
            :label="t('filmCards.columns.digitalCopy')"
            v-model="model.digitalCopy"
            :readonly="true"
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
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-12">
          <text-area-field
            name="fldNotes"
            :label="t('filmCards.columns.notes')"
            v-model="model.notes"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-12">
          <text-area-field
            name="fldDocumentsCharacteristics"
            :label="t('filmCards.columns.documentsCharacteristics')"
            v-model="model.documentsCharacteristics"
            :readonly="true"
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

export default defineComponent({
  name: "FilmCardGeneralDataPanel",
  components: {
    TextField,
    TextAreaField,
  },
  props: {
    filmCardData: {
      type: Object as PropType<FilmCard>,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n();
    const model = computed(() => props.filmCardData);

    return {
      t,
      model,
    };
  },
});
</script>
