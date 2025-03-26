<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.workDoneOnDigitalObjectsReport') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart col-divs">
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.archiveName') }}</label>
                                <Dropdown
                                    v-if="archiveCodes"
                                    :label="t('reports.archiveName')"
                                    name="fldArchive"
                                    required="required"
                                    :items="archiveCodes"
                                    :multiselect="true"
                                    v-model="inputModel.ArchiveCodes"
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
                                    name="fldFundArray"
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
                                <label class="required">{{ t('reports.status') }}</label>
                                <Dropdown
                                    v-if="digitalObjectStatuses"
                                    :label="t('reports.status')"
                                    name="fldStatus"
                                    required="required"
                                    :items="digitalObjectStatuses"
                                    :multiselect="true"
                                    v-model="inputModel.DigitalObjectStatuses"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="digitalObjectStatusesDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.action') }}</label>
                                <Dropdown
                                    v-if="processSteps"
                                    :label="t('reports.action')"
                                    name="fldAction"
                                    required="required"
                                    :items="processSteps"
                                    :multiselect="true"
                                    v-model="inputModel.ProcessSteps"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="processStepsDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.user') }}</label>
                                <Dropdown
                                    v-if="employees"
                                    :label="t('reports.user')"
                                    name="fldEmployees"
                                    required="required"
                                    :items="employees"
                                    :multiselect="true"
                                    v-model="inputModel.UserIds"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="employeesDropdown"
                                />
                            </div>
                        </v-col>
                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart">
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.startedFrom') }}</label>
                                    <DatePicker
                                        :label="t('reports.startedFrom')"
                                        :required="inputNullCheckboxesModel.createdFrom === false"
                                        v-model:date="inputModel.CreatedFrom"
                                        :disabled="inputNullCheckboxesModel.createdFrom === true"
                                    />
                                </div>
                                <v-checkbox
                                    v-model="inputNullCheckboxesModel.createdFrom"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.startedTo') }}</label>
                                    <DatePicker
                                        :label="t('reports.startedTo')"
                                        :required="inputNullCheckboxesModel.createdTo === false"
                                        v-model:date="inputModel.CreatedTo"
                                        :disabled="inputNullCheckboxesModel.createdTo === true"
                                    />
                                </div>
                                <v-checkbox
                                    v-model="inputNullCheckboxesModel.createdTo"
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
        <div v-show="showReport">
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
    WorkDoneOnDigitalObjectsReportModel,
    WorkDoneOnDigitalObjectsReportFiltersModel,
    ReportGridRequestModel,
    ReportGridResponseModel,
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
import { formatDate } from '@/helpers/format.helper';

export default defineComponent({
    name: 'WorkDoneOnDigitalObjectsReport',
    emits: ['loadingChange'],
    props: {
        isCanceled: {
            type: Boolean,
            default: false,
        },
    },
    components: { Dropdown, Grid, DatePicker, Form, Breadcrumbs },
    setup(props, { emit }) {
        onMounted(() => {
            getArchives();
            getFundArrays();
            getProcessSteps();
            getEmployees();
            getDigitalObjectStatuses();
        });

        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };
        const rowsPerPageDropdownValues = ref(itemsPerPageDropdownValues);

        const archivesDropdown = ref();
        const archiveCodes = ref<IDropdownOption[]>();
        const getArchives = async () => {
            archiveCodes.value = await dropdownService.getArchives();
        };

        const fundArraysDropdown = ref();
        const fundArrays = ref<IDropdownOption[]>();
        const getFundArrays = async () => {
            fundArrays.value = await dropdownService.getFundArrays(true);
        };

        const processStepsDropdown = ref();
        const processSteps = ref<IDropdownOption[]>();
        const getProcessSteps = async () => {
            processSteps.value = await dropdownService.getPreparationOfDigitalObjectProcessSteps(true);
        };

        const employeesDropdown = ref();
        const employees = ref<IDropdownOption[]>();
        const getEmployees = async () => {
            employees.value = await dropdownService.getEmployeeNamesInternal(true);
        };

        const digitalObjectStatusesDropdown = ref();
        const digitalObjectStatuses = ref<IDropdownOption[]>();
        const getDigitalObjectStatuses = async () => {
            digitalObjectStatuses.value = await dropdownService.getDocumentObjectStatuses(true);
        };

        const inputModel = ref(new WorkDoneOnDigitalObjectsReportFiltersModel());
        const inputNullCheckboxesModel = ref(new ReportFiltersNullCheckboxesModel());
        watch(
            () => inputNullCheckboxesModel.value,
            (value) => {
                if (value.createdFrom === true) {
                    inputModel.value.CreatedFrom = null;
                }
                if (value.createdTo === true) {
                    inputModel.value.CreatedTo = null;
                }
            },
            { deep: true }
        );
        watch(
            () => props.isCanceled,
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
        const viewReport = (options: GridOptions) => {
            emit('loadingChange', true);
            showReport.value = false;
            const gridInputModel = new ReportGridRequestModel<WorkDoneOnDigitalObjectsReportFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.workDoneOnDigitalObjectsReport;

            reportService
                .getWorkDoneOnDigitalObjectsReport(gridInputModel)
                .then(
                    (
                        result: ReportServiceResultModel<ReportGridResponseModel<WorkDoneOnDigitalObjectsReportModel>>
                    ) => {
                        gridItems.value = [];
                        result.data!.items.forEach((item) => {
                            const itemToDisplay = { ...item };
                            itemToDisplay.createdFrom = inputModel.value.CreatedFrom;
                            itemToDisplay.createdTo = inputModel.value.CreatedTo;
                            gridItems.value.push(itemToDisplay);
                        });
                        totalGridRowsCount.value = result.data!.totalCount;

                        showReport.value = true;
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

        const clear = () => {
            archivesDropdown.value.clear();
            fundArraysDropdown.value.clear();
            processStepsDropdown.value.clear();
            employeesDropdown.value.clear();
            digitalObjectStatusesDropdown.value.clear();

            inputModel.value.CreatedFrom = null;
            inputModel.value.CreatedTo = null;
        };

        const showReport = ref(false);
        const gridItems = ref([] as WorkDoneOnDigitalObjectsReportModel[]);
        const headers = ref([
            {
                title: t('reports.periodFrom'),
                prop: 'createdFrom',
                type: 'string',
                renderFunction: formatDate,
            },
            {
                title: t('reports.periodTo'),
                prop: 'createdTo',
                type: 'string',
                renderFunction: formatDate,
            },
            {
                title: t('reports.objectsCount'),
                prop: 'digitalObjectsCount',
                type: 'int',
            },
            {
                title: t('reports.archiveName'),
                prop: 'archive',
                type: 'string',
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
                title: t('reports.workDoneOnDigitalObjectsReport'),
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
            breadcrumbItems,
            totalGridRowsCount,
            defaultRowsPerPage,
            showReport,
            exportParams,
            exportOptions,
            rowsPerPageDropdownValues,
            archiveCodes,
            archivesDropdown,
            fundArrays,
            fundArraysDropdown,
            processSteps,
            processStepsDropdown,
            employees,
            employeesDropdown,
            digitalObjectStatuses,
            digitalObjectStatusesDropdown,
            clear,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/report.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
