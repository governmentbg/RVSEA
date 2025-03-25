<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.compilationAndNTOOfEDocuments') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart col-divs">
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.archiveName') }}</label>
                                <Dropdown
                                    v-if="archives"
                                    :label="t('reports.archiveName')"
                                    name="fldArchiveName"
                                    required="required"
                                    :items="archives"
                                    :multiselect="true"
                                    v-model="inputModel.ArchiveCodesInternal"
                                    :selectAllText="t('common.selectAll')"
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
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.array') }}</label>
                                <Dropdown
                                    v-if="fundArrays"
                                    :label="t('reports.array')"
                                    name="fldArray"
                                    required="required"
                                    :items="fundArrays"
                                    :multiselect="true"
                                    v-model="inputModel.FundArraysInternal"
                                    :selectAllText="t('common.selectAll')"
                                    ref="fundArraysDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.type') }}</label>
                                <Dropdown
                                    v-if="fundTypes"
                                    :label="t('reports.type')"
                                    name="fldType"
                                    required="required"
                                    :items="fundTypes"
                                    :multiselect="true"
                                    v-model="inputModel.FundTypesInternal"
                                    :selectAllText="t('common.selectAll')"
                                    ref="fundTypesDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.methodOfAcquisition') }}</label>
                                <Dropdown
                                    v-if="acquisitionMethods"
                                    :label="t('reports.methodOfAcquisition')"
                                    name="fldMethodOfAcquisition"
                                    required="required"
                                    :items="acquisitionMethods"
                                    :multiselect="true"
                                    v-model="inputModel.MethodsOfAcquisitionInternal"
                                    :selectAllText="t('common.selectAll')"
                                    ref="acquisitionMethodsDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.status') }}</label>
                                <Dropdown
                                    v-if="statuses"
                                    :label="t('reports.status')"
                                    name="fldStatus"
                                    required="required"
                                    :items="statuses"
                                    :multiselect="true"
                                    v-model="inputModel.StatusesInternal"
                                    :selectAllText="t('common.selectAll')"
                                    ref="statusesDropdown"
                                />
                            </div>

                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.process') }}</label>
                                <Dropdown
                                    v-if="processes"
                                    :label="t('reports.process')"
                                    name="fldProcess"
                                    required="required"
                                    :items="processes"
                                    :multiselect="true"
                                    v-model="inputModel.ProcessTypes"
                                    :selectAllText="t('common.selectAll')"
                                    ref="processesDropdown"
                                    valueProp="id"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label>{{ t('reports.fileFormat') }}</label>
                                <Dropdown
                                    v-if="fileFormats"
                                    :label="t('reports.fileFormat')"
                                    name="fldFileFormat"
                                    :items="fileFormats"
                                    valueProp="label"
                                    :multiselect="true"
                                    v-model="inputModel.FileFormats"
                                    :selectAllText="t('common.selectAll')"
                                    ref="fileFormatsDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label>{{ t('reports.levelOfDescription') }}</label>
                                <Dropdown
                                    v-if="fundLevelOfDescriptions"
                                    :label="t('reports.levelOfDescription')"
                                    name="fldLevelOfDescription"
                                    :items="fundLevelOfDescriptions"
                                    :multiselect="true"
                                    v-model="inputModel.FundLevelOfdescriptionCodes"
                                    :selectAllText="t('common.selectAll')"
                                    ref="fundLevelOfDescriptionsDropdown"
                                />
                            </div>
                        </v-col>

                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart">
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

                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.processStartDate') }}</label>
                                    <DatePicker
                                        :label="t('reports.processStartDate')"
                                        :required="inputNullCheckboxesModel.processStartDate === false"
                                        v-model:date="inputModel.ProcessStartDate"
                                        :disabled="inputNullCheckboxesModel.processStartDate === true"
                                    />
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.processStartDate"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.processEndDate') }}</label>
                                    <DatePicker
                                        :label="t('reports.processEndDate')"
                                        :required="inputNullCheckboxesModel.processEndDate === false"
                                        v-model:date="inputModel.ProcessEndDate"
                                        :disabled="inputNullCheckboxesModel.processEndDate === true"
                                    />
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.processEndDate"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>

                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.chronologicalExtentStartDate') }}</label>
                                    <DatePicker
                                        :label="t('reports.chronologicalExtentStartDate')"
                                        :required="inputNullCheckboxesModel.dateFrom === false"
                                        v-model:date="inputModel.DateFrom"
                                        :disabled="inputNullCheckboxesModel.dateFrom === true"
                                    />
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.dateFrom"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.chronologicalExtentEndDate') }}</label>
                                    <DatePicker
                                        :label="t('reports.chronologicalExtentEndDate')"
                                        :required="inputNullCheckboxesModel.dateTo === false"
                                        v-model:date="inputModel.DateTo"
                                        :disabled="inputNullCheckboxesModel.dateTo === true"
                                    />
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.dateTo"
                                    :label="t('reports.null')"
                                ></v-checkbox>
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
import { defineComponent, ref, watch, onMounted, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import {
    CompilationAndNTOOfEDocumentsFiltersModel,
    CompilationAndNTOOfEDocuments,
    ReportGridRequestModel,
    CompilationAndNTOOfEDocumentsCombinedModel,
    ReportGridWithSummaryGridResponseModel,
    ReportFiltersNullCheckboxesModel,
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
import DatePicker from '@/components/datetime/datepPicker.vue';
import { Message } from '@/models/notification';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { formatBytesToMB, formatDate, formatDuration } from '@/helpers/format.helper';
import { EntityType } from '@/enums/entity';
import router from '@/router';
import { RouteLocationRaw } from 'vue-router';
import RowItem from '@/components/grid/rowItem.vue';

export default defineComponent({
    name: 'CompilationAndNTOOfEDocumentsReport',
    emits: ['loadingChange'],
    props: {
        isCanceled: {
            type: Boolean,
            default: false,
        },
    },
    components: { Dropdown, Grid, DatePicker, Form, Breadcrumbs },
    setup(_, { emit }) {
        onMounted(() => {
            getFundArrays();
            getFundTypes();
            getAcquisitionMethods();
            getStatuses();
            getArchives();
            getProcesses();
            getFileFormats();
            getFundLevelOfDescriptions();
        });

        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };
        const rowsPerPageDropdownValues = ref(itemsPerPageDropdownValues);

        const fundArraysDropdown = ref();
        const fundArrays = ref<IDropdownOption[]>();
        const getFundArrays = async () => {
            fundArrays.value = await dropdownService.getFundArrays(true);
        };

        const fundTypesDropdown = ref();
        const fundTypes = ref<IDropdownOption[]>();
        const getFundTypes = async () => {
            fundTypes.value = await dropdownService.getFundTypes(true);
        };

        const acquisitionMethodsDropdown = ref();
        const acquisitionMethods = ref<IDropdownOption[]>();
        const getAcquisitionMethods = async () => {
            acquisitionMethods.value = await dropdownService.getAcquisitionMethods(true);
        };

        const statusesDropdown = ref();
        const statuses = ref<IDropdownOption[]>();
        const getStatuses = async () => {
            statuses.value = await dropdownService.getFundStatusesNTOReportReduce();
        };

        const archivesDropdown = ref();
        const archives = ref<IDropdownOption[]>();
        const getArchives = async () => {
            archives.value = await dropdownService.getArchives();
        };

        const processesDropdown = ref();
        const entityTypes = [EntityType.allLevels, 'archive', EntityType.fund];
        const processes = ref<IDropdownOption[]>();
        const getProcesses = async () => {
            processes.value = await dropdownService.getProcessTypes(entityTypes, true);
        };

        const fileFormatsDropdown = ref();
        const fileFormats = ref<IDropdownOption[]>();
        const getFileFormats = async () => {
            fileFormats.value = await dropdownService.getFileFormatsWithSelectAll();
        };

        const fundLevelOfDescriptionsDropdown = ref();
        const fundLevelOfDescriptions = ref<IDropdownOption[]>();
        const getFundLevelOfDescriptions = async () => {
            fundLevelOfDescriptions.value = await dropdownService.getFundDescriptionLevels();
        };

        const clear = () => {
            fundArraysDropdown.value.clear();
            fundTypesDropdown.value.clear();
            acquisitionMethodsDropdown.value.clear();
            statusesDropdown.value.clear();
            processesDropdown.value.clear();
            fileFormatsDropdown.value.clear();
            archivesDropdown.value.clear();
            fundLevelOfDescriptionsDropdown.value.clear();

            inputModel.value.RegisteredFrom = null;
            inputModel.value.RegisteredTo = null;
            inputModel.value.ProcessStartDate = null;
            inputModel.value.ProcessEndDate = null;
            inputModel.value.DateFrom = null;
            inputModel.value.DateTo = null;
        };

        const inputModel = ref(new CompilationAndNTOOfEDocumentsFiltersModel());
        const inputNullCheckboxesModel = ref(new ReportFiltersNullCheckboxesModel());
        watch(
            () => _.isCanceled,
            (value) => {
                if (value) {
                    reportService.cancelAxiosToken();
                }
            }
        );
        watch(
            () => inputNullCheckboxesModel.value,
            (value) => {
                if (value.registeredFrom === true) {
                    inputModel.value.RegisteredFrom = null;
                }
                if (value.registeredTo === true) {
                    inputModel.value.RegisteredTo = null;
                }
                if (value.processStartDate === true) {
                    inputModel.value.ProcessStartDate = null;
                }
                if (value.processEndDate === true) {
                    inputModel.value.ProcessEndDate = null;
                }
                if (value.dateFrom === true) {
                    inputModel.value.DateFrom = null;
                }
                if (value.dateTo === true) {
                    inputModel.value.DateTo = null;
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
            inputModel.value.DateFrom?.setUTCHours(0, 0, 0);
            inputModel.value.DateTo?.setUTCHours(23, 59, 59);
            inputModel.value.RegisteredFrom?.setUTCHours(0, 0, 0);
            inputModel.value.RegisteredTo?.setUTCHours(23, 59, 59);
            inputModel.value.ProcessStartDate?.setUTCHours(0, 0, 0);
            inputModel.value.ProcessEndDate?.setUTCHours(23, 59, 59);
            emit('loadingChange', true);
            showReport.value = false;
            const gridInputModel = new ReportGridRequestModel<CompilationAndNTOOfEDocumentsFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.compilationAndNTOOfEDocuments;

            reportService
                .getCompilationAndNTOOfEDocumentsReport(gridInputModel)
                .then(
                    (
                        result: ReportServiceResultModel<
                            ReportGridWithSummaryGridResponseModel<
                                CompilationAndNTOOfEDocumentsCombinedModel,
                                CompilationAndNTOOfEDocuments
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
                        summaryGridItems.value.push(result.data!.summary!);

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

            //По този начин се зарежда само ако сайта е в root директория
            // const href = router.resolve({ name: 'DisplayFund' });
            // let link = href.fullPath;

            // if(rowItem.rowItems.systemIdentifier && rowItem.rowItems.systemIdentifier.length == defaultGuidString().length) {
            //     link = link + '/' + rowItem.rowItems.systemIdentifier;
            // }
            // if(rowItem.rowItems.hasExternalSource) {
            //     link = link + '?hasExternalSource=true' + '&externalIdentifier=' + rowItem.rowItems.externalIdentifier;
            // }

            // window.open(link, '_blank');
        };

        const showReport = ref(false);
        const gridItems = ref([] as CompilationAndNTOOfEDocuments[]);
        const headers = ref([
            {
                title: t('reports.archiveName'),
                prop: 'archive',
                type: 'string',
            },
            {
                title: t('reports.fundNumber'),
                prop: 'fundNumber',
                type: 'string',
            },
            {
                title: t('reports.title'),
                prop: 'title',
                type: 'string',
            },
            {
                title: t('reports.methodOfAcquisition'),
                prop: 'methodOfAcquisitions',
                type: 'string',
            },
            {
                title: t('reports.type'),
                prop: 'type',
                type: 'string',
            },
            {
                title: t('reports.chronologicalScope'),
                prop: 'chronologicalScope',
                type: 'string',
            },
            {
                title: t('reports.dateOfFiling'),
                prop: 'dateOfFiling',
                type: 'string',
                renderFunction: formatDate,
            },
            {
                title: t('reports.status'),
                prop: 'status',
                type: 'string',
            },
            {
                title: t('reports.levelOfDescription'),
                prop: 'levelOfDescription',
                type: 'string',
            },
            {
                title: t('reports.inventoryCount'),
                prop: 'inventoryCount',
                type: 'int',
            },
            {
                title: t('reports.aeCount'),
                prop: 'aeCount',
                type: 'int',
            },
            {
                title: t('reports.documentCount'),
                prop: 'documentCount',
                type: 'int',
            },
            {
                title: t('reports.fileFormats'),
                prop: 'fileFormats',
                type: 'string',
            },
            {
                title: t('reports.volumeMB'),
                prop: 'bytes',
                type: 'bytes',
                renderFunction: formatBytesToMB,
            },
            {
                title: t('reports.duration'),
                prop: 'duration',
                renderFunction: formatDuration,
                type: 'duration',
            },
            {
                title: t('reports.note'),
                prop: 'note',
                type: 'string',
            },
        ]);

        const showSummaryReport = ref(false);
        const summaryGridItems = ref([] as CompilationAndNTOOfEDocumentsCombinedModel[]);
        const summaryHeaders = ref([
            {
                title: t('reports.fundCount'),
                prop: 'fundsCount',
                type: 'number',
            },
            {
                title: t('reports.inventoryCount'),
                prop: 'inventoriesCount',
                type: 'number',
            },
            {
                title: t('reports.archiveEntityCount'),
                prop: 'aesCount',
                type: 'number',
            },
            {
                title: t('reports.volumeMB'),
                prop: 'bytes',
                type: 'number',
                renderFunction: formatBytesToMB,
            },
            {
                title: t('reports.duration'),
                prop: 'duration',
                type: 'string',
                renderFunction: formatDuration,
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
                title: t('reports.compilationAndNTOOfEDocuments'),
                disabled: true,
            },
        ];
        return {
            t,
            fieldSpacing,
            inputModel,
            inputNullCheckboxesModel,
            loading,
            breadcrumbItems,
            viewReportOnSubmit,
            viewReportOnRefresh,
            grid,
            gridItems,
            headers,
            totalGridRowsCount,
            defaultRowsPerPage,
            showReport,
            exportParams,
            exportOptions,
            rowsPerPageDropdownValues,
            fundArrays,
            fundArraysDropdown,
            fundTypes,
            fundTypesDropdown,
            acquisitionMethods,
            acquisitionMethodsDropdown,
            processes,
            processesDropdown,
            fileFormats,
            fileFormatsDropdown,
            statuses,
            statusesDropdown,
            archives,
            archivesDropdown,
            showSummaryReport,
            summaryGridItems,
            summaryHeaders,
            clear,
            onRowClick,
            fundLevelOfDescriptions,
            fundLevelOfDescriptionsDropdown,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/report.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
