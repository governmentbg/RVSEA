<template>
    <Loader :showCancel="true" @cancel="cancleSearchClickHandler" :isLoading="isLoading" />
    <search-card v-if="!awaitData" class="mx-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('navigation.top.search') }}</v-card-title>
        <v-container v-if="showAlert">
            <v-row>
                <v-col>
                    <v-alert type="info" closable>{{ t('common.searchCriteria') }}</v-alert>
                </v-col>
            </v-row>
        </v-container>
        <Form @submit="goSearch">
            <v-container>
                <v-row>
                    <v-col class="col-12 col-lg-6">
                        <label class="required" for="fldArchive">{{ t('inventories.columns.archive') }}</label>
                        <Dropdown
                            v-if="archives"
                            :items="archives"
                            name="fldArchive"
                            :multiselect="true"
                            :label="t('archives.archive')"
                            :selectAllText="t('common.selectAll')"
                            :required="true"
                            v-model="searchModel.archiveId"
                        />
                    </v-col>
                    <v-col class="col-12 col-lg-6">
                        <label>{{ t('globalSearch.descLevel') }}</label>
                        <Dropdown
                            v-if="descriptionLevels"
                            :multiselect="true"
                            :label="t('globalSearch.descLevel')"
                            :selectAllText="t('common.selectAll')"
                            :items="descriptionLevels"
                            v-model="searchModel.descriptionLevelCode"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12 col-lg-4">
                        <label>{{ t('globalSearch.fundNumber') }}</label>
                        <text-field v-model="searchModel.fundNumber" />
                    </v-col>
                    <v-col class="col-12 col-lg-4">
                        <label>{{ t('globalSearch.inventoryyNumber') }}</label>
                        <text-field v-model="searchModel.inventoryNumber" />
                    </v-col>
                    <v-col class="col-12 col-lg-4">
                        <label>{{ t('globalSearch.archivalEntityNumber') }}</label>
                        <text-field v-model="searchModel.archivalEntityNumber" />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12 col-lg-6">
                        <label>{{ t('globalSearch.countryOfOrigin') }}</label>
                        <Dropdown
                            v-if="cmfNomenclatures"
                            :items="cmfNomenclatures"
                            :selectAllText="t('common.selectAll')"
                            :multiselect="true"
                            v-model="searchModel.cmfCountriesOfOriginCodes"
                        />
                    </v-col>
                    <v-col class="col-12 col-lg-6">
                        <label>{{ t('globalSearch.cmfNumber') }}</label>
                        <text-field v-model="searchModel.cmfNumber" />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12 col-lg-4">
                        <v-checkbox
                            :label="t('globalSearch.advancedSearch')"
                            v-model="searchModel.advancedSearch"
                            hide-details="auto"
                        />
                    </v-col>
                    <v-col class="col-12 col-lg-4">
                        <v-checkbox
                            :label="t('globalSearch.fileContentSearch')"
                            hide-details="auto"
                            v-model="searchModel.searchFileContent"
                        />
                    </v-col>
                    <v-col class="col-12 col-lg-4">
                        <v-checkbox
                            :label="t('globalSearch.foreignarchives')"
                            v-model="searchModel.foreignArchives"
                            hide-details="auto"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12 col-lg-6">
                        <label>{{ t('globalSearch.searchByDigitalCopies') }}</label>
                        <Dropdown
                            :label="t('globalSearch.searchByDigitalCopies')"
                            :items="searchByDigitalCopyArray"
                            v-model="searchModel.searchByDigitalCopies"
                        />
                    </v-col>
                    <v-col v-if="fundArrays" class="col-12 col-lg-6">
                        <label>{{ t('globalSearch.fundArray') }}</label>
                        <Dropdown
                            :label="t('globalSearch.fundArray')"
                            :selectAllText="t('common.selectAll')"
                            :multiselect="true"
                            :items="fundArrays"
                            v-model="searchModel.fundArrayCode"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12 col-lg-6">
                        <label>{{ t('globalSearch.name') }}</label>
                        <text-field v-model="searchModel.name" />
                    </v-col>
                    <v-col class="col-12 col-lg-6">
                        <label>{{ t('globalSearch.keyWords') }}</label>
                        <text-field class="textField" v-model="searchModel.keyWords" />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12 col-lg-6">
                        <label>{{ t('globalSearch.dateFrom') }}</label>
                        <DatePicker
                            v-model:date="searchModel.dateFrom"
                            :label="t('reports.chronologicalExtentEndDate')"
                        />
                    </v-col>
                    <v-col cclass="col-12 col-lg-6">
                        <label>{{ t('globalSearch.dateTo') }}</label>
                        <DatePicker
                            v-model:date="searchModel.dateTo"
                            :label="t('reports.chronologicalExtentEndDate')"
                        />
                    </v-col>
                </v-row>
                <v-row class="mt-3">
                    <v-col class="d-flex gap-2 justify-content-center">
                        <submit-btn type="submit">
                            {{ t('common.search') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('common.searchTooltip') }}
                            </v-tooltip>
                        </submit-btn>
                        <cancel-btn @click="clearCriteria">
                            {{ t('common.clear') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('common.clearTooltip') }}
                            </v-tooltip>
                        </cancel-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
    </search-card>
    <v-container class="mx-auto search-results">
        <v-row v-if="searchResultsData.items">
            <v-col>
                <v-list class="justify-content-start" variant="text">
                    <v-list-item
                        v-for="item in searchResultsData.items"
                        :key="item"
                        :to="{
                            name: getRouteName(item.entityType!, item.hasExternalSource),
                            params: {
                                id: item.systemIdentifier,
                                filmId: item.filmSystemIdentifier,
                            },
                            query: {
                                hasExternalSource: item.hasExternalSource,
                                externalIdentifier: item.externalIdentifier,
                            },
                        }"
                    >
                        <v-list-item-title>
                            {{
                                t(`searchTemplates.${item.entityType}.0`, {
                                    ...title(item, 0),
                                })
                            }}
                        </v-list-item-title>
                        <v-list-item-title>
                            {{
                                t(`searchTemplates.${item.entityType}.1`, {
                                    ...title(item, 1),
                                })
                            }}
                        </v-list-item-title>
                        <v-list-item-title v-if="showListItemTitle2(item)">
                            {{
                                t(`searchTemplates.${item.entityType}.2`, {
                                    ...title(item, 2),
                                })
                            }}
                        </v-list-item-title>
                        <v-list-item-title v-if="showListItemTitle3(item)">
                            {{
                                t(`searchTemplates.${item.entityType}.3`, {
                                    ...title(item, 3),
                                })
                            }}
                        </v-list-item-title>
                        <v-list-item-title v-if="showListItemTitle4(item)">
                            {{
                                t(`searchTemplates.${item.entityType}.4`, {
                                    ...title(item, 4),
                                })
                            }}
                        </v-list-item-title>
                        <v-list-item-subtitle>
                            {{ item.statusText }}{{ showListItemTitle4(item) == true && item.hasDigitizedDigitalObjects == true ? ' / ' + t('documents.activeDigitalObject') : ''}}
                        </v-list-item-subtitle>
                    </v-list-item>
                </v-list>
            </v-col>
        </v-row>

        <v-row v-else class="justify-content-center">
            <v-col>
                {{ t('search.emptyResult') }}
            </v-col>
        </v-row>
        <v-row v-if="!awaitData && searchResultsData.items.length" dense class="justify-content-center">
            <v-col>
                <Pager
                    :totalPages="totalPages"
                    :initialPage="pagerOptions.page"
                    :initialPageSize="pagerOptions.itemsPerPage"
                    @change="changePage"
                    ref="pager"
                ></Pager>
            </v-col>
        </v-row>
        <v-row v-if="!awaitData && searchResultsData.items.length" dense class="justify-content-center">
            <v-col style="text-align:center; font-weight: bold">
                {{ t('globalSearch.resultsFound') }} {{ searchResultsData.totalCount }}
            </v-col>
        </v-row>
        <v-row v-if="showMessageForEmptyResult" dense class="justify-content-center">
            <v-col style="text-align:center; font-weight: bold">
                {{ t('search.emptyResult') }}
            </v-col>
        </v-row>
    </v-container>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, watch, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import Dropdown from '@/components/dropdown/dropdown.vue';
