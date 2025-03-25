<template>
	<v-select
		:name="componentName"
		:label="label"
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
		:error="meta.validated && !meta.valid"
		:error-messages="errorMessage"
	>
	</v-select>
</template>

<script lang="ts">
	import { computed, defineComponent, PropType, ref, onMounted, watch } from 'vue';
	import { useField } from 'vee-validate';
	import { IDropdownOption } from '@/interfaces/dropdown';
	import { uid } from 'uid';

	export default defineComponent({
		name: 'Dropdown',
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

			const onSelect = (option: string) => {
				console.log('select ', option);
			};
			const onDeselect = (option: string) => {
				console.log('deselect ', option);
			};
			const onClear = () => {
				itemsLocal.value = [...props.items];
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
		min-height: 55px;
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
		top: -50%;
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
