<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.fundReport') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart">
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
                                <label class="required">{{ t('reports.array') }}</label>
                                <Dropdown
                                    v-if="fundArrays"
                                    :label="t('reports.array')"
                                    name="fldArray"
                                    required="required"
                                    :items="fundArrays"
                                    :multiselect="true"
                                    v-model="inputModel.FundArrays"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
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
                        </v-col>
                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart">
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.status') }}</label>
                                <Dropdown
                                    v-if="statuses"
                                    :label="t('reports.status')"
                                    name="fldStatus"
                                    required="required"
                                    :items="statuses"
                                    :multiselect="true"
                                    v-model="inputModel.Statuses"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="statusesDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label>{{ t('reports.methodOfAcquisition') }}</label>
                                <Dropdown
                                    v-if="acquisitionMethods"
                                    :label="t('reports.methodOfAcquisition')"
                                    name="fldAcquisitionMethods"
                                    :items="acquisitionMethods"
                                    :multiselect="true"
                                    v-model="inputModel.MethodsOfAcquisition"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="acquisitionMethodsDropdown"
                                />
                            </div>
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
                        </v-col>
                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart">
                            <label>{{ t('reports.chronologicalExtentApproximateDate') }}</label>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox textField">
                                <div class="width100Percent">
                                    <text-field
                                        :label="t('reports.chronologicalExtentApproximateDate')"
                                        :hideLabelInField="true"
                                        v-model="inputModel.TextDate"
                                        :disabled="inputNullCheckboxesModel.textDate === true"
                                        :validation="inputNullCheckboxesModel.textDate === false ? 'required' : ''"
                                    ></text-field>
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.textDate"
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
        <span v-show="showReport">
            <Grid
                :columns="summaryHeaders"
                :items="summaryGridItems"
                :totalItems="1"
                :showSearch="false"
                mode="custom"
                :showExport="false"
                @refresh="viewReportOnRefresh"
            />
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
                @rowClick="onRowClick"
            />
        </span>
    </v-container>