import { IDropdownOption } from '@/interfaces/dropdown';
import dropdownService from '@/services/dropdown.service';
import TextField from '@/components/field/text.field.vue';
import { Form } from 'vee-validate';
import { SearchModel } from '@/models/search';
import DatePicker from '@/components/datetime/datepPicker.vue';
import { GridOptions, GridResponseModel, PageSize } from '@/models/grid';
import { ResponseResult } from '@/models/responseResult';
//import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ISearchResult } from '@/interfaces/searchResult';
import searchService from '@/services/globalSearch.service';
import router from '@/router';
import Pager from '@/components/grid/pager.vue';
import Loader from '@/components/loader/loader.vue';
import { ReportResultType } from '@/enums/reports';
import { returExternalCodesFromInternalCodes } from '@/helpers/report.helper';
import { displayMessage } from '@/helpers/notification.helper';
//import { AbortError } from '@microsoft/signalr';

export default defineComponent({
    components: {
        Dropdown,
        TextField,
        DatePicker,
        Form,
        Pager,
        Loader,
    },
    name: 'SearchEngine',
    setup() {
        const panel = ref('items');
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const descriptionLevels = ref<IDropdownOption[]>();
        const cmfNomenclatures = ref<IDropdownOption[]>();
        const searchModel = ref<SearchModel>(new SearchModel());
        const isLoading = ref(false);
        const totalPages = ref(0);
        const awaitData = ref(true);
        const searchByDigitalCopyArray = ref<IDropdownOption[]>([]);
        const showAlert = ref(false);
        const showMessageForEmptyResult = ref(false);

        searchByDigitalCopyArray.value.push(
            {
                id: 1,
                code: '1',
                label: 'Да',
            },
            { id: 2, code: '2', label: 'Не' }
        );

        const defaultItemsPerPage = PageSize.ten;

        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: defaultItemsPerPage,
            sortByType: '',
        });

        const initialOptions = new GridOptions({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: defaultItemsPerPage,
            sortByType: '',
        });

        const showListItemTitle2 = (item: ISearchResult) => {
            return ['document', 'archival_entity', 'inventory'].includes(item.entityType!);
        };
        const showListItemTitle3 = (item: ISearchResult) => {
            return ['document', 'archival_entity', 'film_card'].includes(item.entityType!);
        };
        const showListItemTitle4 = (item: ISearchResult) => {
            return ['document'].includes(item.entityType!);
        };

        const title = (item: ISearchResult, rowIndex: number) => {
            if (item) {
                let rows = [];
                switch (item.entityType) {
                    case 'fund':
                        rows = [
                            { archiveName: item.archiveName },
                            {
                                fundDescriptionLevelText: item.fundDescriptionLevelText,
                                fundNumber: item.fundNumber,
                                title: item.title,
                                chronologicalScope: item.fundApproximateChronologicalScope
                                    ? `(${item.fundApproximateChronologicalScope})`
                                    : '',
                            },
                        ];
                        return rows[rowIndex];
                    case 'inventory':
                        rows = [
                            { archiveName: item.archiveName },
                            {
                                fundNumber: item.fundNumber,
                                fundDescriptionLevelText: item.fundDescriptionLevelText,
                                title: item.title,
                            },
                            {
                                inventoryNumber: item.inventoryNumber,
                                inventoryDescriptionLevelText: item.inventoryDescriptionLevelText,
                                chronologicalScope: item.inventoryApproximateChronologicalScope
                                    ? `(${item.inventoryApproximateChronologicalScope})`
                                    : '',
                            },
                        ];
                        return rows[rowIndex];
                    case 'archival_entity':
                        rows = [
                            { archiveName: item.archiveName },
                            {
                                fundDescriptionLevelText: item.fundDescriptionLevelText,
                                fundNumber: item.fundNumber,
                            },
                            {
                                inventoryNumber: item.inventoryNumber,
                                inventoryDescriptionLevelText: item.inventoryDescriptionLevelText,
                            },
                            {
                                archivalEntityNumber: item.archivalEntityNumber,
                                archivalEntityDescriptionLevelText: item.archivalEntityDescriptionLevelText,
                                title: item.title,
                                chronologicalScope: item.archivalEntityApproximateChronologicalScope
                                    ? `(${item.archivalEntityApproximateChronologicalScope})`
                                    : '',
                            },
                        ];
                        return rows[rowIndex];
                    case 'document':
                        rows = [
                            { archiveName: item.archiveName },
                            { fundNumber: item.fundNumber },
                            { inventoryNumber: item.inventoryNumber },
                            { archivalEntityNumber: item.archivalEntityNumber },
                            { 
                                documentNumber: item.documentNumber,
                                title: item.title 
                            },
                        ];
                        return rows[rowIndex];
                    case 'film':
                        rows = [
                            { archiveName: item.archiveName },
                            {
                                fundDescriptionLevelText: item.externalIdentifier
                                    ? item.fundDescriptionLevelText
                                    : 'КМФ',
                                kmfNumber: item.hasExternalSource && item.externalIdentifier 
                                    ? item.fundNumber 
                                    : item.kmfNumber,
                            },
                        ];
                        return rows[rowIndex];
                    case 'film_card':
                        rows = [
                            { archiveName: item.archiveName },
                            {
                                fundDescriptionLevelText: item.hasExternalSource && item.externalIdentifier
                                    ? item.fundDescriptionLevelText
                                    : 'КМФ',
                                kmfNumber: item.hasExternalSource && item.externalIdentifier 
                                    ? item.fundNumber 
                                    : item.kmfNumber,
                            },
                            {
                                inventoryNumber: item.inventoryNumber,
                                inventoryDescriptionLevelText: item.inventoryDescriptionLevelText,
                                n: item.externalIdentifier ? '№' : '',
                            },
                            {
                                archivalEntityNumber: item.archivalEntityNumber,
                                archivalEntityDescriptionLevelText: item.archivalEntityDescriptionLevelText,
                                title: item.title,
                                chronologicalScope: item.fundApproximateChronologicalScope
                                    ? `(${item.fundApproximateChronologicalScope})`
                                    : '',
                                n: item.externalIdentifier ? '№' : '',
                            },
                        ];
                        return rows[rowIndex];
                }
            }
        };

        const getRouteName = (enityType: string, hasExternalSource?: boolean) => {
            let result = '';
            switch (enityType) {
                case 'fund':
                    result = 'DisplayFund';
                    break;
                case 'inventory':
                    result = 'DisplayInventory';
                    break;
                case 'archival_entity':
                    result = 'DisplayArchiveEntity';
                    break;
                case 'document':
                    result = 'DisplayDocument';
                    break;
                case 'film':
                    if (hasExternalSource) {
                        result = 'DisplayFund';
                    } else {
                        result = 'DisplayFilm';
                    }
                    break;
                case 'film_card':
                    if (hasExternalSource) {
                        result = 'DisplayArchiveEntity';
                    } else {
                        result = 'DisplayFilmCard';
                    }
                    break;
            }

            return result;
        };

        const archives = ref<IDropdownOption[]>();

        const getArchives = async () => {
            archives.value = await dropdownService.getArchives();
        };
        const fundArrays = ref<IDropdownOption[]>();

        const getFundArrays = async () => {
            fundArrays.value = await dropdownService.getFundArraysInternalAndExternal();
        };
        const getCmfNomenlatures = async () => (cmfNomenclatures.value = await dropdownService.getFilmCountries());

        const getDescriptionLevels = async () => {
            descriptionLevels.value = await dropdownService.getFundInventoryAEDocumentDescLevels(
                ReportResultType.BothDBs
            );
            descriptionLevels.value.forEach((element) => {
                if (element.label == 'КМФ картон') {
                    element.code = 'fc_2';
                }
            });
        };

        const searchResultsData = ref<GridResponseModel<ISearchResult>>(
            new GridResponseModel<ISearchResult>({ totalCount: 0, items: [] })
        );
        const pager = ref();

        const getSearchResultsData = async (options: GridOptions, changePage = false) => {
            try {
                showMessageForEmptyResult.value = false;
                if (searchModel.value) {
                    searchModel.value.sortBy = options.sortBy;
                    searchModel.value.sortDesc = options.sortDesc;
                    searchModel.value.page = options.page;
                    searchModel.value.itemsPerPage = options.itemsPerPage;
                    searchModel.value.sortByType = options.sortByType;
                }

                let itemsPerPage = pagerOptions.value.itemsPerPage;
                if (!changePage && pager.value) {
                    pager.value.goToPage(1);
                    pager.value.setPageSize(defaultItemsPerPage);
                    itemsPerPage = defaultItemsPerPage;
                }
                splitCodes();
                searchResultsData.value = await searchService.getResultFromSearchCriteria(searchModel.value);

                if (!searchResultsData.value.items.length) {
                    showMessageForEmptyResult.value = true;
                }

                totalPages.value =
                    searchResultsData.value.totalCount < pagerOptions.value.page
                        ? 1
                        : Math.ceil(searchResultsData.value.totalCount / itemsPerPage);

                isLoading.value = false;
                showAlert.value = false;
                //ТРЯБВА ДА БЪДЕ СЛЕД  РЕЗУЛТАТА !
                updateUrl();
            } catch (error: unknown) {
                console.log('aborted', searchService.abortSignal.aborted);
                if (searchService.abortSignal.aborted) {
                    //const cancelResult = error as AbortError;
                    displayMessage(message, t('common.cancelSearch'), 'warning');
                } else {
                    const errorResult = error as ResponseResult;
                    console.log(errorResult);
                    displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
                }
                // if (errorResult.message == 'Timeout') {
                //     text = t('globalSearch.timeout');
                // } else if (errorResult.message == undefined && errorResult.showMessage == undefined) {
                //     text = t('common.cancelSearch');
                // } else {
                //     text = errorResult.showMessage ? errorResult.message : t('error.basic');
                // }
                // message.value = new Message({
                //     text: text,
                //     display: true,
                // });
            } finally {
                isLoading.value = false;
            }
        };
        const splitCodes = () => {
            if (descriptionLevels.value) {
                (searchModel.value.descriptionLevelCodeExternal as string[]) = returExternalCodesFromInternalCodes(
                    searchModel.value.descriptionLevelCode as string[],
                    descriptionLevels.value!
                );
            }
            if (fundArrays.value) {
                (searchModel.value.fundArrayCodeExternal as string[]) = returExternalCodesFromInternalCodes(
                    searchModel.value.fundArrayCode as string[],
                    fundArrays.value!
                );
            }
        };
        const goSearch = () => {
            isLoading.value = true;
            getSearchResultsData(initialOptions);
            localStorage.setItem('searchModel', JSON.stringify(searchModel.value));
        };

        const clearCriteria = () => {
            localStorage.removeItem('searchModel');
            const query = Object.assign({}, router.currentRoute.value.query);
            delete query.aI;
            delete query.dLC;
            delete query.fN;
            delete query.iN;
            delete query.aN;
            delete query.cmfC;
            delete query.cmfN;
            delete query.advancedSearch;
            delete query.foreignarchives;
            delete query.byDigitalCopyArray;
            delete query.fndArr;
            delete query.name;
            delete query.keyWords;
            delete query.dF;
            delete query.dT;
            delete query.page;
            delete query.itemsPerPage;
            router.replace({ query: {} });
            searchModel.value = new SearchModel();
            searchResultsData.value = new GridResponseModel<ISearchResult>();
            getArchives();
            getFundArrays();
            getDescriptionLevels();
            getCmfNomenlatures();
            showMessageForEmptyResult.value = false;
        };

        watch(
            () => searchModel.value.foreignArchives,
            (val) => {
                if (val == true) {
                    const selectedArchive = archives.value?.find(a => a.label == 'ЦДА')
                    if (selectedArchive && searchModel.value) {
                        searchModel.value.archiveId = [];
                        searchModel.value.archiveId.push(selectedArchive.code as string);
                    }

                    const selectedDescriptionLevels = descriptionLevels.value?.filter(dl => dl.label!.indexOf('КМФ') > -1);
                    if (selectedDescriptionLevels && selectedDescriptionLevels.length > 0 && searchModel.value) {
                        searchModel.value.descriptionLevelCode = selectedDescriptionLevels.map(dl => dl.code as string);
                    } 
                }
            }
        );

        const changePage = async (pageNumber: number, pageSize: number) => {
            pagerOptions.value.page = pageNumber;
            pagerOptions.value.itemsPerPage = pageSize;
            isLoading.value = true;
            await getSearchResultsData(pagerOptions.value, true);
        };

        const cancleSearchClickHandler = () => {
            //searchService.cancelAxiosToken();
            searchService.abort();
            localStorage.removeItem('searchModel');
            router.replace({ query: {} });
        };

        onMounted(() => {
            getFundArrays();
            getCmfNomenlatures();
            getArchives();
            getDescriptionLevels();
        });

        const setSearchCriteriaByQuery = () => {
            if (router.currentRoute.value.query.aI) {
                const model = router.currentRoute.value.query;
                if (model.aI) {
                    if (Array.isArray(model.aI)) {
                        searchModel.value.archiveId = model.aI as string[];
                    } else {
                        searchModel.value.archiveId?.push(model['aI'] as string);
                    }
                }
                if (model.dLC) {
                    if (Array.isArray(model.dLC)) {
                        searchModel.value.descriptionLevelCode = model.dLC as string[];
                    } else {
                        searchModel.value.descriptionLevelCode?.push(model['dLC'] as string);
                    }
                }
                searchModel.value.fundNumber = model.fN as string;
                searchModel.value.inventoryNumber = model.iN as string;
                searchModel.value.archivalEntityNumber = model.aN as string;
                if (model.cmfC) {
                    if (Array.isArray(model.cmfC)) {
                        searchModel.value.cmfCountriesOfOriginCodes = model.cmfC as string[];
                    } else {
                        searchModel.value.cmfCountriesOfOriginCodes?.push(model['cmfC'] as string);
                    }
                }
                searchModel.value.cmfNumber = model.cmfN as string;
                searchModel.value.advancedSearch = model.advancedSearch == 'true' ? true : undefined;
                searchModel.value.foreignArchives = model.foreignarchives == 'true' ? true : undefined;
                searchModel.value.searchByDigitalCopies = model.byDigitalCopyArray?.toString();
                // if (model.byDigitalCopyArray) {
                //     if (Array.isArray(model.fndArr)) {
                //         searchModel.value.fundArrayCode = model.fndArr as string[];
                //     } else {
                //         searchModel.value.fundArrayCode?.push(model['fndArr'] as string);
                //     }
                // }
                searchModel.value.name = model.name as string;
                searchModel.value.keyWords = model.keyWords as string;
                if (model.dF) {
                    searchModel.value.dateFrom = new Date(model.dF as string);
                }
                if (model.dT) {
                    searchModel.value.dateTo = new Date(model.dT as string);
                }
                //get grid options by query
                pagerOptions.value.itemsPerPage = Number.parseInt(model.itemsPerPage as string);
                pagerOptions.value.page = Number.parseInt(model.page as string);

                getSearchResultsData(pagerOptions.value);
            } else {
                searchModel.value =
                    JSON.parse(localStorage.getItem('searchModel') as string) ?? new SearchModel();
                if (searchModel.value.archiveId?.length) {
                    showAlert.value = true;
                    getSearchResultsData(pagerOptions.value);
                }
            }
        };

        const updateUrl = () => {
            if (searchModel.value.advancedSearch == true) {
                router.replace({
                    query: {
                        aI: searchModel.value.archiveId,
                        dLC: searchModel.value.descriptionLevelCode,
                        fN: searchModel.value.fundNumber,
                        iN: searchModel.value.inventoryNumber,
                        aN: searchModel.value.archivalEntityNumber,
                        cmfC: searchModel.value.cmfCountriesOfOriginCodes,
                        cmfN: searchModel.value.cmfNumber,
                        advancedSearch: searchModel.value.advancedSearch == true ? 'true' : null,
                        byDigitalCopyArray: searchModel.value.searchByDigitalCopies,
                        fndArr: searchModel.value.fundArrayCode,
                        name: searchModel.value.name,
                        keyWords: searchModel.value.keyWords,
                        dF: searchModel.value.dateFrom?.toString(),
                        dT: searchModel.value.dateTo?.toString(),
                        page: searchModel.value.page,
                        itemsPerPage: searchModel.value.itemsPerPage,
                    },
                });
            } else if (searchModel.value.foreignArchives == true) {
                router.replace({
                    query: {
                        aI: searchModel.value.archiveId,
                        dLC: searchModel.value.descriptionLevelCode,
                        fN: searchModel.value.fundNumber,
                        iN: searchModel.value.inventoryNumber,
                        aN: searchModel.value.archivalEntityNumber,
                        cmfC: searchModel.value.cmfCountriesOfOriginCodes,
                        cmfN: searchModel.value.cmfNumber,
                        foreignarchives: searchModel.value.foreignArchives == true ? 'true' : null,
                        byDigitalCopyArray: searchModel.value.searchByDigitalCopies,
                        fndArr: searchModel.value.fundArrayCode,
                        name: searchModel.value.name,
                        keyWords: searchModel.value.keyWords,
                        dF: searchModel.value.dateFrom?.toString(),
                        dT: searchModel.value.dateTo?.toString(),
                        page: searchModel.value.page,
                        itemsPerPage: searchModel.value.itemsPerPage,
                    },
                });
            } else if (searchModel.value.foreignArchives && searchModel.value.advancedSearch) {
                router.replace({
                    query: {
                        aI: searchModel.value.archiveId,
                        dLC: searchModel.value.descriptionLevelCode,
                        fN: searchModel.value.fundNumber,
                        iN: searchModel.value.inventoryNumber,
                        aN: searchModel.value.archivalEntityNumber,
                        cmfC: searchModel.value.cmfCountriesOfOriginCodes,
                        cmfN: searchModel.value.cmfNumber,
                        advancedSearch: searchModel.value.advancedSearch == true ? 'true' : null,
                        foreignarchives: searchModel.value.foreignArchives == true ? 'true' : null,
                        byDigitalCopyArray: searchModel.value.searchByDigitalCopies,
                        fndArr: searchModel.value.fundArrayCode,
                        name: searchModel.value.name,
                        keyWords: searchModel.value.keyWords,
                        dF: searchModel.value.dateFrom?.toString(),
                        dT: searchModel.value.dateTo?.toString(),
                        page: searchModel.value.page,
                        itemsPerPage: searchModel.value.itemsPerPage,
                    },
                });
            } else {
                router.replace({
                    query: {
                        aI: searchModel.value.archiveId,
                        dLC: searchModel.value.descriptionLevelCode,
                        fN: searchModel.value.fundNumber,
                        iN: searchModel.value.inventoryNumber,
                        aN: searchModel.value.archivalEntityNumber,
                        cmfC: searchModel.value.cmfCountriesOfOriginCodes,
                        cmfN: searchModel.value.cmfNumber,
                        byDigitalCopyArray: searchModel.value.searchByDigitalCopies,
                        fndArr: searchModel.value.fundArrayCode,
                        name: searchModel.value.name,
                        keyWords: searchModel.value.keyWords,
                        dF: searchModel.value.dateFrom?.toString(),
                        dT: searchModel.value.dateTo?.toString(),
                        page: searchModel.value.page,
                        itemsPerPage: searchModel.value.itemsPerPage,
                    },
                });
            }
        };

        watch(
            () => descriptionLevels?.value?.length,
            (val) => {
                if (val! > 1) {
                    setSearchCriteriaByQuery();
                    awaitData.value = false;
                }
            }
        );

        return {
            t,
            clearCriteria,
            goSearch,
            changePage,
            pagerOptions,
            panel,
            totalPages,
            searchByDigitalCopyArray,
            fundArrays,
            archives,
            awaitData,
            searchModel,
            cancleSearchClickHandler,
            descriptionLevels,
            cmfNomenclatures,
            isLoading,
            searchResultsData,
            title,
            showAlert,
            showListItemTitle2,
            showListItemTitle3,
            showListItemTitle4,
            getRouteName,
            showMessageForEmptyResult,
            pager,
        };
    },
});
</script>

