<!-- eslint-disable @typescript-eslint/no-explicit-any -->
<template>
  <Multiselect
    class="d-down"
    :name="componentName"
    v-model="inputValue"
    :searchable="true"
    :filter-results="false"
    :resolve-on-load="false"
    :close-on-select="!multiselect"
    :min-chars="1"
    :delay="2000"
    :options="itemsFunction"
    :label="labelProp"
    :valueProp="valueProp"
    :mode="multiselect ? 'tags' : 'single'"
    :disabled="disabled"
		:internalValue="{systemIdentifier: '123445', longTitle: 'Test'}"
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
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const options = ref<any[]>([]);

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
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
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
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

<style lang="scss" scoped>
.d-down {
    position: relative;
}

.text-danger {
    font-size: 0.75rem;
    color: #b00020 !important; // RGB rgb(176,0,32) - като цвета на vuetify
}

span {
    position: absolute;
    margin: -80px 10px;
}

// DROPDOWN ===>

.d-down {
    background-color: var(--input-background-color);
    border: none;
    border-radius: 0px;
    border-bottom: 1px solid var(--input-border-color);
    min-height: 55px;
}

.is-disabled {
  background-color: rgba(128, 128, 128, 0.22);
}

:deep(div.multiselect-dropdown) {
  padding: 10px;
  animation: growOut 300ms ease-in-out forwards;
  transform-origin: top center;
  top: 100%;
  min-height: 150px;
  border-radius: 0px 0px 7.5px 7.5px;
}

:deep(::-webkit-scrollbar)  {
  width: 15px !important;
}

:deep(::-webkit-scrollbar-track) {
  background-color: rgba(211, 211, 211, 0.434);
  border-radius: 0px 0px 7.5px 0px;
} 

:deep(::-webkit-scrollbar-thumb) {
  background-color: var(--bs-primary);
  border-radius: 7.5px;
}

.text-danger {
  position: relative;
  top: -50%;
}

@keyframes growOut {
    0% {
        transform: scaleY(0)
    }
    100% {
        transform: scaleY(1)
    }
}

</style>
