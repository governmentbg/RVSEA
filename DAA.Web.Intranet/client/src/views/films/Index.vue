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
            :noDataMessage="t('common.noDataMessage')"
            @rowClick="onRowClick"
        >
            <template v-slot:menubar v-if="canCreate == true">
                <v-btn @click="addHandler">{{ t('films.create') }}
                    <v-tooltip
                        activator="parent"
                        location="bottom"
                    >
                    {{t('films.buttons.createTooltip')}}
                    </v-tooltip>
                </v-btn>
            </template>
        </grid>
    </div>
</template>

<script lang="ts">
import { computed, defineComponent, inject, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
//import { formatDateTime } from '@/helpers/format.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { BusinessObjectType, ExportMode, PageSize } from '@/models/grid';
import filmService from '@/services/film.service';
// import authorization from '@/helpers/authorization.helper';

import Grid from '@/components/grid/grid.vue';
// import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
// import { IFilm } from '@/interfaces/film';
import { IMessage } from '@/interfaces/notification';
// import { ResponseResult } from '@/models/responseResult';
import { RoleNames } from '@/enums/roles';
import { useStore } from '@/store/user';
import RowItem from '@/components/grid/rowItem.vue'

export default defineComponent({
    name: 'Films',
    components: {
        Grid,
        Breadcrumbs,
    },
    props: {
        hasExternalSource: {
            type: Boolean,
            required: false,
        },
        externalIdentifier: {
            type: Number,
            required: false,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const userStore = useStore();

        const gridUrl = computed(() => filmService.getFilmsUrl(props.hasExternalSource, props.externalIdentifier));

        const grid = ref();
        const pageSize = PageSize.twenty;
        const objectType = BusinessObjectType.film;
        const exportMode = ExportMode.all;

        const router = useRouter();
        const canCreate = computed(() => userStore.getters.hasRole(RoleNames.GroupI));
        // const canDelete = computed(() => userStore.getters.hasRole(RoleNames.GroupI));

        const addHandler = () => {
            useRedirect(router, 'CreateFilm');
        };


        const onRowClick = (row: typeof RowItem) => {
            if (row.items.systemIdentifier) {
                if (row.items.hasExternalSource) {
                    useRedirect(
                        router,
                        'DisplayFilm',
                        { id: ' ' /*item.systemIdentifier*/ },
                        {
                            hasExternalSource: String(row.items.hasExternalSource),
                            externalIdentifier: row.items.externalIdentifier,
                        }
                    );
                } else if (row.items.systemIdentifier) {
                    useRedirectWithId(router, 'DisplayFilm', row.items.systemIdentifier);
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
        //         name: 'btnDisplayFilm',
        //         text: t('films.buttons.display'),
        //         tooltip: t('films.buttons.displayTooltip'),
        //         icon: 'mdi mdi-eye',
        //         show: authorization.isAuthenticated(),
        //         clickHandler: (item: IFilm) => {
        //             if (item.hasExternalSource) {
        //                 useRedirect(
        //                     router,
        //                     'DisplayFilm',
        //                     { id: ' ' /*item.systemIdentifier*/ },
        //                     {
        //                         hasExternalSource: String(item.hasExternalSource),
        //                         externalIdentifier: item.externalIdentifier,
        //                     }
        //                 );
        //             } else if (item.systemIdentifier) {
        //                 useRedirectWithId(router, 'DisplayFilm', item.systemIdentifier);
        //             } else {
        //                 message.value = new Message({
        //                     text: t('error.operationError'),
        //                     display: true,
        //                 });
        //             }
        //         },
        //     },
        //     {
        //         name: 'btnDeleteFilm',
        //         text: t('films.buttons.delete'),
        //         tooltip: t('films.buttons.deleteTooltip'),
        //         class: 'text-danger',
        //         icon: 'mdi mdi-delete',
        //         show: (item: IFilm) =>
        //             authorization.isAuthenticated() && canDelete.value == true && !item.hasExternalSource,
        //         clickHandler: async (item: IFilm) => {
        //             if (item.id) {
        //                 if (confirm(t('films.buttons.deleteConfirmation', { number: item.inventoryNumber }))) {
        //                     try {
        //                         const result =
        //                             item.isDraft == true
        //                                 ? await filmService.deleteFilmDraft(item.id)
        //                                 : await filmService.deleteFilm(item.systemIdentifier || '0');
        //                         if (result.status == 200) {
        //                             if (grid.value) {
        //                                 grid.value.refreshData();
        //                             }
        //                         } else {
        //                             message.value = new Message({
        //                                 text: result.response.data.message,
        //                                 display: true,
        //                             });
        //                         }
        //                     } catch (error: unknown) {
        //                         const errorResult = error as ResponseResult;
        //                         message.value = new Message({
        //                             text: errorResult.showMessage ? errorResult.message : t('error.basic'),
        //                             display: true,
        //                         });
        //                     }
        //                 }
        //             }
        //         },
        //     },
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
                title: t('films.columns.archive'),
                prop: 'archiveName',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            {
                title: t('films.columns.inventoryNumber'),
                prop: 'inventoryNumber',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('films.columns.country'),
                prop: 'countryName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('films.columns.KMFNumber'),
                prop: 'countryCode',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            // {
            //     title: t('films.columns.process'),
            //     prop: 'currentProcessTypeName',
            //     type: 'string',
            //     sortable: true,
            //     filterable: true,
            // },
            // {
            //     title: t('films.columns.isDraft'),
            //     prop: 'isDraft',
            //     type: 'boolean',
            //     renderFunction: formatYesNo,
            //     sortable: true,
            // },

            // {
            //     title: t('films.columns.createdBy'),
            //     prop: 'createdByDisplayName',
            //     type: 'string',
            //     sortable: true,
            //     filterable: true,
            // },
            // {
            //     title: t('films.columns.createdOn'),
            //     prop: 'createdOn',
            //     type: 'date',
            //     renderFunction: formatDateTime,
            //     sortable: true,
            //     filterable: true,
            // },
            // {
            //     title: t('films.columns.updatedBy'),
            //     prop: 'updatedByDisplayName',
            //     type: 'string',
            //     sortable: true,
            //     filterable: true,
            // },
            // {
            //     title: t('films.columns.updatedOn'),
            //     prop: 'updatedOn',
            //     type: 'date',
            //     renderFunction: formatDateTime,
            //     sortable: true,
            //     filterable: true,
            // },
        ];
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('archives.kmf'),
                disabled: true,
            },
        ];
        return {
            t,
            addHandler,
            columns,
            gridUrl,
            grid,
            pageSize,
            exportMode,
            objectType,
            canCreate,
            breadcrumbItems,
            onRowClick,
        };
    },
});
</script>
>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
