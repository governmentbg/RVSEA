export interface IInformation {
    id?: number,
    title: string,
    content: string
    createdOn?: Date;
    createdBy?: string;
    updatedOn?: Date;
    updatedBy?: string;
    deletedOn?: Date;
    deletedBy?: string;
    deleted?: boolean;
    startDate?: Date;
    endDate?: Date;
    uid?: string;

    isEditMode?: boolean;
}