export class SessionProtocol {
    constructor(obj?: SessionProtocol) {
        Object.assign(this, obj);
    }

    id?: number;
    isDraft?: boolean;
    content?: string;
    standPointIds? = [] as number[];
}

export class SessionProtocolUploadFileModel {
    constructor(obj?: SessionProtocolUploadFileModel) {
        Object.assign(this, obj);
    }

    sessionId?: number;
    files? = [] as File[];
}
