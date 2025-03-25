<template>
    <Loader :isLoading="isLoading" />
    <v-container v-if="showAlert">
        <v-row>
            <v-col>
                <v-alert type="info" closable>{{ t('common.searchCriteria') }}</v-alert>
            </v-col>
        </v-row>
    </v-container>
    <Form @submit="submitClickHandler">
        <v-container>
            <v-row>
                <v-col class="col-12 col-lg-6">
                    <label class="required" for="fldArchive">{{ t('archives.archive') }}</label>
                    <Dropdown
                        v-if="archives"
                        :multiselect="true"
                        :items="archives"
                        name="fldArchive"
                        :required="true"
                        :label="t('archives.archive')"
                        :selectAllText="t('common.selectAll')"
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
                    <text-field v-model="searchModel.searchFileContent" />
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
                        :label="t('globalSearch.countryOfOrigin')"
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
                        hide-details="auto"
                        v-model="searchModel.advancedSearch"
                    />
                </v-col>
                <v-col class="col-12 col-lg-4">
                    <v-checkbox
                        :label="t('globalSearch.fileContentSearch')"
                        hide-details="auto"
                        v-model="searchModel.advancedSearch"
                    />
                </v-col>
                <v-col class="col-12 col-lg-4">
                    <v-checkbox
                        :label="t('globalSearch.foreignarchives')"
                        hide-details="auto"
                        v-model="searchModel.foreignarchives"
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
                <v-col class="col-12 col-lg-6">
                    <label>{{ t('globalSearch.dateTo') }}</label>
                    <DatePicker
                        v-model:date="searchModel.dateTo"
                        :label="t('reports.chronologicalExtentEndDate')"
                    />
                </v-col>
            </v-row>
            <v-row class="mt-3">
                <v-col class="d-flex gap-2 justify-content-center">
                    <v-btn color="primary" type="submit" class="btn-submit">
                        {{ t('common.search') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('common.searchTooltip') }}
                        </v-tooltip>
                    </v-btn>
                    <v-btn color="secondary" @click="btnClearFitersClickHandler">
                        {{ t('common.clear') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('common.clearTooltip') }}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
        </v-container>
    </Form>
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, Ref, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { LocationQueryRaw, useRouter } from 'vue-router';
import { displayMessage } from '@/helpers/notification.helper';
import { returExternalCodesFromInternalCodes } from '@/helpers/report.helper';

import { ResponseResult } from '@/models/responseResult';
import { PageSize } from '@/models/grid';
import { IDropdownOption } from '@/interfaces/dropdown';
import { IMessage } from '@/interfaces/notification';
import { SearchModel } from '@/models/search';
import dropdownService from '@/services/dropdown.service';

import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import Dropdown from '@/components/dropdown/dropdown.vue';
import Pager from '@/components/grid/pager.vue';
import Loader from '@/components/loader/loader.vue';
import DatePicker from '@/components/datetime/datepPicker.vue';

