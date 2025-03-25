export interface IFilm {
    archiveName?: string;
    systemIdentifier?: string;
    externalIdentifier?: number;
    hasExternalSource?: boolean;
    comment?: string;
    inventoryNumber?: number;
    countryName?: string;
    countryCode?: string;
    framesCount?: number;
    microfilmNegativeRollsCount?: number;
    microfilmNegativeFramesCount?: number;
    microfilmPositiveRollsCount?: number;
    microfilmPositiveFramesCount?: number;
    photoCopy?: string;
    digitalCopy?: string;
    size?: string;
    other?: string;
    acceptedOnDay?: number;
    acceptedOnMonth?: number;
    acceptedOnYear?: number;
    source?: string;
    content?: string;
    notes?: string;
    packageAId?: number;
    packageBId?: number;
}

export interface IFilmFull {
    archiveName?: string;
    systemIdentifier?: string;
    externalIdentifier?: number;
    hasExternalSource?: boolean;
    comment?: string;
    inventoryNumber?: number;
    countryName?: string;
    countryCode?: string;
    framesCount?: number;
    microfilmNegativeRollsCount?: number;
    microfilmNegativeFramesCount?: number;
    microfilmPositiveRollsCount?: number;
    microfilmPositiveFramesCount?: number;
    photoCopy?: string;
    digitalCopy?: string;
    size?: string;
    other?: string;
    acceptedOnDay?: number;
    acceptedOnMonth?: number;
    acceptedOnYear?: number;
    source?: string;
    content?: string;
    notes?: string;
    packageAId?: number;
    packageBId?: number;
}

export interface IFilmCard {
    systemIdentifier?: string;
    filmSystemIdentifier?: string;
    archiveId?: number;
    archiveName?: string;
    inventoryNumber?: number;
    countryName?: string;
    countryCode?: string;
    city?: string;
    documentsCypher?: string;
    title?: string;
    archiveOriginals?: string;
    startDateDay?: number;
    startDateMonth?: number;
    startDateYear?: number;
    endDateDay?: number;
    endDateMonth?: number;
    endDateYear?: number;
    aproximateDate?: string;
    languageCodes?: Array<string>;
    filmingExtentId?: number;
    filmingExtentName?: string;
    source?: string;
    framesCount?: number;
    microfilmNegativeCount?: number;
    microfilmPositiveCount?: number;
    photoCopy?: string;
    digitalCopy?: string;
    size?: string;
    other?: string;
    notes?: string;
    documentsFormat?: string;
    documentsCharacteristics?: string;
    documentIds?: Array<number>;
}

export interface IFilmPackageDocument {
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
}

export interface IFilmChangeStepModel {
    filmId: number | null;
    filmSystemIdentifier: string | null;
    stepType: number | null;
    comment?: string;
    assignedToUserId?: string;
    assignedToRoleId?: string;
    endDate?: Date | null;
}

export interface IFilmReader {
    id?: number;
    systemIdentifier?: string;
    title?: string;
    archiveId?: number;
    archiveName?: string;
    inventoryNumber?: number;
    countryName?: string;
    framesCount?: number;
    microfilmNegativeRollsCount?: number;
    microfilmNegativeFramesCount?: number;
    microfilmPositiveRollsCount?: number;
    microfilmPositiveFramesCount?: number;
    photoCopy?: string;
    digitalCopy?: string;
    size?: string;
    other?: string;
    deleted?: boolean;
}
