<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.numberOfArchiveEntitiesOrderedByEmployeeReport') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" xl="12" class="flexStart col-divs">
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
                                <label>{{ t('reports.resultTypes') }}</label>
                                <Dropdown
                                    v-if="reportResultTypes"
                                    name="ReportResultTypes"
                                    :items="reportResultTypes"
                                    v-model="inputModel.ReportResultType"
                                    :defaultValue="1"
                                    @change="onChange"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('users.user') }}</label>
                                <Dropdown
                                    v-if="employeeNames"
                                    :label="t('users.user')"
                                    name="fldUser"
                                    required="required"
                                    :items="employeeNames"
                                    :multiselect="true"
                                    v-model="inputModel.EmployeeNames"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="employeeNamesDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('inventories.inventory') }}</label>
                                    <Dropdown
                                        v-if="inventories"
                                        :label="t('inventories.inventory')"
                                        name="fldInventory"
                                        :items="inventories"
                                        :multiselect="true"
                                        v-model="inputModel.Inventories"
                                        :selectAllText="t('common.selectAll')"
                                        :selectAllTextInternal="t('common.selectAllSEA')"
                                        :selectAllTextExternal="t('common.selectAllISDA')"
                                        ref="inventoriesDropdown"
                                    />
                                </div>
                                <v-checkbox
                                    v-model="inputNullCheckboxesModel.inventories"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('inventories.columns.startDate') }}</label>
                                    <DatePicker
                                        :label="t('inventories.columns.startDate')"
                                        :required="inputNullCheckboxesModel.dateFrom === false"
                                        v-model:date="inputModel.DateFrom"
                                        :disabled="inputNullCheckboxesModel.dateFrom === true"
                                    />
                                </div>
                                <v-checkbox
                                    v-model="inputNullCheckboxesModel.dateFrom"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('funds.columns.endDate') }}</label>
                                    <DatePicker
                                        :label="t('funds.columns.endDate')"
                                        :required="inputNullCheckboxesModel.dateTo === false"
                                        v-model:date="inputModel.DateTo"
                                        :disabled="inputNullCheckboxesModel.dateTo === true"
                                    />
                                </div>
                                <v-checkbox
                                    v-model="inputNullCheckboxesModel.dateTo"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.levelOfDescription') }}</label>
                                <Dropdown
                                    v-if="archiveEntitiesDescriptionLevels"
                                    :label="t('reports.levelOfDescription')"
                                    name="fldLevelOfDescription"
                                    required="required"
                                    :items="archiveEntitiesDescriptionLevels"
                                    :multiselect="true"
                                    v-model="inputModel.AchiveEntitiesDescriptionLevels"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="archiveEntitiesDescriptionLevelsDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('funds.fund') }}</label>
                                    <Dropdown
                                        v-if="funds"
                                        :label="t('funds.fund')"
                                        name="fldFund"
                                        :items="funds"
                                        :multiselect="true"
                                        v-model="inputModel.Funds"
                                        :selectAllText="t('common.selectAll')"
                                        :selectAllTextInternal="t('common.selectAllSEA')"
                                        :selectAllTextExternal="t('common.selectAllISDA')"
                                        ref="fundsDropdown"
                                    />
                                </div>
                                <v-checkbox
                                    v-model="inputNullCheckboxesModel.funds"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div>
                                <v-checkbox
                                    v-model="inputNullCheckboxesModel.statisticDataOnly"
                                    :label="t('reports.statisticDataOnly')"
                                ></v-checkbox>
                            </div>
                        </v-col>
                    </v-row>
                    <v-row justify="center">
                        <v-btn type="submit" :disabled="false">
                            {{ t('reports.viewReport') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('reports.viewReportTooltip') }}
                            </v-tooltip>
                        </v-btn>
                        <v-btn class="mr-4 clear cancel" @click="clear" :disabled="false">
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
        </div>
        <div v-if="showReport && !StatisticDataOnly">
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
    NumberOfArchiveEntitiesOrderedByEmployeeReportFiltersModel,
    NumberOfArchiveEntitiesOrderedByEmployeeReport,
    NumberOfArchiveEntitiesOrderedByEmployeeCombined,
    ReportGridRequestModel,
    ReportGridWithSummaryGridResponseModel,
    ReportFiltersNullCheckboxesModel,
    defaultItemsPerPage,
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

