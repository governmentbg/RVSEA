/* eslint-disable @typescript-eslint/no-explicit-any */
export class GridColumn {
    constructor(obj: any = {}) {
        this.prop = obj.prop || '';
        this.title = obj.title || '';
        this.type = obj.type || '';
    }

    prop: string;
    title: string;
    type: string;
}

export class GridOptions {
    constructor(obj: any) {
        this.page = obj.page || 1;
        this.itemsPerPage = obj.itemsPerPage || 20;
        this.sortBy = obj.sortBy;
        this.sortDesc = obj.sortDesc || false;
        this.sortByType = obj.sortByType;
        this.totalPages = obj.totalPages || 1;
    }

    page: number;
    itemsPerPage: number;
    sortBy: string;
    sortDesc: boolean;
    sortByType: string;
    searchString?: string;
    totalPages?: number;
}

export class GridResponseModel<T> {
    constructor(obj: any = {}) {
        this.totalCount = obj.totalCount || 0;
        this.totalCountInWords = obj.TotalCountInWords || '';
        this.items = obj.items || [];
    }
    totalCountInWords?: string;
    totalCount: number;
    items: T[];
}

export class GridExport {
    mimetype: string = '';
    filename: string = '';
    data: string = '';
}

export enum BusinessObjectType {
    unknown = 'unknown',
    report = 'report',
    log = 'log',
    role = 'role',
    task = 'task',
    user = 'user',
    archive = 'archive',
    fund = 'fund',
    rawFund = 'raw_fund',
    memory = 'memory',
    chp = 'chp',
    inventory = 'inventory',
    rawInventory = 'raw_inventory',
    archivalEntity = 'archival_entity',
    document = 'document',
    nomenclature = 'nomenclature',
    film = 'film',
    filmCard = 'film_card',
    fundReconstruction = 'fund_reconstruct',
    application = 'eDocsApplication',
    packageB = 'packageB',
    systemInventory = 'system_inventory',
    systemArchivalEntity = 'system_archival_entity',
}

export enum PageSize {
    five = 5,
    ten = 10,
    twenty = 20,
    fifty = 50,
    hundred = 100,
    fiveTousand = 5000,
}

export enum ExportMode {
    currentPage = 'currentPage',
    all = 'all',
}

export class GridRequestModel<T> {
    constructor(obj: GridRequestModel<T>) {
        this.Page = obj.Page || 1;
        this.ItemsPerPage = obj.ItemsPerPage || 10;
        this.Filters = obj.Filters;
    }

    Page: number;
    ItemsPerPage: number;
    Filters: T;
}