<style lang="scss" scoped>
@media screen and (width > 960px) {
    .v-card,
    .search-results {
        width: 75%;
    }
}
.v-card {
    border-radius: 6px;
    border-width: 1px;
}

.v-list-item:hover {
    color: var(--ISDA-main-color4);
}

.v-list-item-subtitle {
    font-style: italic;
    color: #783b08;
}

.pager {
    justify-content: center;
}

// div.v-container > div.v-container {
//     color: var(--ISDA-main-color1);
//     //max-width: 1500px !important;
// }

// h3 {
//     margin: auto;
//     margin-bottom: 30px;
//     width: 70%;
//     padding: 10px;
//     color: var(--ISDA-main-color1);
//     border-bottom: 2px solid var(--ISDA-main-color1);
// }

// form {
//     padding: 20px;
//     margin: auto;
//     margin-bottom: 20px;
//     width: 70%;
//     border-radius: 6px;
//     box-shadow: gray 0px 0px 3px 0px;
//     background-color: var(--ISDA-main-color2-1);
//     text-align: left !important;
// }

// button {
//     margin-right: 20px;
// }

// .btn-submit {
//     background-color: var(--ISDA-main-color4);
//     color: white;
// }

// .btn-cancel {
//     background-color: var(--ISDA-main-color1);
//     color: white;
// }

