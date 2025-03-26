<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.workDoneOnDigitalObjectsCombinedReport') }}</h3>
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
                                    v-model="inputModel.ArchiveCodes"
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
                                    ref="statusesDropdown"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('users.user') }}</label>
                                <Dropdown
                                    v-if="employees"
                                    :label="t('users.user')"
                                    name="fldUser"
                                    required="required"
                                    :items="employees"
                                    v-model="inputModel.Employees"
                                    ref="employeesDropdown"
                                    :multiselect="true"
                                />
                            </div>
                            
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.reportTypes') }}</label>
                                <Dropdown
                                    v-if="reportTypes"
                                    :label="t('reports.reportTypes')"
                                    name="fldReportType"
                                    :items="reportTypes"
                                    v-model="reportType"
                                    ref="reportTypesDropdown"
                                    :multiselect="false"
                                    required="required"
                                />
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
                                    <label>{{ t('reports.chronologicalExtentStartDate') }}</label>
                                    <DatePicker
                                        :label="t('reports.chronologicalExtentStartDate')"
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
        <div v-show="showQualityControlReport && reportType == 'qualityControlReport'">
            <div class="summaryGrid">
                <Grid
                    :columns= headersSummaryGridItemsQualityControl
                    :items= summaryGridItemsQualityControl
                    :totalItems="1"
                    :showSearch="false"
                    mode="custom"
                    :showExport="false"
                    @refresh="viewReportOnRefresh"
                />
            </div>
            <Grid
                :columns= headersQualityControl
                :items= gridItemsQualityControl
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
        <div v-show="showDigitalObjectsPreparationReport && reportType == 'digitalObjectsPreparationReport'">
            <div class="summaryGrid">
                <Grid
                    :columns= headersSummaryGridItemsDigitalObjectsPreparation
                    :items= summaryGridItemsDigitalObjectsPreparation
                    :totalItems="1"
                    :showSearch="false"
                    mode="custom"
                    :showExport="false"
                    @refresh="viewReportOnRefresh"
                />
            </div>
            <Grid
                :columns= headersDigitalObjectsPreparation
                :items= gridItemsDigitalObjectsPreparation
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
import { defineComponent, ref, onMounted, inject, Ref, watch } from 'vue'; //watch
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import {
    WorkDoneOnDigitalObjectsCombinedReportInputModel,
    QualityControlReport,
    QualityControlCombined,
    DigitalObjectsPreparationReport,
    DigitalObjectsPreparationCombined,
    ReportGridRequestModel,
    ReportGridWithSummaryGridResponseModel,
    ReportFiltersNullCheckboxesModel,
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
import { Message } from '@/models/notification';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import DatePicker from '@/components/datetime/datepPicker.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { formatDate } from '@/helpers/format.helper';
import { RoleNames } from '@/enums/roles';
export default defineComponent({
    name: 'WorkDoneOnDigitalObjectsCombinedReport',
    emits: ['loadingChange'],
    props: {
        isCanceled: {
            type: Boolean,
            default: false
        }
    },
    components: { Dropdown, Form, Grid, Breadcrumbs, DatePicker },
    setup(_, { emit }) {
        onMounted(() => {
            getArchives();
            getStatuses();
            getEmployees();
            getReportTypes();
        });
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };
        const rowsPerPageDropdownValues = ref(itemsPerPageDropdownValues);

        const archivesDropdown = ref();
        const archives = ref<IDropdownOption[]>();
        const getArchives = async () => {
            archives.value = await dropdownService.getArchives();
        };

        const statusesDropdown = ref();
        const statuses = ref<IDropdownOption[]>();
        const getStatuses = async () => {
            statuses.value = await dropdownService.getStatuses(true);
        };

        const employeesDropdown = ref();
        const employees = ref<IDropdownOption[]>();
        const getEmployees = async () => {
            employees.value = await dropdownService.getUsersInRolesAllArchives([RoleNames.GroupG, RoleNames.GroupJ, RoleNames.GroupZ]);
        };

        const reportTypesDropdown = ref();
        const reportTypes = ref<IDropdownOption[]>();
        const getReportTypes = async () => {
            reportTypes.value = [
                {
                    code: ReportType.qualityControlReport,
                    label: 'Контрол по качеството'
                },
                {
                    code: ReportType.digitalObjectsPreparationReport,
                    label: 'Изготвяне на дигитални обекти'
                }
            ]
        }

        const clear = () => {
            archivesDropdown.value.clear();
        };

        const inputModel = ref(new WorkDoneOnDigitalObjectsCombinedReportInputModel());
        const inputNullCheckboxesModel = ref(new ReportFiltersNullCheckboxesModel());

        const defaultRowsPerPage = ref(defaultItemsPerPage);
        const loading = ref(false);
        const totalGridRowsCount = ref(0);
        const grid = ref();
        const exportParams = ref();
        const exportOptions = ref();

        const reportType = ref();

        const showQualityControlReport = ref(false);
        const showDigitalObjectsPreparationReport = ref(false);

        const viewReport = async (options: GridOptions) => {
            inputModel.value.DateFrom?.setUTCHours(0, 0, 0);
            inputModel.value.DateTo?.setUTCHours(23, 59, 59);
            inputModel.value.Employees.forEach(e => e.toString())
            emit('loadingChange', true);
            showQualityControlReport.value = false;
            showDigitalObjectsPreparationReport.value = false;
            const gridInputModel = new ReportGridRequestModel<WorkDoneOnDigitalObjectsCombinedReportInputModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            if(reportType.value == ReportType.qualityControlReport) {
                exportParams.value = ReportType.qualityControlReport;
                reportService
                    .getQualityControlReport(gridInputModel)
                    .then((result: ReportGridWithSummaryGridResponseModel<QualityControlCombined, QualityControlReport>) => {
                        
                        gridItemsQualityControl.value = [];
                        summaryGridItemsQualityControl.value = [];

                        result.items.forEach(item => {
                            gridItemsQualityControl.value.push(item);
                        });
                    
                        summaryGridItemsQualityControl.value.push({
                            periodFrom: result.summary?.periodFrom,
                            periodTo: result.summary?.periodTo,
                            checkedDocuments: result.summary?.checkedDocuments,
                            checkedDo: result.summary?.checkedDo,
                            acceptedDocuments: result.summary?.acceptedDocuments,
                            acceptedDo: result.summary?.acceptedDo,
                            returnedDocuments: result.summary?.returnedDocuments,
                            returnedDo: result.summary?.returnedDo
                        })

                        totalGridRowsCount.value = result.totalCount;
                        showQualityControlReport.value = true;
                    })
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
            } else if (reportType.value == ReportType.digitalObjectsPreparationReport) {
                exportParams.value = ReportType.digitalObjectsPreparationReport;
                reportService
                    .getDigitalObjectsPreparationReport(gridInputModel)
                    .then((result: ReportGridWithSummaryGridResponseModel<DigitalObjectsPreparationCombined, DigitalObjectsPreparationReport>) => {
                        
                        gridItemsDigitalObjectsPreparation.value = [];
                        summaryGridItemsDigitalObjectsPreparation.value = [];

                        result.items.forEach(item => {
                            gridItemsDigitalObjectsPreparation.value.push(item);
                        });

                        summaryGridItemsDigitalObjectsPreparation.value.push({
                            periodFrom: result.summary?.periodFrom,
                            periodTo: result.summary?.periodTo,
                            newDocuments: result.summary?.newDocuments,
                            newDo: result.summary?.newDo,
                            recreatedDocuments: result.summary?.recreatedDocuments,
                            recreatedDo: result.summary?.recreatedDo
                        })

                        totalGridRowsCount.value = result.totalCount;
                        showDigitalObjectsPreparationReport.value = true;
                    })
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
            
        }


        const viewReportOnSubmit = () => {
            const options = new GridOptions({});
            options.itemsPerPage = inputModel.value.ItemsPerPage;
            viewReport(options);
            grid.value.setInitialValues(inputModel.value.ItemsPerPage);
        };
        const viewReportOnRefresh = (options: GridOptions) => viewReport(options);

        watch(
            () => inputNullCheckboxesModel.value,
            (value) => {
                if (value.registeredFrom === true) {
                    inputModel.value.DateFrom = null;
                }
                if (value.registeredTo === true) {
                    inputModel.value.DateTo = null;
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

        const gridItemsQualityControl = ref([] as QualityControlReport[]);
        const headersQualityControl = ref([
            {
                title: t('reports.archive'),
                prop: 'archive',
                type: 'string',
            },
            {
                title: t('reports.employee'),
                prop: 'employer',
                type: 'string',
            },
            {
                title: t('reports.checkedDocuments'),
                prop: 'checkedDocuments',
                type: 'int',
            },
            {
                title: t('reports.totalNumberOfCheckedRecords'),
                prop: 'checkedDo',
                type: 'int',
            },
            {
                title: t('reports.acceptedDocuments'),
                prop: 'acceptedDocuments',
                type: 'int',
            },
            {
                title: t('reports.totalNumberOfAcceptedRecords'),
                prop: 'acceptedDo',
                type: 'int',
            },
            {
                title: t('reports.returnedDocuments'),
                prop: 'returnedDocuments',
                type: 'int',
            },
            {
                title: t('reports.totalNumberOfReturnedRecords'),
                prop: 'returnedDo',
                type: 'int',
            }
        ]);
        const summaryGridItemsQualityControl = ref([] as QualityControlCombined[]);
        const headersSummaryGridItemsQualityControl = ref([
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
            },
            {
                title: t('reports.checkedDocuments'),
                prop: 'checkedDocuments',
                type: 'int',
            },
            {
                title: t('reports.totalNumberOfCheckedRecords'),
                prop: 'checkedDo',
                type: 'int',
            },
            {
                title: t('reports.acceptedDocuments'),
                prop: 'acceptedDocuments',
                type: 'int',
            },
            {
                title: t('reports.totalNumberOfAcceptedRecords'),
                prop: 'acceptedDo',
                type: 'int',
            },
            {
                title: t('reports.returnedDocuments'),
                prop: 'returnedDocuments',
                type: 'int',
            },
            {
                title: t('reports.totalNumberOfReturnedRecords'),
                prop: 'returnedDo',
                type: 'int',
            }
        ]);

        const gridItemsDigitalObjectsPreparation = ref([] as DigitalObjectsPreparationReport[]);
        const headersDigitalObjectsPreparation = ref([
            {
                title: t('reports.archive'),
                prop: 'archive',
                type: 'string',
            },
            {
                title: t('reports.employee'),
                prop: 'employer',
                type: 'string',
            },
            {
                title: t('reports.newDocuments'),
                prop: 'newDocuments',
                type: 'int',
            },
            {
                title: t('reports.totalNumberOfNewRecords'),
                prop: 'newDo',
                type: 'int',
            },
            {
                title: t('reports.recreatedDocuments'),
                prop: 'recreatedDocuments',
                type: 'int',
            },
            {
                title: t('reports.totalNumberOfRecreatedRecords'),
                prop: 'recreatedDo',
                type: 'int',
            }
        ]);
        const summaryGridItemsDigitalObjectsPreparation = ref([] as DigitalObjectsPreparationCombined[]);
        const headersSummaryGridItemsDigitalObjectsPreparation = ref([
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
            },
            {
                title: t('reports.newDocuments'),
                prop: 'newDocuments',
                type: 'int',
            },
            {
                title: t('reports.totalNumberOfNewRecords'),
                prop: 'newDo',
                type: 'int',
            },
            {
                title: t('reports.recreatedDocuments'),
                prop: 'recreatedDocuments',
                type: 'int',
            },
            {
                title: t('reports.totalNumberOfRecreatedRecords'),
                prop: 'recreatedDo',
                type: 'int',
            }
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
                title: t('reports.workDoneOnDigitalObjectsCombinedReport'),
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
            breadcrumbItems,
            totalGridRowsCount,
            defaultRowsPerPage,
            showQualityControlReport,
            showDigitalObjectsPreparationReport,
            exportParams,
            exportOptions,
            rowsPerPageDropdownValues,
            archives,
            archivesDropdown,
            clear,
            statuses,
            statusesDropdown,
            employeesDropdown,
            employees,

            gridItemsQualityControl,
            summaryGridItemsQualityControl,
            gridItemsDigitalObjectsPreparation,
            summaryGridItemsDigitalObjectsPreparation,

            headersQualityControl,
            headersSummaryGridItemsQualityControl,
            headersDigitalObjectsPreparation,
            headersSummaryGridItemsDigitalObjectsPreparation,
            reportTypesDropdown,
            reportTypes,
            reportType
        };
    }
})
</script>

<style lang="scss" scoped>
@import '@/assets/styles/report.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
