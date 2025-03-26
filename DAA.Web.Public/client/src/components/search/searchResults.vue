<template>
    <Loader :showCancel="true" @cancel="btnCancelClickHandler" :isLoading="isLoading" />
    <v-row v-if="searchResultsData.items">
        <v-col>
            <v-list class="justify-content-start" variant="text">
                <v-list-item
                    v-for="item in searchResultsData.items"
                    :key="item"
                    :to="{
                        name: getRouteName(item.entityType, item.hasExternalSource),
                        params:
                            item.entityType === 'film_card' && !item.hasExternalSource
                                ? {
                                        id: item.systemIdentifier,
                                        filmId: item.filmSystemIdentifier,
                                    }
                                : {
                                        id: item.systemIdentifier,
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
                        {{ item.statusText }}
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
    <v-row v-if="searchResultsData.items.length" class="justify-content-center">
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
    <v-row v-if="searchResultsData.items.length" class="justify-content-center">
        <v-col class="ml-5" style="font-weight: bold">
            <span>{{ t('globalSearch.resultsFound') }} {{ searchResultsData.totalCount }}</span>
        </v-col>
    </v-row>
    <v-row v-if="showMessageForEmptyResult" class="justify-content-center">
        <v-col style="font-weight: bold">
            {{ t('search.emptyResult') }}
        </v-col>
    </v-row>
</template>
<script lang="ts">
import { defineComponent, ref } from 'vue'

import { GridOptions, PageSize } from '@/models/grid';

export default defineComponent({
    name: "SearchResults",
    setup() {

        const isLoading = ref<boolean>(false);
        
        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.ten,
            sortByType: '',
        });
        
        // const changePage = async (pageNumber: number, pageSize: number) => {
        //     pagerOptions.value.page = pageNumber;
        //     pagerOptions.value.itemsPerPage = pageSize;

        //     await getFundInventoryData();
        // };

        // const totalPages = computed(() => {
        //     const total =
        //         inventoryData.value.totalCount < pagerOptions.value.itemsPerPage
        //             ? 1
        //             : Math.ceil(inventoryData.value.totalCount / pagerOptions.value.itemsPerPage);
        //     return total;
        // });

        return {
            isLoading,
            pagerOptions,
        }
    },
})
</script>
