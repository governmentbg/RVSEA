<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <div>
        <h3 class="text-center">{{ t('eDocsCollection.index.title') }}</h3>
    </div>
    <v-row>
        <v-col>
            <Grid
                :columns="columns"
                :showLoading="true"
                :paging="true"
                :pageSize="pageSize"
                :mode="'remote'"
                :baseUrl="'/api/CollectingProcedure/list'"
                @rowClick="onRowClick"
            >
                <template v-slot:menubar>
                    <v-menu offset-y>
                        <v-list>
                            <v-list-item v-for="(item, index) in procedures" :key="index" :to="item.to">
                                <v-list-item-title>{{ item.text }}</v-list-item-title>
                            </v-list-item>
                        </v-list>
                    </v-menu>
                </template>
            </Grid>
        </v-col>
    </v-row>
</template>

<script lang="ts">
import { defineComponent, ref, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { formatDateTime, formatYesNo } from '@/helpers/format.helper';
import { IDropdownItem } from '@/models/dropdown';
import Grid from '@/components/grid/grid.vue';
import RowItem from '@/components/grid/rowItem.vue';
import { PageSize } from '@/models/grid';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { useRedirectWithId } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import { IMessage } from '../../interfaces/notification';

export default defineComponent({
    components: {
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const grid = ref();
        const pageSize = PageSize.ten;
        const router = useRouter();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const procedures = ref([] as IDropdownItem[]);

        procedures.value.push({
            id: 1,
            text: 'Комплектуване на ценни електронни документи',
            to: '/edocscollection/create?type=Processed',
        } as IDropdownItem);
        procedures.value.push({
            id: 2,
            text: 'Комплектуване на ценни електронни документи от личен произход/Частично постъпление/Спомен/Учрежденски необработен (Вътрешен)',
            to: '/edocscollection/create?type=NotProcessedInternal',
        } as IDropdownItem);
        procedures.value.push({
            id: 3,
            text: 'Комплектуване на ценни електронни документи от личен произход/Частично постъпление/Спомен/Учрежденски необработен (Външен)',
            to: '/edocscollection/create?type=NotProcessedExternal',
        } as IDropdownItem);

        const onRowClick = (row: typeof RowItem) => {
            console.log(row.items);

            if (row.items.fundSystemId) {
                useRedirectWithId(router, 'DisplayFund', row.items.fundSystemId);
            } else if (row.items.inventorySystemId) {
                useRedirectWithId(router, 'DisplayInventory', row.items.inventorySystemId);
            } else {
                message.value = new Message({
                    text: t('error.operationError'),
                    display: true,
                });
            }
        };

        const columns = [
            {
                title: t('eDocsCollection.index.grid.cols.type'),
                prop: 'processTypeTitle',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('eDocsCollection.index.grid.cols.archive'),
                prop: 'archiveName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('eDocsCollection.index.grid.cols.fund'),
                prop: 'fundNumber',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('eDocsCollection.index.grid.cols.inventory'),
                prop: 'inventoryNumber',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('eDocsCollection.index.grid.cols.completed'),
                prop: 'completed',
                type: 'bool',
                sortable: true,
                filterable: true,
                renderFunction: formatYesNo,
            },
            {
                title: t('eDocsCollection.index.grid.cols.startedOn'),
                prop: 'createdOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },
            {
                title: t('eDocsCollection.index.grid.cols.startedBy'),
                prop: 'createdByDisplayName',
                type: 'string',
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
                title: t('Комплектуване на ценни електронни документи'),
                disabled: true,
            },
        ];
        return {
            t,
            procedures,
            columns,
            pageSize,
            breadcrumbItems,
            grid,
            onRowClick,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
