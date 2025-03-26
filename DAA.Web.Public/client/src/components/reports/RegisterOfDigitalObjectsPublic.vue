<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.registerOfDigitalObjects') }}</h3>
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
                                <label class="required">{{ t('reports.digitalObjectStatus') }}</label>
                                <Dropdown
                                    v-if="digitalObjectStatuses"
                                    :label="t('reports.digitalObjectStatus')"
                                    name="fldDigitalObjectStatus"
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
                        </v-col>
                        <v-col col="12" sm="12" md="12" lg="6" xl="6" class="flexStart">
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox">
                                <div class="width100Percent">
                                    <label>{{ t('reports.createdFrom') }}</label>
                                    <DatePicker
                                        :label="t('reports.createdFrom')"
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
                                    <label>{{ t('reports.createdTo') }}</label>
                                    <DatePicker
                                        :label="t('reports.createdTo')"
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
                            <label>{{ t('reports.functionalId') }}</label>
                            <div :class="fieldSpacing" class="reportFieldwithCheckbox textField">
                                <div class="width100Percent">
                                    <text-field
                                        :label="t('reports.functionalId')"
                                        :hideLabelInField="true"
                                        v-model="inputModel.SystemId"
                                        :disabled="inputNullCheckboxesModel.systemId === true"
                                        :validation="inputNullCheckboxesModel.systemId === false ? 'required' : ''"
                                    ></text-field>
                                </div>
                                <v-checkbox class="reportNullCheckbox"
                                    v-model="inputNullCheckboxesModel.systemId"
                                    :label="t('reports.null')"
                                ></v-checkbox>
                            </div>
                            <div :class="fieldSpacing">
                                <label for="ItemsPerPage">{{ t('reports.resultsLimit') }}</label>
                                <Dropdown
                                    name="ItemsPerPage"
                                    labelProp="text"
                                    :items="rowsPerPageDropdownValues"
                                    v-model="inputModel.ItemsPerPage"
                                    :defaultValue="defaultRowsPerPage"
                                />
                            </div>
                            <v-checkbox
                                v-model="showSummaryOnly"
                                :label="t('reports.statisticalDataOnly')"
                            ></v-checkbox>
                        </v-col>
                    </v-row>
                    <v-row justify="center">
                        <v-btn class="mr-4" type="submit" :disabled="false">
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
            <div v-show="mainGridLoaded">
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
        </div>
    </v-container>
