import { IComment } from "@/interfaces/comment";

export class CommentModel implements IComment {
    constructor(obj?: IComment) {
        Object.assign(this, obj)
    }
    id?: number;
    processId?: number;
    processStepId?: number;
    sessionAgendaStandpointId?: number;
    isDraft?: boolean
    text?: string
}
