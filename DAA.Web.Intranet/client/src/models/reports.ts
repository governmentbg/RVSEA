import { PageSize } from '@/models/grid';
import { IDropdownOption } from '@/interfaces/dropdown';
import { IInventoryBook } from '@/interfaces/reports';
import { IWorkListForPriorityRestorationReport } from '@/interfaces/reports';
import { IFundMemoriesAndReceiptsLists } from '@/interfaces/reports';
import { IFund } from '@/interfaces/reports';
import { IReportGridResponseModel1 } from '@/interfaces/reports';

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

export class ReportInputBaseModelInternalOnly {
    Statuses: IDropdownOption[] = [];
    Archives: IDropdownOption[] = [];
}

export const pageSizesList = [PageSize.twenty, PageSize.fifty, PageSize.hundred];
export const defaultItemsPerPage = PageSize.twenty;
export const allFromDropdownValue = '-999';
export const allFromDropdownInternalValue = '-998';
export const allFromDropdownExternalValue = '-997';
export const noDropdownItemValue = '-899';
export const noDropdownItemInternalValue = '-898';
export const noDropdownItemExternalValue = '-897';
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

export class ReportServiceResultModel<T> {
    constructor(obj: ReportServiceResultModel<T>) {
        this.data = obj.data;
        this.metadata = obj.metadata;
    }

    data: T | null = null;
    metadata: string = '';
}

export class ReportGridResponseModel<T> {
    totalCount: number = 0;
    items: T[] = [];
}

export class ReportGridWithSummaryGridResponseModel<T1, T2> extends ReportGridResponseModel<T2> {
    summary: T1 | null = null;
}

export class ReportGridWithSummaryGridResponseModel1<T1, T2> extends ReportGridResponseModel<T2> {
    summary: Array<T1> = [];
}

export class ReportFiltersNullCheckboxesModel {
    registeredFrom: boolean = true;
    registeredTo: boolean = true;
    createdFrom: boolean = true;
    createdTo: boolean = true;
    textDate: boolean = true;
    dateFrom: boolean = true;
    dateTo: boolean = true;
    processStartDate: boolean = true;
    processEndDate: boolean = true;
    docLGid: boolean = true;
    lGid: boolean = true;
    statisticDataOnly: boolean = false;
    inventories: boolean = true;
    funds: boolean = true;
    processStartedFrom: boolean = true;
    processStartedTo: boolean = true;
    fundNumber: boolean = true;
}

export class ListFiltersModel {
    ArchiveCodesInternal: string[] = [];
    ArchiveGid: string[] = []; // Външна номеклатура
    Archives: string[] = []; // Външна и вътрешна номеклатура заедно
    ItemsPerPage: number = 10;
    ReportResultType: number = 1;
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
    ReportResultType: number | undefined;
}

export class FundReport {
    constructor(obj: IFund) {
        this.linearMeters = obj.linearMeters;
        this.digitalSize = obj.digitalSize;
        this.inventoryCount = obj.inventoryCount;
        this.aeCount = obj.aeCount;
        this.immediateSourceOfAcquisition = obj.immediateSourceOfAcquisition;
        this.archive = obj.archive;
        this.number = obj.number;
        this.fundType = obj.fundType;
        this.industryIndex = obj.industryIndex;
        this.methodOfAcquisition = obj.methodOfAcquisition;
        this.textDate = obj.textDate;
        this.startDate = obj.startDate;
        this.endDate = obj.endDate;
        this.creationDate = obj.creationDate;
        this.title = obj.title;
        this.note = obj.note;
        this.fundStatus = obj.fundStatus;
        this.levelOfDescription = obj.levelOfDescription;
        this.systemIdentifier = obj.systemIdentifier;
        this.externalIdentifier = obj.externalIdentifier;
        this.hasExternalSource = obj.hasExternalSource;
    }

    linearMeters: number | undefined;
    digitalSize: number | undefined;
    inventoryCount: number | null | undefined;
    aeCount: number | null | undefined; // ArchiveEntityCount
    immediateSourceOfAcquisition: string | null | undefined;
    archive: string | undefined;
    number: string | null | undefined; // FundNumbe
    fundType: string | null | undefined;
    industryIndex: string | null | undefined;
    methodOfAcquisition: string | null | undefined;
    textDate: string | null | undefined;
    startDate: string | null | undefined;
    endDate: string | null | undefined;
    creationDate: string | null | undefined;
    title: string | null | undefined;
    note: string | null | undefined;
    fundStatus: string | null | undefined;
    levelOfDescription: string | null | undefined;
    systemIdentifier: string | null;
    externalIdentifier: number | null;
    hasExternalSource: boolean;
}

export class FundAvailabilityReportFiltersModel extends ReportInputBaseModel {
    ReportResultType: number = 1;
    FundArraysInternal: string[] = [];
    PeriodGids: string[] = []; // това е наименованието на FundArraysExternal в ИСДА
    FundArrays: string[] = [];
    FundTypesInternal: string[] = [];
    FundTypeGids: string[] = []; // това е наименованието на FundTypesExternal в ИСДА
    FundTypes: string[] = [];
    MethodsOfAcquisitionInternal: string[] = [];
    MethodOfAcquisitionGids: string[] = []; // това е наименованието на MethodsOfAcquisitionExternal в ИСДА
    MethodsOfAcquisition: string[] = [];
    // Архивите искат да се махне, но го правя така, че да няма ефект, защото не знам дали няма да си променят решението
    ProcessTypesInternal: string[] = [allFromDropdownValue];
    ProcessGids: string[] = [allFromDropdownValue];
    ProcessTypes: string[] = [allFromDropdownValue];
    FileFormats: string[] = [];
    RegisteredFrom: Date | null = null;
    RegisteredTo: Date | null = null;
    TextDate: string | null = null;
    DateFrom: Date | null = null;
    DateTo: Date | null = null;
    ItemsPerPage: number = 10;
}

