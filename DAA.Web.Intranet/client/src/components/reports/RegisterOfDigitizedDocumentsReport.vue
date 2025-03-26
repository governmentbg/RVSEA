<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.registerOfDigitizedDocumentsReport') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" xl="12" class="flexStart col-divs">
                            <!-- <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.resultTypes') }}</label>
                                <Dropdown
                                    v-if="reportResultTypes"
                                    name="ReportResultTypes"
                                    :items="reportResultTypes"
                                    :label="t('reports.resultTypes')"
                                    required="required"
                                    v-model="inputModel.ReportResultType"
                                    :defaultValue="1"
                                />
                            </div> -->
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.archiveName') }}</label>
                                <Dropdown
                                    v-if="archives"
                                    :label="t('reports.archiveName')"
                                    name="fldArchiveName"
                                    :required="true"
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

                        <v-col col="12" sm="12" xl="12" class="flexStart">
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
                                <v-checkbox class="reportNullCheckbox"
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
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.registeredTo"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                                <v-checkbox
                                v-model="showSummaryOnly"
                                :label="t('reports.statisticDataOnly')"
                            ></v-checkbox>
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
        <div id="grids" v-show="showReport">
            <div class="combinedGrid">
                <Grid
                    :columns="combinedHeaders"
                    :items="combinedGridItems"
                    :totalItems="1"
                    :showSearch="false"
                    mode="custom"
                    :showExport="false"
                    @refresh="viewReportOnRefresh"
                />
            </div>
            <div class="combinedGrid">
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
            <div id="main-grid" v-show="mainGridLoaded">
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
                    @tdClick="tdClick"
                    ref="grid"
                />
            </div>
        </div>
    </v-container>
</template>

