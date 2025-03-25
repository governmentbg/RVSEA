<template>
	<v-file-input
		ref="fileUploader"
		:label="label ?? $t('files.upload')"
		:prepend-icon="icon"
		v-model="files"
		truncate-length="15"
		hide-details="auto"
		:multiple="multipleFiles"
		:rules="[rules.required, rules.maxSize]"
		@change="inputChanged"
		@click:clear="inputChanged"
		:accept="acceptedFileTypes"
	></v-file-input>
</template>

<script lang="ts">
	import { defineComponent, computed, ref, watch } from 'vue';
	import { useI18n } from 'vue-i18n';
	import { useStore } from '@/store/app';
	import { VFileInput } from 'vuetify/lib/components';
	import { formatBytesToMB } from '@/helpers/format.helper';

	export default defineComponent({
		name: 'UploadFile',
		components: {},
		emits: ['change'],
		props: {
			acceptedFileTypes: {
				type: String,
				default: '',
			},
			packageType: {
				type: String,
				required: false,
			},
			required: {
				type: Boolean,
				required: false,
				default: false,
			},
			fileName: {
				type: String,
				required: false,
				default: '',
			},
			multipleFiles: {
				type: Boolean,
				required: false,
				default: false,
			},
			label: {
				type: String,
			},
			icon: {
				type: String,
				default: 'mdi mdi-paperclip',
			},
		},
		setup(props, context) {
			const { t } = useI18n();
			const store = useStore();
			const maxFileSize = computed(() =>
				props.packageType == 'A'
					? store.getters.maxPackageAFileSizeInMB
					: props.packageType == 'B'
					? store.getters.maxPackageBFileSizeInMB
					: 0
			);

			const fileUploader = ref();
			const files = ref([] as File[]);

			const rules = {
				maxSize: (files: File[]) =>
					!files ||
					maxFileSize.value == 0 ||
					formatBytesToMB(files.map(x => x.size ?? 0).reduce((acc, curr) => acc + curr, 0)) < maxFileSize.value ||
					t('files.maxFileSizeMessage', { size: maxFileSize.value }),
				required: (files: File[]) => props.required == false || files.length > 0 || t('files.requiredFileMessage'),
			};

			const inputChanged = () => {
				context.emit('change', files.value);
			};

			watch(
				() => props.fileName,
				(value: string) => {
					if (value && value != '') {
						files.value.push(new File([], value));
						context.emit('change', files.value);
					}
				}
			);

			const isValid = () => {
				(fileUploader.value! as typeof VFileInput).validate();

				const requiredResult = rules.required(files.value);
				const maxSizeResult = rules.maxSize(files.value);

				if (requiredResult != true || maxSizeResult != true) {
					return false;
				}

				return true;
			};

			const clear = () => {
				(fileUploader.value! as typeof VFileInput).reset();
				files.value = [];
			};

			return {
				clear,
				t,
				files,
				rules,
				inputChanged,
				isValid,
				fileUploader,
			};
		},
	});
</script>
