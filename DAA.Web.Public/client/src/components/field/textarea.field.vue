<template>
  <v-textarea
    v-model="inputValue"
    :label="label"
    :variant="variant"
    persistent-hint
    :error="meta.validated && !meta.valid"
    :error-messages="errorMessage"
    @input="handleChange"
    @blur="handleBlur"
    :color="color"
    :readonly="readonly"
    :disabled="disabled"
    hide-details="auto"
  >
    <template v-slot:label>
      <span v-bind:class="{ required: required }">{{ label }}</span>
    </template>
  </v-textarea>

  <!-- <v-text-field
		v-model="inputValue"
		:label="label"
		:variant="variant"
		persistent-hint
		:error="meta.validated && !meta.valid"
		:error-messages="errorMessage"
		@input="handleChange"
		@blur="handleBlur"
		:color="color"
		:readonly="readonly"
		:disabled="disabled"
		hide-details="auto"
	>
		<template v-slot:label>
			<span v-bind:class="{required: required}">{{label}}</span>
		</template>
	</v-text-field> -->
</template>

<script lang="ts">
import { computed, defineComponent, watch } from "vue";
import { useField } from "vee-validate";
import { uid } from "uid";

export default defineComponent({
  name: "TextAreaField",
  props: {
    modelValue: {
      type: String,
      default: "",
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
      //default: "underlined",
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
  },
  emits: ["update:modelValue"],
  setup(props, { emit }) {
    const required = computed(() => {
      return props.validation.indexOf("required") !== -1;
    });
    const validation = computed(() => props.validation);
    const label = computed(() => props.label || props.name);

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
        emit("update:modelValue", val);
      }
    );

    return {
      inputValue,
      errorMessage,
      handleBlur,
      handleChange,
      meta,
      required,
    };
  },
});
</script>

<style scoped></style>
