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
import { defineComponent, inject, ref, Ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { formatDateTime } from '@/helpers/format.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { BusinessObjectType, ExportMode, PageSize } from '@/models/grid';
import { IMessage } from '../../interfaces/notification';
// import { ResponseResult } from '../../models/responseResult';
//import { IArchivalEntity } from '@/interfaces/archivalEntity';
//import authorization from '@/helpers/authorization.helper';
import archiveEntityService from '@/services/archivalEntity.service';

import Grid from '@/components/grid/grid.vue';
//import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import RowItem from '@/components/grid/rowItem.vue';

export default defineComponent({
    name: 'ArchiveEntities',
    components: {
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const gridUrl = computed(() => archiveEntityService.getArchivalEntitiesUrl());

        const grid = ref();
        const pageSize = PageSize.twenty;
        const objectType = BusinessObjectType.archivalEntity;
        const exportMode = ExportMode.all;

        const router = useRouter();

        const addArchiveEntityHandler = () => {
            useRedirect(router, 'CreateArchiveEntity');
        };

        const onRowClick = (row: typeof RowItem) => {
            if (row.items.systemIdentifier) {
                if (row.items.hasExternalSource) {
                    useRedirect(
                        router,
                        'DisplayArchiveEntity',
                        { id: row.items.systemIdentifier },
                        {
                            hasExternalSource: String(row.items.hasExternalSource),
                            externalIdentifier: row.items.externalIdentifier,
                        }
                    );
                } else {
                    useRedirectWithId(router, 'DisplayArchiveEntity', row.items.systemIdentifier);
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
        //         name: 'btnDisplayArchiveEntity',
        //         text: t('common.display'),
        //         tooltip: t('archiveEntities.buttons.displayTooltip'),
        //         icon: 'mdi mdi-eye',
        //         show: authorization.isAuthenticated(),
        //         clickHandler: (item: IArchivalEntity) => {
        //             if (item.systemIdentifier) {
        //                 if (item.hasExternalSource) {
        //                     useRedirect(
        //                         router,
        //                         'DisplayArchiveEntity',
        //                         { id: item.systemIdentifier },
        //                         {
        //                             hasExternalSource: String(item.hasExternalSource),
        //                             externalIdentifier: item.externalIdentifier,
        //                         }
        //                     );
        //                 } else {
        //                     useRedirectWithId(router, 'DisplayArchiveEntity', item.systemIdentifier);
        //                 }
        //             } else {
        //                 message.value = new Message({
        //                     text: t('error.operationError'),
        //                     display: true,
        //                 });
        //             }

        //             // useRedirectWithIdAndExternalIdentifierAndExternalSource(
        //             //   router,
        //             //   "DisplayArchiveEntity",
        //             //   item.id,
        //             //   item.externalIdentifier,
        //             //   item.externalIdentifier ? "1" : "0"
        //             // );
        //         },
        //     },
        //     // {
        //     //     name: 'btnEditArchiveEntity',
        //     //     text: t('common.edit'),
        //     //     tooltip: t('archiveEntities.buttons.editTooltip'),
        //     //     icon: 'mdi mdi-pencil',
        //     //     show: authorization.isAuthenticated(),
        //     //     clickHandler: (item: IArchivalEntity) => {
        //     //         if (item.systemIdentifier && !item.hasExternalSource) {
        //     //             useRedirectWithId(router, 'EditArchiveEntity', item.systemIdentifier);
        //     //         } else {
        //     //             message.value = new Message({
        //     //                 text: t('error.operationError'),
        //     //                 display: true,
        //     //             });
        //     //         }

        //     //         // if (item.id) {
        //     //         //   if (!item.externalIdentifier) {
        //     //         //     useRedirectWithId(router, "EditArchiveEntity", item.id);
        //     //         //   } else {
        //     //         //     message.value = new Message({
        //     //         //       text: t('error.operationError'),
        //     //         //       display: true,
        //     //         //     });
        //     //         //     //alert("Не можете да променяте архивна единица от ИСДА.");
        //     //         //   }
        //     //         // }
        //     //     },
        //     // },
        //     // {
        //     //     name: 'btnDeleteArchiveEntity',
        //     //     text: t('common.delete'),
        //     //     tooltip: t('archiveEntities.buttons.deleteTooltip'),
        //     //     class: 'text-danger',
        //     //     icon: 'mdi mdi-delete',
        //     //     show: authorization.isAuthenticated(),
        //     //     clickHandler: async (item: IArchivalEntity) => {
        //     //         if (confirm(t('archiveEntities.buttons.deleteConfirmation', { title: item.number }))) {
        //     //             try {
        //     //                 const result = await archiveEntityService.deleteArchivalEntity(item.systemIdentifier!);
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

        //     //         // if(item.externalIdentifier) {
        //     //         //   message.value = new Message({
        //     //         //       text: t('error.operationError'),
        //     //         //       display: true,
        //     //         //     });
        //     //         //   //alert("Не можете да изтривате архивна единица от ИСДА.");
        //     //         //   return;
        //     //         // }
        //     //         // if (item.id) {
        //     //         //   if (
        //     //         //     confirm(
        //     //         //       t("archiveEntities.buttons.deleteConfirmation", {
        //     //         //         title: item.title,
        //     //         //       })
        //     //         //     )
        //     //         //   ) {
        //     //         //     try {
        //     //         //       const result = await archiveEntityService.deleteArchiveEntity(
        //     //         //         item.id
        //     //         //       );
        //     //         //       if (result.status == 200) {
        //     //         //         if (grid.value) {
        //     //         //           grid.value.refreshData();
        //     //         //         }
        //     //         //       } else {
        //     //         //         message.value = new Message({
        //     //         //           text: result.response.data.message,
        //     //         //           display: true,
        //     //         //         });
        //     //         //       }
        //     //         //     } catch (error: unknown) {
        //     //         //       const errorResult  = error as ResponseResult
        //     //         //       message.value = new Message({
        //     //         //         text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
        //     //         //         display: true,
        //     //         //       });
        //     //         //     }
        //     //         //   }
        //     //         // }
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
                title: t('archiveEntities.columns.archive'),
                prop: 'archiveName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('archiveEntities.columns.fund'),
                prop: 'fundNumber',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('archiveEntities.columns.inventory'),
                prop: 'inventoryNumber',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('archiveEntities.columns.number'),
                prop: 'number',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('archiveEntities.columns.descriptionLevel'),
                prop: 'descriptionLevelText',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('archiveEntities.columns.title'),
                prop: 'title',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('archiveEntities.columns.status'),
                prop: 'statusText',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('archiveEntities.columns.createdBy'),
                prop: 'createdByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('archiveEntities.columns.createdOn'),
                prop: 'createdOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },
            {
                title: t('archiveEntities.columns.updatedBy'),
                prop: 'updatedByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('archiveEntities.columns.updatedOn'),
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
                title: t('archiveEntities.archivalEntities'),
                disabled: true,
                to: { name: 'ArchiveEntities' },
            },
        ];

        return {
            t,
            addArchiveEntityHandler,
            columns,
            pageSize,
            objectType,
            exportMode,
            grid,
            gridUrl,
            breadcrumbItems,
            onRowClick,
        };
    },
});
</script>
>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs-ae.scss';
</style>
