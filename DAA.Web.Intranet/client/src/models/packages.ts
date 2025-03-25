import { IPackageFile } from '@/interfaces/package';

export interface IPackagesFormData {
    applicationId: number;
    packageA: Array<IPackageAFile>;
    packageB: Array<IPackageBFile>;
}

export interface IInternalPackagesFormData {
    inventoryId: string;
    packageB: Array<IPackageBFile>;
}

export interface IPackageBFile {
    id?: string;
    fileId?: string;
    name?: string;
    fileName?: string;
    size?: number;
    type?: string;
    file?: File;
    documentId?: string;
    _deleted?: boolean;
    description: string;
    fileSize: number;
    formattedSize?: string | number;
    documentSystemIdentifier: string;
    isInvaluable: boolean;
    typeCode: number | null;
}

export interface IPackageAFile extends IPackageBFile {
    documentTypeId: number;
    rowNumber: number;
    fileTypeName: string;
    fileSizeInMB: number;
    createdOn?: string;
    createdByUserName?: string;
    createdByDisplayName?: string;
    isSigned?: string;
    updatedOn?: string;
    updateOrCreateDate?: string;
}

export interface IPackageAAddFile {
    description: string;
    packageId: number;
    documentTypeId: number;
    file: File;
    files: File[];
    skipValidation: boolean;
    signatureFile?: boolean;
    inventorySysIdentifier?: string;
}

export class PackageFile implements IPackageFile {
    constructor(obj?: IPackageFile) {
        Object.assign(this, obj);
    }
}
export interface ImportErrorList {
    sheet: string;
    row: string;
    col: string;
    description: string;
}