export default defineComponent({
    name: "SearchForm",
    components: {
        Dropdown,
        TextField,
        DatePicker,
        Form,
        Pager,
        Loader,
    },
    props: {
        
    },
    emits: ['submit', 'clearSearch'],
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const router = useRouter();

        const isLoading = ref<boolean>(false);
        const showAlert = ref<boolean>(false);
        const searchModel = ref<SearchModel>(new SearchModel({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.ten,
            sortByType: '',
        }));

        const searchByDigitalCopyArray = ref<IDropdownOption[]>([]);
        searchByDigitalCopyArray.value.push(
            {
                id: 1,
                code: '1',
                label: 'Да',
            },
            { id: 2, code: '2', label: 'Не' }
        );

        const archives = ref<IDropdownOption[]>();
        const getArchives = async () => {
            isLoading.value = true;
            try {
                archives.value = await dropdownService.getArchivesInternalAndExternal(message);
            } catch (error: unknown) {
                console.error(error);
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            } finally {
                isLoading.value = false;
            }
        };

        const fundArrays = ref<IDropdownOption[]>();
        const getFundArrays = async () => {
            isLoading.value = true;
            try {
                fundArrays.value = await dropdownService.getFundArraysInternalAndExternal(message);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            } finally {
                isLoading.value = false;
            }
        };

        const cmfNomenclatures = ref<IDropdownOption[]>();
        const getCmfNomenlatures = async () => {
            isLoading.value = true;
            try {
                cmfNomenclatures.value = await dropdownService.getFilmCountries();
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            } finally {
                isLoading.value = false;
            }
        };

        const descriptionLevels = ref<IDropdownOption[]>();
        const getDescriptionLevels = async () => {
            isLoading.value = true;
            try {
                descriptionLevels.value = await dropdownService.getAllDescLevelsForPublicSearch();
                descriptionLevels.value.forEach((element) => {
                    if (element.label == 'КМФ картон') {
                        element.code = 'fc_2';
                    }
                });
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                displayMessage(message, errorResult.showMessage ? errorResult.message : t('error.basic'));
            } finally {
                isLoading.value = false;
            }
        };

        const splitCodes = () => {
            if (descriptionLevels?.value) {
                (searchModel.value.descriptionLevelCodeExternal as string[]) = returExternalCodesFromInternalCodes(
                    searchModel.value.descriptionLevelCode as string[],
                    descriptionLevels?.value || []
                );
            }
            if (fundArrays?.value) {
                (searchModel.value.fundArrayCodeExternal as string[]) = returExternalCodesFromInternalCodes(
                    searchModel.value.fundArrayCode as string[],
                    fundArrays?.value || []
                );
            }
        };

        const setRouteQuery = () => {
            let query: LocationQueryRaw = {};
            query.aI = searchModel.value.archiveId;
            query.dLC = searchModel.value.descriptionLevelCode;
            query.fN = searchModel.value.fundNumber;
            query.iN = searchModel.value.inventoryNumber;
            query.aN = searchModel.value.archivalEntityNumber;
            query.cmfC = searchModel.value.cmfCountriesOfOriginCodes;
            query.cmfN = searchModel.value.cmfNumber;
            
            if (searchModel.value.advancedSearch) {
                query.advancedSearch = String(searchModel.value.advancedSearch);
            }
            
            query.byDigitalCopyArray = searchModel.value.searchByDigitalCopies;
            query.fndArr = searchModel.value.fundArrayCode;
            query.name = searchModel.value.name;
            query.keyWords = searchModel.value.keyWords;
            query.dF = searchModel.value.dateFrom?.toString();
            query.dT = searchModel.value.dateTo?.toString();
            query.page = searchModel.value.page;
            query.itemsPerPage = searchModel.value.itemsPerPage;

            if (searchModel.value.foreignarchives) {
                query.foreignarchives = String(searchModel.value.foreignarchives);
            }

            router.replace({ query: query});
            
            console.log(router.currentRoute.value.query);
        };

        const setSearchFiltersByQuery = () => {
            if (router.currentRoute.value.query.aI) {
                var model = router.currentRoute.value.query;
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
                searchModel.value.foreignarchives = model.foreignarchives == 'true' ? true : undefined;
                searchModel.value.searchByDigitalCopies = model.byDigitalCopyArray?.toString();
                // if (model.byDigitalCopyArray) {
                //     if (Array.isArray(model.byDigitalCopyArray)) {
                //         searchModel.value.searchByDigitalCopies = model.byDigitalCopyArray as string[];
                //     } else {
                //         searchModel.value.searchByDigitalCopies?.push(model['byDigitalCopyArray'] as string);
                //     }
                // }
                if (model.byDigitalCopyArray) {
                    if (Array.isArray(model.fndArr)) {
                        searchModel.value.fundArrayCode = model.fndArr as string[];
                    } else {
                        searchModel.value.fundArrayCode?.push(model['fndArr'] as string);
                    }
                }
                searchModel.value.name = model.name as string;
                searchModel.value.keyWords = model.keyWords as string;
                if (model.dF) {
                    searchModel.value.dateFrom = new Date(model.dF as string);
                }
                if (model.dT) {
                    searchModel.value.dateTo = new Date(model.dT as string);
                }
                //get grid options by query
                // pagerOptions.value.itemsPerPage = Number.parseInt(model.itemsPerPage as string);
                // pagerOptions.value.page = Number.parseInt(model.page as string);

                // getSearchResultsData(pagerOptions.value);
            } else {
                if (localStorage.getItem('searchModel'))
                    searchModel.value = JSON.parse(localStorage.getItem('searchModel')!.toString());
                if (searchModel.value.archiveId?.length) {
                    showAlert.value = true;
                    //getSearchResultsData(pagerOptions.value);
                }
            }
        };

        const btnClearFitersClickHandler = () => {
            localStorage.removeItem('searchModel');
            let query = Object.assign({}, router.currentRoute.value.query);
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
            
            getArchives();
            getFundArrays();
            getCmfNomenlatures();
            getDescriptionLevels();
            
            context.emit('clearSearch');
        };

        const submitClickHandler = () => {
            splitCodes();
            localStorage.setItem('searchModel', JSON.stringify(searchModel.value));
            setRouteQuery();
            context.emit('submit', searchModel.value);
        }

        watch(
            () => searchModel?.value?.foreignarchives,
            (val) => {
                if (val == true) {
                    const autoSelectArchive = ref<IDropdownOption[]>();
                    autoSelectArchive.value = archives.value?.filter(
                        (a) => a.label == 'ЦДА (ИСДА)' || a.label == 'ЦДА'
                    );
                    if (autoSelectArchive.value && searchModel.value && autoSelectArchive.value[0]) {
                        searchModel.value.archiveId = [];
                        searchModel.value.archiveId?.push(autoSelectArchive.value[0].code as string);
                    }
                }
            }
        );

        onMounted(() => {
            getFundArrays();
            getCmfNomenlatures();
            getArchives();
            getDescriptionLevels();
            setSearchFiltersByQuery();
        });


        return {
            t,
            isLoading,
            showAlert,
            searchByDigitalCopyArray,
            fundArrays,
            archives,
            searchModel,
            descriptionLevels,
            cmfNomenclatures,
            btnClearFitersClickHandler,
            submitClickHandler,
        }
    },
})
</script>
