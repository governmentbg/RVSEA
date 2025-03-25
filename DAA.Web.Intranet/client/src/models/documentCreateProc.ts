import { CommentModel } from '@/models/comment';

export class ProcedureViewModel {
    constructor(obj?: unknown) {
        Object.assign(this, obj);
    }

    id?: number;
    archiveId?: number;
    completed?: boolean;
    procedureStepTypeId?: number;
    procedureType?: number;
    procedureStepId?: number;
    readyForImport?: boolean;
    documentId?: number;
    procedureStepName?: string;
    assignToUserId?: string;
    assignToRoleId?: string;
    documentSystemIdentifier?: string;
    comments? = [] as CommentModel[];
    files? = [] as File[];
    masterFiles? = [] as File[];
    derivativesFiles? = [] as File[];
    skipMasterValidation?: boolean;
    skipDerivativeValidation?: boolean;
    skipDemoValidation?: boolean;
}

export class ProcedureCreateModel {
    documentSys?: string;
    procedureType?: number;
    procedureStepTypeId?: number;
    archiveId?: number;
    assignToUserId?: string;
    assignToRoleId?: string;
    readyForImport?: boolean;
    archiveEntityExternalIdentifier?: number;
}
