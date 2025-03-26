<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div class="card-cust">
                <h3 class="display-6">{{ t('reports.numberOfDocumentsOrderedByEmployeeReport') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" xl="12" class="flexStart col-divs">
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
                                <label class="required">{{ t('reports.archiveName') }}</label>
                                <Dropdown
                                    v-if="archives"
                                    :label="t('reports.archiveName')"
                                    name="fldArchiveName"
                                    required="required"
                                    :items="archives"
                                    :multiselect="true"
                                    v-model="inputModel.ArchiveCodes"
                                    :selectAllText="t('common.selectAll')"
                                    ref="archivesDropdown"
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
                            <div :class="fieldSpacing">
                                <label>{{ t('users.user') }}</label>
                                <Dropdown
                                    v-if="employeeNames"
                                    :label="t('users.user')"
                                    name="fldUser"
                                    :items="employeeNames"
                                    v-model="inputModel.Employee"
                                    :selectAllText="t('common.selectAll')"
                                    ref="employeeNamesDropdown"
                                />
                            </div>
                            <label>{{ t('reports.fund') }}</label>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox textField">
                                <div class="width100Percent">
                                    <text-field
                                        :label="t('reports.fund')"
                                        :hideLabelInField="true"
                                        v-model="inputModel.FundNumber"
                                        :disabled="inputNullCheckboxesModel.fundNumber === true"
                                        :validation="inputNullCheckboxesModel.fundNumber === false ? 'required' : ''"
                                    ></text-field>
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.fundNumber"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <label>{{ t('reports.inventory') }}</label>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox textField">
                                <div class="width100Percent">
                                    <text-field
                                        :label="t('reports.inventory')"
                                        :hideLabelInField="true"
                                        v-model="inputModel.InventoryNumber"
                                        :disabled="inputNullCheckboxesModel.inventoryNumber === true"
                                        :validation="
                                            inputNullCheckboxesModel.inventoryNumber === false ? 'required' : ''
                                        "
                                    ></text-field>
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.inventoryNumber"
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
                                <v-checkbox class="reportNullCheckbox"
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
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.dateTo"
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
                    :gridClass="'summary-grid-centered table-bordered'"
                />
            </div>
        </div>
        <div v-show="showReport && !StatisticDataOnly">
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
import { defineComponent, ref, watch, onMounted, inject, Ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import {
    NumberOfDocumentsOrderedByEmployeeReportFiltersModel,
    NumberOfDocumentsOrderedByEmployeeReport,
    NumberOfDocumentsOrderedByEmployeeReportCombined,
    ReportGridRequestModel,
    ReportGridWithSummaryGridResponseModel,
    defaultItemsPerPage,
    itemsPerPageDropdownValues,
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
import TextField from '@/components/field/text.field.vue';
import { formatDateTime } from '@/helpers/format.helper';
import router from '@/router';
import { RouteLocationRaw } from 'vue-router';
import RowItem from '@/components/grid/rowItem.vue';
export default defineComponent({
    name: 'NumberOfDocumentsOrderedByEmployeeReport',
    emits: ['loadingChange'],
    props: {
        isCanceled: {
            type: Boolean,
            default: false,
        },
    },
    components: { Dropdown, Grid, DatePicker, Form, Breadcrumbs, TextField },
    setup(_, { emit }) {
        onMounted(() => {
            getArchives();
            getFundLevelOfDescriptions();
            getEmployeeNames();
        });
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };
        const rowsPerPageDropdownValues = ref(itemsPerPageDropdownValues);

        const inputModel = ref(new NumberOfDocumentsOrderedByEmployeeReportFiltersModel());
        const StatisticDataOnly = computed(() => inputModel.value.StatisticDataOnly);
        const inputNullCheckboxesModel = ref({
            fundNumber: true,
            inventoryNumber: true,
            dateFrom: true,
            dateTo: true,
            statisticDataOnly: false,
        });

        const archivesDropdown = ref();
        const archives = ref<IDropdownOption[]>();
        const getArchives = async () => {
            archives.value = await dropdownService.getArchives();
        };

        const fundLevelOfDescriptionsDropdown = ref();
        const fundLevelOfDescriptions = ref<IDropdownOption[]>();
        const getFundLevelOfDescriptions = async () => {
            fundLevelOfDescriptions.value = await dropdownService.getFundDescriptionLevels();
        };

        const employeeNamesDropdown = ref();
        const employeeNames = ref<IDropdownOption[]>();
        const getEmployeeNames = async () => {
            employeeNames.value = await dropdownService.getEmployeeNamesInternal();
        };

        const clear = () => {
            archivesDropdown.value.clear();
            fundLevelOfDescriptionsDropdown.value.clear();
            employeeNamesDropdown.value.clear();
            inputModel.value.StatisticDataOnly = false;
            inputModel.value.DateFrom = null;
            inputModel.value.DateTo = null;
            inputModel.value.FundNumber = null;
            inputModel.value.InventoryNumber = null;
        };

        const onChange = (option: IDropdownOption) => {
            if (option) {
                archivesDropdown.value?.clear();
                archivesDropdown.value?.setDataSourceType(option.code);
                fundLevelOfDescriptionsDropdown.value?.clear();
                fundLevelOfDescriptionsDropdown.value?.setDataSourceType(option.code);
                employeeNamesDropdown.value?.clear();
                employeeNamesDropdown.value?.setDataSourceType(option.code);
            }
        };

        const onRowClick = (row: typeof RowItem) => {
            const route: RouteLocationRaw = {
                name: 'DisplayDocument',
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
            () => inputNullCheckboxesModel.value,
            (value) => {
                if (value.fundNumber === true) {
                    inputModel.value.FundNumber = null;
                }
                if (value.inventoryNumber === true) {
                    inputModel.value.InventoryNumber = null;
                }
                if (value.dateFrom === true) {
                    inputModel.value.DateFrom = null;
                }
                if (value.dateTo === true) {
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
        watch(
            () => _.isCanceled,
            (value) => {
                if (value) {
                    reportService.cancelAxiosToken();
                }
            }
        );
        const defaultRowsPerPage = ref(defaultItemsPerPage);
        const loading = ref(false);
        const totalGridRowsCount = ref(0);
        const grid = ref();
        const exportParams = ref();
        const exportOptions = ref();

        const viewReport = async (options: GridOptions) => {
            inputModel.value.DateFrom?.setUTCHours(0, 0, 0);
            inputModel.value.DateTo?.setUTCHours(23, 59, 59);
            emit('loadingChange', true);
            showReport.value = false;
            const gridInputModel = new ReportGridRequestModel<NumberOfDocumentsOrderedByEmployeeReportFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.numberOfDocumentsOrderedByEmployeeReport;

            await reportService
                .getNumberOfDocumentsOrderedByEmployeeReport(gridInputModel)
                .then(
                    (
                        result: ReportGridWithSummaryGridResponseModel<
                            NumberOfDocumentsOrderedByEmployeeReportCombined,
                            NumberOfDocumentsOrderedByEmployeeReport
                        >
                    ) => {
                        gridItems.value = [];
                        summaryGridItems.value = [];
                        result.items.forEach((item) => {
                            gridItems.value.push(item);
                        });
                        totalGridRowsCount.value = result.totalCount;
                        summaryGridItems.value.push(result.summary!);

                        showReport.value = true;
                        showSummaryReport.value = true;
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

        const viewReportOnSubmit = async () => {
            const options = new GridOptions({});
            options.itemsPerPage = inputModel.value.ItemsPerPage;
            await viewReport(options);
            grid.value.setInitialValues(inputModel.value.ItemsPerPage);
        };
        const viewReportOnRefresh = async (options: GridOptions) => await viewReport(options);
        const showReport = ref(false);
        const gridItems = ref([] as NumberOfDocumentsOrderedByEmployeeReport[]);
        const showSummaryReport = ref(false);
        const summaryGridItems = ref([] as NumberOfDocumentsOrderedByEmployeeReportCombined[]);

        const headers = ref([
            {
                title: t('users.columns.userName'),
                prop: 'employee',
                type: 'string',
            },
            {
                title: t('documents.archive'),
                prop: 'archive',
                type: 'string',
            },
            {
                title: t('funds.columns.descriptionLevel'),
                prop: 'fundLevelOfDescription',
                type: 'string',
            },
            {
                title: t('funds.fund'),
                prop: 'fund',
                type: 'string',
            },
            {
                title: t('inventories.inventory'),
                prop: 'inventoryNumber',
                type: 'string',
            },
            {
                title: t('archiveEntities.archiveEntity'),
                prop: 'archivalEntityNumber',
                type: 'string',
            },
            {
                title: t('documents.document'),
                prop: 'documentNumber',
                type: 'string',
            },
            {
                title: t('common.date'),
                prop: 'accessDate',
                type: 'Date',
                renderFunction: formatDateTime,
            },
        ]);

        const summaryHeaders = ref([
            {
                title: t('reports.totalUniqueAEs'),
                prop: 'disticntAEsCount',
                type: 'int',
            },
            {
                title: t('reports.totalDocumentsCount'),
                prop: 'documentsReviewsCount',
                type: 'int',
            },
        ]);

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
                title: t('reports.numberOfDocumentsOrderedByEmployeeReport'),
                disabled: true,
            },
        ];

        return {
            t,
            fieldSpacing,
            inputModel,
            inputNullCheckboxesModel,
            loading,
            viewReportOnSubmit,
            viewReportOnRefresh,
            grid,
            gridItems,
            headers,
            totalGridRowsCount,
            defaultRowsPerPage,
            breadcrumbItems,
            rowsPerPageDropdownValues,
            showReport,
            exportParams,
            exportOptions,
            archives,
            archivesDropdown,
            fundLevelOfDescriptions,
            fundLevelOfDescriptionsDropdown,
            employeeNames,
            employeeNamesDropdown,
            showSummaryReport,
            summaryGridItems,
            summaryHeaders,
            onChange,
            clear,
            StatisticDataOnly,
            onRowClick,
        };
    },
});
</script>
<style lang="scss" scoped>
@import '@/assets/styles/report.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
