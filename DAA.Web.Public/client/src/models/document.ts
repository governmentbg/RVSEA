import { IDocument } from '@/interfaces/document';

export class Document implements IDocument {
    constructor(obj?: IDocument) {
        Object.assign(this, obj);
    }
    archiveId?: number;
    archiveName?: string;
    systemIdentifier?: string;
    fundSystemIdentifier?: string;
    fundExternalIdentifier?: number;
    fundHasExternalSource?: boolean;
    inventorySystemIdentifier?: string;
    inventoryExternalIdentifier?: number;
    inventoryHasExternalSource?: boolean;
    archivalEntitySystemIdentifier?: string;
    archivalEntityExternalIdentifier?: number;
    archivalEntityHasExternalSource?: boolean;
    externalIdentifier?: number;
    number?: number;
    title?: string;
    descriptionLevelCode?: string;
    statusCode?: string;
    creationMethodCodes?: Array<string>;
    languageCodes?: Array<string>;
    originalityCodes?: Array<string>;
    fileTypeCodes?: Array<string>;
    scaling?: string;
    location?: string;
    bytes?: number;
    sheetCount?: number;
    startSheetNumber?: number;
    endSheetNumber?: number;
    digitalDevice?: string;
    duration?: number;
    sizeCm?: string;
    author?: string;
    description?: string;
    documentsAccessDescription?: string;
    features?: string;
    microfilmedCopyCount?: number;
    digitizedCopyCount?: number;
    paperCopyCount?: number;
    negativeFrameCount?: number;
    positiveFrameCount?: number;
    otherCopyCount?: string;
    transcription?: string;
    notes?: string;
    hasNoChronologicalScope?: boolean;
    startDateYear?: number;
    startDateMonth?: number;
    startDateDay?: number;
    endDateYear?: number;
    endDateMonth?: number;
    endDateDay?: number;
    approximateChronologicalScope?: string;
    resultMessage?: string;
}
