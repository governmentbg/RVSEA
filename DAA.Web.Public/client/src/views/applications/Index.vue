<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <div>
        <h3>{{ $t('applications.myApplications') }}</h3>
        <div class="py-3">
            <Grid
                :mode="'remote'"
                :baseUrl="'/api/applications/list'"
                :columns="gridColumns"
                :noDataMessage="$t('common.noData')"
                :showSearch="false"
                :showExport="false"
                :paging="true"
                :pageSize="10"
                @tdClick="onRowClick"
                :hasRowButtons="true"
            >
                <template v-slot:menubar>
                    <v-btn :to="'/applications/create'"
                        >{{ $t('applications.newApplication') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ $t('applications.newApplicationTooltip') }}
                        </v-tooltip>
                    </v-btn>
                </template>
            </Grid>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, onBeforeMount, computed, inject, Ref } from 'vue';
import Grid from '@/components/grid/grid.vue';
import { formatDateTime } from '@/helpers/format.helper';
import { IApplicationGrid } from '@/models/applications';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { ApplicationType, Status } from '@/enums/applications';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { useStore } from '@/store/user';
import { ProfileType } from '@/enums/profile';
import { useRedirect } from '@/helpers/router.helper';
import RowItem from '@/components/grid/rowItem.vue';
import applicationService from '@/services/applications.service';
import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
export default defineComponent({
    name: 'Applications',
    components: {
        Grid,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const router = useRouter();
        const applicationStatus = Status;
        //const showConfirmDelete = ref(false);
        const message = inject('notificationMessage') as Ref<IMessage>;
        const userStore = useStore();

        const isUserFDN = () => {
            if (userStore.getters.profileType != ProfileType.FundCreator) {
                useRedirect(router, 'AccessDenied');
            }
        };
        const onRowClick = (row: typeof RowItem) => {
            router.push('/applications/display/' + row.items.id);
        };

        const rowButtons = [
            {
                name: 'btnDisplay',
                text: () => t('applications.grid.btns.display'),
                tooltip: t('applications.grid.btns.displayTooltip'),
                icon: 'mdi mdi-eye',
                show: true,
                clickHandler: (e: IApplicationGrid) => {
                    router.push('/applications/display/' + e.id);
                },
            },
            {
                name: 'btnAddPackages',
                text: () => t('applications.grid.btns.addPackages'),
                tooltip: '',
                icon: 'mdi mdi-plus',
                show: (e: IApplicationGrid) => {
                    return e.statusId === applicationStatus.addPackages;
                },
                clickHandler: (e: IApplicationGrid) => {
                    if (e.typeId === ApplicationType.raw) {
                        router.push('/applications/packages/raw/' + e.id);
                    } else {
                        router.push('/applications/packages/assembled/' + e.id);
                    }
                },
            },
            {
                name: 'btnEditPackages',
                text: () => t('applications.grid.btns.editPackages'),
                tooltip: '',
                icon: 'mdi mdi-pencil',
                show: (e: IApplicationGrid) => {
                    return e.statusId === applicationStatus.updatePackages;
                },
                clickHandler: (e: IApplicationGrid) => {
                    if (e.typeId === ApplicationType.raw) {
                        router.push('/applications/packages/raw/' + e.id);
                    } else {
                        router.push('/applications/packages/assembled/' + e.id);
                    }
                },
            },
            {
                name: 'btnModifyPackagesAfterCommission',
                text: () => t('applications.grid.btns.modifyPackagesAfterCommission'),
                tooltip: '',
                icon: 'mdi mdi-pencil',
                show: (e: IApplicationGrid) => {
                    return e.statusId === applicationStatus.modificationRequest;
                },
                clickHandler: (e: IApplicationGrid) => {
                    if (e.typeId === ApplicationType.raw) {
                        router.push('/applications/modify-packages/raw/' + e.id);
                    } else {
                        router.push('/applications/modify-packages/assembled/' + e.id);
                    }
                },
            },
            {
                name: 'btnUploadSignePackageDocuments',
                text: () => t('applications.grid.btns.uploadSignedDocuments'),
                tooltip: t('applications.grid.btns.uploadSignedDocumentsTooltip'),
                icon: 'mdi mdi-pencil',
                show: (e: IApplicationGrid) => {
                    return e.statusId === applicationStatus.signatureRequest;
                },
                clickHandler: (e: IApplicationGrid) => {
                    useRedirect(router, 'UploadSignedDocuments', { applicationId: e.id });
                },
            },
            {
                name: 'btnDelete',
                text: () => t('applications.grid.btns.delete'),
                tooltip: t('applications.grid.btns.deleteTooltip'),
                class: 'text-danger',
                icon: 'mdi mdi-delete',
                show: (e: IApplicationGrid) => {
                    return e.statusId === applicationStatus.new;
                },
                clickHandler: async (e: IApplicationGrid) => {
                    // showConfirmDelete.value = true;
                    applicationService
                        .delete(e.id)
                        .then(() => {
                            router.go(0);
                            message.value = new Message({
                                text: t('applicationPackages.successfullyDeleted'),
                                display: true,
                                type: 'green',
                            });
                        })
                        .catch((error) => {
                            console.error(error);
                            const errorResult = error as ResponseResult;
                            message.value = new Message({
                                text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                                display: true,
                            });
                        });
                },
            },
        ];

        const gridColumns = [
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
                title: () => t('applications.grid.cols.number'),
                prop: 'number',
                type: 'text',
                sortable: true,
                filterable: true,
                visible: true,
            },
            {
                title: () => t('applications.grid.cols.type'),
                prop: 'type',
                type: 'text',
                sortable: true,
                filterable: true,
                visible: true,
            },
            {
                title: () => t('applications.grid.cols.archive'),
                prop: 'archive',
                type: 'text',
                sortable: true,
                filterable: true,
                visible: true,
            },
            {
                title: () => t('applications.grid.cols.status'),
                prop: 'status',
                type: 'text',
                sortable: true,
                filterable: true,
                visible: true,
            },
            {
                title: () => t('applications.grid.cols.creator'),
                prop: 'applicant',
                type: 'text',
                sortable: true,
                filterable: true,
                visible: true,
            },
            {
                title: () => t('applications.grid.cols.applicationDate'),
                prop: 'applicationDate',
                type: 'date',
                sortable: true,
                filterable: false,
                visible: true,
                renderFunction: formatDateTime,
            },
        ];

        const breadcrumbItems = computed(() => [
            {
                title: t('navigation.left.home'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('applications.myApplications'),
                disabled: true,
            },
        ]);
        onBeforeMount(() => {
            isUserFDN();
        });
        return {
            gridColumns,
            onRowClick,
            breadcrumbItems,
            userStore,
            isUserFDN,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/applications.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
