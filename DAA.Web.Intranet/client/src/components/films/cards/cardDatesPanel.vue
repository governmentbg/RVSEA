<template>
  <v-expansion-panel value="dates">
    <v-expansion-panel-title>{{
      t("filmCards.panels.dates")
    }}</v-expansion-panel-title>
    <v-expansion-panel-text>
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
    </v-expansion-panel-text>
  </v-expansion-panel>
</template>

<script lang="ts">
import { defineComponent, computed, PropType } from "vue";
import { useI18n } from "vue-i18n";
import { FilmCard } from "@/models/film";

import TextField from "@/components/field/text.field.vue";

export default defineComponent({
  name: "FilmCardDatesPanel",
  components: {
    TextField,
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
