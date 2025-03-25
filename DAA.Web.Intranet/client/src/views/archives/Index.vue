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
        >
            <template v-slot:menubar>
                <v-btn @click="addArchiveHandler">{{ t('archives.create') }}
                    <v-tooltip
                        activator="parent"
                        location="bottom"
                    >
                    {{t('archives.buttons.createTooltip')}}
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
import { formatDateTime } from '@/helpers/format.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { BusinessObjectType, ExportMode, PageSize } from '@/models/grid';
import archiveService from '@/services/archive.service';
import authorization from '@/helpers/authorization.helper';
import { IArchive } from '@/interfaces/archive';

import Grid from '@/components/grid/grid.vue';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '../../models/responseResult';

export default defineComponent({
    name: 'Archives',
    components: {
        //ButtonGroup,
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const gridUrl = computed(() => archiveService.getArchivesUrl());

        const grid = ref();
        const pageSize = PageSize.twenty;
        const objectType = BusinessObjectType.archive;
        const exportMode = ExportMode.all;

        const router = useRouter();
        const addArchiveHandler = () => {
            useRedirect(router, 'CreateArchive');
        };
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.archives'),
                disabled: true,
            },
        ];
        const rowButtons = [
            {
                name: 'btnDisplayArchive',
                text: t('archives.buttons.display'),
                tooltip: t('archives.buttons.displayTooltip'),
                icon: 'mdi mdi-eye',
                show: authorization.isAuthenticated(),
                clickHandler: (item: IArchive) => {
                    if (item.id) {
                        useRedirectWithId(router, 'DisplayArchive', item.id);
                    }
                },
            },
            {
                name: 'btnEditArchive',
                text: t('archives.buttons.edit'),
                tooltip: t('archives.buttons.editTooltip'),
                icon: 'mdi mdi-pencil',
                show: authorization.isAuthenticated(),
                clickHandler: (item: IArchive) => {
                    if (item.id) {
                        useRedirectWithId(router, 'EditArchive', item.id);
                    }
                },
            },
            {
                name: 'btnDeleteArchive',
                text: t('archives.buttons.delete'),
                tooltip: t('archives.buttons.deleteTooltip'),
                class: 'text-danger',
                icon: 'mdi mdi-delete',
                show: authorization.isAuthenticated(),
                clickHandler: async (item: IArchive) => {
                    if (item.id) {
                        if (confirm(t('archives.buttons.deleteConfirmation', { title: item.name }))) {
                            try {
                                const result = await archiveService.deleteArchive(item.id);
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
                title: t('archives.columns.name'),
                prop: 'name',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('archives.columns.code'),
                prop: 'code',
                type: 'number',
                sortable: true,
                filterable: true,
            },
            {
                title: t('archives.columns.sortOrder'),
                prop: 'sortOrder',
                type: 'number',
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

        return {
            t,
            addArchiveHandler,
            columns,
            gridUrl,
            grid,
            pageSize,
            exportMode,
            objectType,
            breadcrumbItems,
        };
    },
});
</script>
>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