</template>
<script lang="ts">
import { defineComponent, ref, watch, onMounted, inject, Ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import {
    ReportGridWithSummaryGridResponseModel,
    RegisterOfDigitalObjectsPublicReport,
    RegisterOfDigitalObjectsReportFiltersModel,
    ReportGridRequestModel,
    RegisterOfDigitalObjectsReportSummary,
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
import RowItem from '@/components/grid/rowItem.vue';
import { useRouter } from 'vue-router';
import { displayMessage } from '@/helpers/notification.helper';
import { RouteLocationRaw } from 'vue-router';

export default defineComponent({
    name: 'RegisterOfDigitalObjects',
    components: { Dropdown, Grid, DatePicker, Form, TextField, Breadcrumbs },
    emits: ['loadingChange'],
    props: {
        isCanceled: {
            type: Boolean,
            default: false,
        },
    },
    setup(props, { emit }) {
        onMounted(() => {
            getDigitalObjectStatuses();
            getArchives();
        });

        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };
        const rowsPerPageDropdownValues = itemsPerPageDropdownValues;

        const digitalObjectStatusesDropdown = ref();
        const digitalObjectStatuses = ref<IDropdownOption[]>();

        const getDigitalObjectStatuses = () => {
            try {
                digitalObjectStatuses.value = dropdownService.getDocumentObjectStatuses(true);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            }
        };

        const archivesDropdown = ref();
        const archives = ref<IDropdownOption[]>();
        const getArchives = async () => {
            archives.value = await dropdownService.getArchives(true);
        };

        const inputModel = ref<RegisterOfDigitalObjectsReportFiltersModel>(
            new RegisterOfDigitalObjectsReportFiltersModel()
        );
        const inputNullCheckboxesModel = ref(new ReportFiltersNullCheckboxesModel());

        const clear = () => {
            digitalObjectStatusesDropdown.value.clear();
            archivesDropdown.value.clear();

            inputModel.value.RegisteredFrom = null;
            inputModel.value.RegisteredTo = null;
            inputModel.value.SystemId = null;
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
                if (value.systemId === true) {
                    inputModel.value.SystemId = null;
                }
            },
            { deep: true }
        );

        const router = useRouter();

        const onRowClick = (row: typeof RowItem) => {
        const route: RouteLocationRaw = {
                name: 'DisplayDocument',
            };
            
            if (row.items.systemId) {
                route.params = {
                    id: row.items.systemId,
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
        const showSummaryOnly = ref(true);
        const exportParams = ref();
        const exportOptions = ref();

        const viewReport = (options: GridOptions) => {
            emit('loadingChange', true);
            showReport.value = false;
            const gridInputModel = new ReportGridRequestModel<RegisterOfDigitalObjectsReportFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });

            if (showSummaryOnly.value) {
                reportService
                    .getRegisterOfDigitalObjectsPublicReportSummary(gridInputModel)
                    .then((result: ReportServiceResultModel<RegisterOfDigitalObjectsReportSummary>) => {
                        summaryGridItems.value = [];
                        summaryGridItems.value.push(result.data!);

                        showReport.value = true;
                        mainGridLoaded.value = false;

                        processMetadata(result.metadata);
                    })
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
            } else {
                exportOptions.value = gridInputModel.Filters;
                exportParams.value = ReportType.registerOfDigitalObjects;

                reportService
                    .getRegisterOfDigitalObjectsPublicReport(gridInputModel)
                    .then(
                        (
                            result: ReportServiceResultModel<
                                ReportGridWithSummaryGridResponseModel<
                                    RegisterOfDigitalObjectsReportSummary,
                                    RegisterOfDigitalObjectsPublicReport
                                >
                            >
                        ) => {
                            gridItems.value = [];
                            summaryGridItems.value = [];
                            result.data!.items.forEach((item) => {
                                item.duration = formatDuration(Number.parseInt(item.duration as string) || 0);
                                gridItems.value.push(item);
                            });
                            totalGridRowsCount.value = result.data!.totalCount;

                            // result.data!.summary!.totalDuration = formatDuration(
                            //     Number.parseInt(result.data!.summary!.totalDuration as string) || 0
                            // );

                            summaryGridItems.value.push(result.data!.summary!);

                            showReport.value = true;
                            mainGridLoaded.value = true;

                            processMetadata(result.metadata);
                        }
                    )
                    .catch((error: unknown) => {
                        const errorResult = error as ResponseResult;
                        let text: string | undefined;
                        if (errorResult.message == undefined && errorResult.showMessage == undefined) {
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
            }
        };

        const viewReportOnSubmit = () => {
            const options = new GridOptions({});
            options.itemsPerPage = inputModel.value.ItemsPerPage;
            viewReport(options);
            grid.value.setInitialValues(inputModel.value.ItemsPerPage);
        };

        const viewReportOnRefresh = (options: GridOptions) => viewReport(options);

        const tdClick = (rowItem: { column: string; rowItems: { documentLink: string } }) => {
            if (rowItem.column === 'documentLink' && rowItem.rowItems.documentLink) {
                window.open(rowItem.rowItems.documentLink, '_blank');
            }
        };

        const showReport = ref(false);
        const mainGridLoaded = ref(false);
        const gridItems = ref([] as RegisterOfDigitalObjectsPublicReport[]);
        const headers = ref([
            {
                title: t('reports.archiveCode'),
                prop: 'archiveCode',
                type: 'int',
            },
            // {
            //     title: t('reports.documentLink'),
            //     prop: '',
            //     type: 'vue',
            //     template: (e: RegisterOfDigitalObjectsPublicReport) => {
            //         return {
            //             template: HyperlinkTemplate,
            //             templateArgs: {
            //                 ...e,
            //                 formatter: (item: RegisterOfDigitalObjectsPublicReport | undefined) => {
            //                     return [
            //                         new HyperlinkInfo({
            //                             title: t('reports.documentLinktitle'),
            //                             href: item!.documentLink,
            //                             target: '_blank',
            //                         }),
            //                     ];
            //                 },
            //             },
            //         };
            //     },
            //     sortable: false,
            //     filterable: false,
            // },
            {
                title: t('reports.archiveName'),
                prop: 'archiveName',
                type: 'string',
            },
            {
                title: t('reports.documentFunctionalId'),
                prop: 'systemId',
                type: 'int',
            },
            {
                title: t('reports.unitOfDescriptionOnFundLevel'),
                prop: 'levelOfDescription',
                type: 'string',
            },
            {
                title: t('reports.fundNumberMemory'),
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
            // todo: Махни изличните данни listNumbers, които идват до тук
            // От Архивите иската да се махне
            // {
            //     title: t('reports.listNumbers'),
            //     prop: 'listNumbers',
            //     type: 'string',
            // },
            {
                title: t('reports.documentTitle'),
                prop: 'documentTitle',
                type: 'string',
            },
            {
                title: t('reports.documentCreationDate'),
                prop: 'chronologicalScope',
                type: 'string',
            },
            {
                title: t('reports.digitalObjectCreationDate'),
                prop: 'digitalObjectCreationDate',
                type: 'string',
            },
            // todo: Махни изличните данни masterImagesCountInDigitalObject, които идват до тук
            // От Архивите иската да се махне
            // {
            //     title: t('reports.masterImagesCountInDigitalObject'),
            //     prop: 'imageCount',
            //     type: 'int',
            // },
            {
                title: t('reports.duration'),
                prop: 'duration',
                type: 'duration',
            },
            {
                title: t('reports.sizeOfDigitalObjectInMB'),
                prop: 'bytesCount',
                renderFunction: formatBytesToMB,
                type: 'bytes',
            },
        ]);

        const summaryGridItems = ref([] as RegisterOfDigitalObjectsReportSummary[]);
        const summaryHeaders = ref([
            {
                title: t('reports.digitalObjectsCount'),
                prop: 'totalRows',
                type: 'int',
            },
            {
                title: t('reports.masterImagesCount'),
                prop: 'totalImageCount',
                type: 'int',
            },
            {
                title: t('reports.sizeInMB'),
                prop: 'totalBytesCount',
                type: 'int',
                renderFunction: formatBytesToMB,
            },
            {
                title: t('reports.duration'),
                prop: 'totalDuration',
                renderFunction: formatDuration,
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
                title: t('reports.registerOfDigitalObjects'),
                disabled: true,
            },
        ]);

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
            mainGridLoaded,
            exportParams,
            exportOptions,
            rowsPerPageDropdownValues,
            digitalObjectStatuses,
            archives,
            digitalObjectStatusesDropdown,
            archivesDropdown,
            clear,
            tdClick,
            summaryHeaders,
            summaryGridItems,
            showSummaryOnly,
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
