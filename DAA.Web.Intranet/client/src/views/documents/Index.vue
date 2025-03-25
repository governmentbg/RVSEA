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
import {
    useRedirect,
    // useRedirect,
    useRedirectWithId,
    //useRedirectWithIdAndExternalIdentifierAndExternalSource,
    //useRedirectWithIdAndExternalIdentifierAndExternalSourceAndProcedureType,
} from '@/helpers/router.helper';
import { Message } from '@/models/notification';

import { IMessage } from '@/interfaces/notification';
// import { ResponseResult } from '@/models/responseResult';
import { BusinessObjectType, ExportMode, PageSize } from '@/models/grid';
//import { DocumentOfListDisplayModel } from "@/models/document";
//import authorization from '@/helpers/authorization.helper';
import documentService from '@/services/document.service';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import Grid from '@/components/grid/grid.vue';
//import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
//import { IDocument } from '@/interfaces/document';
import { formatDateTime } from '@/helpers/format.helper';
import RowItem from '@/components/grid/rowItem.vue';

export default defineComponent({
    name: 'Documents',
    components: {
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const gridUrl = computed(() => documentService.getDocumentsUrl());

        const grid = ref();
        const pageSize = PageSize.twenty;
        const objectType = BusinessObjectType.document;
        const exportMode = ExportMode.all;

        const router = useRouter();

        const addDocumentHandler = () => {
            useRedirect(router, 'CreateDocument');
        };

        const onRowClick = (row: typeof RowItem) => {
            if (row.items.systemIdentifier) {
                if (row.items.hasExternalSource) {
                    useRedirect(
                        router,
                        'DisplayDocument',
                        { id: row.items.systemIdentifier },
                        {
                            hasExternalSource: String(row.items.hasExternalSource),
                            externalIdentifier: row.items.externalIdentifier,
                        }
                    );
                } else {
                    useRedirectWithId(router, 'DisplayDocument', row.items.systemIdentifier);
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
        //         name: 'btnDisplayDocument',
        //         text: t('common.display'),
        //         tooltip: t('documents.buttons.displayTooltip'),
        //         icon: 'mdi mdi-eye',
        //         show: authorization.isAuthenticated(),
        //         clickHandler: (item: IDocument) => {
        //             if (item.systemIdentifier) {
        //                 if (item.hasExternalSource) {
        //                     useRedirect(
        //                         router,
        //                         'DisplayDocument',
        //                         { id: item.systemIdentifier },
        //                         {
        //                             hasExternalSource: String(item.hasExternalSource),
        //                             externalIdentifier: item.externalIdentifier,
        //                         }
        //                     );
        //                 } else {
        //                     useRedirectWithId(router, 'DisplayDocument', item.systemIdentifier);
        //                 }
        //             } else {
        //                 message.value = new Message({
        //                     text: t('error.operationError'),
        //                     display: true,
        //                 });
        //             }

        //             // useRedirectWithIdAndExternalIdentifierAndExternalSource(
        //             //   router,
        //             //   "DisplayDocument",
        //             //   item.id,
        //             //   item.externalIdentifier,
        //             //   item.externalIdentifier ? "1" : "0"
        //             // );
        //         },
        //     },
        //     // {
        //     //     name: 'btnEditDocument',
        //     //     text: t('common.edit'),
        //     //     tooltip: t('documents.buttons.editTooltip'),
        //     //     icon: 'mdi mdi-pencil',
        //     //     show: authorization.isAuthenticated(),
        //     //     clickHandler: (item: IDocument) => {
        //     //         if (item.systemIdentifier && !item.hasExternalSource) {
        //     //             useRedirectWithId(router, 'EditDocument', item.systemIdentifier);
        //     //         } else {
        //     //             message.value = new Message({
        //     //                 text: t('error.operationError'),
        //     //                 display: true,
        //     //             });
        //     //         }

        //     //         // if (item.id) {
        //     //         //   if (!item.externalIdentifier) {
        //     //         //     useRedirectWithId(router, "EditDocument", item.id);
        //     //         //   } else {
        //     //         //     alert("Не можете да променяте документ от ИСДА.");
        //     //         //   }
        //     //         // }
        //     //     },
        //     // },
        //     // {
        //     //     name: 'btnDeleteDocument',
        //     //     text: t('common.delete'),
        //     //     tooltip: t('documents.buttons.deleteTooltip'),
        //     //     class: 'text-danger',
        //     //     icon: 'mdi mdi-delete',
        //     //     show: authorization.isAuthenticated(),
        //     //     clickHandler: async (item: IDocument) => {
        //     //         if (confirm(t('documents.buttons.deleteConfirmation', { title: item.number }))) {
        //     //             try {
        //     //                 const result = await documentService.deleteDocument(item.systemIdentifier!);
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

        //     //         // if (item.externalIdentifier) {
        //     //         //   alert("Не можете да изтривате документ от ИСДА.");
        //     //         //   return;
        //     //         // }
        //     //         // if (item.id) {
        //     //         //   if (
        //     //         //     confirm(
        //     //         //       t("documents.buttons.deleteConfirmation", {
        //     //         //         title: item.title,
        //     //         //       })
        //     //         //     )
        //     //         //   ) {
        //     //         //     try {
        //     //         //       const result = await documentService.deleteDocument(item.id);
        //     //         //       if (result.status == 200) {
        //     //         //         if (grid.value) {
        //     //         //           grid.value.refreshData();
        //     //         //         }
        //     //         //       } else {
        //     //         //         alert(result.response.data.message);
        //     //         //         message.value = new Message({
        //     //         //           text: result.response.data.message,
        //     //         //           display: true,
        //     //         //         });
        //     //         //       }
        //     //         //     } catch (error: unknown) {
        //     //         //       alert(error);
        //     //         //       const errorResult  = error as ResponseResult;
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
                title: t('documents.columns.archive'),
                prop: 'archiveName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('documents.columns.fund'),
                prop: 'fundNumber',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('documents.columns.inventory'),
                prop: 'inventoryNumber',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('documents.columns.archivalEntity'),
                prop: 'archivalEntityNumber',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('documents.columns.descriptionLevel'),
                prop: 'descriptionLevelText',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('documents.columns.title'),
                prop: 'title',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('documents.columns.status'),
                prop: 'statusText',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('documents.columns.createdBy'),
                prop: 'createdByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('documents.columns.createdOn'),
                prop: 'createdOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },
            {
                title: t('documents.columns.updatedBy'),
                prop: 'updatedByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('documents.columns.updatedOn'),
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
                title: t('archives.documents'),
                disabled: true,
            },
        ];

        return {
            t,
            addDocumentHandler,
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
@import '@/assets/styles/breadcrumbs-doc.scss';
</style>
