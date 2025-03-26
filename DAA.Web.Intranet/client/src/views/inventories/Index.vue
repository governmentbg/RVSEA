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

import { BusinessObjectType, ExportMode, PageSize } from '@/models/grid';
//import { IInventory } from '@/interfaces/inventory';
import inventoryService from '@/services/inventory.service';
//import authorization from '@/helpers/authorization.helper';

import Grid from '@/components/grid/grid.vue';
//import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import { IMessage } from '../../interfaces/notification';
// import { ResponseResult } from '../../models/responseResult';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import RowItem from '@/components/grid/rowItem.vue';

export default defineComponent({
    name: 'Inventories',
    components: {
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const gridUrl = computed(() => inventoryService.getInventoriesUrl());

        const grid = ref();
        const pageSize = PageSize.twenty;
        const objectType = BusinessObjectType.fund;
        const exportMode = ExportMode.all;

        const router = useRouter();
        const addFundHandler = () => {
            useRedirect(router, 'CreateInventory');
        };

        const onRowClick = (row: typeof RowItem) => {
            if (row.items.systemIdentifier) {
                if (row.items.hasExternalSource) {
                    useRedirect(
                        router,
                        'DisplayInventory',
                        { id: row.items.systemIdentifier },
                        {
                            hasExternalSource: String(row.items.hasExternalSource),
                            externalIdentifier: row.items.externalIdentifier,
                        }
                    );
                } else {
                    useRedirectWithId(router, 'DisplayInventory', row.items.systemIdentifier);
                }
            } else {
                message.value = new Message({
                    text: t('error.operationError'),
                    display: true,
                });
            }
        };

        // const rowButtons = [
        //     {
        //         name: 'btnDisplayInventory',
        //         text: t('inventories.buttons.display'),
        //         tooltip: t('inventories.buttons.displayTooltip'),
        //         icon: 'mdi mdi-eye',
        //         show: authorization.isAuthenticated(),
        //         clickHandler: (item: IInventory) => {
        //             if (item.systemIdentifier) {
        //                 if (item.hasExternalSource) {
        //                     useRedirect(
        //                         router,
        //                         'DisplayInventory',
        //                         { id: item.systemIdentifier },
        //                         {
        //                             hasExternalSource: String(item.hasExternalSource),
        //                             externalIdentifier: item.externalIdentifier,
        //                         }
        //                     );
        //                 } else {
        //                     useRedirectWithId(router, 'DisplayInventory', item.systemIdentifier);
        //                 }
        //             } else {
        //                 message.value = new Message({
        //                     text: t('error.operationError'),
        //                     display: true,
        //                 });
        //             }
        //         },
        //     },
        //     // {
        //     //     name: 'btnEditInventory',
        //     //     text: t('inventories.buttons.edit'),
        //     //     tooltip: t('inventories.buttons.editTooltip'),
        //     //     icon: 'mdi mdi-pencil',
        //     //     show: authorization.isAuthenticated(),
        //     //     clickHandler: (item: IInventory) => {
        //     //         // if (item.id) {
        //     //         //   useRedirectWithId(router, "EditInventory", item.id);
        //     //         // }
        //     //         if (item.systemIdentifier && !item.hasExternalSource) {
        //     //             useRedirectWithId(router, 'EditInventory', item.systemIdentifier);
        //     //         } else {
        //     //             message.value = new Message({
        //     //                 text: t('error.operationError'),
        //     //                 display: true,
        //     //             });
        //     //         }
        //     //     },
        //     // },
        //     // {
        //     //     name: 'btnDeleteInventory',
        //     //     text: t('inventories.buttons.delete'),
        //     //     tooltip: t('inventories.buttons.deleteTooltip'),
        //     //     class: 'text-danger',
        //     //     icon: 'mdi mdi-delete',
        //     //     show: authorization.isAuthenticated(),
        //     //     clickHandler: async (item: IInventory) => {
        //     //         if (confirm(t('inventories.buttons.deleteConfirmation', { title: item.number }))) {
        //     //             try {
        //     //                 const result = await inventoryService.deleteInventory(item.systemIdentifier!);
        //     //                 if (result.status == 200) {
        //     //                     if (grid.value) {
        //     //                         grid.value.refreshData();
        //     //                     }
        //     //                 } else {
        //     //                     message.value = new Message({
        //     //                         text: result.response.data.message,
        //     //                         display: true,
        //     //                     });
        //     //                 }
        //     //             } catch (error: unknown) {
        //     //                 const errorResult = error as ResponseResult;
        //     //                 message.value = new Message({
        //     //                     text: errorResult.showMessage ? errorResult.message : t('error.basic'),
        //     //                     display: true,
        //     //                 });
        //     //             }
        //     //         }
        //     //     },
        //     // },
        // ];

        const columns = [
            // {
            //     prop: '',
            //     type: 'vue',
            //     template: (e: ObjectConstructor) => {
            //         return {
            //             template: BtnsTemplate,
            //             templateArgs: {
            //                 ...e,
            //                 btns: rowButtons,
            //                 showAsDropdown: true,
            //             },
            //         };
            //     },
            //     sortable: false,
            //     filterable: false,
            // },
            {
                title: t('inventories.columns.archive'),
                prop: 'archiveName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('inventories.columns.fund'),
                prop: 'fundNumber',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('inventories.columns.number'),
                prop: 'number',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('inventories.columns.descriptionLevel'),
                prop: 'descriptionLevelText',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('inventories.columns.status'),
                prop: 'statusText',
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
                title: t('inventories.inventories'),
                disabled: true,
                to: { name: 'Inventories' },
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
            objectType,
            breadcrumbItems,
            onRowClick,
        };
    },
});
</script>
>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs-inv.scss';
</style>
