import { IDigitalObject, IDigitalObjectDraft } from '@/interfaces/digitalObject';

export class DigitalObject implements IDigitalObject {
    constructor(obj?: IDigitalObject) {
        Object.assign(this, obj);
    }

    id?: number;
    systemIdentifier?: string;
    archiveId?: number;
    fundDraftId?: number;
    fundSystemIdentifier?: string;
    fundExternalIdentifier?: number;
    fundHasExternalSource?: boolean;
    inventoryDraftId?: number;
    inventorySystemIdentifier?: string;
    inventoryExternalIdentifier?: number;
    inventoryHasExternalSource?: boolean;
    archivalEntityDraftId?: number;
    archivalEntitySystemIdentifier?: string;
    archivalEntityExternalIdentifier?: number;
    archivalEntityHasExternalSource?: boolean;
    documentDraftId?: number;
    documentSystemIdentifier?: string;
    documentExternalIdentifier?: number;
    documentHasExternalSource?: boolean;
    externalIdentifier?: number;
    hasExternalSource?: boolean;
    parentId?: number;
    parentSystemIdentifier?: string;
    typeCode?: number;
    name?: string;
    sourceName?: string;
    uncPath?: string;
    fileType?: string;
    contentType?: string;
    statusCode?: string;
    content?: File;
    watermarkName?: string;
    watermarkUncPath?: string;
    hashCode?: string;
    skipValidation: boolean = false;
    isDigitized?: boolean;
}

export class DigitalObjectDraft extends DigitalObject implements IDigitalObjectDraft {
    constructor(obj?: IDigitalObjectDraft) {
        super(obj);
        Object.assign(this, obj);
    }

    isCurrent?: boolean;
    readOnly?: boolean;
    workflowTypeCode?: string;
    workflowTypeText?: string;
    workflowId?: number;
    workflowStepTypeCode?: string;
    workflowStepTypeText?: string;
    workflowStepId?: number;
}

export class DigitalObjectReviewDisplayModel {
    constructor(obj?: DigitalObjectReviewDisplayModel) {
        Object.assign(this, obj);
    }
    systemIdentifier?: string;
    digitalObjectName?: string;
    archivalEntityNumber?: string;
    documentNumber?: string;
    userDisplayName?: string;
    userType?: string;
    userSystemIdentifier?: string;
    date?: Date;
}

export class DigitalObjectReviewFilterModel {
    ArchivalEntitySystemIdentifier?: string | null = null;
    StartDate?: Date | null = null;
    EndDate?: Date | null = null;
}
