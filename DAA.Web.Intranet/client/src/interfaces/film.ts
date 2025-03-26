export interface IFilm {
    id?: number,
    isDraft?: boolean;
    isCurrent?: boolean;
    readOnly?: boolean;
    archiveId?: number,
    archiveName?: string,
    systemIdentifier?: string;
    externalIdentifier?: number,
    hasExternalSource?: boolean,

    currentProcessId?: number;
    currentProcessTypeId?: number;
    currentProcessTypeName?: string;
    currentStepId?: number;
    currentStepTypeId?: number;
    currentStepTypeName?: string;
    comment?: string;
    hasCompletedCardsProcess?: boolean;
    
    inventoryNumber?: number,
    countryId?: number,
    countryName?: string,
    countryCode?: string,
    framesCount?: number,
    microfilmNegativeRollsCount?: number,
    microfilmNegativeFramesCount?: number,
    microfilmPositiveRollsCount?: number;
    microfilmPositiveFramesCount?: number;
    photoCopy?: string;
    digitalCopy?: string;
    size?: string;
    other?: string;
    acceptedOnDay?: number;
    acceptedOnMonth?: number;
    acceptedOnYear?: number;
    source?: string,
    content?: string,
    notes?: string,

    packageAId?: number;
    packageBId?: number;
    
    createdOn?: Date,
    deletedOn?: Date,
    updatedOn?: Date,
    createdBy?: string,
    deletedBy?: string,
    updatedBy?: string;
    deleted?: boolean,
    createdByUserName?: string,
    createdByDisplayName?: string,
    updatedByUserName?: string,
    updatedByDisplayName?: string,
    deletedByUserName?: string,
    deletedByDisplayName?: string,
}

export interface IFilmCard {
    id?: number,
    systemIdentifier?: string;
    externalIdentifier?: number,
    hasExternalSource?: boolean,
    isDraft?: boolean;
    isCurrent?: boolean;
    readonly?: boolean;
    filmId?: number;
    filmSystemIdentifier?: string;
    filmExternalIdentifier?: number,
    archiveId?: number,
    archiveName?: string,
    
    inventoryNumber?: number,
    countryId?: number,
    countryName?: string,
    countryCode?: string,
    city?: string,
    documentsCypher?: string,
    title?: string,
    archiveOriginals?: string,
    startDateDay?: number;
    startDateMonth?: number;
    startDateYear?: number;
    endDateDay?: number;
    endDateMonth?: number;
    endDateYear?: number;
    aproximateDate?: string,
    languageCodes?: Array<string>;
    filmingExtentId?: number;
    filmingExtentName?: string,
    source?: string,
    framesCount?: number,
    microfilmNegativeCount?: number,
    microfilmPositiveCount?: number,
    photoCopy?: string;
    digitalCopy?: string;
    size?: string;
    other?: string;
    notes?: string,
    documentsFormat?: string,
    documentsCharacteristics?: string,
    documentIds?: Array<number>;
    
    createdOn?: Date,
    deletedOn?: Date,
    updatedOn?: Date,
    createdBy?: string,
    deletedBy?: string,
    updatedBy?: string;
    deleted?: boolean,
    createdByUserName?: string,
    createdByDisplayName?: string,
    updatedByUserName?: string,
    updatedByDisplayName?: string,
    deletedByUserName?: string,
    deletedByDisplayName?: string,
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
    hashCode?: string;
        
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
    filmId: number| null;
    filmSystemIdentifier: string | null;
    stepType: number | null;
    comment?: string;
    assignedToUserId?: string;
    assignedToRoleId?: string;
    endDate?: Date | null;
}

export interface IPrintedFilmCard {
    country: string | null;
    countryCode: string | null;
    city: string | null;
    archiveOriginals: string | null;
    archive: string | null;
    documentsCipher: string | null;
    number: string | null;
    title: string | null;
    copyType: number | null;
    startDateDay: number | null;
    startDateMonth: number | null;
    startDateYear: number | null;
    endDateDay: number | null;
    endDateMonth: number | null;
    endDateYear: number | null;
    documentsFormat: string | null;
    documentsLanguage: Array<string> | null;
    filmingExtent: string | null;
    acceptedOnDay: number | null;
    acceptedOnMonth: number | null;
    acceptedOnYear: number | null;
    copyVolume: string | null;
    source: string | null;
    notes: string | null;
    documentsCharacteristics: string | null;
    createdByDisplayName: string | null;
    createdOn: Date | null;
}




export interface IFilmReview {
    systemIdentifier?: string | null;
    userId: string | null | undefined;
    readerName: string | null;
    filmSystemIdentifier: string | null | undefined;
    accessAllowed: boolean | null;
    deleted: boolean | null;
    firstName?: string | null;
    surname?: string | null;
    lastName?: string | null;
}