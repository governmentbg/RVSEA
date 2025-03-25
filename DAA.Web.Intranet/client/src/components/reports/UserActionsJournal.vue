<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div class="card-cust">
                <h3 class="display-6">{{ t('reports.userActionsJournalReport') }}</h3>
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
                                    :selectAllText="t('reports.all')"
                                />
                            </div>
                            <div :class="fieldSpacing">
                                <label>{{ t('reports.user') }}</label>
                                <Dropdown
                                    v-if="employeeNames"
                                    :label="t('reports.user')"
                                    name="fldUser"
                                    :items="employeeNames"
                                    :multiselect="true"
                                    v-model="inputModel.EmployeeNames"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    :searchable="true"
                                    ref="employeeNamesDropdown"
                                />
                            </div>
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
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="archiveCodesDropdown"
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
                            <label>{{ t('reports.archiveEntity1') }}</label>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox textField">
                                <div class="width100Percent">
                                    <text-field
                                        :label="t('reports.archiveEntity1')"
                                        :hideLabelInField="true"
                                        v-model="inputModel.ArchiveEntityNumber"
                                        :disabled="inputNullCheckboxesModel.archiveEntityNumber === true"
                                        :validation="
                                            inputNullCheckboxesModel.archiveEntityNumber === false ? 'required' : ''
                                        "
                                    ></text-field>
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.archiveEntityNumber"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.dateFrom') }}</label>
                                    <DatePicker
                                        :label="t('reports.dateFrom')"
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
                                    <label>{{ t('reports.dateTo') }}</label>
                                    <DatePicker
                                        :label="t('reports.dateTo')"
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
                                <label>{{ t('reports.process') }}</label>
                                <Dropdown
                                    v-if="processes"
                                    :label="t('reports.process')"
                                    name="fldProcess"
                                    :items="processes"
                                    :multiselect="true"
                                    v-model="inputModel.Process"
                                    :selectAllText="t('common.selectAll')"
                                    :selectAllTextExternal="t('common.selectAllISDA')"
                                    ref="processesDropdown"
                                />
                            </div>
                            <label>{{ t('reports.kmfNumber') }}</label>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox textField">
                                <div class="width100Percent">
                                    <text-field
                                        :label="t('reports.kmfNumber')"
                                        :hideLabelInField="true"
                                        v-model="inputModel.KmfNumber"
                                        :disabled="inputNullCheckboxesModel.kmfNumber === true"
                                        :validation="inputNullCheckboxesModel.kmfNumber === false ? 'required' : ''"
                                    ></text-field>
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.kmfNumber"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing">
                                <label>{{ t('reports.levelOfDescription') }}</label>
                                <Dropdown
                                    v-if="descriptionLevels"
                                    :label="t('reports.levelOfDescription')"
                                    name="fldLevelOfDescription"
                                    :items="descriptionLevels"
                                    :multiselect="true"
                                    v-model="inputModel.DescriptionLevels"
                                    :selectAllText="t('common.selectAll')"
                                    ref="levelOfDescriptionDropdown"
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
import { defineComponent, ref, onMounted, inject, Ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import {
    UserActionsJournalReport,
    UserActionsJournalReportFiltersModel,
    ReportGridRequestModel,
    ReportGridResponseModel,
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
import { formatDateTime } from '@/helpers/format.helper';
import router from '@/router';
import { RouteLocationRaw } from 'vue-router';
import RowItem from '@/components/grid/rowItem.vue';
export default defineComponent({
    name: 'UserActionsJournalReport',
    emits: ['loadingChange'],
    props: {
        isCanceled: {
            type: Boolean,
            default: false,
        },
    },
    components: { Dropdown, Grid, Form, Breadcrumbs, DatePicker, TextField },
    setup(props, { emit }) {
        onMounted(() => {
            getEmployeeNames();
            getArchiveCodes();
            getProcesses();
            getDescriptionLevels();
        });

        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };
        const rowsPerPageDropdownValues = ref(itemsPerPageDropdownValues);

        const employeeNamesDropdown = ref();
        const employeeNames = ref<IDropdownOption[]>();
        const getEmployeeNames = async () => {
            employeeNames.value = await dropdownService.geEmployeeNamesExternal(true);
        };

        const archiveCodesDropdown = ref();
        const archiveCodes = ref<IDropdownOption[]>();
        const getArchiveCodes = async () => {
            archiveCodes.value = await dropdownService.getArchives();
        };

        const processesDropdown = ref();
        const processes = ref<IDropdownOption[]>();
        const getProcesses = async () => {
            processes.value = await dropdownService.GetProcessesExternal(true);
        };

        const levelOfDescriptionDropdown = ref();
        const descriptionLevels = ref<IDropdownOption[]>();
        const getDescriptionLevels = async () => {
            descriptionLevels.value = await dropdownService.GetDescriptionLevelsExternal(true);
        };

        const clear = () => {
            employeeNamesDropdown.value.clear();
            archiveCodesDropdown.value.clear();
            processesDropdown.value.clear();
            levelOfDescriptionDropdown.value.clear();
            inputModel.value.FundNumber = null;
            inputModel.value.InventoryNumber = null;
            inputModel.value.ArchiveEntityNumber = null;
            inputModel.value.KmfNumber = null;
            inputModel.value.DateFrom = null;
            inputModel.value.DateTo = null;
        };

        const onChange = (option: IDropdownOption) => {
            if (option) {
                employeeNamesDropdown.value?.clear();
                employeeNamesDropdown.value?.setDataSourceType(option.code);
                archiveCodesDropdown.value?.clear();
                archiveCodesDropdown.value?.setDataSourceType(option.code);
                processesDropdown.value?.clear();
                processesDropdown.value?.setDataSourceType(option.code);
                levelOfDescriptionDropdown.value?.clear();
                levelOfDescriptionDropdown.value?.setDataSourceType(option.code);
            }
        };

        const inputNullCheckboxesModel = ref({
            dateFrom: true,
            dateTo: true,
            fundNumber: true,
            inventoryNumber: true,
            archiveEntityNumber: true,
            kmfNumber: true,
        });

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

        watch(
            () => inputNullCheckboxesModel.value,
            (value) => {
                if (value.dateFrom === true) {
                    inputModel.value.DateFrom = null;
                }
                if (value.dateTo === true) {
                    inputModel.value.DateTo = null;
                }
                if (value.fundNumber === true) {
                    inputModel.value.FundNumber = null;
                }
                if (value.inventoryNumber === true) {
                    inputModel.value.InventoryNumber = null;
                }
                if (value.archiveEntityNumber === true) {
                    inputModel.value.ArchiveEntityNumber = null;
                }
                if (value.kmfNumber === true) {
                    inputModel.value.KmfNumber = null;
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
        const inputModel = ref(new UserActionsJournalReportFiltersModel());

        const viewReport = (options: GridOptions) => {
            inputModel.value.DateFrom?.setUTCHours(0, 0, 0);
            inputModel.value.DateTo?.setUTCHours(23, 59, 59);
            emit('loadingChange', true);
            showReport.value = false;
            const gridInputModel = new ReportGridRequestModel<UserActionsJournalReportFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.userActionsJournalReport;

            reportService
                .getUserActionsJournalReport(gridInputModel)
                .then((result: ReportServiceResultModel<ReportGridResponseModel<UserActionsJournalReport>>) => {
                    //gridItems.value = [...result]; // това не е реактивно
                    gridItems.value = [];
                    result.data!.items.forEach((item) => {
                        gridItems.value.push(item);
                    });
                    totalGridRowsCount.value = result.data!.totalCount;

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

        const viewReportOnSubmit = async () => {
            const options = new GridOptions({});
            options.itemsPerPage = inputModel.value.ItemsPerPage;
            await viewReport(options);
            grid.value.setInitialValues(inputModel.value.ItemsPerPage);
        };
        const viewReportOnRefresh = async (options: GridOptions) => await viewReport(options);

        const defaultRowsPerPage = ref(defaultItemsPerPage);
        const loading = ref(false);
        const totalGridRowsCount = ref(0);
        const grid = ref();
        const exportParams = ref();
        const exportOptions = ref();
        const showReport = ref(false);
        const gridItems = ref([] as UserActionsJournalReport[]);

        const headers = ref([
            {
                title: t('reports.archiveName'),
                prop: 'archiveName',
                type: 'string',
            },
            {
                title: t('reports.archiveCode'),
                prop: 'archiveCode',
                type: 'number',
            },
            {
                title: t('reports.levelOfDescription'),
                prop: 'descriptionLevel',
                type: 'string',
            },
            {
                title: t('reports.kmfNumber'),
                prop: 'kmf',
                type: 'string',
            },
            {
                title: t('reports.fund'),
                prop: 'fund',
                type: 'string',
            },
            {
                title: t('reports.inventory'),
                prop: 'inventory',
                type: 'number',
            },
            {
                title: t('reports.archiveEntity1'),
                prop: 'archivalEntity',
                type: 'string',
            },
            {
                title: t('reports.documentSystemIdentifier'),
                prop: 'documentServiceNumber',
                type: 'number',
            },
            {
                title: t('reports.employee'),
                prop: 'employee',
                type: 'string',
            },
            {
                title: t('reports.date'),
                prop: 'date',
                type: 'Date',
                renderFunction: formatDateTime,
            },
            {
                title: t('reports.process'),
                prop: 'process',
                type: 'string',
            },
            {
                title: t('processes.columns.processStep'),
                prop: 'steps',
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
                title: t('reports.userActionsJournalReport'),
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
            employeeNames,
            employeeNamesDropdown,
            descriptionLevels,
            levelOfDescriptionDropdown,
            archiveCodes,
            archiveCodesDropdown,
            processes,
            processesDropdown,
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