</template>
<script lang="ts">
import { defineComponent, ref, watch, onMounted, inject, Ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import {
    ReportGridWithSummaryGridResponseModel,
    FundPublicReport,
    FundPublicReportSummary,
    FundReportFiltersModel,
    ReportGridRequestModel,
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
import TextField from '@/components/field/text.field.vue';
import { Message } from '@/models/notification';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { formatBytesToMB, formatDuration } from '@/helpers/format.helper';
import { displayMessage } from '@/helpers/notification.helper';
import { returExternalCodesFromInternalCodes } from '@/helpers/report.helper';
import RowItem from '@/components/grid/rowItem.vue';
import { useRouter } from 'vue-router';
import { RouteLocationRaw } from 'vue-router';

export default defineComponent({
    name: 'FundsReport',
    emits: ['loadingChange'],
    props: {
        isCanceled: {
            type: Boolean,
            default: false,
        },
    },
    components: { Dropdown, Grid, DatePicker, Form, TextField, Breadcrumbs },
    setup(props, { emit }) {
        onMounted(() => {
            getFundArrays();
            getFundTypes();
            getIndustryIndexes();
            getAcquisitionMethods();
            getStatuses();
            getArchives();
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
            try {
                fundArrays.value = await dropdownService.getFundArraysInternalAndExternal(message);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

        const fundTypesDropdown = ref();
        const fundTypes = ref<IDropdownOption[]>();
        const getFundTypes = async () => {
            try {
                fundTypes.value = await dropdownService.getFundTypesInternalAndExternal(message);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

        const industryIndexesDropdown = ref();
        const industryIndexes = ref<IDropdownOption[]>();
        const getIndustryIndexes = async () => {
            try {
                industryIndexes.value = await dropdownService.getIndustryIndexesInternalAndExternal(message);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

        const acquisitionMethodsDropdown = ref();
        const acquisitionMethods = ref<IDropdownOption[]>();
        const getAcquisitionMethods = async () => {
            try {
                acquisitionMethods.value = await dropdownService.getAcquisitionMethodsInternalAndExternal(message);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

        const statusesDropdown = ref();
        const statuses = ref<IDropdownOption[]>();
        const getStatuses = async () => {
            statuses.value = await dropdownService.getFundStatuses();
        };

        const archivesDropdown = ref();
        const archives = ref<IDropdownOption[]>();
        const getArchives = async () => {
            archives.value = await dropdownService.getArchives(true);
        };

        const inputModel = ref(new FundReportFiltersModel());
        const inputNullCheckboxesModel = ref(new ReportFiltersNullCheckboxesModel());

        const clear = () => {
            fundArraysDropdown.value.clear();
            acquisitionMethodsDropdown.value.clear();
            statusesDropdown.value.clear();
            archivesDropdown.value.clear();
            industryIndexesDropdown.value.clear();
            fundTypesDropdown.value.clear();

            inputModel.value.RegisteredFrom = null;
            inputModel.value.RegisteredTo = null;
            inputModel.value.TextDate = null;
            inputModel.value.DateFrom = null;
            inputModel.value.DateTo = null;
        };

        watch(
            () => props.isCanceled,
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
                if (value.dateFrom === true) {
                    inputModel.value.DateFrom = null;
                }
                if (value.textDate === true) {
                    inputModel.value.TextDate = null;
                }
                if (value.dateTo === true) {
                    inputModel.value.DateTo = null;
                }
            },
            { deep: true }
        );

        const router = useRouter();
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

        const defaultRowsPerPage = ref(defaultItemsPerPage);
        const loading = ref(false);
        const totalGridRowsCount = ref(0);
        const grid = ref();
        const exportParams = ref();
        const exportOptions = ref();
        const viewReport = (options: GridOptions) => {
            emit('loadingChange', true);
            showReport.value = false;
            splitCodes(inputModel.value);
            const gridInputModel = new ReportGridRequestModel<FundReportFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.fund;
            reportService
                .getFundsPublicReport(gridInputModel)
                .then(
                    (
                        result: ReportServiceResultModel<
                            ReportGridWithSummaryGridResponseModel<FundPublicReportSummary, FundPublicReport>
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

                        processMetadata(result.metadata);
                    }
                )
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
        };

        const splitCodes = (model: FundReportFiltersModel) => {
            inputModel.value.PeriodGids = returExternalCodesFromInternalCodes(model.FundArrays, fundArrays.value!);
            inputModel.value.FundArraysInternal = [...model.FundArrays];

            inputModel.value.FundTypeGids = returExternalCodesFromInternalCodes(model.FundTypes, fundTypes.value!);
            inputModel.value.FundTypesInternal = [...model.FundTypes];

            inputModel.value.IndustryIndexGids = returExternalCodesFromInternalCodes(
                model.IndustryIndexes,
                industryIndexes.value!
            );
            inputModel.value.IndustryIndexesInternal = [...model.IndustryIndexes];

            inputModel.value.MethodOfAcquisitionGids = returExternalCodesFromInternalCodes(
                model.MethodsOfAcquisition,
                acquisitionMethods.value!
            );
            inputModel.value.MethodsOfAcquisitionInternal = [...model.MethodsOfAcquisition];
        };

        const viewReportOnSubmit = () => {
            const options = new GridOptions({});
            options.itemsPerPage = inputModel.value.ItemsPerPage;
            viewReport(options);
            grid.value.setInitialValues(inputModel.value.ItemsPerPage);
        };
        const viewReportOnRefresh = (options: GridOptions) => viewReport(options);

        const showReport = ref(false);
        const gridItems = ref([] as FundPublicReport[]);
        const headers = ref([
            // {
            //   title: t("reports.countryCode"),
            //   prop: "id",
            //   type: "string",
            //   sortable: true,
            //   filterable: true,
            // },
            {
                title: t('reports.archiveName'),
                prop: 'archive',
                type: 'string',
            },
            {
                title: t('reports.fundNumber'),
                prop: 'number',
                type: 'string',
            },
            {
                title: t('reports.name'),
                prop: 'title',
                type: 'string',
            },
            {
                title: t('reports.type'),
                prop: 'fundType',
                type: 'string',
            },
            {
                title: t('reports.index'),
                prop: 'industryIndex',
                type: 'string',
            },
            {
                title: t('reports.methodOfAcquisition'),
                prop: 'methodOfAcquisition',
                type: 'string',
            },
            {
                title: t('reports.chronologicalExtent'),
                prop: 'textDate',
                type: 'string',
            },
            {
                title: t('reports.chronologicalExtentStartDate'),
                prop: 'startDate',
                type: 'string',
            },
            {
                title: t('reports.chronologicalExtentEndDate'),
                prop: 'endDate',
                type: 'string',
            },
            {
                title: t('reports.filingDate'),
                prop: 'creationDate',
                type: 'string',
            },
            {
                title: t('reports.note'),
                prop: 'note',
                type: 'string',
            },
            {
                title: t('reports.status'),
                prop: 'fundStatus',
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
                title: t('reports.archiveEntityCount'),
                prop: 'aeCount',
                type: 'int',
            },
            {
                title: t('reports.linearMeters'),
                prop: 'linearMeters',
                type: 'number',
            },
            {
                title: t('reports.volumeMB'),
                prop: 'digitalSize',
                type: 'bytes',
                renderFunction: formatBytesToMB,
            },
            {
                title: t('reports.duration'),
                prop: 'totalDuration',
                type: 'duration',
                renderFunction: formatDuration,
            },
        ]);

        const summaryGridItems = ref([] as FundPublicReportSummary[]);
        const summaryHeaders = ref([
            {
                title: t('reports.fundsCount'),
                prop: 'totalFunds',
                type: 'int',
            },
            {
                title: t('reports.inventoryCount'),
                prop: 'totalInventories',
                type: 'int',
            },
            {
                title: t('reports.archiveEntityCount'),
                prop: 'totalArchiveEntities',
                type: 'int',
            },
            {
                title: t('reports.volumeMB'),
                prop: 'totalSize',
                type: 'number',
                renderFunction: formatBytesToMB,
            },
            {
                title: t('reports.duration'),
                prop: 'totalDuration',
                type: 'number',
                renderFunction: formatDuration,
            },
            {
                title: t('reports.volumeLinearMeters'),
                prop: 'totalLinearMeters',
                type: 'number',
            },
        ]);

        const breadcrumbItems = computed(() => [
            {
                title: t('navigation.left.home'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.reports'),
                disabled: false,
                to: { name: 'Reports' },
            },
            {
                title: t('reports.fundReport'),
                disabled: true,
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

        return {
            t,
            fieldSpacing,
            //dropdownModel,
            inputModel,
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
            fundArrays,
            fundTypes,
            industryIndexes,
            acquisitionMethods,
            statuses,
            archives,
            fundArraysDropdown,
            acquisitionMethodsDropdown,
            statusesDropdown,
            archivesDropdown,
            industryIndexesDropdown,
            fundTypesDropdown,
            clear,
            summaryHeaders,
            summaryGridItems,
            onRowClick,
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
