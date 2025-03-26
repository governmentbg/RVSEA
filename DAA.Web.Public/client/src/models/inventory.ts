import { IInventory } from '@/interfaces/inventory';

export class Inventory implements IInventory {
    constructor(obj?: IInventory) {
        Object.assign(this, obj);
    }
    systemIdentifier?: string;
    archiveId?: number;
    fundDraftId?: number;
    fundSystemIdentifier?: string;
    fundExternalIdentifier?: number;
    fundHasExternalSource?: boolean;
    externalIdentifier?: number;
    hasExternalSource?: boolean;
    numberArray?: string;
    number?: string;
    descriptionLevelCode?: string;
    statusCode?: string;
    acquisitionMethodCodes?: Array<string>;
    creationMethodCodes?: Array<string>;
    fileTypeCodes?: Array<string>;
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
    microfilmedArchivalEntityCount?: number;
    digitizedArchivalEntityCount?: number;
    negativeFrameCount?: number;
    positiveFrameCount?: number;
    resultMessage?: string;
}
