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
            :showExport="false"
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
import { IMessage } from '../../interfaces/notification';
import { BusinessObjectType, PageSize } from '@/models/grid';
import Grid from '@/components/grid/grid.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import RowItem from '@/components/grid/rowItem.vue';
import inventoryService from '@/services/inventory.service';
export default defineComponent({
    name: 'RecordsA',
    components: {
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const gridUrl = computed(() => inventoryService.getInventoriesUrl(false));

        const grid = ref();
        const pageSize = PageSize.twenty;
        const objectType = BusinessObjectType.fund;

        const router = useRouter();

        const onRowClick = (row: typeof RowItem) => {
            if (row.items.systemIdentifier) {
                if (row.items.hasExternalSource) {
                    useRedirect(
                        router,
                        'DisplayRecordAInventory',
                        { id: row.items.systemIdentifier },
                        {
                            hasExternalSource: String(row.items.hasExternalSource),
                            externalIdentifier: row.items.externalIdentifier,
                        }
                    );
                } else {
                    useRedirectWithId(router, 'DisplayRecordAInventory', row.items.systemIdentifier);
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
                title: t('packages.recordsA'),
                disabled: true,
            },
        ];

        return {
            t,
            columns,
            gridUrl,
            grid,
            pageSize,
            breadcrumbItems,
            objectType,
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