// .textAlignLeft {
//     text-align: left;
// }

// .v-list-item {
//     display: block;
//     margin-right: 0px !important;
// }

// .subtitle {
//     font-size: 0.875rem;
//     font-weight: 400;
//     letter-spacing: 0.0178571429em;
//     line-height: 1rem;
//     text-transform: none;
//     font-style: italic;
//     color: #783b08;
// }

// .small-row {
//     margin-bottom: -40px;
//     position: relative;
// }

// :deep(div:has(.v-list)) {
//     width: 100%;
//     margin: auto;
// }

// :deep(.v-list) > a {
//     margin-bottom: 5px;
//     //margin-right: 50px;
//     //background-color: var(--ISDA-main-color2);
//     border-bottom: 1px solid rgb(213, 213, 213) !important; //var(--ISDA-main-color1) !important;
// }

:deep(.page-link) {
    color: rgb(var(--v-theme-on-surface));
}

:deep(.active a) {
    color: rgb(var(--v-theme-on-primary));
    background-color: rgb(var(--v-theme-primary));
    border-color: rgba(var(--v-border-color));
}

:deep(.col-md-5) {
    padding: 0px 1px !important;
}

// :deep(.text-left.active a) {
//     background-color: var(--ISDA-main-color2-1) !important;
//     color: var(--ISDA-main-color4) !important;
// }

