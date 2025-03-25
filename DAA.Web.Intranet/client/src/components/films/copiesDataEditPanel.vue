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
            validation="numeric"
          />
          <small id="fldFramesCount" class="form-text text-muted">{{
            $t("films.atLeastOneRequired")
          }}</small>
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldSize"
            :label="t('films.columns.size')"
            v-model="model.size"
          />
          <small id="fldSize" class="form-text text-muted">{{
            $t("films.atLeastOneRequired")
          }}</small>
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldMicrofilmNegativeRollsCount"
            :label="t('films.columns.microfilmNegativeRollsCount')"
            v-model="model.microfilmNegativeRollsCount"
            validation="numeric"
          />
          <small
            id="fldMicrofilmNegativeRollsCount"
            class="form-text text-muted"
            >{{ $t("films.atLeastOneRequired") }}</small
          >
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldMicrofilmNegativeFramesCount"
            :label="t('films.columns.microfilmNegativeFramesCount')"
            v-model="model.microfilmNegativeFramesCount"
            validation="numeric"
          />
          <small
            id="fldMicrofilmNegativeFramesCount"
            class="form-text text-muted"
            >{{ $t("films.atLeastOneRequired") }}</small
          >
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldMicrofilmPositiveRollsCount"
            :label="t('films.columns.microfilmPositiveRollsCount')"
            v-model="model.microfilmPositiveRollsCount"
            validation="numeric"
          />
          <small
            id="fldMicrofilmPositiveRollsCount"
            class="form-text text-muted"
            >{{ $t("films.atLeastOneRequired") }}</small
          >
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldMicrofilmPositiveFramesCount"
            :label="t('films.columns.microfilmPositiveFramesCount')"
            v-model="model.microfilmPositiveFramesCount"
            validation="numeric"
          />
          <small
            id="fldMicrofilmPositiveFramesCount"
            class="form-text text-muted"
            >{{ $t("films.atLeastOneRequired") }}</small
          >
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldPhotoCopy"
            :label="t('films.columns.photoCopy')"
            v-model="model.photoCopy"
          />
          <small id="fldPhotoCopy" class="form-text text-muted">{{
            $t("films.atLeastOneRequired")
          }}</small>
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldDigitalCopy"
            :label="t('films.columns.digitalCopy')"
            v-model="model.digitalCopy"
          />
          <small id="fldDigitalCopy" class="form-text text-muted">{{
            $t("films.atLeastOneRequired")
          }}</small>
        </v-col>
      </v-row>
      <v-row>
        <v-col class="col-12">
          <text-field
            name="fldOther"
            :label="t('films.columns.other')"
            v-model="model.other"
          />
          <small id="fldOther" class="form-text text-muted">{{
            $t("films.atLeastOneRequired")
          }}</small>
        </v-col>
      </v-row>

      <v-row>
        <v-col class="col-12 col-lg-2">
          <label>{{ t("films.columns.acceptedOn") }}</label>
          <text-field
            name="fldAcceptedOnDay"
            :label="t('films.columns.day')"
            v-model="model.acceptedOnDay"
            :validation="acceptedDayValidationString"
          />
        </v-col>
        <v-col class="col-12 col-lg-2">
          <label></label>
          <text-field
            name="fldAcceptedOnMonth"
            :label="t('films.columns.month')"
            v-model="model.acceptedOnMonth"
            validation="numeric|min_value:1|max_value:12"
          />
        </v-col>
        <v-col class="col-12 col-lg-2">
          <label></label>
          <text-field
            name="fldAcceptedOnYear"
            :label="t('films.columns.year')"
            v-model="model.acceptedOnYear"
            validation="required|numeric|min_value:1900|max_value:2200"
          />
        </v-col>

        <v-col class="col-6">
          <label></label>
          <text-field
            name="fldSource"
            :label="t('films.columns.source')"
            v-model="model.source"
          />
        </v-col>
      </v-row>

      <v-row>
        <v-col class="col-6">
          <text-area-field
            name="fldContent"
            :label="t('films.columns.content')"
            v-model="model.content"
          />
        </v-col>
        <v-col class="col-6">
          <text-area-field
            name="fldNotes"
            :label="t('films.columns.notes')"
            v-model="model.notes"
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
import { validateDay } from '@/helpers/format.helper';

export default defineComponent({
  name: "FilmCopiesDataEditPanel",
  components: {
    TextField,
    TextAreaField,
  },
  emits: ["update:filmData"],
  props: {
    filmData: {
      type: Object as PropType<Film>,
      required: true,
    },
  },
  setup(props, context) {
    const { t } = useI18n();

    const model = computed({
      get: () => props.filmData,
      set: (value) => context.emit("update:filmData", value),
    });

    const acceptedDayValidationString = computed(() => `numeric|min_value:1|max_value:${validateDay(model.value.acceptedOnMonth, model.value.acceptedOnYear)}`)

     const isValid = () => {
      if (
        (!model.value.framesCount || model.value.framesCount == 0) &&
        (!model.value.microfilmNegativeRollsCount ||
          model.value.microfilmNegativeRollsCount == 0) &&
        (!model.value.microfilmNegativeFramesCount ||
          model.value.microfilmNegativeFramesCount == 0) &&
        (!model.value.microfilmPositiveRollsCount ||
          model.value.microfilmPositiveRollsCount == 0) &&
        (!model.value.microfilmPositiveFramesCount ||
          model.value.microfilmPositiveFramesCount == 0) &&
        !model.value.photoCopy?.trim() &&
        !model.value.digitalCopy?.trim() &&
        !model.value.size?.trim() &&
        !model.value.other?.trim()
      ) {
        return false;
      } else {
        return true;
      }
    };

    return {
      t,
      model,
      isValid,
      acceptedDayValidationString,
    };
  },
});
</script>
