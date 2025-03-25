<template>
    <Breadcrumbs :items="breadcrumbItems" />

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
            :noDataMessage="t('common.noDataMessage')"
            @rowClick="onRowClick"
        >
        </grid>
    </div>
</template>
<script lang="ts">
import { computed, defineComponent, inject, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { formatDate, formatDateTime, returnSessionTypeName, switchProtocolStatusText } from '@/helpers/format.helper';
import { useRedirectWithId } from '@/helpers/router.helper';

import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { PageSize } from '@/models/grid';
import commissionSessionService from '@/services/commissionSession.service';

import Grid from '@/components/grid/grid.vue';
import RowItem from '@/components/grid/rowItem.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';

export default defineComponent({
    name: 'PastSessions',
    components: {
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const gridUrl = computed(() => commissionSessionService.getListPastSessionsUrl());

        const router = useRouter();

        const grid = ref();

        const onRowClick = (row: typeof RowItem) => {
            if (row.items.id) {
                useRedirectWithId(router, 'DisplaySession', row.items.id);
            } else {
                message.value = new Message({
                    text: t('error.operationError'),
                    display: true,
                });
            }
        };

        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.pastSessions'),
                disabled: true,
            },
        ];

        const columns = [
            {
                title: t('sessions.columns.date'),
                prop: 'sessionDate',
                type: 'date',
                renderFunction: formatDate,
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.type'),
                prop: 'sessionTypeCode',
                renderFunction: returnSessionTypeName,
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.archive'),
                prop: 'archiveName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.chairman'),
                prop: 'chairmanDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.secretary'),
                prop: 'secretaryDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.minutesOfMeetingStatus'),
                prop: 'minutesOfMeetingStatus',
                type: 'string',
                sortable: true,
                filterable: true,
                renderFunction: switchProtocolStatusText,
            },
            {
                title: t('sessions.columns.createdBy'),
                prop: 'createdByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.createdOn'),
                prop: 'createdOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.updatedBy'),
                prop: 'updatedByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('sessions.columns.updatedOn'),
                prop: 'updatedOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },
        ];

        const pageSize = PageSize.twenty;

        return {
            t,
            grid,
            gridUrl,
            columns,
            pageSize,
            breadcrumbItems,
            onRowClick,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
