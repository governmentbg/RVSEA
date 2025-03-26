<template>
    <div>
        <DatePicker
            class="d-pick"
            mode="date"
            v-model="dateValue"
            :locale="locale"
            :popover="{ visibility: 'focus' }"
            :disabled="disabled"
            @click="onClick"
        >
            <template v-slot="{ inputValue, inputEvents }">
                <div class="input-group pointer">
                    <span
                        class="input-group-text"
                        :class="{ cursorPointer: !disabled }"
                        id="date-addon"
                        v-if="showIcon"
                    >
                        <i class="far fa-calendar-alt"></i>
                    </span>

                    <input
                        :value="inputValue"
                        v-on="inputEvents"
                        :label="label"
                        :disabled="disabled"
                        type="text"
                        class="form-control"
                        :placeholder="placeholder"
                        aria-label="Datepicker"
                        aria-describedby="date-addon"
                        ref="input"
                    />
                </div>
            </template>
        </DatePicker>
        <div class="text-danger" v-show="errorMessage">
            {{ errorMessage }}
        </div>
    </div>
</template>
<script lang="ts">
/*eslint-disable*/
import { defineComponent, computed, ref } from 'vue';
import { DatePicker } from 'v-calendar';
import { useStore } from '@/store/app';
import { useField } from 'vee-validate';
import { uid } from 'uid';

export default defineComponent({
    components: {
        DatePicker,
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
            default: 'Date',
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
            default: false,
        },
    },
    setup(props) {
        const store = useStore();
        const locale = computed(() => store.getters.language);
        const component_name = props.name || 'date' + uid();
        const required = computed(() => (props.required ? 'required' : ''));

        const {
            value: dateValue,
            errorMessage,
            meta,
        } = useField(component_name, required, {
            initialValue: props.date,
            label: props.label,
        });

        const input = ref<HTMLElement>();
        const onClick = (e: Event) => {
            e.stopPropagation();
            input!.value!.focus();
        };

        return {
            store,
            locale,
            component_name,
            dateValue,
            errorMessage,
            meta,
            onClick,
            input,
        };
    },
    methods: {
        onDateInput(e: Event) {
            console.log(e);
        },
    },
    watch: {
        dateValue: function (val) {
            this.$emit('update:date', val);
        },
        date: function (val) {
            this.dateValue = val;
        },
    },
});
</script>
<style lang="scss" scoped>
@import 'v-calendar/dist/style.css';

.text-danger {
    font-size: 0.75rem;
    color: #b00020 !important; // RGB rgb(176,0,32) - като цвета на vuetify
}

.d-pick input {
    background-color: var(--input-background-color) !important;
    border-radius: 0px !important;
    border: none !important;
    border-bottom: 1px solid var(--input-border-color) !important;
    box-shadow: none;
    min-height: 56px;
}

input:disabled {
    background-color: rgba(211, 211, 211, 0.709) !important;
}

.input-group-text {
    border: 1px solid var(--input-border-color);
}

.cursorPointer {
    border: 1px solid var(--input-border-color);
    cursor: pointer;
}
</style>
