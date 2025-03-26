export interface IComment {
    id?: number;
    processId?: number;
    processStepId?: number
    sessionAgendaStandpointId?: number;
    isDraft?: boolean;
    text?: string
    createdOn?: Date,
    deletedOn?: Date,
    updatedOn?: Date,
    createdBy?: string,
    deletedBy?: string,
    updatedBy?: string;
    deleted?: boolean,
    createdByUserName?: string,
    createdByDisplayName?: string,
    updatedByUserName?: string,
    updatedByDisplayName?: string,
    deletedByUserName?: string,
    deletedByDisplayName?: string,
}