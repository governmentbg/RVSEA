/* eslint-disable @typescript-eslint/no-explicit-any */
import { PageSize } from '@/models/grid';
import { IDropdownOption } from '@/interfaces/dropdown';

// Налага се property-тата на някои модели да бъдат с главна буква, тъй като те се model-bind-ват в бекенда към обект от тип Objects
// при експорт на справки, а това изглежда е case sensitive

export class ReportInputBaseModel {
    StatusesInternal: IDropdownOption[] = [];
    StatusGids: IDropdownOption[] = []; // Външна номеклатура
    Statuses: IDropdownOption[] = []; // Външна и вътрешна номеклатура заедно
    ArchiveCodesInternal: IDropdownOption[] = [];
    ArchiveGids: IDropdownOption[] = []; // Външна номеклатура
    Archives: IDropdownOption[] = []; // Външна и вътрешна номеклатура заедно
}

export const pageSizesList = [PageSize.twenty, PageSize.fifty, PageSize.hundred];
export const defaultItemsPerPage = PageSize.twenty;
export const allFromDropdownValue = '-999';
export const allFromDropdownInternalValue = '-998';
export const allFromDropdownExternalValue = '-997';
export const itemsPerPageDropdownValues = [
    { code: PageSize.twenty, text: PageSize.twenty },
    { code: PageSize.fifty, text: PageSize.fifty },
    { code: PageSize.hundred, text: PageSize.hundred },
];
export const externalSourceSuffix = '_ext';

export class ReportGridRequestModel<T> {
    constructor(obj: ReportGridRequestModel<T>) {
        this.Page = obj.Page || 1;
        this.ItemsPerPage = obj.ItemsPerPage || 10;
        this.Filters = obj.Filters;
    }

    Page: number;
    ItemsPerPage: number;
    Filters: T;
}

export class ReportGridResponseModel<T> {
    totalCount: number = 0;
    items: T[] = [];
}

export class ReportServiceResultModel<T> {
    constructor(obj: ReportServiceResultModel<T>) {
        this.data = obj.data;
        this.metadata = obj.metadata;
    }

    data: T | null = null;
    metadata: string = '';
}

export class ReportGridWithSummaryGridResponseModel<T1, T2> extends ReportGridResponseModel<T2> {
    summary: T1 | null = null;
}

// export class ReportGridResponseSummaryOnlyModel<T> {
//     summary: T | null = null;
//     metadata: string = '';
// }

export class ReportFiltersNullCheckboxesModel {
    registeredFrom: boolean = true;
    registeredTo: boolean = true;
    textDate: boolean = true;
    dateFrom: boolean = true;
    dateTo: boolean = true;
    systemId: boolean = true;
    lGid: boolean = true;
}

export class FundReportFiltersModel extends ReportInputBaseModel {
    FundArraysInternal: string[] = [];
    PeriodGids: string[] = []; // това е наименованието на FundArraysExternal в ИСДА
    FundArrays: string[] = [];
    FundTypesInternal: string[] = [];
    FundTypeGids: string[] = []; // това е наименованието на FundTypesExternal в ИСДА
    FundTypes: string[] = [];
    IndustryIndexesInternal: string[] = [];
    IndustryIndexGids: string[] = []; // това е наименованието на IndustryIndexExternal в ИСДА
    IndustryIndexes: string[] = [];
    MethodsOfAcquisitionInternal: string[] = [];
    MethodOfAcquisitionGids: string[] = []; // това е наименованието на MethodsOfAcquisitionExternal в ИСДА
    MethodsOfAcquisition: string[] = [];
    RegisteredFrom: Date | null = null;
    RegisteredTo: Date | null = null;
    TextDate: string | null = null;
    DateFrom: Date | null = null;
    DateTo: Date | null = null;
    ItemsPerPage: number = 10;
}

export class FundPublicReport {
    linearMeters: number | null = 0;
    digitalSize: number | null = 0;
    inventoryCount: number | null = null;
    aeCount: number | null = null; // ArchiveEntityCount
    immediateSourceOfAcquisition: string | null = null;
    archive: string = '';
    number: string | null = null; // FundNumber
    fundType: string | null = null;
    industryIndex: string | null = null;
    methodOfAcquisition: string | null = null;
    textDate: string | null = null;
    startDate: string | null = null;
    endDate: string | null = null;
    creationDate: string | null = null;
    title: string | null = null;
    note: string | null = null;
    fundStatus: string | null = null;
    levelOfDescription: string | null = null;
    systemIdentifier: string | null = null;
    hasExternalSource: boolean = false;
    externalIdentifier: number | null = null;
}

