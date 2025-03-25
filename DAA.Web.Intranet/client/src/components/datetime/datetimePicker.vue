<template>
  <DatePicker
    mode="dateTime"
    :is24hr="true"
    v-model="dateValue"
    :locale="locale"
    :popover="{ visibility: 'focus' }"
  >
    <template v-slot="{ inputValue, inputEvents }">
      <div class="input-group pointer">
        <span class="input-group-text" id="date-addon" v-if="showIcon">
          <i class="far fa-calendar-alt me-1"></i>
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
import { Field, ErrorMessage, useField } from "vee-validate";
import { uid } from "uid";

export default defineComponent({
  components: {
    DatePicker,
    Field,
    ErrorMessage,
  },
  props: {
    date: {
      type: [Date, String],
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
    name: {
      type: String,
      required: false,
    },
    placeholder: {
      type: String,
      required: false,
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  setup(props) {
    const model = ref(props.date);
    const store = useStore();
    const locale = computed(() => store.getters.language);
    const component_name = props.name || "datetime" + uid();

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
        label: props.label
      }
    );

    return {
      model,
      store,
      formatedDate,
      locale,
      component_name,
      dateValue,
      errorMessage,
      meta,
    };
  },
  methods: {
    onDateInput(e: Event) {
      console.log(e);
    },
  },
  watch: {
    dateValue: function(val) {
      this.$emit("update:date", val);
    }
  }
});
</script>
<style lang="scss" scoped>
  @import 'v-calendar/dist/style.css'
</style>