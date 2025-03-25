export interface INomenclature {
    id?: number;
    code: string;
    text: string;
    description?: string;
    inactive?: boolean;
    locked?: boolean;
    createdOn?: Date;
    createdBy?: string;
    createdByDisplayName?: string;
    createdByUserName?: string;
    updatedOn?: Date;
    updatedBy?: string;
    updatedByDisplayName?: string;
    updatedByUserName?: string;
    deleted?: boolean;
    deletedOn?: Date;
    deletedBy?: string;
    deletedByName?: string;
}

export interface INomenclatureValue extends INomenclature {
    parentId: number | undefined;
    parentCode?: string;
    parentText?: string;
    sortOrder?: number;
    externalIdentifier?: number;
}