<script lang="ts">
import { defineComponent, ref, onMounted, inject, Ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import {
    RegisterOfDigitizedDocumentsReportFiltersModel,
    RegisterOfDigitizedDocumentsReport,
    RegisterOfDigitizedDocumentsCombined,
    ReportGridRequestModel,
    ReportGridWithSummaryGridResponseModel,
    ReportFiltersNullCheckboxesModel,
    defaultItemsPerPage,
    itemsPerPageDropdownValues,
    ReportServiceResultModel,
    RegisterOfDigitizedDocumentsSummary,
    RegisterOfDigitizedDocumentsSummaryAndCombined
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
import DatePicker from '@/components/datetime/datepPicker.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { formatBytesToMB, formatDate, formatDuration } from '@/helpers/format.helper';
import { RouteLocationRaw, useRouter } from 'vue-router';
import { defaultGuidString } from '@/helpers/format.helper';
import RowItem from './rowItem.vue';
export default defineComponent({
    name: 'RegisterOfDigitizedDocumentsReport',
    emits: ['loadingChange'],
    props: {
        isCanceled: {
            type: Boolean,
            default: false,
        },
    },
    components: { Dropdown, Grid, Form, Breadcrumbs, DatePicker },
    setup(_, { emit }) {
        onMounted(() => {
            getReportResultTypes();
            getArchives();
        });

        const router = useRouter();
        const showSummaryOnly = ref(true);
        const mainGridLoaded = ref(false);

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

        const clear = () => {
            archivesDropdown.value.clear();
            inputModel.value.RegisteredFrom = null;
            inputModel.value.RegisteredTo = null;
        };

        const inputModel = ref(new RegisterOfDigitizedDocumentsReportFiltersModel());
        const inputNullCheckboxesModel = ref(new ReportFiltersNullCheckboxesModel());

        watch(
            () => inputNullCheckboxesModel.value,
            (value) => {
                if (value.registeredFrom === true) {
                    inputModel.value.RegisteredFrom = null;
                }
                if (value.registeredTo === true) {
                    inputModel.value.RegisteredTo = null;
                }
            },
            { deep: true }
        );

        const defaultRowsPerPage = ref(defaultItemsPerPage);
        const loading = ref(false);
        const totalGridRowsCount = ref(0);
        const grid = ref();
        const exportParams = ref();
        const exportOptions = ref();
        const viewReport = (options: GridOptions) => {
            inputModel.value.RegisteredFrom?.setUTCHours(0, 0, 0);
            inputModel.value.RegisteredTo?.setUTCHours(23, 59, 59);
            emit('loadingChange', true);
            showReport.value = false;
            const gridInputModel = new ReportGridRequestModel<RegisterOfDigitizedDocumentsReportFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.registerOfDigitizedDocumentsReport;

            if (showSummaryOnly.value) {
                reportService
                    .getRegisterOfDigitizedDocumentsReportSummary(gridInputModel)
                    .then((result: RegisterOfDigitizedDocumentsSummaryAndCombined) => {
                        summaryGridItems.value = [];
                        combinedGridItems.value = [];

                        summaryGridItems.value.push(result.summary!);
                        combinedGridItems.value.push(result.combined!);

                        showReport.value = true;
                        mainGridLoaded.value = false;
                    })
                    .catch((error: unknown) => {
                        const errorResult = error as ResponseResult;
                        let text: string | undefined;
                        if (error == 'Cancel' && errorResult.message == undefined) {
                            text = t('common.cancelSearch');
                        } else {
                            text = errorResult.showMessage ? errorResult.message : t('error.basic');
                        }
                        message.value = new Message({
                            text: text,
                            display: true,
                        });
                    })
                    .finally(() => emit('loadingChange', false));
            } else {
            reportService
                .getRegisterOfDigitizedDocumentsReport(gridInputModel)
                .then(
                    (
                        result: ReportServiceResultModel<
                            ReportGridWithSummaryGridResponseModel<
                                RegisterOfDigitizedDocumentsSummaryAndCombined,
                                RegisterOfDigitizedDocumentsReport
                            >
                        >
                    ) => {
                        gridItems.value = [];
                        summaryGridItems.value = [];
                        combinedGridItems.value = [];

                        result.data!.items.forEach((item) => {
                            item.duration = formatDuration(Number.parseInt(item.duration as string) || 0);
                            gridItems.value.push(item);
                        });

                        totalGridRowsCount.value = result.data!.totalCount;

                        summaryGridItems.value.push(result.data!.summary!.summary!);
                        combinedGridItems.value.push(result.data!.summary!.combined!);

                        showReport.value = true;
                        showSummaryReport.value = true;

                        mainGridLoaded.value = true;

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
            }
        };

        const viewReportOnSubmit = () => {
            const options = new GridOptions({});
            options.itemsPerPage = inputModel.value.ItemsPerPage;
            viewReport(options);
            grid.value.setInitialValues(inputModel.value.ItemsPerPage);
        };

        const viewReportOnRefresh = (options: GridOptions) => viewReport(options);

        const tdClick = (rowItem: typeof RowItem) => {
            if (rowItem.items) {
                const route: RouteLocationRaw = {
                    name: 'DisplayDocument',
                };

                if (rowItem.items.systemId?.length === defaultGuidString().length) {
                    route.params = {
                        id: rowItem.items.systemId,
                    };
                } else {
                    route.query = {
                        hasExternalSource: String(true),
                        externalIdentifier: rowItem.items.systemId,
                    };
                }

                const reolvedRoute = router.resolve(route);
                window.open(reolvedRoute.href, '_blank');

                //По този начин се зарежда само ако сайта е в root директория
                // const href = router.resolve({name: 'DisplayDocument' })
                // let link;
                // if(rowItem.rowItems.systemId.length != defaultGuidString().length) {
                //     link = href.fullPath + '?hasExternalSource=true' + '&externalIdentifier=' + rowItem.rowItems.systemId;
                // } else {
                //     link = href.fullPath + '/' + rowItem.rowItems.systemId;
                // }
                // window.open(link, '_blank');
            }
        };

        watch(
            () => _.isCanceled,
            (value) => {
                if (value) {
                    reportService.cancelAxiosToken();
                }
            }
        );
        const showReport = ref(false);
        const gridItems = ref([] as RegisterOfDigitizedDocumentsReport[]);
        const headers = ref([
            {
                title: t('reports.documentLink'),
                prop: 'documentLink',
                type: 'string',
            },
            {
                title: t('reports.archiveCode'),
                prop: 'archiveCode',
                type: 'string',
            },
            {
                title: t('reports.archiveName'),
                prop: 'archiveName',
                type: 'string',
            },
            {
                title: t('reports.levelOfDescription'),
                prop: 'levelOfDescription',
                type: 'string',
            },
            {
                title: t('reports.fundNumber'),
                prop: 'fundNumber',
                type: 'string',
            },
            {
                title: t('reports.inventoryNumber'),
                prop: 'inventoryNumber',
                type: 'string',
            },
            {
                title: t('reports.archiveEntityNumber'),
                prop: 'archiveEntityNumber',
                type: 'string',
            },
            {
                title: t('reports.title'),
                prop: 'title',
                type: 'string',
            },
            {
                title: t('reports.documentCreationDate'),
                prop: 'docCreationDate',
                type: 'string',
            },
            {
                title: t('reports.themes'),
                prop: 'themes',
                type: 'string',
            },
            {
                title: t('reports.status'),
                prop: 'docStatus',
                type: 'string',
            },
            {
                title: t('reports.digitalObjectCreationDate'),
                prop: 'creationDateDO',
                type: 'string',
            },
            {
                title: t('reports.recordsCountDO'),
                prop: 'mastersCount',
                type: 'int',
            },
            {
                title: t('reports.mbDO'),
                prop: 'bytesDO',
                type: 'bytes',
                renderFunction: formatBytesToMB,
            },
            {
                title: t('reports.digitalObjectRecreationDate'),
                prop: 'digitalObjectRecreationDate',
                type: 'string',
            },
            {
                title: t('reports.duration'),
                prop: 'duration',
                type: 'duration',
            },
            {
                title: t('reports.digitalObjectStatus'),
                prop: 'statusDO',
                type: 'string',
            },
            {
                title: t('reports.operator'),
                prop: 'operator',
                type: 'string',
            },
            {
                title: t('reports.correctionReturnDate'),
                prop: 'correctionReturnDate',
                type: 'string',
            },
            {
                title: t('reports.finalCorrectionDate'),
                prop: 'finalCorrectionDate',
                type: 'string',
            },
            {
                title: t('reports.digitalObjectAcceptanceDate'),
                prop: 'digitalObjectAcceptanceDate',
                type: 'string',
            },
        ]);

        const showSummaryReport = ref(false);
        const combinedGridItems = ref([] as RegisterOfDigitizedDocumentsCombined[]);
        const combinedHeaders = ref([
            {
                title: t('reports.periodFrom'),
                prop: 'periodFrom',
                type: 'string',
                renderFunction: formatDate,
            },
            {
                title: t('reports.periodTo'),
                prop: 'periodTo',
                type: 'string',
                renderFunction: formatDate,
            }
        ]);

        const summaryGridItems = ref([] as RegisterOfDigitizedDocumentsSummary[]);
        const summaryHeaders = ref([
            {
                title: t('reports.digitalObjectsCount'),
                prop: 'allDOCount',
                type: 'int',
            },
            {
                title: t('reports.masterImagesCount'),
                prop: 'mastersCount',
                type: 'int',
            },
            {
                title: t('reports.sizeInMB'),
                prop: 'totalBytesCount',
                type: 'int',
                renderFunction: formatBytesToMB,
            },
            {
                title: t('reports.duration'),
                prop: 'totalDuration',
                renderFunction: formatDuration,
                type: 'int',
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
                title: t('reports.registerOfDigitizedDocumentsReport'),
                disabled: true,
            },
        ];

        return {
            t,
            fieldSpacing,
            inputModel,
            summaryGridItems,
            summaryHeaders,
            inputNullCheckboxesModel,
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
            combinedGridItems,
            combinedHeaders,
            clear,
            tdClick,
            showSummaryOnly,
            mainGridLoaded
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/report.scss';
@import '@/assets/styles/breadcrumbs.scss';

:deep(#main-grid tbody tr td:first-of-type) {
    color: blue !important;
    text-decoration: underline !important;
}
</style>
