export interface ICommissionSession {
    id?: number;
    archiveId?: number;
    secretaryId?: string;
    secretaryDisplayName?: string;
    chairmanId?: string;
    chairmanDisplayName?: string;
    archiveName?: string;
    sessionDate?: Date;
    minutesOfMeetingNumber?: string;
    sessionTypeCode?: string;
    sessionTypeName?: string;
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

export interface ICommissionReport {
    id?: number;
    processId?: number;
    isDraft?: boolean;
    number?: number;
    //fundName?: string;
    title?: string;
    content?: string;
    //entityLink?: string;
    //linkTitle?: string;
    createdOn?: Date;
    deletedOn?: Date;
    updatedOn?: Date;
    createdBy?: string;
    deletedBy?: string;
    updatedBy?: string;
    deleted?: boolean;
    createdByUserName?: string;
    createdByDisplayName?: string;
    //createdByJobTitle?: string;
    updatedByUserName?: string;
    updatedByDisplayName?: string;
    deletedByUserName?: string;
    deletedByDisplayName?: string;
}

export interface ICommissionReportFile {
    id?: number;
    reportId?: number;
    name?: string;
    sourceName?: string;
    fileType?: string;
    content?: File;
    createdOn?: Date;
    deletedOn?: Date;
    updatedOn?: Date;
    createdBy?: string;
    deletedBy?: string;
    updatedBy?: string;
    deleted?: boolean;
    createdByUserName?: string;
    createdByDisplayName?: string;
    createdByJobTitle?: string;
    updatedByUserName?: string;
    updatedByDisplayName?: string;
    deletedByUserName?: string;
    deletedByDisplayName?: string;
}

export interface ICommissionDecision {
    id?: number;
    sessionAgendaId?: number;
    decisionText?: string;
    hasAttachedFile?: boolean;
    minutesOfMeetingNumber?: string;
    minutesOfMeetingDate?: string;
    deadlineForApproval?: string;
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

export interface ISessionAgendaItem {
    id?: number;
    sessionId?: number;
    reportId?: number;
    processId?: number;
    sessionDate?: Date;
    reportNumber?: number;
    reportCreatedBy?: string;
    reportCreatedByDisplayName?: string;
    reportCreatedByUserName?: string;
    processTypeTitle?: string;
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

    standpoints?: Array<ISessionAgendaItemStandpoint>;
}

export interface ISessionAgendaItemStandpoint {
    id?: number;
    reportId?: number;
    sessionAgendaItemId?: number;
    isDraft?: boolean;
    content?: string;
    statusCode?: number;
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
