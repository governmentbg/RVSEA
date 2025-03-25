<template>
	<div>
		<label :for="componentName">{{ componentLabel }}</label>
		<AsyncDropdown
			v-model="value"
			:label="componentLabel"
			:name="componentName"
			valueProp="systemIdentifier"
			labelProp="longTitle"
			:itemsFunction="getFunds"
			:disabled="disabled || !archive"
			:required="required"
			@change="onFundChanged"
		/>
	</div>
</template>

<script lang="ts">
	import { defineComponent, PropType, ref } from 'vue'
	import AsyncDropdown from '@/components/dropdown/asyncDropdown.vue'
	import { IInventory } from '@/interfaces/inventory'
	import fundService from '@/services/dropdown.service'
	import { uid } from 'uid'

	export default defineComponent({
		name: 'FundDropdown',
		components: {
			AsyncDropdown,
		},
		props: {
			modelValue: {
				type: Number,
				required: false,
			},
			archive: {
				type: String,
			},
			label: {
				type: String,
				required: false,
			},
			name: {
				type: String,
				required: false,
			},
			required: {
				type: Boolean,
				default: false,
			},
			disabled: {
				type: Boolean,
				default: false,
			},
			descLevels: {
				type: Array as PropType<Array<string>>,
				required: false
			}
		},
		setup() {
			const value = ref()

			return {
				value,
			}
		},
		methods: {
			async getFunds(searchText: string) {
				if (this.archive) {
					const result = await fundService.getFunds(searchText, Number.parseInt(this.archive), this.descLevels)
					return result
				}
			},
			onFundChanged(option: IInventory) {
				if (option) {
					this.$emit('change', option)
				} else {
					this.$emit('change', undefined)
				}
			},
		},
		computed: {
			componentLabel() {
				return this.label || this.$t('inventories.columns.fund')
			},
			componentName() {
				return this.name || 'fldFund' + uid()
			},
		},
		watch: {
			archive: function () {
				//TODO clear dropdown
				this.value = null
				this.$emit('change', undefined)
			},
		},
	})
</script>

<style scoped>
</style>