<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div class="card-cust">
                <h3 class="display-6">{{ t('reports.inventoryReport') }}</h3>
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
                            <label>{{ t('reports.chronologicalScope') }}</label>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox textField">
                                <div class="width100Percent">
                                    <text-field
                                        :label="t('reports.chronologicalScope')"
                                        :hideLabelInField="true"
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
    InventoryReportFiltersModel,
    InventoryReport,
    InventoryReportCombined,
    ReportGridRequestModel,
    ReportGridWithSummaryGridResponseModel,
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
import TextField from '@/components/field/text.field.vue';
import { formatBytesToMB, formatDuration } from '@/helpers/format.helper';
import router from '@/router';
import { RouteLocationRaw } from 'vue-router';
import RowItem from '@/components/grid/rowItem.vue';
export default defineComponent({
    name: 'InventoryReport',
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
            getStatuses();
            getReportResultTypes();
        });
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };
        const rowsPerPageDropdownValues = ref(itemsPerPageDropdownValues);
        const inputModel = ref(new InventoryReportFiltersModel());
        const inputNullCheckboxesModel = ref({
            fundNumber: true,
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

        const statusesDropdown = ref();
        const statuses = ref<IDropdownOption[]>();
        const getStatuses = async () => {
            statuses.value = await dropdownService.getStatusesReduced2(true);
        };

        const clear = () => {
            archivesDropdown.value.clear();
            statusesDropdown.value.clear();
            inputModel.value.FundNumber = null;
            inputModel.value.ChronologicalScope = null;
            inputModel.value.RegisteredFrom = null;
            inputModel.value.RegisteredTo = null;
            inputModel.value.ChronologicalScopeStartDate = null;
            inputModel.value.ChronologicalScopeEndDate = null;
        };

        watch(
            () => inputNullCheckboxesModel.value,
            (value) => {
                if (value.fundNumber === true) {
                    inputModel.value.FundNumber = null;
                }
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
            emit('loadingChange', true);
            showReport.value = false;
            const gridInputModel = new ReportGridRequestModel<InventoryReportFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.inventoryReport;

            await reportService
                .getInventoryReport(gridInputModel)
                .then(
                    (
                        result: ReportServiceResultModel<
                            ReportGridWithSummaryGridResponseModel<InventoryReportCombined, InventoryReport>
                        >
                    ) => {
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

        const viewReportOnSubmit = async () => {
            const options = new GridOptions({});
            options.itemsPerPage = inputModel.value.ItemsPerPage;
            await viewReport(options);
            grid.value.setInitialValues(inputModel.value.ItemsPerPage);
        };
        const viewReportOnRefresh = async (options: GridOptions) => await viewReport(options);

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

        const defaultRowsPerPage = ref(defaultItemsPerPage);
        const loading = ref(false);
        const totalGridRowsCount = ref(0);
        const grid = ref();
        const exportParams = ref();
        const exportOptions = ref();
        const showReport = ref(false);
        const gridItems = ref([] as InventoryReport[]);
        const showSummaryReport = ref(false);
        const summaryGridItems = ref([] as InventoryReportCombined[]);

        const headers = ref([
            {
                title: t('reports.archive'),
                prop: 'archive',
                type: 'string',
            },
            {
                title: t('reports.levelOfDescription'),
                prop: 'fundDescriptionLevel',
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
                title: t('reports.inventoryNumber'),
                prop: 'inventoryNumber',
                type: 'string',
            },
            {
                title: t('reports.levelOfDescription'),
                prop: 'inventoryDescriptionLevel',
                type: 'string',
            },
            {
                title: t('reports.status'),
                prop: 'status',
                type: 'string',
            },
            {
                title: t('reports.countAe'),
                prop: 'aeCount',
                type: 'number',
            },
            // {
            //     title: t('reports.countAeWithChar'),
            //     prop: 'aeWithCharCount',
            //     type: 'number',
            // },
            {
                title: t('reports.eDocumentsCount'),
                prop: 'eDocumentsCount',
                type: 'int',
            },
            {
                title: t('reports.linearMeters'),
                prop: 'linearMeters',
                type: 'number',
            },
            {
                title: t('reports.fileFormat'),
                prop: 'fileFormat',
                type: 'number',
            },
            {
                title: t('reports.duration'),
                prop: 'duration',
                type: 'duration',
                renderFunction: formatDuration,
            },
            {
                title: t('reports.volumeMB'),
                prop: 'bytes',
                type: 'bytes',
                renderFunction: formatBytesToMB,
            },
        ]);

        const summaryHeaders = ref([
            {
                title: t('reports.countInventory'),
                prop: 'inventoryCount',
                type: 'number',
            },
            {
                title: t('reports.countAe'),
                prop: 'aeCount',
                type: 'number',
            },
            {
                title: t('reports.eDocumentsCount'),
                prop: 'eDocumentsCount',
                type: 'int',
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
            {
                title: t('reports.duration'),
                prop: 'duration',
                type: 'number',
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
                title: t('reports.inventoryReport'),
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
            statuses,
            statusesDropdown,
            reportResultTypes,
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
