<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.countOfUsedCopiesOfDocumentsFromForeignArchivesReport') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" xl="12" class="flexStart col-divs">
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.resultTypes') }}</label>
                                <Dropdown
                                    v-if="reportResultTypes"
                                    :label="t('reports.resultTypes')"
                                    required="required"
                                    name="ReportResultTypes"
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
                                />
                            </div>
                        </v-col>

                        <!-- <v-col col="12" sm="6" xl="4" class="flexStart">
                        <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                            <div class="width100Percent">
                                <label>{{ t('reports.filedFrom') }}</label>
                                <DatePicker
                                    :label="t('reports.filedFrom')"
                                    :required="inputNullCheckboxesModel.registeredFrom === false"
                                    v-model:date="inputModel.RegisteredFrom"
                                    :disabled="inputNullCheckboxesModel.registeredFrom === true"
                                />
                            </div>
                            <v-checkbox
                                v-model="inputNullCheckboxesModel.registeredFrom"
                                :label="t('reports.null')"
                            ></v-checkbox>
                        </div>
                        <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                            <div class="width100Percent">
                                <label>{{ t('reports.filedTo') }}</label>
                                <DatePicker
                                    :label="t('reports.filedTo')"
                                    :required="inputNullCheckboxesModel.registeredTo === false"
                                    v-model:date="inputModel.RegisteredTo"
                                    :disabled="inputNullCheckboxesModel.registeredTo === true"
                                />
                            </div>
                            <v-checkbox
                                v-model="inputNullCheckboxesModel.registeredTo"
                                :label="t('reports.null')"
                            ></v-checkbox>
                        </div>
                    </v-col> -->
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
                    :totalItems="3"
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
import { defineComponent, ref, onMounted, inject, Ref, watch } from 'vue'; //watch
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import {
    CountOfUsedCopiesOfDocumentsFromForeignArchivesFiltersModel,
    CountOfUsedCopiesOfDocumentsFromForeignArchivesReport,
    CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined,
    CountOfUsedCopiesOfDocumentsFromForeignArchivesCombinedBeforeSplit,
    ReportGridRequestModel,
    ReportGridWithSummaryGridResponseModel,
    //ReportFiltersNullCheckboxesModel,
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
//import DatePicker from '@/components/datetime/datepPicker.vue'
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { formatBytesToMB } from '@/helpers/format.helper';
import router from '@/router';
import { RouteLocationRaw } from 'vue-router';
import RowItem from '@/components/grid/rowItem.vue';

export default defineComponent({
    name: 'CountOfUsedCopiesOfDocumentsFromForeignArchivesReport',
    emits: ['loadingChange'],
    props: {
        isCanceled: {
            type: Boolean,
            default: false,
        },
    },
    components: { Dropdown, Grid, Form, Breadcrumbs }, //DatePicker

    setup(_, { emit }) {
        onMounted(() => {
            getReportResultTypes();
            getArchives();
        });

        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };

        const rowsPerPageDropdownValues = ref(itemsPerPageDropdownValues);

        const reportResultTypes = ref<IDropdownOption[]>();
        const getReportResultTypes = async () => {
            reportResultTypes.value = await dropdownService.getReportResultTypes();
        };

        const archivesDropdown = ref();
        const archives = ref<IDropdownOption[]>();
        const getArchives = async () => {
            archives.value = await dropdownService.getArchives();
        };
        watch(
            () => _.isCanceled,
            (value) => {
                if (value) {
                    reportService.cancelAxiosToken();
                }
            }
        );

        const clear = () => {
            archivesDropdown.value.clear();
        };

        const inputModel = ref(new CountOfUsedCopiesOfDocumentsFromForeignArchivesFiltersModel());
        // const inputNullCheckboxesModel = ref(new ReportFiltersNullCheckboxesModel())

        // watch(
        //     () => inputNullCheckboxesModel.value,
        //     (value) => {
        //         if (value.registeredFrom === true) {
        //             inputModel.value.RegisteredFrom = null
        //         }
        //         if (value.registeredTo === true) {
        //             inputModel.value.RegisteredTo = null
        //         }
        //     },
        //     { deep: true }
        // )

        const defaultRowsPerPage = ref(defaultItemsPerPage);
        const loading = ref(false);
        const totalGridRowsCount = ref(0);
        const grid = ref();
        const exportParams = ref();
        const exportOptions = ref();
        const viewReport = (options: GridOptions) => {
            emit('loadingChange', true);
            showReport.value = false;
            const gridInputModel =
                new ReportGridRequestModel<CountOfUsedCopiesOfDocumentsFromForeignArchivesFiltersModel>({
                    Page: options.page,
                    ItemsPerPage: options.itemsPerPage,
                    Filters: inputModel.value,
                });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.countOfUsedCopiesOfDocumentsFromForeignArchivesReport;

            reportService
                .getCountOfUsedCopiesOfDocumentsFromForeignArchivesReport(gridInputModel)
                .then(
                    (
                        result: ReportServiceResultModel<
                            ReportGridWithSummaryGridResponseModel<
                                CountOfUsedCopiesOfDocumentsFromForeignArchivesCombinedBeforeSplit,
                                CountOfUsedCopiesOfDocumentsFromForeignArchivesReport
                            >
                        >
                    ) => {
                        //gridItems.value = [...result]; // това не е реактивно
                        gridItems.value = [];
                        summaryGridItems.value = [];
                        result.data!.items.forEach((item) => {
                            gridItems.value.push(item);
                        });
                        totalGridRowsCount.value = result.data!.totalCount;

                        const firstRow: CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined = {
                            rowName: result.data!.summary?.employeeRowName,
                            kmfCount: result.data!.summary?.employeeKMFCount,
                            aeCount: result.data!.summary?.employeeAECount,
                            elDocsCount: result.data!.summary?.employeeElDocsCount,
                            elDocsMB: result.data!.summary?.employeeElDocsMB,
                        };

                        const secondRow: CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined = {
                            rowName: result.data!.summary?.readerRowName,
                            kmfCount: result.data!.summary?.readerKMFCount,
                            aeCount: result.data!.summary?.readerAECount,
                            elDocsCount: result.data!.summary?.readerElDocsCount,
                            elDocsMB: result.data!.summary?.readerElDocsMB,
                        };

                        const thirdRow: CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined = {
                            rowName: result.data!.summary?.totalRowName,
                            kmfCount: result.data!.summary?.totalKMFCount,
                            aeCount: result.data!.summary?.totalAECount,
                            elDocsCount: result.data!.summary?.totalElDocsCount,
                            elDocsMB: result.data!.summary?.totalElDocsMB,
                        };
                        summaryGridItems.value.push(firstRow!);
                        summaryGridItems.value.push(secondRow!);
                        summaryGridItems.value.push(thirdRow!);

                        showReport.value = true;
                        showSummaryReport.value = true;

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
        const showReport = ref(false);

        const onRowClick = (row: typeof RowItem) => {
            const route: RouteLocationRaw = {
                name: 'DisplayFilm',
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

        const gridItems = ref([] as CountOfUsedCopiesOfDocumentsFromForeignArchivesReport[]);
        const headers = ref([
            {
                title: t('films.columns.KMFNumber'),
                prop: 'kmfNumber',
                type: 'string',
            },
            {
                title: t('films.columns.inventoryNumber'),
                prop: 'inventoryNumber',
                type: 'string',
            },
            {
                title: t('reports.statementDate'),
                prop: 'statementDate',
                type: 'string',
            },
            {
                title: t('reports.employee'),
                prop: 'employee',
                type: 'string',
            },
            {
                title: t('users.columns.reader'),
                prop: 'reader',
                type: 'string',
            },
            {
                title: t('reports.aeCount'),
                prop: 'aeCount',
                type: 'number',
            },
            {
                title: t('reports.electronicDocumentsCount'),
                prop: 'ElectronicalDocumentsCount',
                type: 'number',
            },
            {
                title: t('reports.electronicDocumentsMB'),
                prop: 'ElectronicalDocumentsMB',
                type: 'bytes',
                renderFunction: formatBytesToMB,
            },
        ]);

        const showSummaryReport = ref(false);
        const summaryGridItems = ref([] as CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined[]);
        const summaryHeaders = ref([
            {
                title: t(''),
                prop: 'rowName',
                type: 'string',
                titleClass: 'firstCol',
            },
            {
                title: t('films.columns.KMFNumber'),
                prop: 'kmfCount',
                type: 'number',
            },
            {
                title: t('reports.aeCount'),
                prop: 'aeCount',
                type: 'number',
            },
            {
                title: t('reports.electronicDocumentsCount'),
                prop: 'elDocsCount',
                type: 'number',
            },
            {
                title: t('reports.electronicDocumentsMB'),
                prop: 'elDocsMB',
                type: 'string',
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
                title: t('reports.countOfUsedCopiesOfDocumentsFromForeignArchivesReport'),
                disabled: true,
            },
        ];

        return {
            t,
            fieldSpacing,
            inputModel,
            //inputNullCheckboxesModel,
            loading,
            viewReportOnSubmit,
            viewReportOnRefresh,
            grid,
            gridItems,
            breadcrumbItems,
            headers,
            totalGridRowsCount,
            defaultRowsPerPage,
            showReport,
            exportParams,
            exportOptions,
            rowsPerPageDropdownValues,
            reportResultTypes,
            archives,
            archivesDropdown,
            showSummaryReport,
            summaryGridItems,
            summaryHeaders,
            clear,
            onRowClick,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/report.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
