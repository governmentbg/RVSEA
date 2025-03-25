<template>
    <Loader :isLoading="isLoading" />
    <div class="row"></div>
    <div class="row">
        <div class="py-3 col-md">
            <slot name="menubar"></slot>
        </div>
        <div class="py-3 col-md-2" style="display: flex; justify-content: flex-end">
            <button
                v-if="showExport"
                type="button"
                id="btnExportGrid"
                :title="$t('common.exportToExcel')"
                class="btn btn-light mb-2 dropdown-toggle"
                data-bs-toggle="dropdown"
                aria-expanded="false"
            >
                {{ $t('common.exportTo') }}
            </button>
            <ul class="dropdown-menu">
                <li><a class="dropdown-item" href="#" @click="exportData('xlsx')">Excel</a></li>
                <li><a class="dropdown-item" href="#" @click="exportData('csv')">CSV</a></li>
                <li v-if="showWordAndPdfExport">
                    <a class="dropdown-item" href="#" @click="exportData('pdf')">PDF</a>
                </li>
                <li><a class="dropdown-item" href="#" @click="exportData('xml')">XML</a></li>
                <li v-if="showWordAndPdfExport">
                    <a class="dropdown-item" href="#" @click="exportData('word')">Word</a>
                </li>
            </ul>
        </div>
        <div class="py-3 col-md-3" v-if="showSearch">
            <form @submit.prevent="onSearchStringKeyUp">
                <div class="input-group mb-3">
                    <input
                        type="text"
                        class="form-control shadow-none"
                        v-model="dataSource.searchString"
                        :placeholder="searchLabel"
                    />
                    <button
                        class="btn btn-outline-secondary"
                        type="submit"
                        id="button-addon2"
                        v-tooltip="$t('grid.search.tooltip')"
                    >
                        <i class="fa fa-search"></i>
                    </button>
                </div>
            </form>
        </div>
    </div>
    <div class="col-md-12">
        <div class="table-responsive" :class="{ noHorizontalScroll: noHorizontalScroll }">
            <table class="table table-hover" :class="gridClass">
                <grid-header
                    :cols="columns"
                    :sortKey="sortKey"
                    :rowNumbers="rowNumbers"
                    @apply-filter="applyFilter"
                    @clear-filter="clearFilter"
                    @sort="sortBy"
                ></grid-header>
                <tbody v-if="!isLoading">
                    <tr
                        class="pointer"
                        :class="[{ highlighted: row.prop?.highlighted === 'true' || '' }, (row.prop?.class || '')]"
                        v-for="(row, index) in dataSource.data"
                        :key="index"
                        @click="onRowClick(row)"
                    >
                        <td v-if="rowNumbers">
                            {{ (currentPage - 1) * currentPageSize + index + 1 }}
                        </td>
                        <td
                            v-for="(key, index) in columns.filter((key, index) => key.visible != false)"
                            :key="index"
                            v-bind:class="['text-' + key.textAlign, key.titleClass]"
                        >
                            <row-item :col="key" :row="row" @click="onRowItemClick(row, index)"> </row-item>
                        </td>
                    </tr>
                </tbody>
                <!-- <tr v-if="isLoading">
                    <td colspan="10000">
                        <div class="loader"></div>
                    </td>
                </tr> -->
                <tr v-if="!isLoading && dataSource.data.length === 0">
                    <td colspan="10000">
                        <div class="text-danger">{{ localNoDataMessage }}</div>
                    </td>
                </tr>
            </table>
        </div>
        <pager
            v-if="hasPaging"
            :total-pages="totalPages"
            :initial-page="currentPage"
            :initialPageSize="currentPageSize"
            @change="onPageChange"
            ref="pager"
        ></pager>
    </div>
</template>

<script>
import Column from './models/column';
import customFilters from './models/filters';
import Pager from './pager.vue';
import DataSource from './models/data-source';
import RowItem from './rowItem.vue';
import GridHeader from './header.vue';
import modes from './models/modes';
import { base64ToBlob } from '@/helpers/blob.helper';
import { returnWordFromHtml } from '@/helpers/word.helper';
import { GridColumn, PageSize, ExportMode, GridOptions, BusinessObjectType } from '@/models/grid';
import gridService from '@/services/grid.service';
import Loader from '@/components/loader/loader.vue';

// import Vue from "vue";
// import { library } from "@fortawesome/fontawesome-svg-core";
// import {
//   faSort,
//   faSortUp,
//   faSortDown,
//   faFilter,
// } from "@fortawesome/free-solid-svg-icons";

// import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";

// library.add([faSort, faSortUp, faSortDown, faFilter]);
// Vue.component("font-awesome-icon", FontAwesomeIcon);

