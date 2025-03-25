<template>
	<v-dialog v-model="dialog" persistent>
		<v-card class="vw-50 p-3">
			<v-card-title class="text-h5 text-center">
				{{ $t('packages.displayDocumentTitle') }}
			</v-card-title>
			<v-card-text>
				<v-container>
					<v-row>
						<v-col cols="12">
							<div>{{ modelValue.documentType || $t('packageATemplates.file')  }}</div>
							<div class="d-flex w-100">
								{{ `${modelValue.fileName} (${modelValue.fileSize} KB)` }}
								<a :href="buildUrl(modelValue.id)" class="text-decoration-none">
									<v-tooltip>
										<template v-slot:activator="{ props }">
											<v-icon color="primary" dark v-bind="props"> mdi-download </v-icon>
										</template>
										<span>{{ $t('common.download') }}</span>
									</v-tooltip>
								</a>
							</div>
						</v-col>
						<v-col cols="12">
							<div>{{ $t('packageATemplates.description') }}</div>
							<div>{{ modelValue.description }}</div>
						</v-col>
					</v-row>
				</v-container>
			</v-card-text>
			<v-card-actions>
				<v-spacer></v-spacer>
				<v-btn color="primary" variant="outlined" @click="onClose">
					{{ $t('common.close') }}
				</v-btn>
				<v-spacer></v-spacer>
			</v-card-actions>
		</v-card>
	</v-dialog>
</template>

<script lang="ts">
	import { defineComponent, PropType, ref } from 'vue';
	import { useStore } from '@/store/app';
	
	import { IPackageAFile } from '@/models/packages';
	
	import applicationService from '@/services/applications.service';

	export default defineComponent({
		name: 'DisplayPackageFile',
		props: {
			modelValue: {
				type: Object as PropType<IPackageAFile>,
				required: true,
			},
			show: {
				type: Boolean,
				required: true,
			},
		},
		setup() {
			const dialog = ref(false);
			const store = useStore();

			return {
				dialog,
				store
			};
		},
		methods: {
			buildUrl(id: number) {
				//return this.store.getters.baseUrl + '/api/EDocsCollectingApplications/onlyDownloadPackageFile/' + id;
				return applicationService.packageDocumentStreamUrl(id);
			},
			onClose() {
				this.dialog = false;
				this.$emit('update:show', false);
			},
		},
		watch: {
			show: function (val: boolean) {
				this.dialog = val;
			},
		},
	});
</script>

<style scoped lang="scss">
	.vw-50 {
		width: 50vw;
		min-height: 30vh;
	}

	@import '@/assets/styles/dialog.scss';
</style>