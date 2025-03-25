<template>
  <v-expansion-panel value="copies">
    <v-expansion-panel-title>{{
      t("films.panels.copies")
    }}</v-expansion-panel-title>
    <v-expansion-panel-text>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldFramesCount"
            :label="t('films.columns.framesCount')"
            v-model="model.framesCount"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldSize"
            :label="t('films.columns.size')"
            v-model="model.size"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldMicrofilmNegativeRollsCount"
            :label="t('films.columns.microfilmNegativeRollsCount')"
            v-model="model.microfilmNegativeRollsCount"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldMicrofilmNegativeFramesCount"
            :label="t('films.columns.microfilmNegativeFramesCount')"
            v-model="model.microfilmNegativeFramesCount"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldMicrofilmPositiveRollsCount"
            :label="t('films.columns.microfilmPositiveRollsCount')"
            v-model="model.microfilmPositiveRollsCount"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldMicrofilmPositiveFramesCount"
            :label="t('films.columns.microfilmPositiveFramesCount')"
            v-model="model.microfilmPositiveFramesCount"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldPhotoCopy"
            :label="t('films.columns.photoCopy')"
            v-model="model.photoCopy"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldDigitalCopy"
            :label="t('films.columns.digitalCopy')"
            v-model="model.digitalCopy"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-12">
          <text-field
            name="fldOther"
            :label="t('films.columns.other')"
            v-model="model.other"
            :readonly="true"
          />
        </v-col>
      </v-row>

      <v-row>
        <v-col class="col-12 col-lg-2">
          <label>{{ t("films.columns.acceptedOn") }}</label>
          <text-field
            name="fldAcceptedOnDay"
            :label="t('films.columns.day')"
            v-model="model.acceptedOnDay"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-12 col-lg-2">
          <label></label>
          <text-field
            name="fldAcceptedOnMonth"
            :label="t('films.columns.month')"
            v-model="model.acceptedOnMonth"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-12 col-lg-2">
          <label></label>
          <text-field
            name="fldAcceptedOnYear"
            :label="t('films.columns.year')"
            v-model="model.acceptedOnYear"
            :readonly="true"
          />
        </v-col>

        <v-col class="col-6">
          <label></label>
          <text-field
            name="fldSource"
            :label="t('films.columns.source')"
            v-model="model.source"
            :readonly="true"
          />
        </v-col>
      </v-row>

      <v-row>
        <v-col class="col-6">
          <text-area-field
            name="fldContent"
            :label="t('films.columns.content')"
            v-model="model.content"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-area-field
            name="fldNotes"
            :label="t('films.columns.notes')"
            v-model="model.notes"
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
import { Film } from "@/models/film";

import TextField from "@/components/field/text.field.vue";
import TextAreaField from "@/components/field/textarea.field.vue";

export default defineComponent({
  name: "FilmCopiesDataPanel",
  components: {
    TextField,
    TextAreaField,
  },
  props: {
    filmData: {
      type: Object as PropType<Film>,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n();

    const model = computed(() => props.filmData);

    return {
      t,
      model,
    };
  },
});
</script>
