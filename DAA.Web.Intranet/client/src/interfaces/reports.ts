import { IDropdownOption } from "./dropdown";

export interface IReportInputBaseModel {
    StatusGids: string[];
    ArchiveGids: string[];
    ReportResultType?: string[];
}

export interface IReportGridRequestModel<T> {
    Page: number;
    ItemsPerPage: number;
    Filters: T;
}

export interface IReportGridResponseModel<T> {
    totalCount: number;
    items: T[];
}

export interface IReportGridResponseModel1<T> {
    totalCount: number;
    items: T[];
    usageCountTotal: number;
}

export interface IReportFiltersNullCheckboxesModel {
    registeredFrom: boolean;
    registeredTo: boolean;
    textDate: boolean;
    dateFrom: boolean;
    dateTo: boolean;
    docLGid: boolean;
    lGid: boolean;
}

export interface IFundReportFiltersModel {
    StatusGids: string[];
    ArchiveGids: string[];

    FundArrays: IDropdownOption[];
    PeriodGids: IDropdownOption[];
    FundTypes: IDropdownOption[];
    FundTypeGids: IDropdownOption[];
    IndustryIndexes: IDropdownOption[];
    IndustryIndexGids: IDropdownOption[];
    AcquisitionMethods: IDropdownOption[];
    MethodOfAcquisitionGids: IDropdownOption[];
    RegisteredFrom: Date | null;
    RegisteredTo: Date | null;
    TextDate: string | null;
    DateFrom: Date | null;
    DateTo: Date | null;
    ItemsPerPage: number;
}

export interface IFund {
    linearMeters?: number;
    digitalSize?: number;
    inventoryCount?: number | null;
    aeCount?: number | null; // ArchiveEntityCount
    immediateSourceOfAcquisition?: string | null;
    archive?: string;
    number?: string | null; // FundNumber
    fundType?: string | null;
    industryIndex?: string | null;
    methodOfAcquisition?: string | null;
    textDate?: string | null;
    startDate?: string | null;
    endDate?: string | null;
    creationDate?: string | null;
    title?: string | null;
    note?: string | null;
    fundStatus?: string | null;
    levelOfDescription?: string | null;
    systemIdentifier: string | null;
    externalIdentifier: number | null;
    hasExternalSource: boolean;
}

// export interface IFundReport {
//     linearMeters: number;
//     inventoryCount: number | null;
//     aeCount: number | null; // ArchiveEntityCount
//     immediateSourceOfAcquisition: string | null;
//     archive: string;
//     number: string | null; // FundNumber
//     fundType: string | null;
//     industryIndex: string | null;
//     methodOfAcquisition: string | null;
//     textDate: string | null;
//     startDate: string | null;
//     endDate: string | null;
//     creationDate: string | null;
//     title: string | null;
//     note: string | null;
//     fundStatus: string | null;
//     levelOfDescription: string | null;
// }

// export interface IFundsListReport {
//     number: string | null;
//     creationDate: string | null;
//     title: string | null;
//     note: string | null;
// }

export interface IFundMemoriesAndReceiptsLists {
    rowNumber?: number | null;
    number?: string | null;
    creationDate?: string | null;
    immediateSourceOfAcquisitionPlusMethodOfAcquisition?: string | null;
    textDate?: string | null;
    title?: string | null;
    сreatingType?: string | null;
    linearMeters?: number;
    digitalSize?: number | null;
    fundOwnership?: string | null;
    note?: string | null;
    volumeInSheets?: string | null;
    archiveEntitiesCount?: number | null;
    documentsEndDates?: string | null;
    systemIdentifier: string | null;
    externalIdentifier: number | null;
    hasExternalSource: boolean;
}

// export interface IFundMemoriesListReport {
//     number: string | null;
//     creationDate: string | null;
//     immediateSourceOfAcquisitionPlusMethodOfAcquisition: string | null;
//     title: string | null;
//     сreatingType: string | null;
//     linearMeters: number;
//     note: string | null;
// }

// export interface IPartialReceiptsListReport {
//     number: string | null;
//     creationDate: string | null;
//     immediateSourceOfAcquisitionPlusMethodOfAcquisition: string | null;
//     title: string | null;
//     volumeInSheets: string | null;
//     note: string | null;
// }

// export interface IReceiptsListReport {
//     number: string | null;
//     creationDate: string | null;
//     immediateSourceOfAcquisitionPlusMethodOfAcquisition: string | null;
//     title: string | null;
//     linearMeters: number | null;
//     archiveEntitiesCount: number | null;
//     documentsEndDates: string | null;
//     note: string | null;
// }

export interface IWorkListForPriorityRestorationReport {
    fundNumber: string | null;
    inventoryNumber: string | null;
    archiveEntityNumber: string | null;
    documentSystemId: string;
    paperCount: number | null;
    physicalCondition: string | null;
    copyDigital: number | null;
    copyMicrofilm: number | null;
    systemIdentifier: string | null;
    externalIdentifier: number | null;
    hasExternalSource: boolean;
}

export interface IListFiltersModel {
    ArchiveGid: number;
    ItemsPerPage: number;
}

export interface IInventoryBook {
    number: string | null;
    receivedOn: string | null;
    countryOfOrigin: string | null;
    negatives: string | null;
    positives: string | null;
    copyXerox: string | null;
    copyDigital: string | null;
    hasInventory: boolean | null;
    shortDescription: string | null;
    creationAuthor: string | null;
    note: string | null;
    systemIdentifier: string | null;
    externalIdentifier: number | null;
    hasExternalSource: boolean;
}

export interface IInventoryBookOfCopiesFromForeignArchives {
    kmfNumber: string | null;
    inventoryNumber: string | null;
    receivedOn: string | null;
    countryOfOrigin: string | null;
    framesCount: number | null;
    microfilmNegativeRollsCount: number | null;
    microfilmNegativeFramesCount: number | null;
    microfilmPositiveRollsCount: number | null;
    microfilmPositiveFramesCount: number | null;
    xeroxCopy: string | null;
    digitalCopy: string | null;
    electronicDocumentsCount: number | null;
    electronicDocumentsMB: string | null;
    other: string | null;
    hasInventory: boolean | null;
    inventoryShortDescription: string | null;
    creationAuthor: string | null;
}