export default {
    name: 'grid',
    components: {
        Pager,
        RowItem,
        GridHeader,
        Loader,
    },
    emits: ['refresh', 'rowClick', 'error', 'tdClick'],
    props: {
        items: Array,
        columns: Array,
        hasRowButtons: { type: Boolean, default: false },
        rowNumbers: { type: Boolean, default: false },
        paging: { type: Boolean, default: false },
        pageSize: { type: Number, default: PageSize.ten },
        baseUrl: String,
        mode: {
            type: String,
            default: modes.local,
        },
        totalItems: { type: Number, required: false, default: 0 },
        searchLabel: String,
        showLoading: { type: Boolean, default: false },
        noDataMessage: { type: String, default: '' },
        exportMode: {
            type: String,
            default: ExportMode.currentPage,
        },
        businessObjectType: {
            type: String,
            default: BusinessObjectType.unknown,
        },
        showExport: { type: Boolean, default: true },
        exportParams: { type: undefined, default: '' },
        exportOptions: { type: GridOptions },
        showSearch: { type: Boolean, default: true },
        page: { type: Number, default: 1 },
        rowHighlighting: { type: Boolean, default: false },
        gridClass: {
            type: String,
            default: 'table-bordered',
        },
        noHorizontalScroll: { type: Boolean, default: false },
        showWordAndPdfExport: { type: Boolean, default: true },
    },
    data: function () {
        return {
            sortKey: '',
            sortKeyType: '',
            data: [],
            cols: [],
            rows: [],
            currentPage: 1,
            dataSource: DataSource,
            currentSortObject: null,
            currentPageSize: PageSize.ten,
            totalItemsCount: 0,
            isLoading: true,
            hasPaging: false,
            highlightedRowItemId: undefined,
            localNoDataMessage: '',
        };
    },
    filters: {
        ...customFilters,
    },
    methods: {
        init() {
            this.localNoDataMessage = this.noDataMessage;
            if (!this.localNoDataMessage) {
                this.localNoDataMessage = this.$t('common.noDataMessage');
            }

            this.dataSource = new DataSource();

            const queryString = location.href.split('?')[1];

            if (queryString) {
                //TODO Parse query string and set data source params
            }

            this.dataSource.mode = this.mode;
            this.dataSource.emitError = this.onError;
            this.currentPageSize = this.pageSize;

            if (this.paging) {
                this.dataSource.paging = true;
                this.dataSource.pageSize = this.currentPageSize;
                // make sure that the pager is rendered only after we know the initial page size
                this.hasPaging = this.paging;
                this.currentPage = 1;
            }

            //set columns
            this.columns.forEach((item) => {
                this.cols.push(new Column(item));
            });

            if (this.showLoading) {
                this.isLoading = true;
            }

            if (this.mode === modes.remote) {
                this.dataSource.baseUrl = this.baseUrl;
                this.dataSource.setData(null);
            } else {
                this.dataSource.setData(this.items);
            }
        },
        sortBy(sortObject) {
            this.currentSortObject = sortObject;
            this.sortKey = sortObject.key;
            this.sortKeyType = sortObject.type;

            if (this.mode === modes.custom) {
                this.dataSource.setSort(sortObject.key, sortObject.direction, sortObject.type);
                this.refreshData();
            } else {
                this.dataSource
                    .sort(sortObject.key, sortObject.direction, sortObject.type)
                    .then(() => this.$refs.pager.goToPage(1))
                    .catch((err) => console.error(err));
            }
        },
        onRowClick(row) {
            this.$emit('rowClick', row);
            if (this.rowHighlighting) {
                this.highlightRow(row);
            }
        },
        highlightRow(row) {
            const previousHighlightedRowItemId = this.highlightedRowItemId;
            if (this.highlightedRowItemId === row.items.id) {
                row.prop.highlighted = false;
                this.highlightedRowItemId = undefined;
            } else {
                if (previousHighlightedRowItemId !== undefined) {
                    // reverse previous row highlighting
                    const rowIdx = this.dataSource.data.findIndex(
                        (row) => row.items.id === previousHighlightedRowItemId
                    );
                    this.dataSource.data[rowIdx].prop.highlighted = false;
                }
                row.prop.highlighted = true;
                this.highlightedRowItemId = row.items.id;
            }
        },
        highlightRowByItemId(itemId) {
            const previousHighlightedRowItemId = this.highlightedRowItemId;
            if (previousHighlightedRowItemId !== undefined) {
                // reverse previous row highlighting
                const rowIdxPrev = this.dataSource.data.findIndex(
                    (row) => row.items.id === previousHighlightedRowItemId
                );
                this.dataSource.data[rowIdxPrev].prop.highlighted = false;
            }

            const rowIdx = this.dataSource.data.findIndex((row) => row.items.id === itemId);
            if (rowIdx >= 0) {
                this.dataSource.data[rowIdx].prop.highlighted = true;
                this.highlightedRowItemId = itemId;
            }
        },
        onRowItemClick(rowItem, index) {
            if (!this.hasRowButtons) {
                this.$emit('tdClick', rowItem);
            } else {
                if (this.hasRowButtons && index > 0) {
                    this.$emit('tdClick', rowItem);
                } else return;
            }
        },
        applyFilter(filterData) {
            if (!(this.mode === modes.custom)) {
                this.dataSource
                    .applyFilter(filterData)
                    .then(() => this.$refs.pager.goToPage(1))
                    .catch((err) => console.error(err));
            } else {
                this.dataSource.addFilter(filterData);
                this.$refs.pager.goToPage(1);
                this.refreshData();
            }
        },
        clearFilter(col) {
            if (!(this.mode === modes.custom)) {
                this.dataSource
                    .removeFilter(col)
                    .then(() => this.$refs.pager.goToPage(1))
                    .catch((err) => console.error(err));
            } else {
                this.dataSource.deleteFilter(col);
                this.$refs.pager.goToPage(1);
                this.refreshData();
            }
        },
        getOptions() {
            return this.dataSource.getOptions();
        },

        onPageChange(pageNumber, pageSize) {
            if (this.showLoading) {
                this.isLoading = true;
            }
            
            this.currentPage = pageNumber;
            this.currentPageSize = pageSize;
            this.dataSource.setPage(this.currentPage);
            this.dataSource.setPageSize(this.currentPageSize);
            this.refreshData();

            if (this.showLoading) {
                this.isLoading = false;
            }
        },

        onSearchStringKeyUp() {
            console.log('search ', this.dataSource.searchString);
            this.currentPage = 1;
            this.refreshData();
        },
        refreshData() {
            //this.isLoading = true;
            if (this.mode === modes.custom) {
                const options = this.getOptions();
                this.$emit('refresh', options);
            } else {
                this.dataSource.processData();
            }
            this.highlightedRowItemId = undefined;
        },
        setInitialValues(pageSize) {
            this.$refs.pager.setPageSize(pageSize);
            this.$refs.pager.setPage(1);
            this.$refs.pager.setFirstInPageSet(1);
            this.currentPageSize = pageSize;
        },
        onError(error) {
            this.$emit('error', error);
        },
        async exportData(fileType) {
            const currentData = this.dataSource.getData();
            const columnsToExport = [];
            this.columns.forEach((x) => {
                if (x.prop && x.prop.length > 0 && (x.visible == undefined || x.visible === true)) {
                    columnsToExport.push(new GridColumn(x));
                }
            });

            const options = this.getOptions();
            options.page = 0;
            options.itemsPerPage = 0;

            if (this.exportMode === ExportMode.currentPage) {
                await gridService
                    .exportCurrentPage(fileType, columnsToExport, currentData)
                    .then((result) => {
                        const response = result;
                        this.handleExportedFile(response);
                    })
                    .catch(() => {
                        console.log('Error on grid export');
                    });
            } else {
                await gridService
                    .exportAll(
                        fileType,
                        columnsToExport,
                        options,
                        this.businessObjectType,
                        this.exportParams,
                        this.exportOptions
                    )
                    .then((result) => {
                        const response = result;
                        if (fileType === 'word') {
                            returnWordFromHtml(result.result);
                        } else this.handleExportedFile(response);
                    })
                    .catch(() => {
                        console.log('Error on grid export');
                    });
            }
        },

        handleExportedFile(response) {
            const blob = base64ToBlob(response.data, response.mimetype);
            const url = window.URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', response.filename);
            document.body.appendChild(link);
            link.click();
        },
    },
    computed: {
        totalPages() {
            const totalPages =
                this.totalItemsCount < this.currentPageSize
                    ? 1
                    : Math.ceil(this.totalItemsCount / this.currentPageSize);
            return totalPages;
        },
    },
    watch: {
        'dataSource.currentItemsCount': function (val) {
            this.totalItemsCount = val;
        },

        //Този watcher не се тригърва при промени (смяна на страница)
        // 'dataSource.loading': function (val) {
        //     this.isLoading = val;
        // },
        // 'dataSource.data': function () {
        //     debugger;
        //     this.isLoading = false; //Добавен, за да се показва Loader-а всеки път при смяна на страница => По-редно би било за това да се грижи data-source.js
        // },
        'dataSource.loading': function (val) {
            this.isLoading = val;
        },
        items: function () {
            this.dataSource.setData(this.items, this.highlightedRowItemId);
        },
        totalItems: function (val) {
            this.totalItemsCount = val;
            if (this.mode === modes.custom) {
                this.dataSource.setTotalCount(this.totalItemsCount);
            }
        },
        showLoading: function (val) {
            this.isLoading = val;
        },
        page: function () {
            this.currentPage = this.page;
        },
        baseUrl: function (newVal, oldVal) {
            if (newVal != oldVal) {
                this.init();
            }
        },
    },
    mounted: function () {
        this.init();
    },
};
</script>

<style scoped>
.pointer {
    cursor: pointer;
}

.loader {
    width: 50px;
    height: 50px;
    box-sizing: border-box;
    border-top: 2px solid var(--bs-primary);
    border-right: 2px solid var(--bs-primary);
    border-bottom: 2px solid #d3d3d31c;
    border-radius: 50%;
    margin: 0 auto;
    animation: spin 1s linear infinite;
}

.highlighted {
    background-color: #f0eaf9;
}

.noHorizontalScroll {
    overflow: visible;
    display: inline-block;
    margin-right: 1px; /* иначе се губи border */
}

.summary-grid-centered .value-wrapper {
    text-align: center;
}

@keyframes spin {
    0% {
        transform: rotate(0deg);
    }

    100% {
        transform: rotate(360deg);
    }
}
</style>
