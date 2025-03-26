export interface IPackagesFormData {
    applicationId: number;
    packageA: Array<IPackageAFile>;
    packageB: Array<IPackageBFile>;
}

export interface IPackageAFile extends IPackageBFile {
    documentTypeId: number;
    description?: string;
}

export interface IPackageBFile {
    id?: number;
    fileId?: string;
    name?: string;
    size?: number;
    type?: string;
    file?: File;
    documentId?: string;
    _deleted: boolean;
    typeCode?: number;
    parentId?: number;
    formattedSize?: string | number;
    fileSize?: number;
}

export interface FileModel {
    id: string;
    name: string;
    size: number;
    type: string;
}

export interface ImportErrorList {
    sheet: string;
    row: string;
    col: string;
    description: string;
}
