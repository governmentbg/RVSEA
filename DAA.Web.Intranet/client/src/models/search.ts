export class SearchModel {
    constructor(obj?: SearchModel) {
        if (obj) {
            Object.assign(this, obj);
        }
    }
    archiveId?: string[] = [];
    descriptionLevelCode?: string[] = [];
    descriptionLevelCodeExternal: string[] = [];
    fundNumber?: string;
    inventoryNumber?: string;
    archivalEntityNumber?: string;
    cmfNumber?: string;
    cmfCountriesOfOriginCodes?: string[] = [];
    advancedSearch?: boolean;
    searchFileContent?: boolean;
    foreignArchives?: boolean;
    searchByDigitalCopies?: string;
    fundArrayCode?: string[] = [];
    fundArrayCodeExternal?: string[] = [];
    name?: string;
    keyWords?: string;
    dateFrom?: Date | null = null;
    dateTo?: Date | null = null;
    itemsPerPage?: number;
    page?: number;
    searchString?: string;
    sortBy?: string;
    sortByType?: string;
    sortDesc?: boolean;
}

export class AeSearchModel {
    constructor(obj?: AeSearchModel) {
        if (obj) {
            Object.assign(this, obj);
        }
    }
    startDate?: Date | null = null;
    endDate?: Date | null = null;
    Page: number = 1;
    ItemsPerPage: number = 10;
    archivalEntitySystemIdentifier?: string | null = null;
}
