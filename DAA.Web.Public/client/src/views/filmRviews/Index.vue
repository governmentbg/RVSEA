<template>
    <div class="py-3">
        <grid
            ref="grid"
            :baseUrl="gridUrl"
            :columns="columns"
            :mode="'remote'"
            :paging="true"
            :pageSize="pageSize"
            :searchLabel="t('grid.search.tooltip')"
            :showSearch="false"
            :showExport="false"
            :noDataMessage="t('common.noDataMessage')"
            @rowClick="onRowClick"
        >
        </grid>
    </div>
</template>
<script lang="ts">
import { computed, defineComponent, ref, watch, Ref, inject } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import { PageSize } from '@/models/grid';
import Grid from '@/components/grid/grid.vue';
import filmService from '@/services/film.service';
import RowItem from '@/components/grid/rowItem.vue';
import { IMessage } from '@/interfaces/notification';

export default defineComponent({
    name: 'FilmsReaderList',
    components: {
        Grid,
    },
    props: {
        filmId: {
            type: String,
            required: false,
        },
        doRefresh: {
            type: Boolean,
            required: false,
            default: false,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const gridUrl = computed(() => filmService.getFilmsForReaderUrl());

        const router = useRouter();

        const grid = ref();

        const onRowClick = (row: typeof RowItem) => {
            if (row.items.systemIdentifier) {
                if (row.items.hasExternalSource) {
                    useRedirect(
                        router,
                        'DisplayFilmFull',
                        { id: row.items.systemIdentifier },
                        {
                            hasExternalSource: String(row.items.hasExternalSource),
                            externalIdentifier: row.items.externalIdentifier,
                        }
                    );
                } else {
                    useRedirectWithId(router, 'DisplayFilmFull', row.items.systemIdentifier);
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
                title: () => t('filmCards.columns.inventoryNumber'),
                prop: 'inventoryNumber',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            {
                title: () => t('filmCards.columns.KMFNumber'),
                prop: 'countryName',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            {
                title: () => t('filmCards.columns.title'),
                prop: 'title',
                type: 'string',
                sortable: true,
                filterable: false,
            },
        ];

        const pageSize = PageSize.ten;

        watch(
            () => props.doRefresh,
            () => {
                if (props.doRefresh && grid.value) {
                    grid.value.refreshData();
                }
            }
        );

        return {
            t,
            grid,
            gridUrl,
            columns,
            pageSize,
            onRowClick,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
</style>
