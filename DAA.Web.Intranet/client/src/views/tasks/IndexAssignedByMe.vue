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
            :showExport="false"
            :noDataMessage="t('common.noDataMessage')"
        >
        </grid>
    </div>
</template>

<script lang="ts">
import { computed, defineComponent, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
// import { Message } from '@/models/notification';
// import { IMessage } from '@/interfaces/notification';
// import { IMessage } from '@/interfaces/notification';
import { formatDateTime } from '@/helpers/format.helper';
import { PageSize } from '@/models/grid';
import taskService from '@/services/task.service';
import authorization from '@/helpers/authorization.helper';
import Grid from '@/components/grid/grid.vue';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import { ITask } from '@/interfaces/task';
import { useRedirectWithId } from '@/helpers/router.helper';
// import { ResponseResult } from '@/models/responseResult';
// import { TaskStatus } from '@/enums/tasks';
//import { AxiosError } from 'axios'
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';

export default defineComponent({
    name: 'TasksAssignedByMe',
    components: {
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        // const message = inject('notificationMessage') as Ref<IMessage>;
        const router = useRouter();

        const gridUrl = computed(() => taskService.getAssignedByMeUrl());

        const grid = ref();
        const pageSize = PageSize.twenty;
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.tasksAssignedByMe'),
                disabled: true,
            },
        ];
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
            // {
            //     name: 'btnCancelTask',
            //     text: t('tasks.buttons.cancel'),
            //     tooltip: t('tasks.buttons.cancelTooltip'),
            //     class: 'text-danger',
            //     icon: 'mdi mdi-delete',
            //     show: (item: ITask) => {
            //         return authorization.isAuthenticated() && item.statusCode == TaskStatus.Pending;
            //     },
            //     clickHandler: async (item: ITask) => {
            //         if (item.id) {
            //             if (confirm(t('tasks.buttons.cancelConfirmation'))) {
            //                 try {
            //                     await taskService.cancel(item.id);
            //                     if (grid.value) {
            //                         grid.value.refreshData();
            //                     }
            //                 } catch (error: unknown) {
            //                     const errorResult = error as ResponseResult;
            //                     message.value = new Message({
            //                         text: errorResult.showMessage ? errorResult.message : t('error.basic'),
            //                         display: true,
            //                     });
            //                 }
            //             }
            //         }
            //     },
            // },
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
            {
                title: t('tasks.columns.status'),
                prop: 'statusName',
                type: 'string',
                sortable: true,
                sortKey: 'statusCode',
                filterable: true,
            },
            {
                title: t('tasks.columns.relatedContentUrl'),
                prop: 'relatedContentUrl',
                type: 'html',
                sortable: true,
                filterable: true,
            },
            {
                title: t('tasks.columns.assignedTo'),
                prop: 'assignedToDisplayName',
                type: 'string',
                sortable: true,
                sortKey: 'assignedToUserId',
                filterable: true,
            },
            {
                title: t('tasks.columns.assignedToRole'),
                prop: 'assignedToRoleName',
                type: 'string',
                sortable: true,
                sortKey: 'assignedToRoleId',
                filterable: true,
            },
            // {
            //     title: t('tasks.columns.createdBy'),
            //     prop: 'createdByDisplayName',
            //     type: 'string',
            //     sortable: true,
            //     filterable: true,
            // },
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
            columns,
            gridUrl,
            breadcrumbItems,
            grid,
            pageSize,
        };
    },
});
</script>
>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
