<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.fundMemoryReport') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" md="12" lg="12" xl="12" class="flexStart">
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
                                <label for="ItemsPerPage">{{ t('reports.resultsLimit') }}</label>
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
                @refresh="viewReportOnRefresh"
                :noHorizontalScroll="true"
                ref="grid"
                @rowClick="onRowClick"
            />
        </div>
    </v-container>
</template>
<script lang="ts">
import { defineComponent, ref, watch, onMounted, inject, Ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { Form } from 'vee-validate';
import {
    FundMemoryPublicReport,
    ReportGridRequestModel,
    defaultItemsPerPage,
    itemsPerPageDropdownValues,
    ReportServiceResultModel,
    ListFiltersModel,
    FundReportSummary2,
    ReportGridWithSummaryGridResponseModel,
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
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { formatBytesToMB, formatDuration } from '@/helpers/format.helper';
import RowItem from '@/components/grid/rowItem.vue';
import { useRouter } from 'vue-router';
import { RouteLocationRaw } from 'vue-router';

export default defineComponent({
    name: 'FundMemoriesReport',
    emits: ['loadingChange'],
    props: {
        isCanceled: {
            type: Boolean,
            default: false,
        },
    },
    components: { Dropdown, Grid, Form, Breadcrumbs },
    setup(props, { emit }) {
        onMounted(() => {
            getArchives();
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
            archives.value = await dropdownService.getArchives(true);
        };

        const inputModel = ref(new ListFiltersModel());

        const clear = () => {
            archivesDropdown.value.clear();
        };

        watch(
            () => props.isCanceled,
            (value) => {
                if (value) {
                    reportService.cancelAxiosToken();
                }
            }
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

            const gridInputModel = new ReportGridRequestModel<ListFiltersModel>({
                Page: options.page,
                ItemsPerPage: options.itemsPerPage,
                Filters: inputModel.value,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReportType.fundMemory;

            reportService
                .getFundMemoriesPublicReport(gridInputModel)
                .then(
                    (
                        result: ReportServiceResultModel<
                            ReportGridWithSummaryGridResponseModel<FundReportSummary2, FundMemoryPublicReport>
                        >
                    ) => {
                        gridItems.value = [];
                        result.data!.items.forEach((item) => {
                            gridItems.value.push(item);
                        });
                        summaryGridItems.value = [];
                        summaryGridItems.value.push({
                            totalLinearMeters: result.data!.summary!.totalLinearMeters as number,
                            totalRows: result.data?.summary?.totalRows as number,
                            totalSize: result.data?.summary?.totalSize as number,
                        });
                        console.table(summaryGridItems.value);
                        totalGridRowsCount.value = result.data!.totalCount;

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

        const viewReportOnSubmit = () => {
            const options = new GridOptions({});
            options.itemsPerPage = inputModel.value.ItemsPerPage;
            viewReport(options);
            grid.value.setInitialValues(inputModel.value.ItemsPerPage);
        };
        const viewReportOnRefresh = (options: GridOptions) => viewReport(options);

        const showReport = ref(false);
        const gridItems = ref([] as FundMemoryPublicReport[]);
        const headers = ref([
            {
                title: t('reports.number'),
                prop: 'number',
                type: 'string',
            },
            {
                title: t('reports.registerDate'),
                prop: 'creationDate',
                type: 'string',
            },
            {
                title: t('reports.authorNameAndWhereComesFrom'),
                prop: 'immediateSourceOfAcquisitionPlusMethodOfAcquisition',
                type: 'string',
            },
            {
                title: t('reports.title'),
                prop: 'title',
                type: 'string',
            },
            {
                title: t('reports.creationTehnique'),
                prop: 'creatingType',
                type: 'string',
            },
            {
                title: t('reports.volumeLinearMeters'),
                prop: 'linearMeters',
                type: 'number',
            },
            {
                title: t('reports.volumeMB1'),
                prop: 'digitalSize',
                type: 'bytes',
                renderFunction: formatBytesToMB,
            },
            {
                title: t('reports.note'),
                prop: 'note',
                type: 'string',
            },
            {
                title: t('reports.duration'),
                prop: 'duration',
                type: 'duration',
                renderFunction: formatDuration,
            },
            {
                title: t('reports.fileTypes'),
                prop: 'fileTypes',
                type: 'string',
            },
        ]);

        const summaryGridItems = ref([] as FundReportSummary2[]);
        const summaryHeaders = ref([
            {
                title: t('reports.memoriesCount'),
                prop: 'totalRows',
                type: 'int',
            },
            {
                title: t('reports.linearMeters'),
                prop: 'totalLinearMeters',
                type: 'number',
            },
            {
                title: t('reports.volumeMB'),
                prop: 'totalSize',
                type: 'number',
                renderFunction: formatBytesToMB,
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
                title: t('reports.fundMemoryReport'),
                disabled: true,
            },
        ]);

        return {
            t,
            fieldSpacing,
            summaryHeaders,
            inputModel,
            summaryGridItems,
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
            archivesDropdown,
            archives,
            clear,
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
