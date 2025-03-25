import { ProcessStep, ProcessType } from "@/enums/process";

export interface IProcess {
    id?: number;
    processTypeId?: number;
    activeProcessStepId?: number;
    activeProcessStepTypeId?: number;
    isCurrentUserInActiveProcessStep?: boolean;
    archiveId?: number;
    fundSystemIdentifier?: string;
    inventorySystemIdentifier?: string;
    archivalEntitySystemIdentifier?: string;
    documentSystemIdentifier?: string;
    filmSystemIndentifier?: string;
    completed?: boolean;
    processTypeTitle?: string;
    activeProcessStepName?: string;
    archiveName?: string;
    fundNumber?: string;
    inventoryNumber?: string;
    archivalEntityNumber?: string;
    filmNumber?: string;
    documentTitle?: string;
    createdOn?: Date;
    deletedOn?: Date;
    updatedOn?: Date;
    createdBy?: string;
    deletedBy?: string;
    updatedBy?: string;
    deleted?: boolean;
    createdByUserName?: string;
    createdByDisplayName?: string;
    updatedByUserName?: string;
    updatedByDisplayName?: string;
    deletedByUserName?: string;
    deletedByDisplayName?: string;
}

export interface IProcessStep {
    id?: number;
    processId?: number;
    stepTypeId?: number;
    comment?: string;
    assignedToUserId?: string;
    assignedToRoleId?: string;
    endDate?: Date;
}

export interface IProcessTimeline {
    id?: number;
    processId?: number;
    stepTypeId?: number;
    stepTypeName?: string;
    completed?: boolean;
    comment?: string;

    createdOn?: Date,
    createdBy?: string,
    createdByUserName?: string,
    createdByDisplayName?: string,

    assignedToUserId?: string;
    assignedToUserName?: string;
    assignedToUserDisplayName?: string;
    assignedToRoleName?: string;
    endDate?: Date;
}