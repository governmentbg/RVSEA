<template>
	<div class="py-3">
		<grid
			ref="grid"
			:baseUrl="gridUrl"
			:columns="columns"
			:mode="'remote'"
			:paging="true"
			:pageSize="pageSize"
			:showSearch="false"
			:showExport="false"
			:noDataMessage="t('common.noData')"
		>
			<template v-slot:menubar>
				<v-btn v-if="!readonly" @click="addDocumentHandler">{{ t('common.add') }}</v-btn>
			</template>
		</grid>
	</div>
</template>
<script lang="ts">
	import { computed, defineComponent, inject, ref, Ref } from 'vue';
	import { useI18n } from 'vue-i18n';
	import { useRouter } from 'vue-router';
	import { useRedirect } from '@/helpers/router.helper';
	import { Message } from '@/models/notification';

	import authorization from '@/helpers/authorization.helper';
	import documentService from '@/services/applicationPackages.service';
	import { IPackageDocument } from '@/models/applications';
	import { PageSize } from '@/models/grid';

	import Grid from '@/components/grid/grid.vue';
	import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
	import { IMessage } from '@/interfaces/notification';
	import { ResponseResult } from '@/models/responseResult';
	import { formatBytes } from '@/helpers/format.helper';
	import { EntityType } from '@/enums/entity';

	export default defineComponent({
		name: 'FilmDocuments',
		components: {
			Grid,
		},
		props: {
			filmId: {
				type: String,
				required: true,
			},
			packageId: {
				type: Number,
				required: true,
			},
			packageType: {
				type: String,
				required: true,
			},
			readonly: {
				type: Boolean,
				default:false,
			},
		},
		setup(props) {
			const { t } = useI18n();
			const message = inject('notificationMessage') as Ref<IMessage>;

			const gridUrl = computed(() => documentService.getFilmDocumentsUrl(props.packageId));

			const router = useRouter();

			const grid = ref();

			const addDocumentHandler = () => {
				useRedirect(router, 'DocumentCreate', {
					filmId: props.filmId,
					packageId: props.packageId,
					packageType: props.packageType,
				});
			};

			const rowButtons = [
				{
					name: 'btnDisplayFilmDocument',
					text: t('common.display'),
					tooltip: t('filmDocuments.displayTooltip'),
					icon: 'mdi mdi-eye',
					show: authorization.isAuthenticated(),
					clickHandler: (item: IPackageDocument) => {
						if (item.id) {
							useRedirect(router, 'DisplayFilmDocument', {
								filmId: props.filmId,
								packageType: props.packageType,
								id: item.id,
							});
						}
					},
				},
				{
					name: 'btnEditFilmDocument',
					text: t('filmDocuments.edit'),
					tooltip: t('filmDocuments.editTooltip'),
					icon: 'mdi mdi-pencil',
					show: () => {
						return authorization.isAuthenticated() && !props.readonly;
					},
					clickHandler: (item: IPackageDocument) => {
						if (item.id) {
							useRedirect(router, 'EditFilmDocument', {
								filmId: props.filmId,
								packageType: props.packageType,
								id: item.id,
							});
						}
					},
				},
				{
					name: 'btnDeleteFilmDocument',
					text: t('common.delete'),
					tooltip: t('filmDocuments.deleteTooltip'),
					class: 'text-danger',
					icon: 'mdi mdi-delete',
					show: () => {
						return authorization.isAuthenticated() && !props.readonly;
					},
					clickHandler: async (item: IPackageDocument) => {
						if (item.id) {
							if (confirm(t('filmDocuments.deleteConfirmation'))) {
								try {
									const result = await documentService.deleteFilmDocument(
										item.id,
										EntityType.film,
										props.filmId
									);
									if (result.status == 200) {
										if (grid.value) {
											grid.value.refreshData();
										}
									} else {
										message.value = new Message({
											text: result.response.data.message,
											display: true,
										});
									}
								} catch (error: unknown) {
									const errorResult = error as ResponseResult;
									message.value = new Message({
										text: errorResult.showMessage ? errorResult.message : t('error.basic'),
										display: true,
									});
								}
							}
						}
					},
				},
			];

			const columns = [
				{
					prop: '',
					title: '',
					type: 'vue',
					template: (e: ObjectConstructor) => {
						return {
							template: BtnsTemplate,
							templateArgs: {
								...e,
								btns: rowButtons,
								showAsDropdown: true,
							},
						};
					},
					sortable: false,
					filterable: false,
				},
				{
					title: t('filmDocuments.docType'),
					prop: 'documentTypeName',
					type: 'string',
					sortable: false,
					filterable: false,
				},
				{
					title: t('filmDocuments.fileName'),
					prop: 'fileName',
					type: 'string',
					sortable: false,
					filterable: false,
				},
				{
					title: t('filmDocuments.fileSize'),
					prop: 'fileSizeInBytes',
					type: 'number',
					renderFunction: formatBytes,
					sortable: false,
					filterable: false,
				},
				{
					title: t('filmDocuments.description'),
					prop: 'description',
					type: 'string',
					sortable: false,
					filterable: false,
				},
			];

			const pageSize = PageSize.ten;

			return {
				t,
				grid,
				gridUrl,
				columns,
				pageSize,
				addDocumentHandler,
			};
		},
	});
</script>
