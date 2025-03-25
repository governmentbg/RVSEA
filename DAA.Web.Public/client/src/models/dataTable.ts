export class DataTable<T> {
    constructor(obj: any = {}) {
        this.totalCount = obj.totalCount || 0;
        this.items = obj.items || [];
    }

    totalCount: number;
    items: T[];
}

export class DataTableOptions {
    constructor(obj: any = {}) {
        this.sortBy = obj.sortBy || '';
        this.sortDesc = obj.sortDesc || false;
        this.page = obj.page || 1;
        this.itemsPerPage = obj.itemsPerPage || 10;
        this.searchString = obj.searchString || '';
        this.filter = obj.filter || undefined;
    }

    sortBy: string;
    sortDesc: boolean;
    page: number;
    itemsPerPage: number;
    searchString: string;
    filter: any;
}
