<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div class="card-cust">
                <h3 class="display-6">{{ t('reports.listOfRoughDocuments') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" xl="12" class="flexStart col-divs">
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
                                    @change="onChange"
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
                                <label>{{ t('reports.type') }}</label>
                                <Dropdown
                                    v-if="fundTypes"
                                    :label="t('reports.type')"
                                    name="fldType"
                                    :items="fundTypes"
                                    :multiselect="true"
                                    v-model="inputModel.FundTypes"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="fundTypesDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label>{{ t('reports.industryIndex') }}</label>
                                <Dropdown
                                    v-if="industryIndexes"
                                    :label="t('reports.industryIndex')"
                                    name="fldIndustryIndex"
                                    :items="industryIndexes"
                                    :multiselect="true"
                                    v-model="inputModel.IndustryIndexes"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="industryIndexesDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label>{{ t('reports.methodOfAcquisition') }}</label>
                                <Dropdown
                                    v-if="acquisitionMethods"
                                    :label="t('reports.methodOfAcquisition')"
                                    name="fldMethodOfAcquisition"
                                    :items="acquisitionMethods"
                                    :multiselect="true"
                                    v-model="inputModel.MethodsOfAcquisition"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="acquisitionMethodsDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label>{{ t('reports.status') }}</label>
                                <Dropdown
                                    v-if="statuses"
                                    :label="t('reports.status')"
                                    name="fldStatus"
                                    :items="statuses"
                                    :multiselect="true"
                                    v-model="inputModel.Statuses"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="statusesDropdown"
                                />
                            </div>
                            <label>{{ t('reports.chronologicalScope') }}</label>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox textField">
                                <div class="width100Percent">
                                    <text-field
                                        v-model="inputModel.ChronologicalScope"
                                        :disabled="inputNullCheckboxesModel.chronologicalScope === true"
                                        :validation="
                                            inputNullCheckboxesModel.chronologicalScope === false ? 'required' : ''
                                        "
                                    ></text-field>
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.chronologicalScope"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.chronologicalExtentStartDate') }}</label>
                                    <DatePicker
                                        :label="t('reports.chronologicalExtentStartDate')"
                                        :required="inputNullCheckboxesModel.chronologicalScopeStartDate === false"
                                        v-model:date="inputModel.ChronologicalScopeStartDate"
                                        :disabled="inputNullCheckboxesModel.chronologicalScopeStartDate === true"
                                    />
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.chronologicalScopeStartDate"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.chronologicalExtentEndDate') }}</label>
                                    <DatePicker
                                        :label="t('reports.chronologicalExtentEndDate')"
                                        :required="inputNullCheckboxesModel.chronologicalScopeEndDate === false"
                                        v-model:date="inputModel.ChronologicalScopeEndDate"
                                        :disabled="inputNullCheckboxesModel.chronologicalScopeEndDate === true"
                                    />
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.chronologicalScopeEndDate"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.registeredFrom') }}</label>
                                    <DatePicker
                                        :label="t('reports.registeredFrom')"
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
                                    <label>{{ t('reports.registeredTo') }}</label>
                                    <DatePicker
                                        :label="t('reports.registeredTo')"
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
    ListOfRoughDocumentsReportFiltersModel,
    ListOfRoughDocumentsReport,
    ListOfRoughDocumentsReportCombined,
    ReportGridRequestModel,
    ReportGridWithSummaryGridResponseModel,
    defaultItemsPerPage,
    itemsPerPageDropdownValues,
} from '@/models/reports';
import { ReportResultType, ReportType } from '@/enums/reports';
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
import { formatDateTime, formatBytesToMB } from '@/helpers/format.helper';
import router from '@/router';
import { RouteLocationRaw } from 'vue-router';
import RowItem from '@/components/grid/rowItem.vue';
import { displayMessage } from '@/helpers/notification.helper';
import { returExternalCodesFromInternalCodes } from '@/helpers/report.helper';
export default defineComponent({
    name: 'ListOfRoughDocuments',
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
            getFundTypes();
            getIndustryIndexes();
            getAcquisitionMethods();
            getReportResultTypes();
            getStatuses();
        });
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };
        const rowsPerPageDropdownValues = ref(itemsPerPageDropdownValues);
        const inputModel = ref(new ListOfRoughDocumentsReportFiltersModel());
        const inputNullCheckboxesModel = ref({
            chronologicalScope: true,
            registeredFrom: true,
            registeredTo: true,
            chronologicalScopeStartDate: true,
            chronologicalScopeEndDate: true,
        });

        const reportResultTypes = ref<IDropdownOption[]>();
        const getReportResultTypes = async () => {
            reportResultTypes.value = await dropdownService.getReportResultTypes();
        };

        const archivesDropdown = ref();
        const archives = ref<IDropdownOption[]>();
        const getArchives = async () => {
            archives.value = await dropdownService.getArchives();
        };

        const fundTypesDropdown = ref();
        const fundTypes = ref<IDropdownOption[]>();
        const getFundTypes = async (reportResultType = ReportResultType.BothDBs) => {
            try {
                fundTypes.value = await dropdownService.getFundTypesInternalAndExternal(reportResultType, message);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

        const industryIndexesDropdown = ref();
        const industryIndexes = ref<IDropdownOption[]>();
        const getIndustryIndexes = async (reportResultType = ReportResultType.BothDBs) => {
            try {
                industryIndexes.value = await dropdownService.getIndustryIndexesInternalAndExternal(
                    reportResultType,
                    message
                );
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

        const acquisitionMethodsDropdown = ref();
        const acquisitionMethods = ref<IDropdownOption[]>();
        const getAcquisitionMethods = async (reportResultType = ReportResultType.BothDBs) => {
            try {
                acquisitionMethods.value = await dropdownService.getAcquisitionMethodsInternalAndExternal(
                    reportResultType,
                    message
                );
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

        const statusesDropdown = ref();
        const statuses = ref<IDropdownOption[]>();
        const getStatuses = async () => {
            statuses.value = await dropdownService.getRoughDocumentsStatuses(true);
        };

        const clear = () => {
            archivesDropdown.value.clear();
            fundTypesDropdown.value.clear();
            industryIndexesDropdown.value.clear();
            acquisitionMethodsDropdown.value.clear();
            statusesDropdown.value.clear();
            inputModel.value.ChronologicalScope = null;
            inputModel.value.RegisteredFrom = null;
            inputModel.value.RegisteredTo = null;
            inputModel.value.ChronologicalScopeStartDate = null;
            inputModel.value.ChronologicalScopeEndDate = null;
        };

        const onChange = (option: IDropdownOption) => {
            if (option) {
                fundTypesDropdown.value.clear();
                industryIndexesDropdown.value.clear();
                acquisitionMethodsDropdown.value.clear();

                getFundTypes(option.code as number);
                getIndustryIndexes(option.code as number);
                getAcquisitionMethods(option.code as number);

                // fundTypesDropdown.value?.filterChoiceByDataSourceType(option.code);
                // fundTypesDropdown.value?.setDataSourceType(option.code);
                // industryIndexesDropdown.value?.filterChoiceByDataSourceType(option.code);
                // industryIndexesDropdown.value?.setDataSourceType(option.code);
                // acquisitionMethodsDropdown.value?.filterChoiceByDataSourceType(option.code);
                // acquisitionMethodsDropdown.value?.setDataSourceType(option.code);
                // statusesDropdown.value?.filterChoiceByDataSourceType(option.code);
                // statusesDropdown.value?.setDataSourceType(option.code);
            }
        };

        const onRowClick = (row: typeof RowItem) => {
            const route: RouteLocationRaw = {
                name: 'DisplayInventory',
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
                if (value.chronologicalScope === true) {
                    inputModel.value.ChronologicalScope = null;
                }
                if (value.registeredFrom === true) {
                    inputModel.value.RegisteredFrom = null;
                }
                if (value.registeredTo === true) {
                    inputModel.value.RegisteredTo = null;
                }
                if (value.chronologicalScopeStartDate === true) {
                    inputModel.value.ChronologicalScopeStartDate = null;
                }
                if (value.chronologicalScopeEndDate === true) {
                    inputModel.value.ChronologicalScopeEndDate = null;
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
        const viewReport = async (options: GridOptions) => {
            inputModel.value.RegisteredFrom?.setUTCHours(0, 0, 0);
            inputModel.value.RegisteredTo?.setUTCHours(23, 59, 59);
            inputModel.value.ChronologicalScopeStartDate?.setUTCHours(0, 0, 0);
            inputModel.value.ChronologicalScopeEndDate?.setUTCHours(23, 59, 59);
            if (inputModel.value.ReportResultType == ReportResultType.BothDBs) {
                splitCodes(inputModel.value);
            }
            emit('loadingChange', true);
            showReport.value = false;
            const gridInputModel = new ReportGridRequestModel<ListOfRoughDocumentsReportFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.listOfRoughDocumentsReport;

            await reportService
                .getListOfRoughDocumentsReport(gridInputModel)
                .then(
                    (
                        result: ReportGridWithSummaryGridResponseModel<
                            ListOfRoughDocumentsReportCombined,
                            ListOfRoughDocumentsReport
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
                        console.log(gridItems.value);
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

        const splitCodes = (model: ListOfRoughDocumentsReportFiltersModel) => {
            inputModel.value.FundTypeGids = returExternalCodesFromInternalCodes(model.FundTypes, fundTypes.value!);
            inputModel.value.FundTypesInternal = [...model.FundTypes] as string[];

            (inputModel.value.IndustryIndexGids as string[]) = returExternalCodesFromInternalCodes(
                model.IndustryIndexes as string[],
                industryIndexes.value!
            );
            (inputModel.value.IndustryIndexesInternal as string[]) = [...model.IndustryIndexes] as string[];

            (inputModel.value.MethodOfAcquisitionGids as string[]) = returExternalCodesFromInternalCodes(
                model.MethodsOfAcquisition as string[],
                acquisitionMethods.value!
            );
            (inputModel.value.MethodsOfAcquisitionInternal as string[]) = [...model.MethodsOfAcquisition] as string[];
        };

        const defaultRowsPerPage = ref(defaultItemsPerPage);
        const loading = ref(false);
        const totalGridRowsCount = ref(0);
        const grid = ref();
        const exportParams = ref();
        const exportOptions = ref();
        const showReport = ref(false);
        const gridItems = ref([] as ListOfRoughDocumentsReport[]);
        const showSummaryReport = ref(false);
        const summaryGridItems = ref([] as ListOfRoughDocumentsReportCombined[]);

        const headers = ref([
            {
                title: t('reports.countryCode'),
                prop: 'countryCode',
                type: 'string',
            },
            {
                title: t('reports.archive'),
                prop: 'archive',
                type: 'string',
            },
            {
                title: t('reports.fundNumber'),
                prop: 'fundNumber',
                type: 'string',
            },
            {
                title: t('reports.fundName'),
                prop: 'fundTitle',
                type: 'string',
            },
            {
                title: t('reports.inventoryFilingDate'),
                prop: 'entryDate',
                type: 'string',
                renderFunction: formatDateTime,
            },
            {
                title: t('reports.inventoryRoughNumber'),
                prop: 'roughInventoryNumber',
                type: 'string',
            },
            {
                title: t('reports.methodOfAcquisition'),
                prop: 'acquisitionMethod',
                type: 'string',
            },
            {
                title: t('reports.status'),
                prop: 'status',
                type: 'string',
            },
            {
                title: t('reports.linearMeters'),
                prop: 'linearMeters',
                type: 'number',
            },
            {
                title: t('reports.volumeMB'),
                prop: 'bytes',
                type: 'number',
                renderFunction: formatBytesToMB,
            },
        ]);

        const summaryHeaders = ref([
            {
                title: t('reports.fundCount'),
                prop: 'fundCount',
                type: 'number',
            },
            {
                title: t('reports.countInventory'),
                prop: 'inventoryCount',
                type: 'number',
            },
            {
                title: t('reports.linearMeters'),
                prop: 'linearMeters',
                type: 'number',
            },
            {
                title: t('reports.volumeMB'),
                prop: 'bytes',
                type: 'number',
                renderFunction: formatBytesToMB,
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
                title: t('reports.listOfRoughDocuments'),
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
            fundTypes,
            fundTypesDropdown,
            industryIndexes,
            industryIndexesDropdown,
            acquisitionMethods,
            acquisitionMethodsDropdown,
            statusesDropdown,
            statuses,
            reportResultTypes,
            showSummaryReport,
            summaryGridItems,
            summaryHeaders,
            onChange,
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