export class FundAvailabilityReport {
    archive: string | null = null;
    number: string | null = null; // FundNumbe
    title: string | null = null;
    fundType: string | null = null;
    methodOfAcquisition: string | null = null;
    textDate: string | null = null;
    creationDate: string | null = null;
    fundStatus: string | null = null;
    aeCount: number | null = null; // ArchiveEntityCount
    documentCount: number | null = null;
    inventoryCount: number | null = null;
    fileFormats: string | null = null;
    size: number | null = null;
    duration: string | null = null;
    linearMeters: number = 0;
    note: string | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: string | null = null;
    hasExternalSource: boolean = false;
}

export class FundsReportSummary {
    totalInventories: number = 0;
    totalArchiveEntities: number = 0;
    totalSize: number = 0;
    totalDuration: number | null = null;
    totalLinearMeters: number = 0;
}

export class FundsListReport {
    constructor(obj: IFund) {
        this.number = obj.number;
        this.creationDate = obj.creationDate;
        this.title = obj.title;
        this.note = obj.note;
        this.systemIdentifier = obj.systemIdentifier;
        this.externalIdentifier = obj.externalIdentifier;
        this.hasExternalSource = obj.hasExternalSource;
    }

    number: string | null | undefined;
    creationDate: string | null | undefined;
    title: string | null | undefined;
    note: string | null | undefined;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class FundsListReportSummary {
    totalRows: number = 0;
}

export class FundMemoriesListReport {
    constructor(obj: IFundMemoriesAndReceiptsLists) {
        this.number = obj.number;
        this.creationDate = obj.creationDate;
        this.immediateSourceOfAcquisitionPlusMethodOfAcquisition =
            obj.immediateSourceOfAcquisitionPlusMethodOfAcquisition;
        this.title = obj.title;
        this.сreatingType = obj.сreatingType;
        this.linearMeters = obj.linearMeters;
        this.digitalSize = obj.digitalSize;
        this.note = obj.note;
        this.systemIdentifier = obj.systemIdentifier;
        this.externalIdentifier = obj.externalIdentifier;
        this.hasExternalSource = obj.hasExternalSource;
    }

    number: string | null | undefined;
    creationDate: string | null | undefined;
    immediateSourceOfAcquisitionPlusMethodOfAcquisition: string | null | undefined;
    title: string | null | undefined;
    сreatingType: string | null | undefined;
    linearMeters: number | undefined;
    digitalSize: number | null | undefined;
    note: string | null | undefined;
    systemIdentifier: string | null;
    externalIdentifier: number | null;
    hasExternalSource: boolean;
}

export class FundReportSummary2 {
    totalRows: number = 0;
    totalLinearMeters: number = 0;
    totalSize: number = 0;
}

export class FundMemoriesListInternalReportModel {
    immediateSourceOfAcquisition: string | null = null;
    accessConditions: string | null = null;
    archive: string = '';
    number: string | null = null; // FundNumber
    fundType: string | null = null;
    creationDate: string | null = null;
    title: string | null = null;
    note: string | null = null;
    fundStatus: string | null = null;
    creationMethod: string | null = null;
    linearMeters: number | null = null;
    size: number | null = null;
    duration: string | null = null;
    fileFormats: string | null = null;
    hasExternalSource: boolean = false;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
}

export class FundMemoriesListInternalReportSummary {
    totalRows: number = 0;
    totalLinearMeters: number = 0;
    totalSize: number = 0;
    totalDuration: number = 0;
}

export class FundMemoriesListInternalReportFiltersModel extends ReportInputBaseModel {
    ReportResultType: number = 1;
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

export class FundMemoryReportSummary {
    totalRows: number = 0;
    totalLinearMeters: number = 0;
}

export class PartialReceiptsListReport {
    constructor(obj: PartialReceiptsListReport) {
        this.number = obj.number;
        this.creationDate = obj.creationDate;
        this.immediateSourceOfAcquisitionPlusMethodOfAcquisition =
            obj.immediateSourceOfAcquisitionPlusMethodOfAcquisition;
        this.title = obj.title;
        this.volumeInSheets = obj.volumeInSheets;
        this.digitalSize = obj.digitalSize;
        this.note = obj.note;
        this.systemIdentifier = obj.systemIdentifier;
        this.externalIdentifier = obj.externalIdentifier;
        this.hasExternalSource = obj.hasExternalSource;
    }

