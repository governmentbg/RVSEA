<template>
  <v-text-field
    v-model="inputValue"
    :label="labelAsPassedProp"
    :variant="variant"
    persistent-hint
    :error="meta.validated && !meta.valid"
    :error-messages="errorMessage"
    @input="handleChange"
    @blur="handleBlur"
    :color="color"
    :readonly="readonly"
    :disabled="disabled"
    :clearable="!readonly && !disabled && clearable"
    hide-details="auto"
  >
    <template v-if="!hideLabelInField" v-slot:label>
      <span v-bind:class="{ required: required }">{{ label }}</span>
    </template>
    <template v-if="appendButtonIcon && !readonly" v-slot:append>
      <v-btn
          icon
          @click="appendButtonClickHandler"
          :class="appendButtonCssClass"
      >
          <v-icon>{{ appendButtonIcon }}</v-icon>
          <v-tooltip v-if="appendButtonTooltip" activator="parent" location="bottom">
              {{ appendButtonTooltip }}
          </v-tooltip>
      </v-btn>
    </template>
  </v-text-field>
</template>

<script lang="ts">
import { computed, defineComponent, watch, ref } from "vue";
import { useField } from "vee-validate";
import { uid } from "uid";

export default defineComponent({
  name: "TextField",
  props: {
    modelValue: {
      type: [String, Number],
      default: null,
    },
    validation: {
      type: String,
      default: "",
    },
    label: {
      type: String,
      default: "",
    },
    name: {
      type: String,
      default: () => "field" + uid(),
    },
    variant: {
      type: String,
      //default: "outlined",
    },
    color: {
      type: String,
      //default: "teal"
    },
    readonly: {
      type: Boolean,
      default: false,
    },
    disabled: {
      type: Boolean,
      default: false,
    },
    clearable: {
      type: Boolean,
      default: true,
    },
    hideLabelInField: {
      type: Boolean,
      default: false,
    },
    appendButtonIcon: {
      type: String,
    },
    appendButtonTooltip: {
      type: String,
    },
    appendButtonCssClass: {
      type: String,
    },
  },
  emits: ["update:modelValue", "click:append"],
  setup(props, context) {
    const required = computed(() => {
      return props.validation.indexOf("required") !== -1;
    });
    const validation = computed(() => props.validation);
    const label = computed(() => props.label || props.name);
    const labelAsPassedProp = ref(props.hideLabelInField ? undefined : label.value);

    const appendButtonClickHandler = () => {
      context.emit('click:append');
    }

    const {
      value: inputValue,
      errorMessage,
      handleBlur,
      handleChange,
      meta,
    } = useField(props.name, validation, {
      initialValue: props.modelValue,
      label: label,
    });

    watch(
      () => props.modelValue,
      (val) => {
        inputValue.value = val;
      }
    );

    watch(
      () => inputValue.value,
      (val) => {
        context.emit("update:modelValue", val);
      }
    );

    return {
      inputValue,
      errorMessage,
      handleBlur,
      handleChange,
      meta,
      required,
      labelAsPassedProp,
      appendButtonClickHandler,
    };
  },
});
</script>

<style scoped></style>
