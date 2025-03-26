<template>
	<Breadcrumbs :items="breadcrumbItems" />
	<div class="py-3">
		<grid
			ref="grid"
			:mode="'remote'"
			:baseUrl="gridUrl"
			:columns="columns"
			:paging="true"
			:pageSize="pageSize"
			:searchLabel="t('grid.search.tooltip')"
			:businessObjectType="objectType"
			:exportMode="exportMode"
			@rowClick="onRowClick"
		>
			<template v-slot:menubar>
				<v-menu>
					<template v-slot:activator="{ props }">
						<v-btn v-bind="props"> Стартиране на процес </v-btn>
					</template>
					<v-list>
						<v-list-item v-for="(item, index) in procedures" :key="index" :to="item.to">
							<v-list-item-title>{{ item.text }}</v-list-item-title>
						</v-list-item>
					</v-list>
				</v-menu>
			</template>
		</grid>
	</div>
</template>

<script lang="ts">
	import { computed, defineComponent, inject, ref, Ref } from 'vue';
	import { useI18n } from 'vue-i18n';
	import { useRouter } from 'vue-router';
	import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
	import { formatDateTime } from '@/helpers/format.helper';
	import { Message } from '@/models/notification';

	import { IMessage } from '@/interfaces/notification';
	import { ResponseResult } from '@/models/responseResult';
	import { ProcessType } from '@/enums/process';
	import { BusinessObjectType, ExportMode, PageSize } from '@/models/grid';
	import fundService from '@/services/fund.service';
	//import authorization from '@/helpers/authorization.helper';
	import dropdownService from '@/services/dropdown.service';

	import Grid from '@/components/grid/grid.vue';
	import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
	import RowItem from '@/components/grid/rowItem.vue';
	import { IDropdownItem } from '@/models/dropdown';

	export default defineComponent({
		name: 'Funds',
		components: {
			Grid,
			Breadcrumbs,
		},
		setup() {
			const { t } = useI18n();
			const message = inject('notificationMessage') as Ref<IMessage>;

			const gridUrl = computed(() => fundService.getFundsUrl());
			const grid = ref();
			const pageSize = PageSize.twenty;
			const objectType = BusinessObjectType.fund;
			const exportMode = ExportMode.all;

			const router = useRouter();
			const addFundHandler = () => {
				useRedirect(router, 'CreateFund');
			};

			const onRowClick = (row: typeof RowItem) => {
				if (row.items.systemIdentifier) {
					if (row.items.hasExternalSource) {
						useRedirect(
							router,
							'DisplayFund',
							{ id: row.items.systemIdentifier },
							{
								hasExternalSource: String(row.items.hasExternalSource),
								externalIdentifier: row.items.externalIdentifier,
							}
						);
					} else {
						useRedirectWithId(router, 'DisplayFund', row.items.systemIdentifier);
					}
				} else {
					message.value = new Message({
						text: t('error.operationError'),
						display: true,
					});
				}
			};

			const procedures = ref([] as IDropdownItem[]);

			const getProcessTypes = async () => {
				try {
					const processTypes = await dropdownService.getProcessTypes(BusinessObjectType.archive);
					if (processTypes) {
						processTypes.forEach((processType) => {
							procedures.value.push({
								id: processType.id!,
								text: processType.label!,
								to: processType.id === ProcessType.AddFundAndInventory ? '/funds/create?type=Fund' : processType.id === ProcessType.AddRawFundAndRawInventory ? '/funds/create?type=RawFund' : '/funds/create',
							})
						})
					}
				} catch (error: unknown) {
					const errorResult = error as ResponseResult;
					message.value = new Message({
						text: errorResult.showMessage ? errorResult.message : t('error.basic'),
						display: true,
					});
				}
			};
			getProcessTypes();
			
			// procedures.value.push({
			// 	id: 1,
			// 	text: 'Регистриране на нов фонд с обработени документи',
			// 	to: '/funds/create?type=Fund',
			// } as IDropdownItem);
			// procedures.value.push({
			// 	id: 2,
			// 	text: 'Регистриране на нов фонд с необработени документи/ЧП/Спомен',
			// 	to: '/funds/create?type=RawFund',
			// } as IDropdownItem);

			const columns = [
				{
					title: t('funds.columns.archive'),
					prop: 'archiveName',
					type: 'string',
					sortable: true,
					filterable: true,
				},
				{
					title: t('funds.columns.numberArray'),
					prop: 'numberArray',
					type: 'string',
					sortable: true,
					filterable: true,
				},
				{
					title: t('funds.columns.number'),
					prop: 'number',
					type: 'string',
					sortable: true,
					filterable: true,
				},
				{
					title: t('funds.columns.title'),
					prop: 'title',
					type: 'string',
					sortable: true,
					filterable: true,
				},
				{
					title: t('funds.columns.descriptionLevel'),
					prop: 'descriptionLevelText',
					type: 'string',
					sortable: true,
					filterable: true,
				},
				{
					title: t('funds.columns.type'),
					prop: 'typeText',
					type: 'string',
					sortable: true,
					filterable: true,
				},
				{
					title: t('funds.columns.status'),
					prop: 'statusText',
					type: 'string',
					sortable: true,
					filterable: true,
				},
				{
					title: t('funds.columns.acquisitionMethod'),
					prop: 'acquisitionMethodText',
					type: 'string',
					sortable: true,
					filterable: true,
				},
				{
					title: t('funds.columns.industryType'),
					prop: 'industryTypeText',
					type: 'string',
					sortable: true,
					filterable: true,
				},
				{
					title: t('archives.columns.createdBy'),
					prop: 'createdByDisplayName',
					type: 'string',
					sortable: true,
					filterable: true,
				},
				{
					title: t('archives.columns.createdOn'),
					prop: 'createdOn',
					type: 'date',
					renderFunction: formatDateTime,
					sortable: true,
					filterable: true,
				},
				{
					title: t('archives.columns.updatedBy'),
					prop: 'updatedByDisplayName',
					type: 'string',
					sortable: true,
					filterable: true,
				},
				{
					title: t('archives.columns.updatedOn'),
					prop: 'updatedOn',
					type: 'date',
					renderFunction: formatDateTime,
					sortable: true,
					filterable: true,
				},
			];
			const breadcrumbItems = [
				{
					title: t('common.start'),
					disabled: false,
					to: { name: 'Home' },
				},
				{
					title: t('funds.title'),
					disabled: true,
				},
			];

			return {
				t,
				addFundHandler,
				columns,
				gridUrl,
				grid,
				pageSize,
				exportMode,
				breadcrumbItems,
				objectType,
				onRowClick,
				procedures,
			};
		},
	});
</script>
>

<style lang="scss" scoped>
	@import '@/assets/styles/index.scss';
	@import '@/assets/styles/breadcrumbs-fund.scss';
</style>
