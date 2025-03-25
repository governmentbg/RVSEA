<template>
  <Multiselect
    :name="componentName"
    v-model="inputValue"
    :searchable="true"
    :filter-results="false"
    :resolve-on-load="false"
    :close-on-select="!multiselect"
    :min-chars="1"
    :delay="0"
    :options="itemsFunction"
    :label="labelProp"
    :valueProp="valueProp"
    :mode="multiselect ? 'tags' : 'single'"
    :disabled="disabled"
    @select="onOptionSelected"
    @deselect="onOptionDeselected"
    @clear="onValuesCleared"
  ></Multiselect>
  <ErrorMessage :name="componentName" class="text-danger" />
</template>

<script lang="ts">
import { computed, defineComponent, ref } from "vue";
import { ErrorMessage, useField } from "vee-validate";
import Multiselect from "@vueform/multiselect";
import { uid } from "uid";

export default defineComponent({
  name: "AsyncDropdown",
  components: {
    ErrorMessage,
    Multiselect,
  },
  props: {
    required: {
      type: Boolean,
      default: false,
    },
    label: {
      type: String,
      required: false,
    },
    name: {
      type: String,
      required: false,
      default: () => uid(),
    },
    placeholder: {
      type: String,
      required: false,
    },
    itemsFunction: {
      type: Function,
      required: true,
    },
    modelValue: {
      type: [String, Number, Array],
      required: false,
    },
    multiselect: {
      type: Boolean,
      default: false,
    },
    disabled: {
      type: Boolean,
      default: false,
    },
    valueProp: {
      type: String,
      default: "code",
    },
    labelProp: {
      type: String,
      default: "label",
    },
  },
  emits: ["update:modelValue", "change"],
  setup(props) {
    const required = computed(() => (props.required ? "required" : ""));

    const componentName = props.name || "AsyncDropdown" + uid();

    const {
      value: inputValue,
      errorMessage,
      meta,
    } = useField(componentName, required, {
      label: props.label || componentName,
      initialValue: props.modelValue,
    });

    const options = ref<any[]>([]);

    const onOptionSelected = (value: string, option: any) => {
      //console.log('select','value', value, 'option', option);

      if (
        options.value.findIndex(
          (opt) => opt[props.valueProp] === option[props.valueProp]
        ) === -1
      ) {
        options.value.push(option);
      }
      //console.log('selected options', options.value);
    };
    const onOptionDeselected = (value: string, option: any) => {
      //console.log('deselect','value', value, 'option', option);

      options.value = options.value.filter(
        (opt) => opt[props.valueProp] !== option[props.valueProp]
      );

      //console.log('selected options', options.value);
    };
    const onValuesCleared = () => {
      options.value = [];

      //console.log('selected options', options.value)
    };

    return {
      componentName,
      inputValue,
      options,
      errorMessage,
      meta,
      onOptionSelected,
      onOptionDeselected,
      onValuesCleared,
    };
  },
  watch: {
    inputValue: function (val: string | string[]) {
      this.$emit("update:modelValue", val);
      //   const options = this.items.filter((v) => {
      //     if (this.multiselect) {
      //       return (val as []).some(x => x === (v as any)[this.valueProp]);
      //     } else {
      //       return (v as any)[this.valueProp] === val;
      //     }
      //   });

      //   if (this.multiselect) {
      //     this.$emit("change", options);
      //   } else {
      //     this.$emit("change", options.length > 0 ? options[0]: undefined);
      //   }
      if (this.multiselect) {
        this.$emit("change", this.options);
      } else {
        this.$emit(
          "change",
          this.options.length > 0 ? this.options[0] : undefined
        );
      }
    },
    modelValue: function () {
      if (this.modelValue !== this.inputValue) {
        this.inputValue = this.modelValue!;
      }
    },
  },
});
</script>
