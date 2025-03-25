<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.partialReceiptsList') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" xl="12" class="col-divs">
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.resultTypes') }}</label>
                                <Dropdown
                                    v-if="reportResultTypes"
                                    name="ReportResultTypes"
                                    :label="t('reports.resultTypes')"
                                    required="required"
                                    :items="reportResultTypes"
                                    v-model="inputModel.ReportResultType"
                                    :defaultValue="1"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.archiveName') }}</label>
                                <Dropdown
                                    v-if="archives"
                                    :label="t('reports.archiveName')"
                                    name="fldArchiveName"
                                    required="required"
                                    :items="archives"
                                    :multiselect="true"
                                    v-model="inputModel.Archives"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="archivesDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label>{{ t('reports.resultsLimit') }}</label>
                                <Dropdown
                                    name="ItemsPerPage"
                                    labelProp="text"
                                    :items="rowsPerPageDropdownValues"
                                    v-model="inputModel.ItemsPerPage"
                                    :defaultValue="defaultRowsPerPage"
                                    :selectAllText="t('reports.all')"
                                />
                            </div>
                        </v-col>
                    </v-row>
                    <v-row justify="center">
                        <v-btn class="mr-4" type="submit" :disabled="false">
                            {{ t('reports.viewReport') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('reports.viewReportTooltip') }}
                            </v-tooltip>
                        </v-btn>
                        <v-btn class="clear bg-secondary" @click="clear" :disabled="false">
                            {{ t('common.clear') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('common.clearTooltip') }}
                            </v-tooltip>
                        </v-btn>
                    </v-row>
                </Form>
            </div>
        </v-card>
        <!-- </v-card-text>
    </v-card> -->
        <div v-show="showReport">
            <div class="summaryGrid">
                <Grid
                    :columns="summaryHeaders"
                    :items="summaryGridItems"
                    :totalItems="1"
                    :showSearch="false"
                    mode="custom"
                    :showExport="false"
                    @refresh="viewReportOnRefresh"
                />
            </div>
            <Grid
                :columns="headers"
                :items="gridItems"
                :paging="true"
                :pageSize="inputModel.ItemsPerPage"
                :totalItems="totalGridRowsCount"
                :showSearch="false"
                mode="custom"
                :exportMode="'all'"
                :exportParams="exportParams"
                :exportOptions="exportOptions"
                :businessObjectType="'report'"
                :noHorizontalScroll="true"
                @refresh="viewReportOnRefresh"
                @rowClick="onRowClick"
                ref="grid"
            />
        </div>
    </v-container>
