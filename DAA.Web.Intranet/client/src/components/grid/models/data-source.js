import axios from 'axios';
import Row from './row';
import modes from './modes';

export default class DataSource {
    constructor( ) {
        this.mode = null;
        this.items = [];
        this.data = [];
        this.pageSize = 10;
        this.currentPage = 1;
        this.filters = [];
        this.sortKey = '';
        this.sortKeyType = '';
        this.sortDirection = null;
        this.paging = false;
        this.currentItemsCount = 0;
        this.baseUrl = '';
        this.loading = false;
        this.emitError = null;
        this.searchString = '';
    }

    _filterData(data) {
        if (this.filters.length) {
            this.filters.forEach((filter) => {
                data = data.filter(function (row) {
                    switch (filter.col.type) {
                        case 'number': {
                            const op1 = parseFloat(row.items[filter.col.prop]);
                            const op2 = parseFloat(filter.value);
                            const expression = op1 + filter.operator + op2;
                            return Boolean(eval(expression));
                        }
                        case 'date':
                            break;
                        case 'string':
                        case 'html':
                        default: {
                            const op1 = String(row.items[filter.col.prop]).toLowerCase();
                            const op2 = String(filter.value).toLowerCase();

                            if (filter.operator === '~') {
                                //Contains
                                return op1.indexOf(op2) > -1;
                            } else if (filter.operator === '/') {
                                //Starts with
                                return op1.indexOf(op2) === 0;
                            } else if (filter.operator === '==') {
                                //Equal
                                return op1 === op2;
                            }
                        }
                    }
                });
            });
        }

        return data;
    }

