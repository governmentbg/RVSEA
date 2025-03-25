export interface IRoleInfo {
    id?: string,
    archiveId?: number, 
    name: string,
    createdBy?: string,
    createdByName?: string,
    createdOn?: Date,
    updatedBy?: string,
    updatedByName?: string,
    updatedOn?: Date,
    deleted?: boolean,
    deletedBy?: string,
    deletedByName?: string,
    deletedOn?: Date
}