</template>
<script lang="ts">
import { defineComponent, ref, onMounted, inject, Ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import {
    PartialReceiptsListReport,
    ListFiltersModel,
    ReportGridRequestModel,
    ReportGridWithSummaryGridResponseModel,
    FundReportSummary1,
    defaultItemsPerPage,
    itemsPerPageDropdownValues,
    ReportServiceResultModel,
} from '@/models/reports';
import { ReportType } from '@/enums/reports';
import { GridOptions } from '@/models/grid';
import Dropdown from '@/components/dropdown/dropdown.vue';
import dropdownService from '@/services/dropdown.service';
import { IDropdownOption } from '@/interfaces/dropdown';
import reportService from '@/services/report.service';
import Grid from '@/components/grid/grid.vue';
import { Message } from '@/models/notification';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { formatBytesToMB } from '@/helpers/format.helper';
import router from '@/router';
import { RouteLocationRaw } from 'vue-router';
import RowItem from '@/components/grid/rowItem.vue';

export default defineComponent({
    name: 'PartialReceiptsListReport',
    emits: ['loadingChange'],
    props: {
        isCanceled: {
            type: Boolean,
            default: false,
        },
    },
    components: { Dropdown, Grid, Form, Breadcrumbs },
    setup(props, { emit }) {
        onMounted(() => {
            getArchives();
            getReportResultTypes();
        });

        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };
        const rowsPerPageDropdownValues = itemsPerPageDropdownValues;

        const archivesDropdown = ref();
        const archives = ref<IDropdownOption[]>();
        const getArchives = async () => {
            archives.value = await dropdownService.getArchives();
        };

        const reportResultTypes = ref<IDropdownOption[]>();
        const getReportResultTypes = async () => {
            reportResultTypes.value = await dropdownService.getReportResultTypes();
        };

        const clear = () => {
            archivesDropdown.value.clear();
        };

        const inputModel = ref(new ListFiltersModel());

        const defaultRowsPerPage = ref(defaultItemsPerPage);
        const loading = ref(false);
        const totalGridRowsCount = ref(0);
        const grid = ref();
        const exportParams = ref();
        const exportOptions = ref();
        const viewReport = (options: GridOptions) => {
            emit('loadingChange', true);
            showReport.value = false;
            const gridInputModel = new ReportGridRequestModel<ListFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.partialReceiptsList;

            reportService
                .getPartialReceiptsListReport(gridInputModel)
                .then(
                    (
                        result: ReportServiceResultModel<
                            ReportGridWithSummaryGridResponseModel<FundReportSummary1, PartialReceiptsListReport>
                        >
                    ) => {
                        //gridItems.value = [...result]; // това не е реактивно
                        gridItems.value = [];
                        summaryGridItems.value = [];
                        result.data!.items.forEach((item) => {
                            gridItems.value.push(item);
                        });
                        summaryGridItems.value.push(result.data!.summary!);
                        totalGridRowsCount.value = result.data!.totalCount;

                        showReport.value = true;

                        processMetadata(result.metadata);
                    }
                )
                .catch((error: unknown) => {
                    const errorResult = error as ResponseResult;
                    if (error == 'Cancel' && errorResult.message == undefined) {
                        message.value = new Message({
                            text: t('common.cancelSearch'),
                            display: true,
                        });
                    } else
                        message.value = new Message({
                            text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                            display: true,
                        });
                })
                .finally(() => emit('loadingChange', false));
        };
        const viewReportOnSubmit = () => {
            const options = new GridOptions({});
            options.itemsPerPage = inputModel.value.ItemsPerPage;
            viewReport(options);
            grid.value.setInitialValues(inputModel.value.ItemsPerPage);
        };
        const viewReportOnRefresh = (options: GridOptions) => viewReport(options);

        const onRowClick = (row: typeof RowItem) => {
            const route: RouteLocationRaw = {
                name: 'DisplayFund',
            };

            if (row.items.systemIdentifier) {
                route.params = {
                    id: row.items.systemIdentifier,
                };
            }
            if (row.items.hasExternalSource) {
                route.query = {
                    hasExternalSource: String(row.items.hasExternalSource),
                    externalIdentifier: row.items.externalIdentifier,
                };
            }

            const reolvedRoute = router.resolve(route);
            window.open(reolvedRoute.href, '_blank');
        };
        watch(
            () => props.isCanceled,
            (value) => {
                if (value) {
                    reportService.cancelAxiosToken();
                }
            }
        );
        const showReport = ref(false);
        const gridItems = ref([] as PartialReceiptsListReport[]);
        const headers = ref([
            {
                title: t('reports.number'),
                prop: 'number',
                type: 'string',
            },
            {
                title: t('reports.registerDate'),
                prop: 'creationDate',
                type: 'string',
            },
            {
                title: t('reports.name'),
                prop: 'title',
                type: 'string',
            },
            {
                title: t('reports.documentsSubmittedBy'),
                prop: 'immediateSourceOfAcquisitionPlusMethodOfAcquisition',
                type: 'string',
            },
            {
                title: t('reports.linearMetersAndSheetsCount'),
                prop: 'volumeInSheets',
                type: 'number',
            },
            {
                title: t('reports.mb'),
                prop: 'digitalSize',
                type: 'number',
                renderFunction: formatBytesToMB,
            },
            {
                title: t('reports.note'),
                prop: 'note',
                type: 'string',
            },
        ]);

        const summaryGridItems = ref([] as FundReportSummary1[]);
        const summaryHeaders = ref([
            {
                title: t('reports.partialReceiptsCount'),
                prop: 'totalRows',
                type: 'int',
            },
            {
                title: t('reports.inventoryCount2'),
                prop: 'totalInventories',
                type: 'int',
            },
            {
                title: t('reports.archiveEntitiesCount'),
                prop: 'totalArchiveEntities',
                type: 'int',
            },
            {
                title: t('reports.linearMeters'),
                prop: 'totalLinearMeters',
                type: 'number',
            },
            {
                title: t('reports.volumeMB'),
                prop: 'totalSize',
                type: 'number',
                renderFunction: formatBytesToMB,
            },
        ]);

        const processMetadata = (metadata: string) => {
            if (!metadata) {
                return;
            }

            message.value = new Message({
                text: t(`warnings.${metadata}`),
                display: true,
                type: 'warning',
            });
        };

        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('reports.reports'),
                to: { name: 'Reports' },
                disabled: false,
            },
            {
                title: t('reports.partialReceiptsList'),
                disabled: true,
            },
        ];

        return {
            t,
            fieldSpacing,
            inputModel,
            loading,
            viewReportOnSubmit,
            viewReportOnRefresh,
            grid,
            breadcrumbItems,
            gridItems,
            headers,
            totalGridRowsCount,
            defaultRowsPerPage,
            showReport,
            exportParams,
            exportOptions,
            rowsPerPageDropdownValues,
            archives,
            reportResultTypes,
            archivesDropdown,
            clear,
            onRowClick,
            summaryHeaders,
            summaryGridItems,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/report.scss';
@import '@/assets/styles/breadcrumbs.scss';

.summaryGrid {
    max-width: 900px;
}
</style>
