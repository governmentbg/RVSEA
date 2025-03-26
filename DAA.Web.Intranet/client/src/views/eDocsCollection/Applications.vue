<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <div>
        <h3>{{ $t('applications.title') }}</h3>
        <div>
            <Grid
                :mode="'remote'"
                :baseUrl="'/api/EDocsCollectingApplications/list'"
                :columns="gridColumns"
                :noDataMessage="$t('common.noDataMessage')"
                :showSearch="false"
                :showExport="false"
                :paging="true"
                :pageSize="10"
                @rowClick="onRowClick"
            ></Grid>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, inject, Ref, onMounted } from 'vue';
import Grid from '@/components/grid/grid.vue';
import { formatDateTime } from '@/helpers/format.helper';
//import { IApplicationGrid } from '@/models/applications';
//import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import RowItem from '@/components/grid/rowItem.vue';
import { Message } from '@/models/notification';
import { IMessage } from '../../interfaces/notification';

export default defineComponent({
    name: 'Applications',
    components: {
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const router = useRouter();
        const message = inject('notificationMessage') as Ref<IMessage>;

        // const rowButtons = [
        //     {
        //         name: 'btnDisplay',
        //         text: t('applications.grid.btns.display'),
        //         tooltip: '',
        //         icon: 'mdi mdi-eye',
        //         show: true,
        //         clickHandler: (e: IApplicationGrid) => {
        //             router.push('/edocscollection/applications/display/' + e.id);
        //         },
        //     },
        // ];

        const onRowClick = (row: typeof RowItem) => {
            if (row.items.id) {
                router.push('/edocscollection/applications/display/' + row.items.id);
            } else {
                message.value = new Message({
                    text: t('error.operationError'),
                    display: true,
                });
            }
        };

        const goOnTopOfPage = async() => window.scrollTo(0, 0);

        const gridColumns = [
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
                title: t('applications.grid.cols.number'),
                prop: 'number',
                type: 'number',
                sortable: true,
                filterable: true,
                visible: true,
            },
            {
                title: t('applications.grid.cols.type'),
                prop: 'documentOriginType',
                type: 'text',
                sortable: true,
                filterable: true,
                visible: true,
            },
            {
                title: t('applications.grid.cols.institution'),
                prop: 'organization',
                type: 'text',
                sortable: true,
                filterable: true,
                visible: true,
            },
            {
                title: t('applications.grid.cols.status'),
                prop: 'status',
                type: 'text',
                sortable: true,
                filterable: true,
                visible: true,
            },
            {
                title: t('applications.grid.cols.applicant'),
                prop: 'applicant',
                type: 'text',
                sortable: true,
                filterable: true,
                visible: true,
            },
            {
                title: t('applications.grid.cols.applicationDate'),
                prop: 'applicationDate',
                type: 'date',
                sortable: true,
                filterable: false,
                visible: true,
                renderFunction: formatDateTime,
            },
        ];
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('applications.title'),
                disabled: true,
            },
        ];

        onMounted(async () => {
            await goOnTopOfPage();
        })
    
        return {
            t,
            gridColumns,
            breadcrumbItems,
            onRowClick,
            goOnTopOfPage,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/index-1.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
