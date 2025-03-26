<template>
  <v-select
    :items="items"
    :multiple="multiselect"
    :item-title="labelProp"
    :item-value="valueProp"
  >
  </v-select>
</template>
<script lang="ts">
import { defineComponent, PropType } from "vue";
import { IDropdownOption } from "@/interfaces/dropdown";
export default defineComponent({
  name: "Mydopdown",
  props: {
    items: {
      type: Array as PropType<IDropdownOption[]>,
      required: true,
    },
    valueProp: {
      type: String,
      default: "code",
    },
    labelProp: {
      type: String,
      default: "label",
    },
    multiselect: {
      type: Boolean,
      default: false,
    },
  },
  setup() {
    return {};
  },
});
</script>