    number: string | null | undefined;
    creationDate: string | null | undefined;
    immediateSourceOfAcquisitionPlusMethodOfAcquisition: string | null | undefined;
    title: string | null | undefined;
    volumeInSheets: string | null | undefined;
    digitalSize: number | null | undefined;
    note: string | null | undefined;
    systemIdentifier: string | null;
    externalIdentifier: number | null;
    hasExternalSource: boolean;
}

export class FundReportSummary1 {
    totalRows: number = 0;
    totalInventories: number = 0;
    totalArchiveEntities: number = 0;
    totalSize: number = 0;
    totalLinearMeters: number = 0;
}

export class ReceiptsListReportFiltersModel extends ListFiltersModel {
    RegisteredFrom: Date | null = null;
    RegisteredTo: Date | null = null;
}

export class ReceiptsListReport {
    constructor(obj: IFundMemoriesAndReceiptsLists) {
        this.rowNumber = obj.rowNumber;
        this.number = obj.number;
        this.creationDate = obj.creationDate;
        this.immediateSourceOfAcquisitionPlusMethodOfAcquisition =
            obj.immediateSourceOfAcquisitionPlusMethodOfAcquisition;
        this.title = obj.title;
        this.linearMeters = obj.linearMeters;
        this.digitalSize = obj.digitalSize;
        this.archiveEntitiesCount = obj.archiveEntitiesCount;
        this.textDate = obj.textDate;
        this.fundOwnership = obj.fundOwnership;
        this.note = obj.note;
        this.systemIdentifier = obj.systemIdentifier;
        this.externalIdentifier = obj.externalIdentifier;
        this.hasExternalSource = obj.hasExternalSource;
    }

