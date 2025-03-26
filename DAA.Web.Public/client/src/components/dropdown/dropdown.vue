<template>
    <Multiselect
        class="d-down"
        :name="componentName"
        v-model="inputValue"
        :options="itemsLocal"
        :label="labelProp"
        :valueProp="valueProp"
        :mode="multiselect ? 'tags' : 'single'"
        :disabled="disabled"
        @select="onSelect"
        @deselect="onDeselect"
        @clear="onClear"
        ref="multiselectRef"
        :close-on-select="!multiselect"
        multiple
    ></Multiselect>

    <!-- <v-select
    :name="componentName"
    class="d-down"
    :label="labelProp"
    :items="itemsLocal"
    :item-title="labelProp"
    :item-value="valueProp"
    v-model="inputValue"
    :multiple="multiselect"
    :clearable="true"
    :chips="multiselect"
    :closable-chips="multiselect"
    @select="onSelect"
    @deselect="onDeselect"
    @clear="onClear"
    ref="multiselectRef"
  ></v-select> -->

    <!-- <v-select
  class="d-down"
    :items="itemsLocal"
    :multiple="multiselect"
    v-model="inputValue"
    :options="itemsLocal"
    :item-title="labelProp"
    :item-value="valueProp"
    :chips="multiselect"
    :closable-chips="multiselect"
    :clearable="true"
    :id="componentName"
    @select="onSelect"
    @deselect="onDeselect"
    @clear="onClear"
    ref="multiselectRef"
    :close-on-select="true"
    :no-filter="true"
  ></v-select> -->

    <!-- <v-select
    :items="itemsLocal"
    :multiple="multiselect"
    v-model="inputValue"
    :item-title="labelProp"
    :item-value="valueProp"
    :chips="multiselect"
    :closable-chips="multiselect"
    :clearable="true"
    :id="componentName"
    @select="onSelect"
    @deselect="onDeselect"
    @clear="onClear"
    ref="multiselectRef"
  ></v-select> -->
    <ErrorMessage :name="componentName" class="text-danger" />
</template>

<script lang="ts">
import { computed, defineComponent, PropType, ref, onMounted, watch } from 'vue';
import { ErrorMessage, useField } from 'vee-validate';
import { IDropdownOption } from '@/interfaces/dropdown';
import Multiselect from '@vueform/multiselect';
import { uid } from 'uid';

