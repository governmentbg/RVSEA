import {
    ICommissionDecision,
    ICommissionReport,
    ICommissionSession,
    ISessionAgendaItem,
    ISessionAgendaItemStandpoint,
} from '@/interfaces/commission';
import { IAssign } from '@/interfaces/task';

export class CommissionReportModel implements ICommissionReport {
    constructor(obj?: unknown) {
        Object.assign(this, obj);
    }

    id?: number;
    processId?: number;
    processTypeTitle?: string;
    isDraft?: boolean;
    number?: number;
    createdByDisplayName?: string;
    title?: string;
    createdBy?: string;
    content?: string;
    entityLink?: string; //TODO трябва да се разкара
    // linkTitle?: string;
    createdOn?: Date;
}
export class CommissionReportSubmitModel extends CommissionReportModel {
    constructor(obj?: unknown) {
        super(obj);
        Object.assign(this, obj);
    }

    assignToUserId?: string;
    assignToRoleId?: string;
}
export class CommissionSessionModel implements ICommissionSession {
    constructor(obj?: unknown) {
        Object.assign(this, obj);
    }

    id?: number;
    archiveId?: number;
    sessionTypeCode?: string;
    secretaryId?: string;
    chairmanId?: string;
    sessionDate?: Date;
    minutesOfMeetingNumber?: string;
    minutesOfMeetingStatus?: string;
    minutesOfMeetingId?: number;
    minutesOfMeetingHasFile?: boolean;
    minutesOfMeetingRejectReason?: string;
}

export class CommissionDecisionModel implements ICommissionDecision {
    constructor(obj?: unknown) {
        Object.assign(this, obj);
    }

    id?: number;
    isDraft?: boolean;
    sessionAgendaId?: number;
    decisionText?: string;
    minutesOfMeetingNumber?: string;
    minutesOfMeetingDate?: string;
    deadlineForApproval?: string;
    minutesOfMeetingHasFile?: boolean;
    minutesOfMeetingStatus?: string;
}
export class SessionAgendaItem implements ISessionAgendaItem {
    constructor(obj?: ISessionAgendaItem) {
        Object.assign(this, obj);
    }

    id?: number;
    sessionId?: number;
    reportId?: number;
    processId?: number;

    standpoints?: Array<SessionAgendaItemStandpoint>;
}
export class SessionAgendaItemStandpoint implements ISessionAgendaItemStandpoint {
    constructor(obj?: ISessionAgendaItemStandpoint) {
        Object.assign(this, obj);
    }

    id?: number;
    reportId?: number;
    sessionAgendaId?: number;
    isDraft?: boolean;
    content?: string;
    statusCode?: number;
}
export interface ISendForStandpoints extends IAssign {
    processId: number;
}
