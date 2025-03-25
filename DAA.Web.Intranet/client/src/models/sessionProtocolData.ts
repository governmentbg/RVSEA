export class SessionProtocolDataModel {
    constructor(obj?: SessionProtocolDataModel) {
        if (obj) {
            Object.assign(this, obj);
        }
    }

    archiveName?: string;
    directorName?: string;
    currentDate?: string;
    protocolNumber?: string | number;
    sessionTypeName?: string;
    assignedToChairmanName?: string;
    assignedToSecretarName?: string;
    members?: string[] = [];
    standPointsData?: StandPoint[] = [];
}

export class StandPoint {
    constructor(obj?: StandPoint) {
        if (obj) {
            Object.assign(this, obj);
        }
    }

    index?: number;
    fundNumber?: string;
    inventoryNumber?: string;
    fundTitle?: string;
    displayName?: string;
    jobTitle?: string;
    department?: string;
    reportStandpoint?: ReportStandpoint[] = [];
}

export class StandPointDecision {
    constructor(obj?: StandPointDecision) {
        if (obj) {
            Object.assign(this, obj);
        }
    }

    index?: string;
    titel?: string;
    reporterInfo?: string;
    decision?: string;
    deadLine?: string;
}
export class GenerateProtocolModel {
    constructor(obj?: GenerateProtocolModel) {
        if (obj) {
            Object.assign(this, obj);
        }
    }
    sessionId?: number;
    protocolNumber?: number;
    content?: string;
}
export class SessionEditModel {
    constructor(obj?: SessionEditModel) {
        if (obj) {
            Object.assign(this, obj);
        }
    }

    sessionId?: number;
    processIdsForAppending?: number[] = [];
    processIdsForRemove?: number[] = [];
}
export class ReportStandpoint {
    standpointText?: string;
    commentText?: string;
    standPointTextCreatorDisplayName?: string;
    reportCreatorDisplayName?: string;
    index?: string;
}
