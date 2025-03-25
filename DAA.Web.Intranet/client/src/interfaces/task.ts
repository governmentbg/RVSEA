export interface IAssign {
    assignToUserId?: string;
    assignToRoleId?: string;
    endDate?: Date;
}

export interface ITask {
    id?: number;
    processId?: number;
    processTypeName?: string;
    stepId?: number;
    stepTypeName?: string;
    title?: string;
    description?: string;
    assignedToUserId?: string;
    endDate?: Date;
    endDateFormatted?: string;
    relatedEntityId?: number;
    relatedEntityType?: string;    
    relatedContentUrl?: string;
    statusCode?: string;
    statusName?: string;
    createdOn?: Date;
    createdOnFormatted?: string;
    createdByDisplayName?: string;
    updatedOn?: Date;
    updatedOnFormatted?: string;
    updatedByDisplayName?: string;
}
