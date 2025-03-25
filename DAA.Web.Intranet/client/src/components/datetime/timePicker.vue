<template>
  <DatePicker
    mode="time"
    :is24hr="true"
    v-model="dateValue"
    :locale="locale"
    :popover="{ visibility: 'focus' }"
    ref="timePicker"
  >
    <template v-slot="{ inputValue, inputEvents }">
      <div class="input-group pointer">
        <span class="input-group-text" id="date-addon" v-if="showIcon">
          <i class="far fa-clock"></i>
        </span>

        <input
          :value="inputValue"
          v-on="inputEvents"
          :label="label"
          type="text"
          class="form-control"
          :placeholder="placeholder"
          aria-label="Datepicker"
          aria-describedby="date-addon"
          @focus="onPopoverShow"
          :disabled="disabled"
        />
      </div>
    </template>
  </DatePicker>
  <div class="text-danger" v-show="errorMessage">
    {{ errorMessage }}
  </div>
</template>
<script lang="ts">
/*eslint-disable*/
import { defineComponent, watch, ref, computed } from "vue";
import { DatePicker } from "v-calendar";
import { useStore } from "@/store/app";
import moment from "moment";
import { useField } from "vee-validate";
import { uid } from "uid";

export default defineComponent({
  components: {
    DatePicker,
  },
  props: {
    date: {
      type: [String, Date],
      required: false,
      default: null,
    },
    required: {
      type: Boolean,
      default: false,
    },
    showIcon: {
      type: Boolean,
      required: false,
      default: true,
    },
    label: {
      type: String,
      required: false,
      default: "Date",
    },
    placeholder: {
      type: String,
      required: false,
    },
    name: {
      type: String,
      required: false,
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  setup(props, { emit }) {
    const model = ref(props.date || new Date());
    const store = useStore();
    const locale = computed(() => store.getters.language);
    const component_name = props.name || "time" + uid();

    const formatedDate = computed(() => {
      return model.value
        ? moment(model.value).format(store.getters.dateFormat)
        : null;
    });

    const {
      value: dateValue,
      errorMessage,
      meta,
    } = useField(
      component_name,
      { required: props.required },
      {
        initialValue: props.date,
        label: props.label,
      }
    );

    watch(
      () => dateValue.value,
      (val) => {
        emit("update:date", val);
      }
    );

    //TODO popoverWillShow event not working !!!
    const onPopoverShow = () => {
      console.log("show popover");

      if (!dateValue.value) {
        (dateValue.value as unknown) = new Date();
      }
    };

    return {
      model,
      store,
      formatedDate,
      locale,
      component_name,
      onPopoverShow,
      dateValue,
      errorMessage,
      meta,
    };
  }
});
</script>
<style lang="scss" scoped>
  @import 'v-calendar/dist/style.css'
</style>