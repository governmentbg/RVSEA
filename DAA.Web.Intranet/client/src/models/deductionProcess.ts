import { CommentModel } from '@/models/comment';
import { CommissionReportModel } from '@/models/commission';

export class DeductionProcessViewModel {
    constructor(obj?: unknown) {
        Object.assign(this, obj);
    }
    id?: number;
    procedureStepId?: number;
    procedureType?: number;
    fundSystemIdentifier?: string;
    assignToUserId?: string;
    archiveId?: number;
    assignToRoleId?: string;
    isFinal?: boolean;
    inventorySystemIdentifier?: string;
    archivalEntitySystemIdentifier?: string;
    documentSystemIdentifier?: string;
    procedureStepName?: string;
    entityType?: string;
    sessionId?: number;
    sessionAgendaId?: number;
    secretarOpinion?: string;
    comments? = [] as CommentModel[];
    epkReportModel = new CommissionReportModel();
    decisionModelId?: number;
}

export class DeductionProcessCreateModel {
    archiveId?: number;
    fundSystemIdentifier?: string;
    inventorySystemIdentifier?: string;
    archivalEntitySystemIdentifier?: string;
    documentSystemIdentifier?: string;
    procedureType?: number;
    sessionId?: number;
    entityType?: string;
    procedureStepId?: number;
    archiveExternalIdentifier?: number;
    fundExternalIdentifier?: number;
    inventoryExternalIdentifier?: number;
    archivalEntityExternalIdentifier?: number;
    documentEntityExternalIdentifier?: number;
}
