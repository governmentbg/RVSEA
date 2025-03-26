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
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-12">
          <text-field
            name="fldArchiveOriginals"
            :label="t('filmCards.columns.archiveOriginals')"
            v-model="model.archiveOriginals"
            validation="required"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-12">
          <text-area-field
            name="fldDocumentsCypher"
            :label="t('filmCards.columns.documentsCypher')"
            v-model="model.documentsCypher"
            validation="required"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-12">
          <text-area-field
            name="fldTitle"
            :label="t('filmCards.columns.title')"
            v-model="model.title"
            validation="required"
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

      <v-divider></v-divider>

      <v-row>
        <v-col class="col-12">
          <text-area-field
            name="fldNotes"
            :label="t('filmCards.columns.notes')"
            v-model="model.notes"
          />
        </v-col>
      </v-row>
      <v-row>        
        <v-col class="col-12">
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
import { IDropdownOption } from "@/interfaces/dropdown";

import TextField from "@/components/field/text.field.vue";
import TextAreaField from "@/components/field/textarea.field.vue";
import Dropdown from "@/components/dropdown/dropdown.vue";
import { validateDay } from "@/helpers/format.helper"
import { formatBytes } from "@/helpers/format.helper";

export default defineComponent({
  name: "FilmCardGeneralDataEditPanel",
  components: {
    TextField,
    TextAreaField,
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

    const formattedSize = computed(() => model.value.size ? formatBytes(Number(model.value.size)) : '');

    return {
      t,
      model,
      startDayValidationString,
      endDayValidationString,
      formattedSize,
    };
  },
});
</script>
