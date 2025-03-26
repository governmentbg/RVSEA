import { IProcess, IProcessStep, IProcessTimeline } from "@/interfaces/process";

export class ProcessModel implements IProcess {
    constructor (obj?: IProcess) {
        Object.assign(this, obj);
    }

    id?: number;
    processTypeId?: number;
    activeProcessStepId?: number;
    activeProcessStepTypeId?: number;
    archiveId?: number;
    fundSystemIdentifier?: string;
    inventorySystemIdentifier?: string;
    archivalEntitySystemIdentifier?: string;
    documentSystemIdentifier?: string;
    filmSystemIdentifier?: string;
    completed?: boolean;
}

export class ProcessStepModel implements IProcessStep {
    constructor (obj?: IProcessStep) {
        Object.assign(this, obj);
    }
    id?: number;
    processId?: number;
    stepTypeId?: number;
    comment?: string;
    assignedToUserId?: string;
    AssignedToRoleId?: string;
    endDate?: Date;
}

export class ProcessTimeline implements IProcessTimeline {
    constructor (obj?: IProcessTimeline) {
        Object.assign(this, obj);
    }

    id?: number;
    processId?: number;
    stepTypeId?: number;
    stepTypeName?: string;
    completed?: boolean;
    comment?: string;

    createdOn?: Date;
    createdBy?: string;
    createdByUserName?: string;
    createdByDisplayName?: string;

    assignedToUserName?: string;
    assignedToUserDisplayName?: string;
    assignedToRoleName?: string;
    endDate?: Date;
}