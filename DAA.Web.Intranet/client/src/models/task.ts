import { IAssign, ITask } from "@/interfaces/task";

export class AssignModel implements IAssign {
    constructor (obj?: IAssign) {
        Object.assign(this, obj);
    }

    assignToUserId?: string;
    assignToRoleId?: string;
    endDate?: Date;
}

export class Task implements ITask {
    constructor (obj?: ITask) {
        Object.assign(this, obj);
    }

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
    assignedToDisplayName?: string;
    assignedToRoleName?: string;
}