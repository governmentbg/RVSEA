<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.activeProcessesReport') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart col-divs">
                            <div :class="fieldSpacing">
                                <label class="required">{{ t('reports.resultTypes') }}</label>
                                <Dropdown
                                    v-if="reportResultTypes"
                                    name="ReportResultTypes"
                                    :items="reportResultTypes"
                                    :label="t('reports.resultTypes')"
                                    required="required"
                                    v-model="inputModel.ReportResultType"
                                    :defaultValue="1"
                                    @change="onChange"
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
                        </v-col>
                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart">
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
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="processesDropdown"
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
                                    v-model="inputModel.Users"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextInternal="t('common.selectAllSEA')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="employeeNamesDropdown"
                                />
                            </div>
                        </v-col>
                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart">
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.startedFrom') }}</label>
                                    <DatePicker
                                        :label="t('reports.startedFrom')"
                                        :required="inputNullCheckboxesModel.processStartedFrom === false"
                                        v-model:date="inputModel.ProcessStartedFrom"
                                        :disabled="inputNullCheckboxesModel.processStartedFrom === true"
                                    />
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.processStartedFrom"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.startedTo') }}</label>
                                    <DatePicker
                                        :label="t('reports.startedTo')"
                                        :required="inputNullCheckboxesModel.processStartedTo === false"
                                        v-model:date="inputModel.ProcessStartedTo"
                                        :disabled="inputNullCheckboxesModel.processStartedTo === true"
                                    />
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.processStartedTo"
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
            <div class="totalCount">
                <sp class="bold">{{ t('reports.processesCount') }}:</sp> {{ processesCount }}
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
    ActiveProcessesReportModel,
    ActiveProcessesReportFiltersModel,
    ReportGridRequestModel,
    ReportGridResponseModel2,
    ReportFiltersNullCheckboxesModel,
    defaultItemsPerPage,
    itemsPerPageDropdownValues,
    ReportServiceResultModel,
} from '@/models/reports';
import { ReportResultType, ReportType } from '@/enums/reports';
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
import router from '@/router';
import { RouteLocationRaw } from 'vue-router';
import RowItem from '@/components/grid/rowItem.vue';
import { displayMessage } from '@/helpers/notification.helper';
import { returExternalCodesFromInternalCodes } from '@/helpers/report.helper';
export default defineComponent({
    name: 'ActiveProcessesReport',
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
            getReportResultTypes();
            getArchives();
            getProcesses();
            getEmployeeNames();
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

        const processesDropdown = ref();
        const processes = ref<IDropdownOption[]>();
        const getProcesses = async (reportResultType = ReportResultType.BothDBs) => {
            try {
                processes.value = await dropdownService.getProcessTypesInternalAndExternal(reportResultType, message);
                console.table(processes.value);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

        const employeeNamesDropdown = ref();
        const employeeNames = ref<IDropdownOption[]>();
        const getEmployeeNames = async (reportResultType = ReportResultType.BothDBs) => {
            try {
                employeeNames.value = await dropdownService.getEmployeeNamesInternalAndExternal(
                    reportResultType,
                    message
                );
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

        const clear = () => {
            processesDropdown.value.clear();
            employeeNamesDropdown.value.clear();
        };

        const onChange = (option: IDropdownOption) => {
            if (option) {
                processesDropdown.value?.clear();
                getProcesses(option.code as number);

                employeeNamesDropdown.value?.clear();
                getEmployeeNames(option.code as number);
            }
        };

        const inputModel = ref(new ActiveProcessesReportFiltersModel());
        const inputNullCheckboxesModel = ref(new ReportFiltersNullCheckboxesModel());
        watch(
            () => inputNullCheckboxesModel.value,
            (value) => {
                if (value.processStartedFrom === true) {
                    inputModel.value.ProcessStartedFrom = null;
                }
                if (value.processStartedTo === true) {
                    inputModel.value.ProcessStartedTo = null;
                }
                if (value.fundNumber === true) {
                    inputModel.value.FundNumber = null;
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
        const processesCount = ref(0);
        const grid = ref();
        const exportParams = ref();
        const exportOptions = ref();
        const viewReport = (options: GridOptions) => {
            emit('loadingChange', true);
            showReport.value = false;
            showReport.value = false;
            if (inputModel.value.ReportResultType == ReportResultType.BothDBs) {
                splitCodes(inputModel.value);
            }
            const gridInputModel = new ReportGridRequestModel<ActiveProcessesReportFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.activeProcessesReport;

            reportService
                .getActiveProcessesReport(gridInputModel)
                .then((result: ReportServiceResultModel<ReportGridResponseModel2<ActiveProcessesReportModel>>) => {
                    gridItems.value = [];
                    result.data!.items.forEach((item) => {
                        gridItems.value.push(item);
                    });
                    totalGridRowsCount.value = result.data!.totalCount;
                    processesCount.value = result.data!.total;

                    showReport.value = true;

                    processMetadata(result.metadata);
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
        };
        const viewReportOnSubmit = () => {
            const options = new GridOptions({});
            options.itemsPerPage = inputModel.value.ItemsPerPage;
            viewReport(options);
            grid.value.setInitialValues(inputModel.value.ItemsPerPage);
        };
        const viewReportOnRefresh = (options: GridOptions) => viewReport(options);

        const onRowClick = (row: typeof RowItem) => {
            let route: RouteLocationRaw;

            if (
                row.items.descriptionLevel == 'Фонд' ||
                row.items.descriptionLevel == 'Фонд с необработени документи' ||
                row.items.descriptionLevel == 'Спомен' ||
                row.items.descriptionLevel == 'ЧП'
            ) {
                route = {
                    name: 'DisplayFund',
                };
            } else if (
                row.items.descriptionLevel == 'Служебен опис' ||
                row.items.descriptionLevel == 'Инвентарен опис' ||
                row.items.descriptionLevel == 'Груб опис'
            ) {
                route = {
                    name: 'DisplayInventory',
                };
            } else if (
                row.items.descriptionLevel == 'Архивна единица' ||
                row.items.descriptionLevel == 'Служебна архивна единица'
            ) {
                route = {
                    name: 'DisplayArchiveEntity',
                };
            } else {
                route = {
                    name: 'DisplayDocument',
                };
            }

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

        const splitCodes = (model: ActiveProcessesReportFiltersModel) => {
            (inputModel.value.ProcessGids as string[]) = returExternalCodesFromInternalCodes(
                model.ProcessTypes,
                processes.value!
            );
            (inputModel.value.ProcessTypesInternal as string[]) = [...model.ProcessTypes];
        };

        const showReport = ref(false);
        const gridItems = ref([] as ActiveProcessesReportModel[]);
        const headers = ref([
            {
                title: t('reports.archiveName'),
                prop: 'archive',
                type: 'string',
            },
            {
                title: t('reports.levelOfDescription'),
                prop: 'descriptionLevel',
                type: 'string',
            },
            {
                title: t('reports.fundNumber'),
                prop: 'fundNumber',
                type: 'string',
            },
            {
                title: t('reports.fundName'),
                prop: 'title',
                type: 'string',
            },
            {
                title: t('reports.documentSystemId'),
                prop: 'documentId',
                type: 'string',
            },
            {
                title: t('reports.documentNumber'),
                prop: 'documentNumber',
                type: 'string',
            },
            {
                title: t('reports.process'),
                prop: 'processName',
                type: 'string',
            },
            {
                title: t('reports.startingDate'),
                prop: 'processStartDate',
                type: 'string',
            },
            {
                title: t('reports.initiator'),
                prop: 'initiator',
                type: 'string',
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
                title: t('reports.activeProcessesReport'),
                disabled: true,
            },
        ];
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
            headers,
            breadcrumbItems,
            totalGridRowsCount,
            defaultRowsPerPage,
            showReport,
            exportParams,
            exportOptions,
            rowsPerPageDropdownValues,
            reportResultTypes,
            archives,
            archivesDropdown,
            processes,
            processesDropdown,
            employeeNames,
            employeeNamesDropdown,
            onChange,
            clear,
            processesCount,
            onRowClick,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/report.scss';
@import '@/assets/styles/breadcrumbs.scss';

.totalCount {
    top: 100px;
    position: relative;
}

.bold {
    font-weight: bold;
}
</style>