export class FundPublicReportSummary {
    totalFunds: number = 0;
    totalInventories: number = 0;
    totalArchiveEntities: number = 0;
    totalLinearMeters: number = 0;
    totalSize: number = 0;
    totalDuration?: number;
}

export class FundsListReport {
    number: string | null | undefined;
    creationDate: string | null | undefined;
    title: string | null | undefined;
    note: string | null | undefined;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class FundDataReportFiltersModel extends ReportInputBaseModel {
    FundArraysInternal: string[] = [];
    PeriodGids: string[] = []; // това е наименованието на FundArraysExternal в ИСДА
    FundArrays: string[] = [];
    FundTypesInternal: string[] = [];
    FundTypeGids: string[] = []; // това е наименованието на FundTypesExternal в ИСДА
    FundTypes: string[] = [];
    IndustryIndexesInternal: string[] = [];
    IndustryIndexGids: string[] = []; // това е наименованието на IndustryIndexExternal в ИСДА
    IndustryIndexes: string[] = [];
    MethodsOfAcquisitionInternal: string[] = [];
    MethodOfAcquisitionGids: string[] = []; // това е наименованието на MethodsOfAcquisitionExternal в ИСДА
    MethodsOfAcquisition: string[] = [];
    RegisteredFrom: Date | null = null;
    RegisteredTo: Date | null = null;
    TextDate: string | null = null;
    DateFrom: Date | null = null;
    DateTo: Date | null = null;
    LGid: string | null = null;
    ItemsPerPage: number = 10;
}

export class FundDataPublicReport {
    systemId: string | null = null;
    linearMeters: number = 0;
    creationAuthor: string | null = null;
    modificationDate: string | null = null;
    modificationAuthor: string | null = null;
    inventoryCount: number | null = null;
    boxesCount: number | null = null;
    storageTubesCount: number | null = null;
    extentOther: string | null = null;
    size: number | null = null;
    duration: number | null = null;
    eDocumentsCount: number | null = null;
    fileFormats: string | null = null;
    fundFormerNameChange: string | null = null;
    fundFormerFunction: string | null = null;
    fundFormerHistory: string | null = null;
    archivalHistory: string | null = null;
    aeCount: number | null = null; // ArchiveEntityCount
    immediateSourceOfAcquisition: string | null = null;
    archive: string = '';
    documentProperties: string | null = null;
    originality: string | null = null;
    creatingType: string | null = null;
    language: string | null = null;
    accessConditions: string | null = null;
    findingAids: string | null = null;
    relatedUnits: string | null = null;
    number: string | null = null; // FundNumber
    fundType: string | null = null;
    industryIndex: string | null = null;
    methodOfAcquisition: string | null = null;
    textDate: string | null = null;
    startDate: string | null = null;
    endDate: string | null = null;
    creationDate: string | null = null;
    title: string | null = null;
    note: string | null = null;
    fundStatus: string | null = null;
    hasExternalSource: boolean = false;
    externalIdentifier: number | null = null;
}

export class FundDataPublicReportSummary {
    linearMeters: number = 0;
    funds: number | null = null;
    inventories: number | null = null;
    archiveEntities: number | null = null;
    size: number | null = null;
    duration: number | null = null;
    eDocumentsCount: number | null = null;
}

export class FundMemoryReportFiltersModel extends ReportInputBaseModel {
    FundArraysInternal: string[] = [];
    PeriodGids: string[] = []; // това е наименованието на FundArraysExternal в ИСДА
    FundArrays: string[] = [];
    MethodsOfAcquisitionInternal: string[] = [];
    MethodOfAcquisitionGids: string[] = []; // това е наименованието на MethodsOfAcquisitionExternal в ИСДА
    MethodsOfAcquisition: string[] = [];
    RegisteredFrom: Date | null = null;
    RegisteredTo: Date | null = null;
    TextDate: string | null = null;
    DateFrom: Date | null = null;
    DateTo: Date | null = null;
    ItemsPerPage: number = 10;
}

export class FundMemoryPublicReport {
    linearMeters: number = 0;
    bytes: number = 0;
    immediateSourceOfAcquisition: string | null = null;
    accessConditions: string | null = null;
    archive: string = '';
    number: string | null = null; // FundNumber
    fundType: string | null = null;
    methodOfAcquisition: string | null = null;
    textDate: string | null = null;
    startDate: string | null = null;
    endDate: string | null = null;
    creationDate: string | null = null;
    title: string | null = null;
    note: string | null = null;
    fundStatus: string | null = null;
    systemIdentifier: string | null = null;
    hasExternalSource: boolean = false;
    externalIdentifier: number | null = null;
}
export class FundReportSummary2 {
    totalRows: number = 0;
    totalLinearMeters: number = 0;
    totalSize: number = 0;
}

export class FundMemoriesListReport {
    number: string | null = null;
    creationDate: string | null = null;
    immediateSourceOfAcquisitionPlusMethodOfAcquisition: string | null = null;
    title: string | null = null;
    сreatingType: string | null = null;
    linearMeters: number = 0;
    note: string | null = null;
}

export class RegisterOfDigitalObjectsReportFiltersModel {
    Archives: IDropdownOption[] = [];
    RegisteredFrom: Date | null = null;
    RegisteredTo: Date | null = null;
    SystemId: string | null = null;
    ItemsPerPage: number = 10;
}

export class RegisterOfDigitalObjectsPublicReport {
    systemId: string | null = null;
    hasExternalSource: boolean = false;
    levelOfDescription: string | null = null;
    //documentLink: string = '';
    archiveName: string = '';
    fundNumber: string | null = null;
    inventoryNumber: string | null = null;
    archiveEntityNumber: string | null = null;
    listNumbers: string = '';
    documentTitle: string | null = null;
    chronologicalScope: string | null = null;
    //docStatus: string | null = null; // отпада по искане на ДАА
    digitalObjectCreationDate: string | null = null;
    imageCount: number = 0;
    bytesCount: number | null = null;
    duration: string | null = null;
    linkTitle: string = 'Линк';
    //digitalObjectStatus: string = ''; // отпада по искане на ДАА
    //modifiedOn: string | null = null; // отпада по искане на ДАА
}

export class RegisterOfDigitalObjectsReportSummary {
    totalRows: number = 0;
    totalDOs: number = 0;
    totalBytesCount: number = 0;
    totalImageCount: number = 0;
    totalDuration: string = '';
}

export class PartialReceiptsPublicReportFiltersModel extends ReportInputBaseModel {
    FundArraysInternal: string[] = [];
    PeriodGids: string[] = []; // това е наименованието на FundArraysExternal в ИСДА
    FundArrays: string[] = [];
    FundTypesInternal: string[] = [];
    FundTypeGids: string[] = []; // това е наименованието на FundTypesExternal в ИСДА
    FundTypes: string[] = [];
    MethodsOfAcquisitionInternal: string[] = [];
    MethodOfAcquisitionGids: string[] = []; // това е наименованието на MethodsOfAcquisitionExternal в ИСДА
    MethodsOfAcquisition: string[] = [];
    RegisteredFrom: Date | null = null;
    RegisteredTo: Date | null = null;
    TextDate: string | null = null;
    DateFrom: Date | null = null;
    DateTo: Date | null = null;
    ItemsPerPage: number = 10;
}

export class PartialReceiptsPublicReport {
    linearMeters: number = 0;
    inventoryCount: number | null = null;
    aeCount: number | null = null; // ArchiveEntityCount
    immediateSourceOfAcquisition: string | null = null;
    archive: string = '';
    number: string | null = null; // FundNumber
    fundType: string | null = null;
    documentProperties: string | null = null;
    methodOfAcquisition: string | null = null;
    textDate: string | null = null;
    startDate: string | null = null;
    endDate: string | null = null;
    creationDate: string | null = null;
    title: string | null = null;
    note: string | null = null;
    fundStatus: string | null = null;
    size: number | null = null;
    systemIdentifier: string | null = null;
}

export class PartialReceiptsListReport {
    number: string | null = null;
    creationDate: string | null = null;
    immediateSourceOfAcquisitionPlusMethodOfAcquisition: string | null = null;
    title: string | null = null;
    volumeInSheets: string | null = null;
    note: string | null = null;
}

export class ReceiptsListReport {
    number: string | null = null;
    creationDate: string | null = null;
    immediateSourceOfAcquisitionPlusMethodOfAcquisition: string | null = null;
    title: string | null = null;
    linearMeters: number | null = null;
    archiveEntitiesCount: number | null = null;
    documentsEndDates: string | null = null;
    note: string | null = null;
}

export class WorkListForPriorityRestorationReport {
    fundNumber: string | null = null;
    inventoryNumber: string | null = null;
    archiveEntityNumber: string | null = null;
    documentLGid: number = 0;
    paperCount: number | null = null;
    physicalCondition: string | null = null;
    copyDigital: number | null = null;
    copyMicrofilm: number | null = null;
}

export class ListFiltersModel {
    Archives: IDropdownOption[] = [];
    ItemsPerPage: number = 10;
}
