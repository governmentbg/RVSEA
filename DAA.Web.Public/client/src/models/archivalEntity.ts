import { IArchivalEntity } from '@/interfaces/archivalEntity';

export class ArchivalEntity implements IArchivalEntity {
    constructor(obj?: IArchivalEntity) {
        Object.assign(this, obj);
    }
    systemIdentifier?: string;
    archiveId?: number;
    archiveName?: string;
    fundSystemIdentifier?: string;
    fundExternalIdentifier?: number;
    fundHasExternalSource?: boolean;
    inventorySystemIdentifier?: string;
    inventoryExternalIdentifier?: number;
    inventoryHasExternalSource?: boolean;
    inventoryNumberArray?: string;
    hasExternalSource?: boolean;
    externalIdentifier?: number;
    number?: string;
    numberNumeric?: number;
    descriptionLevelCode?: string;
    statusCode?: string;
    creationMethodCodes?: Array<string>;
    languageCodes?: Array<string>;
    originalityCodes?: Array<string>;
    hasNoChronologicalScope?: boolean;
    startDateYear?: number;
    startDateMonth?: number;
    startDateDay?: number;
    endDateYear?: number;
    endDateMonth?: number;
    endDateDay?: number;
    approxmateChronologicalScope?: string;
    bytes?: number;
    linearMeters?: number;
    otherMetrics?: string;
    archivalEntityCount?: number;
    documentCount?: number;
    boxCount?: number;
    rollCount?: number;
    fundCreatorTitleHistory?: string;
    fundCreatorActivityHistory?: string;
    fundCreatorBiographicalHistory?: string;
    documentsProvider?: string;
    documentsDescription?: string;
    documentsAccessDescription?: string;
    history?: string;
    notes?: string;
    audioDocumentArchivalEntityCount?: number;
    photoDocumentArchivalEntityCount?: number;
    videoDocumentArchivalEntityCount?: number;
    digitalDocumentArchivalEntityCount?: number;
    classificationScheme?: string;
    abbreviationList?: string;
    microfilmedArchivalEntityCount?: number;
    digitizedArchivalEntityCount?: number;
    negativeFrameCount?: number;
    positiveFrameCount?: number;
    resultMessage?: string;
}

export class SearchedArchiveEntityRequestModel {
    constructor(obj?: unknown) {
        Object.assign(this, obj);
    }
    inventoryInternaIdentifier?: number;
    inventoryExternalIdentifier?: number;
    hasInventoryExternalSource?: boolean;
    searchText?: string;
}

export class DocumentAncestorsData {
    constructor(obj?: unknown) {
        Object.assign(this, obj);
    }
    archiveName?: string;
    archiveCode?: number;
    fundExternalIdentifier?: number;
    fundNumber?: string;
    inventoryExternalIdentifier?: number;
    inventoryNumber?: number;
    archiveEntityNumber?: string;
}
