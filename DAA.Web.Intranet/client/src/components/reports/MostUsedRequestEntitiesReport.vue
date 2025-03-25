<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.mostUsedRequestEntitiesReport') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart">
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
                                <label class="required">{{ t('reports.archive') }}</label>
                                <Dropdown
                                    v-if="archives"
                                    :label="t('reports.archive')"
                                    name="fldArchive"
                                    required="required"
                                    :items="archives"
                                    :multiselect="true"
                                    v-model="inputModel.Archives"
                                    :selectAllText="t('common.selectAll')"
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
                        </v-col>

                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart">
                            <div :class="fieldSpacing">
                                <label>{{ t('reports.levelOfDescription') }}</label>
                                <Dropdown
                                    v-if="descriptionLevels"
                                    :label="t('reports.levelOfDescription')"
                                    name="fldLevelOfDescription"
                                    :items="descriptionLevels"
                                    :multiselect="true"
                                    v-model="inputModel.descriptionLevels"
                                    :selectAllText="t('common.selectAll')"
                                    ref="levelOfDescriptionDropdown"
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
                        </v-col>
                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart">
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
                            <label>{{ t('reports.document') }}</label>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox textField">
                                <div class="width100Percent">
                                    <text-field
                                        :label="t('reports.document')"
                                        :hideLabelInField="true"
                                        v-model="inputModel.DocumentNumber"
                                        :disabled="inputNullCheckboxesModel.documentNumber === true"
                                        :validation="
                                            inputNullCheckboxesModel.documentNumber === false ? 'required' : ''
                                        "
                                    ></text-field>
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.documentNumber"
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
            <div class="totalCount">
                <span class="bold">{{ t('reports.totalCount') }}:</span> {{ usageCountTotal }}
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
import { defineComponent, ref, onMounted, watch, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import {
    MostUsedRequestEntitiesReportModel,
    MostUsedRequestEntitiesReportFiltersModel,
    ReportGridRequestModel,
    ReportGridResponseModel1,
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
    name: 'MostUsedRequestEntitiesReport',
    emits: ['loadingChange'],
    props: {
        isCanceled: {
            type: Boolean,
            default: false,
        },
    },
    components: { Dropdown, Grid, Form, TextField, Breadcrumbs },
    setup(_, { emit }) {
        onMounted(() => {
            getArchives();
            getReportResultTypes();
            getDescriptionLevels();
        });

        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };
        const rowsPerPageDropdownValues = itemsPerPageDropdownValues;

        const archivesDropdown = ref();
        const archives = ref<IDropdownOption[]>();
        const getArchives = async () => {
            archives.value = await dropdownService.getArchives();
        };

        const reportResultTypes = ref<IDropdownOption[]>();
        const getReportResultTypes = async () => {
            reportResultTypes.value = await dropdownService.getReportResultTypes();
        };

        const levelOfDescriptionDropdown = ref();
        const descriptionLevels = ref<IDropdownOption[]>();
        const getDescriptionLevels = async (reportResultType = ReportResultType.BothDBs) => {
            try {
                descriptionLevels.value = await dropdownService.getFundInventoryAEDocumentDescLevels(reportResultType);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

        const clear = () => {
            levelOfDescriptionDropdown.value.clear();
        };

        watch(
            () => _.isCanceled,
            (value) => {
                if (value) {
                    reportService.cancelAxiosToken();
                }
            }
        );
        const inputModel = ref(new MostUsedRequestEntitiesReportFiltersModel());
        const defaultRowsPerPage = ref(defaultItemsPerPage);
        const loading = ref(false);
        const totalGridRowsCount = ref(0);
        const usageCountTotal = ref(0);
        const grid = ref();
        const exportParams = ref();
        const exportOptions = ref();

        const viewReport = (options: GridOptions) => {
            emit('loadingChange', true);
            showReport.value = false;
            if (inputModel.value.ReportResultType == ReportResultType.BothDBs) {
                splitCodes();
            }

            const gridInputModel = new ReportGridRequestModel<MostUsedRequestEntitiesReportFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.mostUsedRequestEntitiesReport;
            reportService
                .getMostUsedRequestEntitiesReport(gridInputModel)
                .then(
                    (
                        result: ReportServiceResultModel<ReportGridResponseModel1<MostUsedRequestEntitiesReportModel>>
                    ) => {
                        //gridItems.value = [...result]; // това не е реактивно
                        gridItems.value = [];
                        result.data!.items.forEach((item) => {
                            gridItems.value.push(item);
                        });
                        totalGridRowsCount.value = result.data!.totalCount;
                        usageCountTotal.value = result.data!.usageCountTotal;

                        showReport.value = true;

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

        const splitCodes = () => {
            (inputModel.value.descriptionLevelsExternal as string[]) = returExternalCodesFromInternalCodes(
                inputModel.value.descriptionLevels as string[],
                descriptionLevels.value!
            );
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

        const showReport = ref(false);
        const gridItems = ref([] as MostUsedRequestEntitiesReportModel[]);
        const headers = ref([
            {
                title: t('reports.archive'),
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
                title: t('reports.inventoryNumber'),
                prop: 'inventoryNumber',
                type: 'string',
            },
            {
                title: t('reports.archiveEntityNumber'),
                prop: 'archiveEntityNumber',
                type: 'string',
            },
            {
                title: t('reports.documentNumber'),
                prop: 'documentNumber',
                type: 'string',
            },
            {
                title: t('reports.timesUsed'),
                prop: 'usageCount',
                type: 'int',
            },
        ]);

        const inputNullCheckboxesModel = ref({
            fundNumber: true,
            inventoryNumber: true,
            archiveEntityNumber: true,
            documentNumber: true,
        });
        watch(
            () => inputNullCheckboxesModel.value,
            (value) => {
                if (value.fundNumber === true) {
                    inputModel.value.FundNumber = null;
                }
                if (value.inventoryNumber === true) {
                    inputModel.value.InventoryNumber = null;
                }
                if (value.archiveEntityNumber === true) {
                    inputModel.value.ArchiveEntityNumber = null;
                }
                if (value.documentNumber === true) {
                    inputModel.value.DocumentNumber = null;
                }
            },
            { deep: true }
        );

        const onChange = (option: IDropdownOption) => {
            if (option) {
                levelOfDescriptionDropdown.value?.clear();
                getDescriptionLevels(option.code as number);
            }
        };

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
                title: t('reports.mostUsedRequestEntitiesReport'),
                disabled: true,
            },
        ];

        return {
            t,
            fieldSpacing,
            inputModel,
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
            archives,
            reportResultTypes,
            descriptionLevels,
            inputNullCheckboxesModel,
            archivesDropdown,
            levelOfDescriptionDropdown,
            clear,
            onChange,
            usageCountTotal,
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
