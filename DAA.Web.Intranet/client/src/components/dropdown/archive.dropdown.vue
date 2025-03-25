<template>
	<div>
		<label for="fldArchive">{{ componentLabel }}</label>
		<Dropdown
			v-model="value"
			:name="componentName"
			:label="componentLabel"
			labelProp="label"
			valueProp="id"
			:items="archives"
			:required="required"
			@change="onChange"
		/>
	</div>
</template>

<script lang="ts">
	import { IDropdownOption } from "@/interfaces/dropdown";
	import dropdownService from "@/services/dropdown.service";
	import { defineComponent, ref } from "vue";
	import Dropdown from "@/components/dropdown/dropdown.vue";
import { uid } from "uid";

	export default defineComponent({
		name: 'ArchivesDropdown',
		components: {
			Dropdown
		},
		props: {
			modelValue: {
				type: Number,
				required: false
			},
			label: {
				type: String,
				required: false
			},
			name: {
				type: String,
				required: false
			},
			required: {
				type: Boolean,
				default: false
			}
		},
		setup() {
			const archives = ref<IDropdownOption[]>([]);
			const selectedValue = ref(null as IDropdownOption | null);
			const value = ref(null as number | null);
			const getArchives = async () => {
				archives.value = await dropdownService.getArchives();
			};

			getArchives();
			return {
				archives,
				selectedValue,
				value
			};
		},
		methods: {
			onChange(data: IDropdownOption | undefined) {
				this.selectedValue = data || null;
				this.$emit('change', this.selectedValue);
			}
		},
		computed: {
			componentLabel() {
				return this.label || this.$t('inventories.columns.archive')
			},
			componentName() {
				return this.name || 'fldArchive'+uid();
			}
		},
		watch: {
			modelValue: function(val: number | null) {
				this.value = val;
			},
			value: function(val: number | null) {
				this.$emit('update:modelValue', val);
			}
		}
	});
</script>

<style scoped>
</style>