export default defineComponent({
    name: 'NumberOfArchiveEntitiesOrderedByEmployeeReport',
    emits: ['loadingChange'],
    components: { Dropdown, Grid, DatePicker, Form, Breadcrumbs },
    setup(_, { emit }) {
        onMounted(() => {
            getReportResultTypes();
            getEmployeeNames();
            getArchives();
            getInventories();
            getArchiveEntitiesDescriptionLevels();
            getFundArrays();
        });

        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };

        const reportResultTypes = ref<IDropdownOption[]>();
        const getReportResultTypes = async () => {
            reportResultTypes.value = await dropdownService.getReportResultTypes();
        };

        const archivesDropdown = ref();
        const archives = ref<IDropdownOption[]>();
        const getArchives = async () => {
            archives.value = await dropdownService.getArchives();
        };

        const employeeNamesDropdown = ref();
        const employeeNames = ref<IDropdownOption[]>();
        const getEmployeeNames = async () => {
            employeeNames.value = await dropdownService.getEmployeeNamesInternalAndExternal();
        };

        const inventoriesDropdown = ref();
        const inventories = ref<IDropdownOption[]>();
        const getInventories = async () => {
            inventories.value = await dropdownService.getInventoryArraysInternalAndExternal(true);
        };

        const archiveEntitiesDescriptionLevelsDropdown = ref();
        const archiveEntitiesDescriptionLevels = ref<IDropdownOption[]>();
        const getArchiveEntitiesDescriptionLevels = async () => {
            archiveEntitiesDescriptionLevels.value =
                await dropdownService.getArchiveEntitiesDescriptionLevelInternalAndExternal(true);
        };

        const fundsDropdown = ref();
        const funds = ref<IDropdownOption[]>();
        const getFundArrays = async () => {
            funds.value = await dropdownService.getFundArraysInternalAndExternal();
        };

        const clear = () => {
            employeeNamesDropdown.value.clear();
            inventoriesDropdown.value.clear();
            archiveEntitiesDescriptionLevelsDropdown.value.clear();
            fundsDropdown.value.clear();
            archivesDropdown.value.clear();

            inputModel.value.StatisticDataOnly = false;
            inputModel.value.DateFrom = null;
            inputModel.value.DateTo = null;
        };

        const onChange = (option: IDropdownOption) => {
            if (option) {
                Form.reset();
            }
        };

        const inputModel = ref(new NumberOfArchiveEntitiesOrderedByEmployeeReportFiltersModel());
        const StatisticDataOnly = inputModel.value.StatisticDataOnly;
        const inputNullCheckboxesModel = ref(new ReportFiltersNullCheckboxesModel());

        watch(
            () => inputNullCheckboxesModel.value,
            (value) => {
                if (value.registeredFrom === true) {
                    inputModel.value.DateFrom = null;
                }
                if (value.registeredTo === true) {
                    inputModel.value.DateTo = null;
                }
                if (value.statisticDataOnly === true) {
                    inputModel.value.StatisticDataOnly = true;
                } else {
                    inputModel.value.StatisticDataOnly = false;
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
            emit('loadingChange', true);
            showReport.value = false;
            const gridInputModel =
                new ReportGridRequestModel<NumberOfArchiveEntitiesOrderedByEmployeeReportFiltersModel>({
                    Page: options.page,
                    ItemsPerPage: options.itemsPerPage,
                    Filters: inputModel.value,
                });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.numberOfArchiveEntitiesOrderedByEmployeeReport;

            reportService
                .getNumberOfArchiveEntitiesOrderedByEmployeeReport(gridInputModel)
                .then(
                    (
                        result: ReportServiceResultModel<
                            ReportGridWithSummaryGridResponseModel<
                                NumberOfArchiveEntitiesOrderedByEmployeeCombined,
                                NumberOfArchiveEntitiesOrderedByEmployeeReport
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
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                })
                .finally(() => emit('loadingChange', false));
        };
        const viewReportOnSubmit = () => {
            const options = new GridOptions({});
            viewReport(options);
        };
        const viewReportOnRefresh = (options: GridOptions) => viewReport(options);
        const showReport = ref(false);
        const gridItems = ref([] as NumberOfArchiveEntitiesOrderedByEmployeeReport[]);
        const headers = ref([
            {
                title: t('reports.employee'),
                prop: 'employeeName',
                type: 'string',
            },
            {
                title: t('reports.archiveName'),
                prop: 'archive',
                type: 'string',
            },
            {
                title: t('reports.levelOfDescription'),
                prop: 'levelOfDescription',
                type: 'string',
            },
            {
                title: t('funds.fund'),
                prop: 'fund',
                type: 'string',
            },
            {
                title: t('inventories.inventory'),
                prop: 'inventory',
                type: 'string',
            },
            {
                title: t('archiveEntities.archiveEntity'),
                prop: 'archiveEntity',
                type: 'string',
            },
            {
                title: t('documents.document'),
                prop: 'document',
                type: 'string',
            },
            {
                title: t('reports.accessDate'),
                prop: 'accessDate',
                type: 'string',
            },
        ]);

        const showSummaryReport = ref(false);
        const summaryGridItems = ref([] as NumberOfArchiveEntitiesOrderedByEmployeeCombined[]);
        const summaryHeaders = ref([
            {
                title: t('reports.totalCount'),
                prop: 'totalCount',
                type: 'int',
            },
            {
                title: t('reports.totalDocumentsCount'),
                prop: 'totalDocumentsCount',
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
                title: t('reports.numberOfArchiveEntitiesOrderedByEmployeeReport'),
                disabled: true,
            },
        ];

        return {
            t,
            fieldSpacing,
            inputModel,
            breadcrumbItems,
            inputNullCheckboxesModel,
            loading,
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
            reportResultTypes,
            archives,
            archivesDropdown,
            inventories,
            inventoriesDropdown,
            funds,
            fundsDropdown,
            archiveEntitiesDescriptionLevels,
            archiveEntitiesDescriptionLevelsDropdown,
            employeeNames,
            employeeNamesDropdown,
            showSummaryReport,
            summaryGridItems,
            summaryHeaders,
            onChange,
            clear,
            StatisticDataOnly,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/report.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