    _filterDataBySearch(data) {
        if (data && this.searchString) {
            const searchBy = this.searchString;
            if (this.searchString) {
                data = data.filter(function (row) {
                    const props = Object.getOwnPropertyNames(row.items);
                    return props.some((prop) => {
                        return String(row.items[prop]).toLowerCase().includes(searchBy);
                    });
                });
            }
        }

        return data;
    }
    _sortData(data) {
        if (this.sortKey) {
            const order = this.sortDirection || 1;

            data = data.slice().sort((row1, row2) => {
                row1 = row1.items[this.sortKey];
                row2 = row2.items[this.sortKey];
                return (row1 === row2 ? 0 : row1 > row2 ? 1 : -1) * order;
            });
        }

        return data;
    }
    _buildQueryString() {
        let url = '';

        if (this.sortKey) {
            const order = this.sortDirection || 1;
            url += `grid_sort=${this.sortKey}&grid_sort_order=${order}`;
        }

        if (this.filters.length) {
            let filterStr = '';
            this.filters.forEach((filter) => {
                const str = `${filter.col.prop}_${filter.operator}_${filter.value}_${filter.col.type}`;
                filterStr += `&grid_filter=${str}`;
            });

            url += filterStr;
        }

        if (this.paging) {
            url += `&grid_page=${this.currentPage}&grid_page_size=${this.pageSize}`;
        }

        if (url.length && url[0] === '&') {
            url = url.substring(1);
        }

        return url;
    }
    _processLocalData() {
        const promise = new Promise((resolve, reject) => {
            this.loading = true;
            try {
                let data = [...this.items];

                data = this._filterData(data);
                data = this._filterDataBySearch(data);
                data = this._sortData(data);
                this.currentItemsCount = data.length;

                if (this.paging) {
                    const startIndex = (this.currentPage - 1) * this.pageSize;
                    data = data.splice(startIndex, this.pageSize);
                }

                this.data = data;
                resolve();
            } catch (error) {
                this.emitError(error);
                reject(error);
            } finally {
                this.loading = false;
            }
        });

        return promise;
    }
    _processRemoteData() {
        const options = this.getOptions();
        this.data = [];
        this.loading = true;
        //const queryString = this._buildQueryString();
        //let url = this.baseUrl + '?' + queryString;
        //window.history.pushState(null, null, location.href.split('?')[0] + '?' + queryString);
        return axios
            .post(this.baseUrl, options)
            .then((response) => {
                const rows = [];
                //this.currentItemsCount = response.data.totalCount || 0;
                const data = response.data.data || response.data;
                console.log('_processRemoteData', data);
                this.currentItemsCount = data.totalCount || 0;
                //response.data.items.forEach(item => rows.push(new Row(item)));
                data.items.forEach((item) => rows.push(new Row(item)));
                this.data = rows;
            })
            .catch((err) => this.emitError(err))
            .then(() => {
                this.loading = false;
            });
    }
    _processServerSideData() {
        this.data = [...this.items];
        return;
    }
    processData() {
        if (this.mode == modes.remote) {
            return this._processRemoteData();
        } else if (this.mode == modes.custom) {
            this._processServerSideData();
        } else {
            return this._processLocalData();
        }
    }
    setTotalCount(total) {
        this.currentItemsCount = total;
    }
    setData(items, highlighetItemId = undefined) {
        if (!this.baseUrl) {
            this.items = [];
            for (let index = 0; index < items.length; index++) {
                const item = items[index];
                const highlighted = item.id === highlighetItemId;
                this.items.push(new Row(item, { selected: false, highlighted: highlighted }));
            }
        }

        return this.processData();
    }
    sort(sortKey, direction, type) {
        this.setSort(sortKey, direction, type);
        return this.processData();
    }
    setSort(sortKey, direction, type) {
        this.sortKey = sortKey;
        this.sortKeyType = type;
        this.sortDirection = direction;
        this.currentPage = 1;
    }
    addFilter(filter) {
        if (filter.type === 'boolean') {
            filter.value = filter.col.filterByBooleanFunction(
                filter.value,
                filter.col.positiveValueText,
                filter.col.negativeValueText
            );
        }
        const currentIndex = this.filters.findIndex((fl) => {
            return fl.col.prop === filter.col.prop;
        });

        if (currentIndex != -1) {
            this.filters[currentIndex] = filter;
        } else {
            this.filters.push(filter);
        }
    }
    deleteFilter(col) {
        const index = this.filters.findIndex((item) => {
            return item.col.prop === col.prop;
        });
        if (index >= 0) {
            this.filters.splice(index, 1);
        }
        return index;
    }
    getFiltersList() {
        const filtersList = [];
        if (this.filters && this.filters.length) {
            this.filters.forEach((item) => {
                if (item.type === 'date') {
                    const dateValue = new Date(item.value);
                    filtersList.push({
                        field: item.col.prop,
                        operator: item.operator,
                        value: dateValue,
                    });
                } else {
                    filtersList.push({
                        field: item.col.prop,
                        operator: item.operator,
                        value: item.value,
                    });
                }
            });
        }
        return filtersList;
    }
    applyFilter(filter) {
        this.addFilter(filter);
        this.currentPage = 1;
        return this.processData();
    }
    setPage(number) {
        this.currentPage = number;
    }
    setPageSize(pageSize) {
        this.pageSize = pageSize;
    }
    removeFilter(col) {
        const promise = new Promise((resolve, reject) => {
            const existing = this.deleteFilter(col);

            if (existing == -1) {
                resolve();
            }

            this.currentPage = 1;
            this.processData()
                .then(() => resolve())
                .catch((err) => reject(err));
        });

        return promise;
    }
    getOptions() {
        const options = {
            sortBy: this.sortKey || '',
            sortByType: this.sortKeyType || '',
            sortDesc: this.sortDirection < 0 ? true : false,
            page: this.currentPage,
            itemsPerPage: this.pageSize,
            searchString: this.searchString,
            filter: { filters: this.getFiltersList(), logic: 'and' },
        };
        return options;
    }
    getData() {
        const currentData = [];
        this.data.forEach((row) => {
            currentData.push(row.items);
        });
        return currentData;
    }
}
