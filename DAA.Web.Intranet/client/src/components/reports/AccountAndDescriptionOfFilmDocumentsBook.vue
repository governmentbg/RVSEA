<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid class="overflowX">
        <!-- <v-card>
    <v-card-text> -->
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <div>
                <h3 class="display-6">{{ t('reports.AccountAndDescriptionOfFilmDocumentsBook') }}</h3>
                <Form @submit="viewReportOnSubmit">
                    <v-row align="center">
                        <v-col col="12" sm="12" xl="12" class="col-divs">
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
    AccountAndDescriptionOfFilmDocumentsBook,
    ListFiltersModel,
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
import { Message } from '@/models/notification';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import router from '@/router';
import { RouteLocationRaw } from 'vue-router';
import RowItem from '@/components/grid/rowItem.vue';

export default defineComponent({
    name: 'AccountAndDescriptionOfFilmDocumentsBook',
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
            getReportResultTypes();
            getArchives();
        });

        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const fieldSpacing = {
            'pb-2 pr-4 reportFieldHeight': true,
        };
        const rowsPerPageDropdownValues = itemsPerPageDropdownValues;

        const reportResultTypes = ref<IDropdownOption[]>();
        const getReportResultTypes = async () => {
            reportResultTypes.value = await dropdownService.getReportResultTypes();
        };

        const archivesDropdown = ref();
        const archives = ref<IDropdownOption[]>();
        const getArchives = async () => {
            archives.value = await dropdownService.getArchives();
        };

        const inputModel = ref(new ListFiltersModel());

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
            exportParams.value = ReportType.accountAndDescriptionOfFilmDocumentsBook;
            watch(
                () => props.isCanceled,
                (value) => {
                    if (value) {
                        reportService.cancelAxiosToken();
                    }
                }
            );
            reportService
                .getAccountAndDescriptionOfFilmDocumentsBook(gridInputModel)
                .then(
                    (
                        result: ReportServiceResultModel<
                            ReportGridResponseModel<AccountAndDescriptionOfFilmDocumentsBook>
                        >
                    ) => {
                        //gridItems.value = [...result]; // това не е реактивно
                        gridItems.value = [];
                        result.data!.items.forEach((item) => {
                            gridItems.value.push(item);
                        });
                        totalGridRowsCount.value = result.data!.totalCount;

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
        const viewReportOnSubmit = () => {
            const options = new GridOptions({});
            options.itemsPerPage = inputModel.value.ItemsPerPage;
            viewReport(options);
            grid.value.setInitialValues(inputModel.value.ItemsPerPage);
        };
        const viewReportOnRefresh = (options: GridOptions) => viewReport(options);

        const clear = () => {
            archivesDropdown.value.clear();
        };

        const onRowClick = (row: typeof RowItem) => {
            const route: RouteLocationRaw = {
                name: 'DisplayFilm',
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

        const showReport = ref(false);
        const gridItems = ref([] as AccountAndDescriptionOfFilmDocumentsBook[]);
        const headers = ref([
            {
                title: t('reports.dateYear'),
                prop: 'receivedOn',
                type: 'string',
            },
            // {
            //     title: t('reports.xxx'),
            //     prop: 'title',
            //     type: 'xxx',
            // },
            {
                title: t('reports.foundAndSubmittedBy'),
                prop: 'creationAuthor',
                type: 'string',
            },
            // {
            //     title: t('reports.xxx'),
            //     prop: 'оригинал/копие',
            //     type: 'xxx',
            // },
            {
                title: t('reports.nameOfInstitutionOrPersonSubmittedFilm'),
                prop: 'immediateSourceOfAcquisition',
                type: 'string',
            },
            {
                title: t('reports.nationality'),
                prop: 'countryOfOrigin',
                type: 'string',
            },
            // {
            //     title: t('reports.xxx'),
            //     prop: 'documentsCharacteristics',
            //     type: 'xxx',
            // },
            // {
            //     title: t('reports.xxx'),
            //     prop: 'съпроводителна текстова документация',
            //     type: 'xxx',
            // },
            // {
            //     title: t('reports.xxx'),
            //     prop: 'документ, въз основа на който е приет',
            //     type: 'xxx',
            // },
            {
                title: t('reports.relatedToFundNumberInventoryNumberArchiveEntity'),
                prop: 'fundNumberAndInventoryAndArchiveEntiry',
                type: 'string',
            },
            // {
            //     title: t('reports.xxx'),
            //     prop: 'наличие на застрахователно копие/вид носител',
            //     type: 'xxx',
            // },
            {
                title: t('reports.note'),
                prop: 'note',
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

        const breadcrumbItems = ref([
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
                title: t('reports.AccountAndDescriptionOfFilmDocumentsBook'),
                disabled: true,
            },
        ]);

        return {
            t,
            fieldSpacing,
            inputModel,
            breadcrumbItems,
            loading,
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
            reportResultTypes,
            archives,
            archivesDropdown,
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
