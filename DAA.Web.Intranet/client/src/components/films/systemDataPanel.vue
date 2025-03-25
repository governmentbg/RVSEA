<template>
  <v-expansion-panel value="system">
    <v-expansion-panel-title>{{
      t("films.panels.system")
    }}</v-expansion-panel-title>
    <v-expansion-panel-text>
      <v-row>
        <v-col class="col-6">
          <text-field
            name="fldId"
            :label="t('films.columns.id')"
            v-model="id"
            :readonly="true"
          />
        </v-col>
        <v-col class="col-6">
          <text-field
            name="fldInvNumber"
            :label="t('films.columns.inventoryNumber')"
            v-model="model.inventoryNumber"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row v-if="filmData.currentProcessId && filmData.currentProcessId > 0">
        <v-col class="col-12">
          <text-field
            name="fldProcess"
            :label="t('films.columns.process')"
            v-model="model.currentProcessTypeName"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row v-if="filmData.currentProcessId && filmData.currentProcessId > 0">
        <v-col class="col-12">
          <text-field
            name="fldStep"
            :label="t('films.columns.step')"
            v-model="model.currentStepTypeName"
            :readonly="true"
          />
        </v-col>
      </v-row>
      <v-row v-if="filmData.currentProcessId && filmData.currentProcessId > 0">
        <v-col class="col-12">
          <text-area-field
            name="fldStep"
            :label="t('films.columns.comment')"
            v-model="model.comment"
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
  name: "FilmSystemDataPanel",
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
    const id = computed(() => model.value.externalIdentifier ? model.value.externalIdentifier : 'E' + model.value.systemIdentifier);
    
    return {
      t,
      model,
      id,
    };
  },
});
</script>
