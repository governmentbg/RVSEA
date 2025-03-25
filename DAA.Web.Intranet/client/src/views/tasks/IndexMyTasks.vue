<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <div class="py-3">
        <grid
            :showLoading="true"
            ref="grid"
            :mode="'remote'"
            :baseUrl="gridUrl"
            :columns="columns"
            :paging="true"
            :pageSize="pageSize"
            :searchLabel="t('grid.search.tooltip')"
            :showExport="false"
            :noDataMessage="t('common.noDataMessage')"
        >
        </grid>
    </div>
</template>

<script lang="ts">
import { computed, defineComponent, ref, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { formatDateTime } from '@/helpers/format.helper';
import { PageSize } from '@/models/grid';
import taskService from '@/services/task.service';
import authorization from '@/helpers/authorization.helper';
import Grid from '@/components/grid/grid.vue';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import { ITask } from '@/interfaces/task';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import RowItem from '@/components/grid/rowItem.vue';
import { Message } from '@/models/notification';
import { IMessage } from '../../interfaces/notification';
export default defineComponent({
    name: 'MyTasks',
    components: {
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const router = useRouter();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const gridUrl = computed(() => taskService.getMyTasksUrl());
        const grid = ref();
        const pageSize = PageSize.twenty;

        const rowButtons = [
            {
                name: 'btnDisplayTask',
                text: t('tasks.buttons.display'),
                tooltip: t('tasks.buttons.displayTooltip'),
                icon: 'mdi mdi-eye',
                show: authorization.isAuthenticated(),
                clickHandler: (item: ITask) => {
                    if (item.id) {
                        useRedirectWithId(router, 'DisplayTask', item.id);
                    }
                },
            },
        ];
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.myTasks'),
                disabled: true,
            },
        ];

        const onRowClick = (row: typeof RowItem) => {
            if (row.items.id) {
                if (row.items.hasExternalSource) {
                    useRedirect(
                        router,
                        'DisplayTask',
                        { id: row.items.id },
                        {
                            hasExternalSource: String(row.items.hasExternalSource),
                            externalIdentifier: row.items.externalIdentifier,
                        }
                    );
                } else {
                    useRedirectWithId(router, 'DisplayTask', row.items.id);
                }
            } else {
                message.value = new Message({
                    text: t('error.operationError'),
                    display: true,
                });
            }
        };

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
                title: t('tasks.columns.title'),
                prop: 'title',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            // {
            //     title: t('tasks.columns.endDate'),
            //     prop: 'endDate',
            //     type: 'date',
            //     renderFunction: formatDateTime,
            //     sortable: true,
            //     filterable: true,
            // },
            // {
            //     title: t('tasks.columns.status'),
            //     prop: 'statusName',
            //     type: 'string',
            //     sortable: true,
            //     sortKey: 'statusCode',
            //     filterable: true,
            // },
            {
                title: t('tasks.columns.relatedContentUrl'),
                prop: 'relatedContentUrl',
                type: 'html',
                sortable: true,
                filterable: true,
            },
            {
                title: t('tasks.columns.createdOn'),
                prop: 'createdOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },
            {
                title: t('tasks.columns.processType'),
                prop: 'processTypeName',
                type: 'string',
                sortable: true,
                sortKey: 'processId',
                filterable: true,
            },
            {
                title: t('tasks.columns.stepTypeName'),
                prop: 'stepTypeName',
                type: 'string',
                sortable: true,
                sortKey: 'stepId',
                filterable: true,
            },
            {
                title: t('tasks.columns.notificationTypeName'),
                prop: 'notificationTypeName',
                type: 'string',
                sortable: true,
                sortKey: 'notificationType',
                filterable: true,
            },
            // {
            //     title: t('tasks.columns.createdBy'),
            //     prop: 'createdByDisplayName',
            //     type: 'string',
            //     sortable: true,
            //     filterable: true,
            // },
            // {
            //     title: t('tasks.columns.updatedBy'),
            //     prop: 'updatedByDisplayName',
            //     type: 'string',
            //     sortable: true,
            //     filterable: true,
            // },
            // {
            //     title: t('tasks.columns.updatedOn'),
            //     prop: 'updatedOn',
            //     type: 'date',
            //     renderFunction: formatDateTime,
            //     sortable: true,
            //     filterable: true,
            // },
        ];

        return {
            t,
            breadcrumbItems,
            columns,
            gridUrl,
            grid,
            pageSize,
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
