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
        >
            <template v-slot:menubar>
                <v-btn @click="addFilmReviewHandler">{{ t('filmReviews.index.grid.btn.create') }}
                    <v-tooltip
                        activator="parent"
                        location="bottom"
                    >
                    {{t('filmReviews.index.grid.btn.createTooltip')}}
                    </v-tooltip>
                </v-btn>
            </template>
        </grid>
    </div>
    <!-- <CreateReviewModal
        class="mb-3"
		@created="onCreated"
		:procedureId="procedureType"
    ></CreateReviewModal> -->
</template>

<script lang="ts">
import { computed, defineComponent, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
//import { ApplicationUserType } from "@/enums/userType";
import { PageSize } from '@/models/grid';
//import { Message } from "@/models/notification";
import { IFilmReview } from '@/interfaces/film';
//import userService from "@/services/user.service";
import filmService from '@/services/film.service';
//import authorization from "@/helpers/authorization.helper";
import { formatYesNo } from '@/helpers/format.helper';
import Grid from '@/components/grid/grid.vue';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import { formatDateTime } from '@/helpers/format.helper';
//import CreateReviewModal from "@/components/films/createReviewModal.vue"
//import { IMessage } from "@/interfaces/notification";
//import { ResponseResult } from "@/models/responseResult";

export default defineComponent({
    name: 'DisplayFilmReviews',
    components: {
        //ButtonGroup,
        Grid,
        Breadcrumbs,
        //CreateReviewModal,
    },
    setup() {
        const { t } = useI18n();
        //const message = inject("notificationMessage") as Ref<IMessage>;

        const gridUrl = computed(() => filmService.getFilmReviewsUrl());

        const router = useRouter();
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.readerAccessRecords'),
                disabled: true,
            },
        ];
        const grid = ref();

        const pageSize = PageSize.twenty;

        const addFilmReviewHandler = () => {
            useRedirect(router, 'CreateFilmReview');
        };

        const rowButtons = [
            {
                name: 'btnStopAccess',
                text: t('filmReviews.index.grid.btn.stopAccess'),
                tooltip: t('filmReviews.index.grid.btn.stopAccessTooltip'),
                icon: 'mdi mdi-cancel',
                show: (item: IFilmReview) => item.accessAllowed,
                clickHandler: async (item: IFilmReview) => {
                    if (item.systemIdentifier) {
                        const result = await filmService.updateAccess(item);
                        if (result.status == 200) {
                            if (grid.value) {
                                grid.value.refreshData();
                            }
                        }
                    }
                },
            },
            {
                name: 'btnAccessStoped',
                text: t('filmReviews.index.grid.btn.accessStped'),
                tooltip: t('filmReviews.index.grid.btn.accessStpedTooltip'),
                icon: 'mdi',
                show: (item: IFilmReview) => !item.accessAllowed,
                clickHandler: () => {
                    const link = document.createElement('a');
                    document.body.appendChild(link);
                    link.click();
                    link.remove();
                },
            },
        ];

        const columns = [
            {
                prop: '',
                //title: t('users.columns.actions'),
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
                title: t('filmReviews.index.grid.cols.systemIdentifier'),
                prop: 'systemIdentifier',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('filmReviews.index.grid.cols.userId'),
                prop: 'username',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('filmReviews.index.grid.cols.readerName'),
                prop: 'readerName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('filmReviews.index.grid.cols.filmSystemIdentifier'),
                prop: 'filmSystemIdentifier',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('filmReviews.index.grid.cols.filmInventoryNumber'),
                prop: 'filmInventoryNumber',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('filmReviews.index.grid.cols.filmNumber'),
                prop: 'filmNumber',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('filmReviews.index.grid.cols.createdOn'),
                prop: 'createdOn',
                type: 'Date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },
            {
                title: t('filmReviews.index.grid.cols.createdByDisplayName'),
                prop: 'createdByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('filmReviews.index.grid.cols.updatedOn'),
                prop: 'updatedOn',
                type: 'Date',
                renderFunction: formatDateTime,
                sortable: true,
                filterable: true,
            },
            {
                title: t('filmReviews.index.grid.cols.updatedByDisplayName'),
                prop: 'updatedByDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('filmReviews.index.grid.cols.accessAllowed'),
                prop: 'accessAllowed',
                type: 'bool',
                sortable: true,
                renderFunction: formatYesNo,
                filterable: true,
            },
        ];

        return {
            t,
            columns,
            gridUrl,
            grid,
            pageSize,
            addFilmReviewHandler,
            breadcrumbItems,
        };
    },
});
</script>
>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/breadcrumbs.scss';

:deep(a:has(span):has(i.mdi)) {
    color: lightgrey;
}

:deep(a:has(span):has(i.mdi-cancel)) {
    color: red !important;
}
</style>
