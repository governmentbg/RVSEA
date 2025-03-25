export class ApplicationCreateModel {
    constructor(obj: IApplicationCreate) {
        this.type = obj.type;
        this.applicantId = obj.applicantId;
        this.archiveId = obj.archiveId;
        this.documentsOwner = obj.documentsOwner;
        this.documentsSize = obj.documentsSize;
        this.documentsPeriod = obj.documentsPeriod;
        this.documentsOriginType = obj.documentsOriginType;
        this.organizationEIK = obj.organizationEIK;
        this.applicantPhone = obj.applicantPhone;
        this.applicantFullName = obj.applicantFullName;
        this.applicantEmail = obj.applicantEmail;
        this.address = obj.address;
        this.organization = obj.organization;
        this.organizationRepresentative = obj.organizationRepresentative;
    }

    type: string = '';
    applicantId: string = '';
    applicantFullName: string = '';
    applicantEmail: string = '';
    applicantPhone: string = '';
    address: string = '';
    organization: string = '';
    organizationEIK: string = '';
    organizationRepresentative: string = '';
    archiveId: string = '';
    documentsOwner: string = '';
    documentsSize: number = 0;
    documentsPeriod: string = '';
    documentsOriginType: string = '';
}

export interface IApplicationCreate {
    applicantId: string;
    applicantFullName: string;
    applicantEmail: string;
    applicantPhone: string;
    address: string;
    organization: string;
    organizationEIK: string;
    organizationRepresentative: string;
    type: string;
    archiveId: string;
    documentsOwner: string;
    documentsSize: number;
    documentsPeriod: string;
    documentsOriginType: string;
}

export interface IApplicationGrid {
    id: number;
    type: string;
    typeId: string;
    status: string;
    statusId: number;
    applicant: string;
    applicationDate: File;
}

export interface IApplicationDisplay {
    id: number;
    type: string;
    status: string;
    applicant: string;
    applicantEmail: string;
    applicationDate: Date;
    assignToId: string;
    assignToName: string;
    fileId: number;
    fileName: string;
    rejectReason: string;
    archive: string;
    archiveId: number;
    redirectedFromArchiveName?: string;
	redirectedToArchiveName?: string;
    packageARejectReason?: string;
    packageBRejectReason?: string;
}

export interface IPackageDocument {
    id?: number;
    packageId?: number;
    documentTypeId?: number;
    documentTypeName?: string;
    documentType?: string;
    fileId?: string;
    filePath?: string;
    fileName?: string;
    fileType?: string;
    contentType?: string;
    fileSizeInBytes?: number;
    description?: string;

    createdOn?: Date;
    deletedOn?: Date;
    updatedOn?: Date;
    createdBy?: string;
    deletedBy?: string;
    updatedBy?: string;
    deleted?: boolean;
    createdByUserName?: string;
    createdByDisplayName?: string;
    updatedByUserName?: string;
    updatedByDisplayName?: string;
    deletedByUserName?: string;
    deletedByDisplayName?: string;
    content?: File;
}

export class PackageDocument {
    constructor(obj?: IPackageDocument) {
        this.id = obj?.id;
        this.packageId = obj?.packageId;
        this.documentTypeId = obj?.documentTypeId;
        this.documentTypeName = obj?.documentTypeName;
        this.fileId = obj?.fileId;
        this.filePath = obj?.filePath;
        this.fileName = obj?.fileName;
        this.fileType = obj?.fileType;
        this.contentType = obj?.contentType;
        this.fileSizeInBytes = obj?.fileSizeInBytes;
        this.description = obj?.description;
        this.content = obj?.content;
        this.documentType = obj?.documentType;
    }

    id?: number;
    packageId?: number;
    documentTypeId?: number;
    documentTypeName?: string;
    fileId?: string;
    filePath?: string;
    fileName?: string;
    fileType?: string;
    contentType?: string;
    fileSizeInBytes?: number;
    description?: string;
    content?: File;
    documentType?: string;
}

export class PackageDocumentCreateModel {
    entitySystemIdentifier?: string;
    entityType?: string;
    packageId?: number;
    documentTypeId?: number;
    description?: string;
    file: File | null = null;
}

export class PackageDocumentUpdateModel {
    id?: number;
    entitySystemIdentifier?: string;
    entityType?: string;
    packageId?: number;
    documentTypeId?: number;
    description?: string;
    file: File | null = null;
}
