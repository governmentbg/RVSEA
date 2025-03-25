import { IInventory, IInventoryDraft } from '@/interfaces/inventory';

export class Inventory implements IInventory {
    constructor(obj?: IInventory) {
        Object.assign(this, obj);
    }
    id?: number;
    systemIdentifier?: string;
    archiveId?: number;
    fundDraftId?: number;
    fundSystemIdentifier?: string;
    fundExternalIdentifier?: number;
    fundHasExternalSource?: boolean;
    externalIdentifier?: number;
    hasExternalSource?: boolean;
    numberArray?: string;
    numberNumeric?: number;
    number?: string;
    descriptionLevelCode?: string;
    availabilityStatusCode?: number;
    statusCode?: string;
    acquisitionMethodId?: number;
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
    classificationScheme?: string;
    abbreviationList?: string;
    microfilmedArchivalEntityCount?: number;
    digitizedArchivalEntityCount?: number;
    negativeFrameCount?: number;
    positiveFrameCount?: number;
    applicationId?: number;
    hasSystemApplication?: boolean;
    resultMessage?: string;
    textDocsCount?: number;
    graphicalDocsCount?: number;
    isInPersonalFund?: boolean;
    isInProcess?: boolean;
    enrolledLinearMeters?: number;
    deductedLinearMeters?: number;
    enrolledAECount?: number;
    deductedAECount?: number;
    enrolledBytes?: number;
    deductedBytes?: number;
    otherLanguage?: string;
}

export class InventoryDraft extends Inventory implements IInventoryDraft {
    constructor(obj?: IInventoryDraft) {
        super(obj);
        Object.assign(this, obj);
    }
    isCurrent?: boolean;
    readOnly?: boolean;
    workflowTypeCode?: string;
    workflowId?: number;
    workflowStepTypeCode?: string;
    workflowStepId?: number;
}

export class InventoryShort {
    constructor(obj?: IInventory) {
        Object.assign(this, obj);
        this.calculatedIdentifier =
            this.systemIdentifier + '|' + this.id?.toString() + '|' + this.externalIdentifier?.toString();
    }

    id?: number;
    systemIdentifier?: string;
    externalIdentifier?: number;
    calculatedIdentifier?: string;
    hasExternalSource?: boolean;
    isDraft?: boolean;
    archiveId?: number;
    archiveCode?: number;
    archiveName?: string;
    fundDraftId?: number;
    fundSystemIdentifier?: string;
    fundHasExternalSource?: boolean;
    fundExternalIdentiier?: number;
    fundNumber?: string;
    numberArray?: string;
    number?: string;
    approxmateChronologicalScope?: string;
    descriptionLevelCode?: string;
    descriptionLevelText?: string;
    availabilityStatusCode?: number;
    availabilityStatusText?: string;
    statusCode?: string;
    statusText?: string;
    calculatedTitle?: string;
}

export class SearchedInventoryRequestModel {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    constructor(obj?: any) {
        Object.assign(this, obj);

        this.hasFundExternalSource = obj.hasFundExternalSource;
        this.searchText = obj.searchText;
    }

    fundInternaIdentifier?: number;
    fundExternalIdentifier?: number;
    hasFundExternalSource: boolean;
    searchText: string;
}
