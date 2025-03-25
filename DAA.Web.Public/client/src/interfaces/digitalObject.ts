export interface IDigitalObject {
    id?: number;
    systemIdentifier?: string;
    externalIdentifier?: number;
    hasExternalSource?: boolean;
    externalSourceUpdatedOn?: Date;
    parentId?: number;
    parentSystemIdentifier?: string;
    typeCode?: number;
    name?: string;
    sourceName?: string;
    uncPath?: string;
    fileType?: string;
    contentType?: string;
    statusCode?: string;
    statusText?: string;
    content?: File;
    documentSystemIdentifier?: string,
    archivalEntitySystemIdentifier?: string,
}
