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
            :validation="startDayValidationString"
          />
        </v-col>
        <v-col class="col-12 col-lg-2">
          <label></label>
          <text-field
            name="fldStartDateMonth"
            :label="t('filmCards.columns.month')"
            v-model="model.startDateMonth"
            validation="numeric|min_value:1|max_value:12"
          />
        </v-col>
        <v-col class="col-12 col-lg-2">
          <label></label>
          <text-field
            name="fldStartDateYear"
            :label="t('filmCards.columns.year')"
            v-model="model.startDateYear"
            validation="numeric|min_value:1900|max_value:2200"
          />
        </v-col>

         <v-col class="col-12 col-lg-2">
          <label>{{ t("filmCards.columns.endDate") }}</label>
          <text-field
            name="fldEndDateDay"
            :label="t('filmCards.columns.day')"
            v-model="model.endDateDay"
            :validation="endDayValidationString"
          />
        </v-col>
        <v-col class="col-12 col-lg-2">
          <label></label>
          <text-field
            name="fldEndDateMonth"
            :label="t('filmCards.columns.month')"
            v-model="model.endDateMonth"
            validation="numeric|min_value:1|max_value:12"
          />
        </v-col>
        <v-col class="col-12 col-lg-2">
          <label></label>
          <text-field
            name="fldEndDateYear"
            :label="t('filmCards.columns.year')"
            v-model="model.endDateYear"
            validation="numeric|min_value:1900|max_value:2200"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldAproximateDate"
            :label="t('filmCards.columns.aproximateDate')"
            v-model="model.aproximateDate"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <label for="fldLanguage">{{ t("filmCards.columns.language") }}</label>
          <Dropdown
            v-model="model.languageCodes"
            name="fldLanguage"
            :label="t('filmCards.columns.language')"
            labelProp="label"
            valueProp="code"
            :multiselect="true"
            :items="languages"
          />
        </v-col>
        <v-col class="col-6">
          <label for="fldFilmingExtent" class="required">{{
            t("filmCards.columns.filmingExtent")
          }}</label>
          <Dropdown
            v-model="model.filmingExtentId"
            name="fldFilmingExtent"
            :label="t('filmCards.columns.filmingExtent')"
            labelProp="label"
            valueProp="id"
            :items="filmingExtents"
            required="required"
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
            validation="required"
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
import { IDropdownOption } from "@/interfaces/dropdown";

import TextField from "@/components/field/text.field.vue";
import Dropdown from "@/components/dropdown/dropdown.vue";
import { validateDay } from "@/helpers/format.helper"

export default defineComponent({
  name: "FilmCardDatesEditPanel",
  components: {
    TextField,
    Dropdown,
  },
  emits: ["update:filmCardData"],
  props: {
    filmCardData: {
      type: Object as PropType<FilmCard>,
      required: true,
    },
    languages: {
      type: Array as PropType<IDropdownOption[]>,
    },
    filmingExtents: {
      type: Array as PropType<IDropdownOption[]>,
    },
  },
  setup(props, context) {
    const { t } = useI18n();

    const model = computed({
      get: () => props.filmCardData,
      set: (value) => context.emit("update:filmCardData", value),
    });

    const startDayValidationString = computed(() => `numeric|min_value:1|max_value:${validateDay(model.value.startDateMonth, model.value.startDateYear)}`)
    const endDayValidationString = computed(() => `numeric|min_value:1|max_value:${validateDay(model.value.endDateMonth, model.value.endDateYear)}`)

    return {
      t,
      model,
      startDayValidationString,
      endDayValidationString,
    };
  },
});
</script>