export default defineComponent({
    name: 'Dropdown',
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
        items: {
            type: Array as PropType<IDropdownOption[]>,
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
            default: 'code',
        },
        labelProp: {
            type: String,
            default: 'label',
        },
        selectAllId: {
            type: Number,
            default: -999,
        },
        selectAllText: {
            type: String,
            default: 'Select all',
        },
        selectAllIdInternal: {
            type: Number,
            default: -998,
        },
        selectAllTextInternal: {
            type: String,
            default: 'Select all internal',
        },
        selectAllIdExternal: {
            type: Number,
            default: -997,
        },
        selectAllTextExternal: {
            type: String,
            default: 'Select all external',
        },
        defaultValue: {
            type: [Number, String, Array],
        },
    },
    emits: ['update:modelValue', 'change'],
    setup(props) {
        const required = computed(() => (props.required ? 'required' : ''));

        const componentName = props.name || 'Dropdown' + uid();
        // TO DO
        // const dropdownItems = computed(() => {
        //   // докато не се фиксне дроп-дауна
        //   // eslint-disable-next-line @typescript-eslint/no-explicit-any
        //   var a = props.items.map((i: any) => ({
        //     value: i[props.labelProp],
        //     title: i[props.labelProp],
        //     code: i[props.valueProp],
        //   }));
        //   return a;
        // });

        const {
            value: inputValue,
            errorMessage,
            meta,
        } = useField(componentName, required, {
            label: props.label || componentName,
            initialValue: props.modelValue,
        });

        const multiselectRef = ref<{
            /* eslint-disable */
            clear(): void;
            remove(option: IDropdownOption): void;
            select(option: IDropdownOption): void;
            deselect(option: IDropdownOption): void;
            options: IDropdownOption[];
            isSelected(option: IDropdownOption): boolean;
        }>();
        const itemsLocal = ref([...props.items]);
        watch(
            () => props.items,
            (val) => (itemsLocal.value = val)
        );

        const getExternalItems = (items: IDropdownOption[]) => {
            const result = items.filter((item) => item.hasExternalSource === true);
            return result;
        };
        const getExternalItemsCodes = () => {
            return optionsInDropdown
                .filter((option) => option.hasExternalSource === true)
                .map((option) => option.code!.toString());
        };
        const getInternalItemsCodes = () => {
            return optionsInDropdown
                .filter((option) => option.hasExternalSource === false)
                .map((option) => option.code!.toString());
        };
        const getInternalItems = (items: IDropdownOption[]) => {
            const result = items.filter((item) => item.hasExternalSource === false);
            return result;
        };
        const deselect = (codes: string[]) => {
            codes.forEach((code) => multiselectRef.value?.deselect({ code }));
        };
        const getOption = (items: IDropdownOption[], code: string) => {
            const result = items.filter((item) => item.code == code)[0];
            return result;
        };
        const optionsInDropdown = [...itemsLocal.value];
        const optionsInDropdownExternal = getExternalItems(itemsLocal.value);
        const optionsInDropdownInternal = getInternalItems(itemsLocal.value);
        const selectAllOptionInternal = getOption(optionsInDropdown, props.selectAllIdInternal.toString());
        const selectAllOptionExternal = getOption(optionsInDropdown, props.selectAllIdExternal.toString());
        const selectAllOption = getOption(optionsInDropdown, props.selectAllId.toString());

        const onSelect = (option: string) => {
            if (option === props.selectAllId.toString()) {
                if ((inputValue.value as unknown[]).length > 1) {
                    // eslint-disable-next-line @typescript-eslint/no-explicit-any
                    const itemsToDeselect = (inputValue.value as unknown[]).filter((code) => code != props.selectAllId);
                    deselect(itemsToDeselect as string[]);
                }
                itemsLocal.value = [
                    {
                        id: props.selectAllId,
                        code: props.selectAllId.toString(),
                        [props.labelProp]: props.selectAllText,
                    },
                ];
            } else if (option === props.selectAllIdInternal.toString()) {
                // eslint-disable-next-line @typescript-eslint/no-explicit-any
                const isSelectAllOptionExternalSelected =
                    (inputValue.value as IDropdownOption[]).filter(
                        (option) => option == props.selectAllIdExternal.toString()
                    ).length > 0;
                if (isSelectAllOptionExternalSelected) {
                    const selectedOptions = optionsInDropdown.filter((option) =>
                        (inputValue.value as unknown[]).includes(option.code)
                    );
                    itemsLocal.value = [...selectedOptions];
                    const itemsToDeselect = (inputValue.value as unknown[]).filter(
                        (code) => code != props.selectAllIdExternal && code != props.selectAllIdInternal
                    ) as string[];
                    deselect(itemsToDeselect);
                    return;
                }

                const internalItemsCodes = getInternalItemsCodes();
                deselect(internalItemsCodes.filter((code) => code != props.selectAllIdInternal.toString()));
                itemsLocal.value = [selectAllOption, selectAllOptionInternal, ...optionsInDropdownExternal];
            } else if (option === props.selectAllIdExternal.toString()) {
                // eslint-disable-next-line @typescript-eslint/no-explicit-any
                const isSelectAllOptionInternalSelected =
                    (inputValue.value as IDropdownOption[]).filter(
                        (option) => option == props.selectAllIdInternal.toString()
                    ).length > 0;
                if (isSelectAllOptionInternalSelected) {
                    const selectedOptions = optionsInDropdown.filter((option) =>
                        (inputValue.value as unknown[]).includes(option.code)
                    );
                    itemsLocal.value = [...selectedOptions];
                    const itemsToDeselect = (inputValue.value as unknown[]).filter(
                        (code) => code != props.selectAllIdExternal && code != props.selectAllIdInternal
                    ) as string[];
                    deselect(itemsToDeselect);
                    return;
                }

                const externalItemsCodes = getExternalItemsCodes();
                deselect(externalItemsCodes.filter((code) => code != props.selectAllIdExternal.toString()));
                itemsLocal.value = [selectAllOption, selectAllOptionExternal, ...optionsInDropdownInternal];
            }
        };
        const onDeselect = (option: string) => {
            const isSelectAllOptionExternalSelected =
                (inputValue.value as IDropdownOption[]).filter((option) => option == props.selectAllIdExternal).length >
                0;
            const isSelectAllOptionInternalSelected =
                (inputValue.value as IDropdownOption[]).filter((option) => option == props.selectAllIdInternal).length >
                0;
            const isSelectAllOptionSelected =
                (inputValue.value as IDropdownOption[]).length == 1 &&
                (inputValue.value as IDropdownOption[])[0] == props.selectAllId;

            if (
                !isSelectAllOptionInternalSelected &&
                isSelectAllOptionExternalSelected &&
                option === props.selectAllIdInternal.toString()
            ) {
                itemsLocal.value = [selectAllOption, selectAllOptionExternal, ...optionsInDropdownInternal];
            } else if (
                isSelectAllOptionInternalSelected &&
                !isSelectAllOptionExternalSelected &&
                option === props.selectAllIdExternal.toString()
            ) {
                itemsLocal.value = [selectAllOption, selectAllOptionInternal, ...optionsInDropdownExternal];
            } else if (
                !isSelectAllOptionInternalSelected &&
                !isSelectAllOptionExternalSelected &&
                !isSelectAllOptionSelected &&
                (option === props.selectAllIdInternal.toString() || option === props.selectAllIdExternal.toString())
            ) {
                itemsLocal.value = [...optionsInDropdown];
            } else if (
                !isSelectAllOptionInternalSelected &&
                !isSelectAllOptionExternalSelected &&
                isSelectAllOptionSelected &&
                (option === props.selectAllIdInternal.toString() || option === props.selectAllIdExternal.toString())
            ) {
                itemsLocal.value = [selectAllOption];
            } else if (
                isSelectAllOptionInternalSelected &&
                isSelectAllOptionExternalSelected &&
                option !== props.selectAllIdInternal.toString() &&
                option !== props.selectAllIdExternal.toString() &&
                option !== props.selectAllId.toString()
            ) {
                itemsLocal.value = [
                    ...optionsInDropdown.filter((option) => (inputValue.value as unknown[]).includes(option.code)),
                ];
            } else if (option === props.selectAllId.toString()) {
                itemsLocal.value = [...optionsInDropdown];
            }
        };
        const onClear = () => {
            itemsLocal.value = [...props.items];
        };

        const setDataSourceType = (dataSourceType: number) => {
            if (dataSourceType == 1) {
                itemsLocal.value = [...props.items];
            } else if (dataSourceType == 2) {
                itemsLocal.value = [...props.items.filter((item: IDropdownOption) => item.hasExternalSource === true)];
            } else if (dataSourceType == 3) {
                itemsLocal.value = [...props.items.filter((item: IDropdownOption) => item.hasExternalSource === false)];
            }
        };

        const clear = () => {
            multiselectRef!.value!.clear();
            //nputValue.value = [];
        };

        onMounted(() => {
            if (props.defaultValue !== undefined) {
                inputValue.value = props.defaultValue;
            }
        });

        return {
            componentName,
            inputValue,
            errorMessage,
            meta,
            onSelect,
            onDeselect,
            onClear,
            itemsLocal,
            multiselectRef,
            setDataSourceType,
            clear,
        };
    },
    watch: {
        // inputValue: function (val: string | string[])
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        inputValue: function (val: string | string[]) {
            this.$emit('update:modelValue', val);
            const options = this.items.filter((v) => {
                if (this.multiselect) {
                    // eslint-disable-next-line @typescript-eslint/no-explicit-any
                    return (val as []).some((x) => x === (v as any)[this.valueProp]);
                } else {
                    // eslint-disable-next-line @typescript-eslint/no-explicit-any
                    return (v as any)[this.valueProp] === val;
                }
            });

            if (this.multiselect) {
                this.$emit('change', options);
            } else {
                this.$emit('change', options.length > 0 ? options[0] : undefined);
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
    background-color: #a4a4a411;
    border: none;
    border-radius: 0px;
    border-bottom: 1px solid #b4a8a3;
    min-height: 56px;
}

:deep(div:has(.multiselect-options)) {
    padding: 10px;
    animation: growOut 300ms ease-in-out forwards;
    transform-origin: top center;
    top: 100%;
    min-height: 150px;
    border-radius: 0px 0px 7.5px 7.5px;
}
.text-danger {
    position: relative;
    //top: -50%;
}

:deep(::-webkit-scrollbar) {
    width: 15px !important;
}

:deep(::-webkit-scrollbar-track) {
    background-color: rgba(211, 211, 211, 0.434);
    border-radius: 0px 0px 7.5px 0px;
}

:deep(::-webkit-scrollbar-thumb) {
    background-color: var(--ISDA-main-color4);
    border-radius: 7.5px;
}

@keyframes growOut {
    0% {
        transform: scaleY(0);
    }
    100% {
        transform: scaleY(1);
    }
}
</style>