    rowNumber: number | null | undefined;
    number: string | null | undefined;
    creationDate: string | null | undefined;
    immediateSourceOfAcquisitionPlusMethodOfAcquisition: string | null | undefined;
    title: string | null | undefined;
    linearMeters: number | null | undefined;
    digitalSize: number | null | undefined;
    archiveEntitiesCount: number | null | undefined;
    textDate: string | null | undefined;
    fundOwnership: string | null | undefined;
    note: string | null | undefined;
    systemIdentifier: string | null;
    externalIdentifier: number | null;
    hasExternalSource: boolean;
}

export class WorkListForPriorityRestorationReport {
    constructor(obj: IWorkListForPriorityRestorationReport) {
        this.fundNumber = obj.fundNumber;
        this.inventoryNumber = obj.inventoryNumber;
        this.archiveEntityNumber = obj.archiveEntityNumber;
        this.documentSystemId = obj.documentSystemId;
        this.paperCount = obj.paperCount;
        this.physicalCondition = obj.physicalCondition;
        this.copyDigital = obj.copyDigital;
        this.copyMicrofilm = obj.copyMicrofilm;
        this.systemIdentifier = obj.systemIdentifier;
        this.externalIdentifier = obj.externalIdentifier;
        this.hasExternalSource = obj.hasExternalSource;
    }

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

export class InventoryBook {
    constructor(obj: IInventoryBook) {
        this.number = obj.number;
        this.receivedOn = obj.receivedOn;
        this.countryOfOrigin = obj.countryOfOrigin;
        this.negatives = obj.negatives;
        this.positives = obj.positives;
        this.copyXerox = obj.copyXerox;
        this.copyDigital = obj.copyDigital;
        this.hasInventory = obj.hasInventory;
        this.shortDescription = obj.shortDescription;
        this.creationAuthor = obj.creationAuthor;
        this.note = obj.note;
        this.systemIdentifier = obj.systemIdentifier;
        this.externalIdentifier = obj.externalIdentifier;
        this.hasExternalSource = obj.hasExternalSource;
    }

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

export class AccountAndDescriptionOfFilmDocumentsBook {
    receivedOn: string | null = null;
    // title:
    creationAuthor: string | null = null;
    // оригинал/копие:
    immediateSourceOfAcquisition: string | null = null;
    countryOfOrigin: string | null = null;
    // documentsCharacteristics:
    // съпроводителна текстова документация:
    // документ, въз основа на който е приет:
    fundNumberAndInventoryAndArchiveEntiry: string | null = null;
    note: string | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class InsuranceFundOfCopiesOfForeignArchives {
    kmfNumber: string | null = null;
    number: string | null = null;
    copyNegativeRolls: number = 0;
    copyNegativeFrames: number = 0;
    copyPositiveRolls: number = 0;
    copyPositiveFrames: number = 0;
    copyXerox: string | null = null;
    copyDigital: string | null = null;
    electronicDocumentsCount: number = 0;
    electronicDocumentsSize: number = 0;
    other: string | null = null;
    doublesNegativeCount: number = 0;
    doublesNegativeLocation: string | null = null;
    doublesPositiveCount: number = 0;
    doublesPositiveLocation: string | null = null;
    photolabDeliveryDate: string | null = null;
    note: string | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class InventoryBookOfCopiesFromForeignArchives {
    kmfNumber: string | null = null;
    inventoryNumber: string | null = null;
    receivedOn: string | null = null;
    countryOfOrigin: string | null = null;
    framesCount: number | null = null;
    microfilmNegativeRollsCount: number | null = null;
    microfilmNegativeFramesCount: number | null = null;
    microfilmPositiveRollsCount: number | null = null;
    microfilmPositiveFramesCount: number | null = null;
    xeroxCopy: string | null = null;
    digitalCopy: string | null = null;
    electronicDocumentsCount: number | null = null;
    electronicDocumentsSize: string | null = null;
    other: string | null = null;
    hasInventory: boolean | null = null;
    inventoryShortDescription: string | null = null;
    creationAuthor: string | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class CompilationAndNTOOfEDocumentsFiltersModel extends ReportInputBaseModel {
    FundArraysInternal: IDropdownOption[] = [];
    FundTypesInternal: IDropdownOption[] = [];
    MethodsOfAcquisitionInternal: IDropdownOption[] = [];
    MethodsOfAcquisition: IDropdownOption[] = [];
    ProcessTypes: IDropdownOption[] = [];
    FileFormats: IDropdownOption[] = [];
    RegisteredFrom: Date | null = null;
    RegisteredTo: Date | null = null;
    ProcessStartDate: Date | null = null;
    ProcessEndDate: Date | null = null;
    DateFrom: Date | null = null;
    DateTo: Date | null = null;
    FundLevelOfdescriptionCodes: IDropdownOption[] = [];
    ItemsPerPage: number = 10;
}
export class CompilationAndNTOOfEDocuments {
    archive: string | null = null;
    fundNumber: string | null = null;
    title: string | null = null;
    methodOfAcquisitions: string | null = null;
    type: string | null = null;
    chronologicalScope: string | null = null;
    dateOfFiling: Date | null = null;
    status: string | null = null;
    levelOfDescription: string | null = null;
    inventoryCount: number | null = null;
    aeCount: number | null = null;
    documentCount: number | null = null;
    fileFormats: string | null = null;
    bytes: number | null = null;
    duration: string | null = null;
    note: string | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class CompilationAndNTOOfEDocumentsCombinedModel {
    fundsCount: number | null = null;
    inventoriesCount: number | null = null;
    aesCount: number | null = null;
    bytes: number | null = null;
    duration: string | null = null;
}

export class RegisterOfDigitizedDocumentsReportFiltersModel {
    // constructor(obj: RegisterOfDigitizedDocumentsReportFiltersModel) {
    //   this.ReportResultType = obj.ReportResultType || 1;
    // }
    ArchiveCodesInternal: IDropdownOption[] = [];
    ArchiveGids: IDropdownOption[] = []; // Външна номеклатура
    Archives: IDropdownOption[] = []; // Външна и вътрешна номеклатура заедно
    ItemsPerPage: number = 10;
    ReportResultType: number = 1;
    RegisteredFrom: Date | null = null;
    RegisteredTo: Date | null = null;
}

export class RegisterOfDigitizedDocumentsReport {
    documentLink: string | null = null;
    archiveCode: string | null = null;
    archiveName: string | null = null;
    systemId: string | null = null;
    levelOfDescription: string | null = null;
    fundNumber: string | null = null;
    inventoryNumber: string | null = null;
    archiveEntityNumber: string | null = null;
    title: string | null = null;
    docCreationDate: string | null = null;
    themes: string | null = null;
    docStatus: string | null = null;
    creationDateDO: string | null = null;
    recordsCountDO: number | null = null;
    duration: string | null = null;
    digitalObjectRecreationDate: string | null = null;
    bytesDO: string | null = null;
    statusDO: string | null = null;
    operator: string | null = null;
    correctionReturnDate: string | null = null;
    finalCorrectionDate: string | null = null;
    digitalObjectAcceptanceDate: string | null = null;
    fundIntNumber: number | null = null;
    inventoryIntNumber: number | null = null;
    archivalEntityIntNumber: number | null = null;
    ArchiveSortOrder: number | null = null;
    mastersCount: number | null = null;
    allDOCount: number | null = null;

}

export class RegisterOfDigitizedDocumentsCombined {
    periodFrom: string | null = null;
    periodTo: string | null = null;
}
export class RegisterOfDigitizedDocumentsSummary {
    totalRows: number | null = null;
    totalBytesCount: number | null = null;
    totalDuration: number | null = null;
    mastersCount: number | null = null;
    allDOCount: number | null = null;
}

export class RegisterOfDigitizedDocumentsSummaryAndCombined {
    summary: RegisterOfDigitizedDocumentsSummary | null = null;
    combined: RegisterOfDigitizedDocumentsCombined | null = null;
}

export class CountOfUsedCopiesOfDocumentsFromForeignArchivesFiltersModel {
    ArchiveCodesInternal: IDropdownOption[] = [];
    ArchiveGids: IDropdownOption[] = []; // Външна номеклатура
    Archives: IDropdownOption[] = []; // Външна и вътрешна номеклатура заедно
    ItemsPerPage: number = 10;
}

export class CountOfUsedCopiesOfDocumentsFromForeignArchivesReport {
    kmfNumber: string | null = null;
    inventoryNumber: string | null = null;
    statementDate: string | null = null;
    employee: string | null = null;
    reader: string | null = null;
    aeCount: number | null = null;
    ElectronicalDocumentsCount: number | null = null;
    ElectronicalDocumentsMB: number | null = null;
}

export class CountOfUsedCopiesOfDocumentsFromForeignArchivesCombinedBeforeSplit {
    employeeRowName: string | null = null;
    employeeKMFCount: number | null = null;
    employeeAECount: number | null = null;
    employeeElDocsCount: number | null = null;
    employeeElDocsMB: number | null = null;
    readerRowName: string | null = null;
    readerKMFCount: number | null = null;
    readerAECount: number | null = null;
    readerElDocsCount: number | null = null;
    readerElDocsMB: number | null = null;
    totalRowName: string | null = null;
    totalKMFCount: number | null = null;
    totalAECount: number | null = null;
    totalElDocsCount: number | null = null;
    totalElDocsMB: number | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined {
    rowName: string | null | undefined = null;
    kmfCount: number | null | undefined = null;
    aeCount: number | null | undefined = null;
    elDocsCount: number | null | undefined = null;
    elDocsMB: number | null | undefined = null;
}

export class QualityControlFiltersModel {
    ItemsPerPage: number = 10;
    ArchiveIds: IDropdownOption[] = [];
    Statuses: IDropdownOption[] = [];
    Employee: string | null = null;
    DateFrom: Date | null = null;
    DateTo: Date | null = null;
}

export class QualityControlReport {
    archive: string | null = null;
    employer: string | null = null;
    checkedDocuments: number | null = null;
    checkedDo: number | null = null;
    acceptedDocuments: number | null = null;
    acceptedDo: number | null = null;
    returnedDocuments: number | null = null;
    returnedDo: number | null = null;
}

export class QualityControlCombined {
    periodFrom: string | undefined | null = null;
    periodTo: string | undefined | null = null;
    checkedDocuments: number | undefined | null = null;
    checkedDo: number | undefined | null = null;
    acceptedDocuments: number | undefined | null = null;
    acceptedDo: number | undefined | null = null;
    returnedDocuments: number | undefined | null = null;
    returnedDo: number | undefined | null = null;
}

export class DigitalObjectsPreparationReport {
    archive: string | null = null;
    employer: string | null = null;
    newDocuments: number | null = null;
    newDo: number | null = null;
    recreatedDocuments: number | null = null;
    recreatedDo: number | null = null;
}

export class DigitalObjectsPreparationCombined {
    periodFrom: string | undefined | null = null;
    periodTo: string | undefined | null = null;
    newDocuments: number | undefined | null = null;
    newDo: number | undefined | null = null;
    recreatedDocuments: number | undefined | null = null;
    recreatedDo: number | undefined | null = null;
}

export class WorkDoneOnDigitalObjectsCombinedReportInputModel {
    ItemsPerPage: number = 10;
    ArchiveCodes: string[] = [];
    Employees: string[] = [];
    Statuses: string[] = [];
    DateFrom: Date | null = null;
    DateTo: Date | null = null;
}

export class SpecialRegistrationListReportModel {
    title: string | null = null;
    archive: string | null = null;
    descriptionLevel: string | null = null;
    fundNumber: string | null = null;
    inventoryNumber: string | null = null;
    archiveEntityNumber: string | null = null;
    size: number | null = null;
    papersCount: number | null = null;
    startDate: string | null = null;
    endDate: string | null = null;
    physicalCondition: string | null = null;
    isInRisk: boolean | null = null;
    location: string | null = null;
    buildingNumber: string | null = null;
    floorNumber: string | null = null;
    premisesNumber: string | null = null;
    roomNumber: string | null = null;
    stillageNumber: string | null = null;
    rowNumber: string | null = null;
    cellNumber: string | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class SpecialRegistrationListReportFiltersModel {
    ArchiveGids: string[] = [];
    FundNumber: string | null = null;
    InventoryNumber: string | null = null;
    ArchiveEntityNumber: string | null = null;
    IsInRisk: boolean = false;
    DescriptionLevel: string[] = [];
    ItemsPerPage: number = 10;
}

export class NumberOfArchiveEntitiesOrderedByReaderReportFiltersModel {
    ReportResultType: number = 1;
    FundTypeGids: IDropdownOption[] = [];
    FundTypesInternal: IDropdownOption[] = [];
    Funds: IDropdownOption[] = [];
    ArchiveGids: IDropdownOption[] = [];
    ArchiveCodesInternal: IDropdownOption[] = [];
    Archives: IDropdownOption[] = [];
    InventoryGids: IDropdownOption[] = [];
    InventoryInternal: IDropdownOption[] = [];
    Inventories: IDropdownOption[] = [];
    DateFrom: Date | null = null;
    ArchiveEntitiesDescriptionLevelsGids: IDropdownOption[] = [];
    ArchiveEntitiesDescriptionLevelsInternal: IDropdownOption[] = [];
    ArchiveEntitiesDescriptionLevels: IDropdownOption[] = [];
    DateTo: Date | null = null;
    StatisticDataOnly: boolean = false;
    ItemsPerPage: number = 10;
}

export class NumberOfArchiveEntitiesOrderedByReaderReport {
    reader: string | null = null;
    archive: string | null = null;
    levelOfDescription: string | null = null;
    fund: string | null = null;
    inventory: string | null = null;
    archiveEntity: string | null = null;
    document: string | null = null;
    applicationDate: string | null = null;
    accessDate: string | null = null;
}

export class NumberOfArchiveEntitiesOrderedByReaderCombined {
    totalCount: number | null = null;
    totalDocumentsCount: number | null = null;
}

export class NumberOfArchiveEntitiesOrderedByReaderSummary {
    totalRows: number | null = null;
}

export class NumberOfArchiveEntitiesOrderedByEmployeeReportFiltersModel extends ReportInputBaseModel {
    ReportResultType: number = 1;
    FundTypeGids: IDropdownOption[] = [];
    FundTypesInternal: IDropdownOption[] = [];
    Funds: IDropdownOption[] = [];
    ArchiveGids: IDropdownOption[] = [];
    ArchiveCodesInternal: IDropdownOption[] = [];
    Archives: IDropdownOption[] = [];
    InventoryGids: IDropdownOption[] = [];
    InventoryInternal: IDropdownOption[] = [];
    Inventories: IDropdownOption[] = [];
    DateFrom: Date | null = null;
    AchiveEntitiesDescriptionLevels: IDropdownOption[] = [];
    AchiveEntitiesDescriptionLevelsGids: IDropdownOption[] = [];
    AchiveEntitiesDescriptionLevelsInternal: IDropdownOption[] = [];
    DateTo: Date | null = null;
    StatisticDataOnly: boolean = false;
    ItemsPerPage: number = 10;
    EmployeeNames: IDropdownOption[] = [];
    EmployeeNamesGids: IDropdownOption[] = [];
    EmployeeNamesInternal: IDropdownOption[] = [];
}

export class NumberOfArchiveEntitiesOrderedByEmployeeReport {
    employeeName: string | null = null;
    archive: string | null = null;
    levelOfDescription: string | null = null;
    fund: string | null = null;
    inventory: string | null = null;
    archiveEntity: string | null = null;
    document: string | null = null;
    accessDate: string | null = null;
}

export class NumberOfArchiveEntitiesOrderedByEmployeeCombined {
    totalCount: number | null = null;
    totalDocumentsCount: number | null = null;
}

export class NumberOfArchiveEntitiesOrderedByEmployeeSummary {
    totalRows: number | null = null;
}

export class MostUsedRequestEntitiesReportModel {
    archive: string | null = null;
    descriptionLevel: string | null = null;
    fundNumber: string | null = null;
    inventoryNumber: string | null = null;
    archiveEntityNumber: string | null = null;
    documentNumber: string | null = null;
    usageCount: number = 0;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class MostUsedRequestEntitiesReportFiltersModel {
    ReportResultType: number = 1;
    Archives: string[] = [];
    FundNumber: string | null = null;
    InventoryNumber: string | null = null;
    ArchiveEntityNumber: string | null = null;
    DocumentNumber: string | null = null;
    FundLevelOfdescriptionCodes: string | null = null;
    descriptionLevelsExternal: string[] = [];
    descriptionLevels: string[] = [];
    ItemsPerPage: number = 10;
}

export class NumberOfDocumentsOrderedByReaderReportFiltersModel {
    ArchiveCodes: IDropdownOption[] = [];
    FundNumber: string | null = null;
    FundLevelOfdescriptionCodes: IDropdownOption[] = [];
    InventoryNumber: string | null = null;
    LibraryCardNumber: string | null = null;
    DateFrom: Date | null = null;
    DateTo: Date | null = null;
    StatisticDataOnly: boolean = false;
    ItemsPerPage: number = 10;
}

export class NumberOfDocumentsOrderedByReaderReport {
    reader: string | null = null;
    libraryCardNumber: string | null = null;
    archive: string | null = null;
    fundLevelOfDescription: string | null = null;
    fund: string | null = null;
    inventory: string | null = null;
    archiveEntity: string | null = null;
    document: string | null = null;
    accessDate: Date | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class NumberOfDocumentsOrderedByReaderReportCombined {
    disticntAEsCount: number | null = null;
    documentsReviewsCount: number | null = null;
}

export class NumberOfDocumentsOrderedByReaderReportSummary {
    totalRows: number | null = null;
}

export class NumberOfDocumentsOrderedByEmployeeReportFiltersModel {
    ArchiveCodes: IDropdownOption[] = [];
    FundNumber: string | null = null;
    FundLevelOfdescriptionCodes: IDropdownOption[] = [];
    InventoryNumber: string | null = null;
    Employee: string | null = null;
    DateFrom: Date | null = null;
    DateTo: Date | null = null;
    StatisticDataOnly: boolean = false;
    ItemsPerPage: number = 10;
}

export class NumberOfDocumentsOrderedByEmployeeReport {
    employee: string | null = null;
    archive: string | null = null;
    fundLevelOfDescription: string | null = null;
    fund: string | null = null;
    inventory: string | null = null;
    archiveEntity: string | null = null;
    document: string | null = null;
    accessDate: Date | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
    inventoryNumber: string | null = null;
    archivalEntityNumber: string | null = null;
    documentNumber: string | null = null;
}

export class NumberOfDocumentsOrderedByEmployeeReportCombined {
    disticntAEsCount: number | null = null;
    documentsReviewsCount: number | null = null;
}

export class NumberOfDocumentsOrderedByEmployeeReportSummary {
    totalRows: number | null = null;
}

export class ReportGridResponseModel1<T> {
    constructor(obj: IReportGridResponseModel1<T>) {
        this.totalCount = obj.totalCount || 0;
        this.items = obj.items || 0;
        this.usageCountTotal = obj.usageCountTotal || 0;
    }

    totalCount: number;
    items: T[];
    usageCountTotal: number;
}

export class ReportGridResponseModel2<T> extends ReportGridResponseModel<T> {
    total: number = 0;
}

export class ActiveProcessesReportModel {
    archive: string | null = null;
    descriptionLevel: string | null = null;
    fundNumber: string | null = null;
    title: string | null = null;
    documentId: string | null = null;
    documentNumber: string | null = null;
    processName: string | null = null;
    processStartDate: string | null = null;
    initiator: string | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class ActiveProcessesReportFiltersModel {
    Archives: string[] = [];
    ReportResultType: number = 1;
    ProcessStartedFrom: Date | null = null;
    ProcessStartedTo: Date | null = null;
    FundNumber: string | null = null;
    ProcessGids: IDropdownOption[] = [];
    ProcessTypes: string[] = [];
    ProcessTypesInternal: IDropdownOption[] = [];
    UserGids: IDropdownOption[] = [];
    Users: string[] = [];
    UserIdsInternal: IDropdownOption[] = [];
    ItemsPerPage: number = 10;
}

export class InventoryReportFiltersModel {
    ReportResultType: number = 1;
    ItemsPerPage: number = 10;
    Page: number = 1;
    Archives: IDropdownOption[] = [];
    Statuses: IDropdownOption[] = [];
    FundNumber: string | null = null;
    RegisteredFrom: Date | null = null;
    RegisteredTo: Date | null = null;
    ChronologicalScope: string | null = null;
    ChronologicalScopeStartDate: Date | null = null;
    ChronologicalScopeEndDate: Date | null = null;
}

export class InventoryReport {
    archive: string | null = null;
    fundDescriptionLevel: string | null = null;
    fundNumber: string | null = null;
    fundTitle: string | null = null;
    inventoryNumber: string | null = null;
    inventoryDescriptionLevel: string | null = null;
    status: string | null = null;
    aeCount: number | null = null;
    aeWithCharCount: number | null = null;
    eDocumentsCount: number | null = null;
    linearMeters: number | null = null;
    fileFormat: string | null = null;
    duration: string | null = null;
    mb: number | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class InventoryReportCombined {
    inventoryCount: number | null = null;
    aeCount: number | null = null;
    aeWithCharCount: number | null = null;
    eDocumentsCount: number | null = null;
    duration: number | null = null;
    linearMeters: number | null = null;
    mb: number | null = null;
}

export class InventoryReportSummary {
    totalRows: number | null = null;
}

export class ListOfRoughDocumentsReportFiltersModel {
    ReportResultType: number = 1;
    ItemsPerPage: number = 10;
    Page: number = 1;
    Archives: IDropdownOption[] = [];
    FundTypesInternal: string[] = [];
    FundTypeGids: string[] = []; // това е наименованието на FundTypesExternal в ИСДА
    FundTypes: string[] = [];
    IndustryIndexGids: IDropdownOption[] = [];
    IndustryIndexesInternal: IDropdownOption[] = [];
    IndustryIndexes: IDropdownOption[] = [];
    MethodOfAcquisitionGids: IDropdownOption[] = [];
    MethodsOfAcquisitionInternal: IDropdownOption[] = [];
    MethodsOfAcquisition: IDropdownOption[] = [];
    Statuses: IDropdownOption[] = [];
    FundNumber: string | null = null;
    RegisteredFrom: Date | null = null;
    RegisteredTo: Date | null = null;
    ChronologicalScope: string | null = null;
    ChronologicalScopeStartDate: Date | null = null;
    ChronologicalScopeEndDate: Date | null = null;
}

export class ListOfRoughDocumentsReport {
    countryCode: string | null = null;
    archive: string | null = null;
    fundNumber: string | null = null;
    fundTitle: string | null = null;
    entryDate: string | null = null;
    roughInventoryNumber: string | null = null;
    acquisitionMethod: string | null = null;
    status: string | null = null;
    linearMeters: number | null = null;
    bytes: number | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class ListOfRoughDocumentsReportCombined {
    fundCount: number | null = null;
    inventoryCount: number | null = null;
    linearMeters: number | null = null;
    bytes: number | null = null;
}

export class ListOfRoughDocumentsReportSummary {
    totalRows: number | null = null;
}

export class DigitalDocumentsUsageReportFiltersModel extends ReportInputBaseModelInternalOnly {
    DateFrom: string | null = null;
    DateTo: string | null = null;
    ItemsPerPage: number = 10;
}

export class DigitalDocumentsUsageReportModel {
    archiveName: string | null = null;
    documentSystemIdentifier: string | null = null;
    documentTitle: string | null = null;
    EmpCount: number | null = null;
    CdhCount: number | null = null;
    OtherCount: number | null = null;
}

export class DigitalDocumentsUsageReportSummaryModel {
    rowTitle: string | null = null;
    rowValue: number | null = null;
}

export class ListOfPartialReceiptsInArchiveReportFiltersModel {
    ReportResultType: number = 1;
    ItemsPerPage: number = 10;
    Page: number = 1;
    Archives: IDropdownOption[] = [];
    PeriodGids: IDropdownOption[] = [];
    FundArraysInternal: IDropdownOption[] = [];
    FundArrays: IDropdownOption[] = [];
    Statuses: IDropdownOption[] = [];
    // махат се по забележка от ИСДА
    //FundTypeGids: IDropdownOption[] = [];
    //FundTypesInternal: IDropdownOption[] = [];
    //FundTypes: IDropdownOption[] = [];
    MethodOfAcquisitionGids: IDropdownOption[] = [];
    MethodsOfAcquisitionInternal: IDropdownOption[] = [];
    MethodsOfAcquisition: IDropdownOption[] = [];
    RegisteredFrom: Date | null = null;
    RegisteredTo: Date | null = null;
    ChronologicalScope: string | null = null;
    ChronologicalScopeStartDate: Date | null = null;
    ChronologicalScopeEndDate: Date | null = null;
}

export class ListOfPartialReceiptsInArchiveReport {
    countryCode: string | null = null;
    archive: string | null = null;
    fundNumber: string | null = null;
    fundTitle: string | null = null;
    creationDate: string | null = null;
    immediateSourceOfAcquisition: string | null = null;
    //fundType: string | null = null; отпада по забележка на Архивите
    documentProperties: string | null = null;
    note: string | null = null;
    fundStatus: string | null = null;
    methodOfAcquisition: string | null = null;
    chronologicalScope: string | null = null;
    // махат се по забележка от ИСДА
    //chronologicalScopeStartDate: string | null = null;
    //chronologicalScopeEndDate: string | null = null;
    inventoryCount: number | null = null;
    aeCount: number | null = null;
    linearMeters: number | null = null;
    size: number = 0;
    duration: string | null = null;
    eDocumentsCount: number = 0;
    FileFormats: string | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class ListOfPartialReceiptsInArchiveReportCombined {
    fundCount: number | null = null;
    inventoryCount: number | null = null;
    aeCount: number | null = null;
    linearMeters: number | null = null;
    size: number = 0;
    duration: string | null = null;
    eDocumentsCount: number = 0;
}

export class ListOfPartialReceiptsInArchiveReportSummary {
    totalRows: number | null = null;
}

export class UserActionsJournalReportFiltersModel {
    ItemsPerPage: number = 10;
    Page: number = 1;
    EmployeeNames: IDropdownOption[] = [];
    ArchiveCodes: IDropdownOption[] = [];
    FundNumber: string | null = null;
    InventoryNumber: string | null = null;
    ArchiveEntityNumber: string | null = null;
    DateFrom: Date | null = null;
    DateTo: Date | null = null;
    Process: IDropdownOption[] = [];
    KmfNumber: string | null = null;
    DescriptionLevel: IDropdownOption[] = [];
}

export class UserActionsJournalReport {
    archiveName: string | null = null;
    archiveCode: number | null = null;
    descriptionLevel: string | null = null;
    kmf: string | null = null;
    fund: string | null = null;
    inventory: number | null = null;
    archivalEntity: string | null = null;
    documentServiceNumber: number | null = null;
    employee: string | null = null;
    date: string | null = null;
    process: string | null = null;
    steps: string | null = null;
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class UserActionsJournalReportSummary {
    totalRows: number | null = null;
}

export class CardForm1Summary {
    archive: string | null = null;
    archiveCode: number | null = null;
    number: string | null = null;
    title: string | null = null;
    type: string | null = null;
    creationDate: string | null = null;
    industryIndex: string | null = null;
    inventoriesCount: number | null = null;
    archivalEntitiesCount: number | null = null;
    methodOfAcquisition: string | null = null;
}

export class CardForm1InternalData {
    systemIdentifier: string | null = null;
    yearCreatedAndInventoryNumber: string | null = null;
    endDates: string | null = null;
    inventorizedCount: string | null = null;
    uninventorizedCount: string | null = null;
    deductedCount: string | null = null;
    availableArchivalEntitiesCountAndSize: string | null = null;
    documentsCount: number | null = null;
}

export class CardForm1SummaryInternalData extends CardForm1Summary {
    size: number | null = null;
}

export class CardForm1InternalDataFiltersModel {
    FundSystemIdentifier: string | null = null;
}

export class CardForm1Data {
    lGid: string | null = null;
    systemIdentifier: string | null = null;
    yearCreatedAndInventoryNumber: string | null = null;
    endDates: string | null = null;
    inventorizedCount: string | null = null;
    uninventorizedCount: string | null = null;
    deductedCount: string | null = null;
    availableArchivalEntitiesCountAndSize: string | null = null;
    documentsCount: string | null = null;
    microfilmedArchivalOfEntityCount: number | null = null;
    negativeFramesCount: number | null = null;
    positiveFramesCount: number | null = null;
    phonoDocumentsCount: number | null = null;
    photoDocumentsCount: number | null = null;
    videoDocumentsCount: number | null = null;
    digitalDocumentCount: number | null = null;
    availableMicrofilmedArchivalEntitiesCountAndSize: string | null = null;
    intNumber: number | null = null;
    number: number | null = null;
}

export class CardForm1DataFiltersModel {
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean | null = null;
}
export class CardForm1SummaryExternalData extends CardForm1Summary {
    linearMeters: number | null = null;
    size: number | null = null;
}

export class FundDataReportFiltersModel extends ReportInputBaseModel {
    ReportResultType: number = 1;
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

export class FundDataReport {
    systemId: number = 0;
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
    systemIdentifier: string | null = null;
    externalIdentifier: number | null = null;
    hasExternalSource: boolean = false;
}

export class FundDataReportSummary {
    linearMeters: number = 0;
    funds: number | null = null;
    inventories: number | null = null;
    archiveEntities: number | null = null;
    size: number | null = null;
    duration: number | null = null;
    eDocumentsCount: number | null = null;
}

export class WorkDoneOnDigitalObjectsReportFiltersModel {
    ArchiveCodes: string | null = null;
    FundArrays: string[] = [];
    UserIds: string[] = [];
    ProcessSteps: string[] = [];
    DigitalObjectStatuses: string[] = [];
    CreatedFrom: Date | null = null;
    CreatedTo: Date | null = null;
    ItemsPerPage: number = 10;
}

export class WorkDoneOnDigitalObjectsReportModel {
    archive: string | null = null;
    userName: string | null = null;
    digitalObjectsCount: number = 0;
    createdFrom: Date | null = null;
    createdTo: Date | null = null;
}
