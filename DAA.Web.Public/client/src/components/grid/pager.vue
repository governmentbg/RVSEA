<template>
    <div style="display: flex; justify-content: left">
        <nav>
            <ul class="pagination">
                <li class="page-item" v-bind:class="{ disabled: currentPage === 1 }">
                    <a class="page-link" href="#" :aria-label="$t('grid.pager.first')" @click="goToPage(1)">
                        <span aria-hidden="true">&laquo;</span>
                        <span class="sr-only">{{ $t('grid.pager.first') }}</span>
                    </a>
                </li>
                <li class="page-item" v-bind:class="{ disabled: currentPage === 1 }">
                    <a
                        class="page-link"
                        href="#"
                        :aria-label="$t('grid.pager.previous')"
                        @click="goToPage(currentPage - 1)"
                    >
                        <span aria-hidden="true">&lt;</span>
                        <span class="sr-only">{{ $t('grid.pager.previous') }}</span>
                    </a>
                </li>
                <li class="page-item" v-if="showPreviousPageSetButton">
                    <a
                        class="page-link"
                        href="#"
                        :aria-label="$t('grid.pager.previous')"
                        @click="goToPage(firstInPageSet - 1)"
                    >
                        <span aria-hidden="true">...</span>
                        <span class="sr-only">{{ $t('grid.pager.previous') }}</span>
                    </a>
                </li>
                <li
                    class="page-item"
                    v-for="(page, index) in currentPageSet"
                    :key="index"
                    v-bind:class="{ active: currentPage == page }"
                    @click="goToPage(page)"
                >
                    <a class="page-link" href="#">{{ page }}</a>
                </li>
                <li class="page-item" v-if="showNextPageSetButton">
                    <a
                        class="page-link"
                        href="#"
                        :aria-label="$t('grid.pager.next')"
                        @click="goToPage(firstInPageSet + pageSetSize)"
                    >
                        <span aria-hidden="true">...</span>
                        <span class="sr-only">{{ $t('grid.pager.next') }}</span>
                    </a>
                </li>
                <li class="page-item" v-bind:class="{ disabled: currentPage === totalPages }">
                    <a
                        class="page-link"
                        href="#"
                        :aria-label="$t('grid.pager.next')"
                        @click="goToPage(currentPage + 1)"
                    >
                        <span aria-hidden="true">&gt;</span>
                        <span class="sr-only">{{ $t('grid.pager.next') }}</span>
                    </a>
                </li>
                <li class="page-item" v-bind:class="{ disabled: currentPage === totalPages }">
                    <a class="page-link" href="#" :aria-label="$t('grid.pager.last')" @click="goToPage(totalPages)">
                        <span aria-hidden="true">&raquo;</span>
                        <span class="sr-only">{{ $t('grid.pager.last') }}</span>
                    </a>
                </li>
            </ul>
        </nav>
        <div v-if="totalPages" class="row mx-3 ml-1 mr-1 align-items-baseline" style="max-height: 38px; padding: 0px;">
            <div class="col">
                <select class="form-select" v-model="currentOptionPage" @change="goToPage(currentOptionPage);  setFirstInPageSet(currentOptionPage-2 < 1 ? 1 : currentOptionPage-2)">
                    <option
                        v-for="(page, index) in totalPages"
                        :key="index"
                        :value="page"
                        :selected="currentOptionPage === page"
                    >
                        {{ page }}
                    </option>
                </select>
            </div>
        </div>
        <div class="row mx-3 align-items-baseline">
            <div class="col">
                <select class="form-select" v-model="selectedPageSize" @change="changePageSize(selectedPageSize)">
                    <option
                        v-for="(pageSize, index) in pageSizeList"
                        :key="index"
                        :value="pageSize"
                        :selected="currentPageSize === pageSize"
                    >
                        {{ pageSize }}
                    </option>
                </select>
            </div>
            <div class="col-md-7 text-nowrap">{{ $t('grid.pager.rowsOnPage') }}</div>
        </div>
    </div>
</template>

<script>
import { PageSize } from '@/models/grid';

export default {
    props: {
        totalPages: Number,
        initialPage: { type: Number, default: 1 },
        initialPageSize: { type: Number, default: PageSize.five },
        pageSizeList: {
            type: Array,
            default() {
                return Object.values(PageSize).filter((val) => !isNaN(Number(val)));
            },
        },
    },
    inheritAttrs: false,
    data() {
        return {
            currentPage: null,
            currentOptionPage: null,
            currentPageSize: null,
            selectedPageSize: null,
            pageSetSize: 5,
            firstInPageSet: 1,
        };
    },
    methods: {
        goToPage(pageNumber) {
            if (pageNumber === this.currentPage) {
                return;
            }
            this.currentOptionPage = pageNumber;
            this.currentPage = pageNumber;
            this.changePageSet();
            this.$emit('change', this.currentPage, this.currentPageSize);
        },
        changePageSize(pageSize) {
            if (pageSize === this.currentPageSize) {
                return;
            }
            this.currentPageSize = pageSize;
            this.currentPage = 1;
            this.changePageSet();
            this.$emit('change', this.currentPage, this.currentPageSize);
        },
        setPageSize(pageSize) {
            this.currentPageSize = pageSize;
            this.selectedPageSize = pageSize;
        },
        setPage(page) {
            this.currentPage = page;
        },
        setFirstInPageSet(page) {
            this.firstInPageSet = page;
        },
        changePageSet() {
            if (this.currentPage >= this.firstInPageSet + this.pageSetSize) {
                this.firstInPageSet = this.firstInPageSet + this.pageSetSize;
                if (this.currentPage == this.totalPages) {
                    let minSets = Math.floor(this.totalPages / this.pageSetSize);
                    this.firstInPageSet =
                        this.totalPages % this.pageSetSize === 0 ? minSets : minSets * this.pageSetSize + 1;
                }
            } else if (this.currentPage < this.firstInPageSet) {
                this.firstInPageSet = this.firstInPageSet - this.pageSetSize;
                if (this.currentPage == 1) {
                    this.firstInPageSet = 1;
                }
            }
        },
    },
    mounted() {
        this.currentOptionPage = this.initialPage;
        this.currentPage = this.initialPage;
        this.currentPageSize = this.initialPageSize;
        this.selectedPageSize = this.currentPageSize;
    },
    computed: {
        currentPageSet() {
            let currentPageSet = [];
            let firstPage = this.firstInPageSet;
            let lastPage = firstPage + this.pageSetSize - 1;
            if (this.totalPages < lastPage) {
                lastPage = this.totalPages;
            }
            for (let i = firstPage; i <= lastPage; i++) {
                currentPageSet.push(i);
            }

            return currentPageSet;
        },
        showPreviousPageSetButton() {
            let showPrevious = this.firstInPageSet > this.pageSetSize;
            return showPrevious;
        },
        showNextPageSetButton() {
            let showNext = this.firstInPageSet + this.pageSetSize <= this.totalPages;
            return showNext;
        },
    },
    watch: {
        initialPage: function () {
            if (this.currentPage === this.initialPage) {
                return;
            }
            this.currentOptionPage = this.initialPage;
            this.currentPage = this.initialPage;
            this.changePageSet();
        },
    },
};
</script>

<style scoped></style>
