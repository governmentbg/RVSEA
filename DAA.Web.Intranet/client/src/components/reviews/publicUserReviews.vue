<template>
    <v-row class="mt-3">
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
        >
            <template v-slot:menubar> </template>
        </grid>
    </v-row>
</template>
<script lang="ts">
import { defineComponent, ref, computed } from 'vue';
import Grid from '@/components/grid/grid.vue';
import { useI18n } from 'vue-i18n';
import { PageSize } from '@/models/grid';
import { formatDateTime, formatUserProfileType } from '@/helpers/format.helper';
import fundService from '@/services/fund.service';
import inventoryService from '@/services/inventory.service';
import archivalEntityService from '@/services/archivalEntity.service';
import documentService from '@/services/document.service';
export default defineComponent({
    name: 'PublicUserReviews',
    components: {
        Grid,
    },
    props: {
        systemIdentifier: {
            type: String,
        },
        type: {
            type: String,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const pageSize = PageSize.five;

        const grid = ref();

        let gridUrl;

        switch (props.type) {
            case t('funds.fund'):
                gridUrl = computed(() => fundService.getFundPublicUserReviewsUrl(props.systemIdentifier));
                break;
            case t('inventories.inventory'):
                gridUrl = computed(() => inventoryService.getInventoryPublicUserReviewsUrl(props.systemIdentifier));
                break;
            case t('archiveEntities.archiveEntity'):
                gridUrl = computed(() => archivalEntityService.getArchivalEntityPublicUserReviewsUrl(props.systemIdentifier));
                break;
            case t('documents.document'):
                gridUrl = computed(() => documentService.getDocumentPublicUserReviewsUrl(props.systemIdentifier));
                break;
            default:
                break;
        }

        const columns = [
            {
                title: t('users.user'),
                prop: 'userDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('users.columns.profileType'),
                prop: 'userProfileType',
                type: 'string',
                sortable: true,
                filterable: true,
                renderFunction: formatUserProfileType,
            },
            {
                title: t('common.date'),
                prop: 'date',
                type: 'Date',
                sortable: true,
                filterable: true,
                renderFunction: formatDateTime,
            },
        ];

        return {
            t,
            grid,
            gridUrl,
            columns,
            pageSize,
        };
    },
});
</script>

<style lang="scss" scoped>

:deep(.fa-filter),
:deep(.btn-link) {
    margin-top: 0px !important;
    margin-bottom: 50px;
}
</style>
