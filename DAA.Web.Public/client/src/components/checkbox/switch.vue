<template>
  <Field
    v-slot="{ field }"
    :name="name"
    :label="label"
  >
    <div class="form-check form-switch d-flex align-items-center">
      <input
        class="form-check-input"
        :class="{ large: large }"
        type="checkbox"
        :id="name"
        v-bind="field"
        v-model="model"
        :disabled="disabled"
      />
      <label v-if="showLabel" class="form-check-label ms-2" :for="name">{{
        label
      }}</label>
    </div>
  </Field>
  <ErrorMessage :name="name" class="text-danger" />
</template>
<script lang="ts">
import { defineComponent, watch, ref } from "vue";
import { Field, ErrorMessage } from "vee-validate";
import { uid } from "uid";

export default defineComponent({
  components: {
    Field,
    ErrorMessage,
  },
  props: {
    modelValue: {
      type: Boolean,
      required: false,
      default: false,
    },
    required: {
      type: Boolean,
      default: false,
    },
    label: {
      type: String,
      required: false,
    },
    showLabel: {
      type: Boolean,
      required: false,
      default: false,
    },
    large: {
      type: Boolean,
      required: false,
      default: true,
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ["update:modelValue", "change"],
  setup(props, { emit }) {
    const model = ref(props.modelValue);
    const name = "switch_" + uid();

    watch(
      () => model.value,
      (val) => {
        if (val !== props.modelValue) {
          emit("update:modelValue", val);
          emit("change", val);
        }
      }
    );

    watch(
      () => props.modelValue,
      (val) => {
        if (val !== model.value) {
          model.value = val;
        }
      }
    );

    return {
      model,
      name,
    };
  },
});
</script>
<style lang="scss" scoped>
.form-check-input.large {
  width: 3em;
  height: 1.5em;
}
</style>