// :deep(.col-md-5) {
//     padding: 1px;
// }

// :deep(.align-items-baseline) {
//     height: 40px !important;
//     padding-right: 15px;
//     border-radius: 6px;
//     box-shadow: gray 0px 1px 3px 0px;
// }

// :deep(.col-md-12 > div:nth-of-type(2)) {
//     margin-top: 20px;
// }

// :deep(.mx-3) {
//     background-color: white !important;
//     color: var(--ISDA-main-color1) !important;
//     box-shadow: none !important;
//     border: 1px solid lightgray;
// }

// :deep(#btnExportGrid) {
//     color: var(--ISDA-main-color1) !important;
//     background-color: white !important;
// }

// :deep(.multiselect-tag) {
//     background-color: 'primary';
// }

// :deep(.firstCol) {
//     background-color: var(--ISDA-main-color2) !important;
//     color: var(--ISDA-main-color1) !important;
//     font-weight: bold;
// }

// :deep(li.is-selected) {
//     background-color: var(--ISDA-main-color4) !important;
// }

// :deep(.form-select) {
//     border: none !important;
// }

// :deep(.v-field__input) {
//     margin-bottom: 0px;
//     margin-top: -19px;
// }

// :deep(.v-field__clearable) {
//     padding-top: 6px;
// }

// :deep(.multiselect) {
//     min-height: 38px;
// }

// @media screen and (max-width: 960px) {
//     .colSm {
//         flex: 0 0 100%;
//         max-width: 100%;
//     }
// }

// @media screen and (max-width: 500px) {
//     .colTiny {
//         flex: 0 0 100%;
//         max-width: 100%;
//     }

//     .small-row div {
//         margin-bottom: -20px;
//     }

//     .small-row + div {
//         margin-top: 40px;
//     }
// }

// :deep(.v-checkbox .v-checkbox-btn) {
//     width: -webkit-fill-available;
// }

// :deep(.v-checkbox .v-label) {
//     white-space: normal;
//     max-width: fit-content;
// }

// :deep(.v-checkbox-btn) {
//     height: auto;
// }

// .results {
//     width: 80%;
// }
</style>
