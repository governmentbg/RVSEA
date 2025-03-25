export interface IDataTable<T> {
    totalCount: number;
    items: T[];
}

export interface IDataTableOptions {
    sortBy: string;
    sortDesc: boolean;
    page: number;
    itemsPerPage: number;
    searchString: string;
    filter: any;
}

export interface IDataTableResponse<T> {
    totalCount: number;
    items: T[];
}