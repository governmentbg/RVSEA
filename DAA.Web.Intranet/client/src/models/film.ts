import { IFilm, IFilmCard, IFilmPackageDocument } from "@/interfaces/film";


export class Film implements IFilm {
    constructor (obj?: IFilm) {
        Object.assign(this, obj);
    }

    id?: number;
    isDraft?: boolean;
    isCurrent?: boolean;
    readonly?: boolean;
    archiveId?: number;
    systemIdentifier?: string;
    externalIdentifier?: number;
    hasExternalSource?: boolean;

    currentProcessId?: number;
    currentProcessTypeId?: number;
    currentProcessTypeName?: string;
    currentStepId?: number;
    currentStepTypeId?: number;
    currentStepTypeName?: string;
    comment?: string;
    hasCompletedCardsProcess?: boolean;

    inventoryNumber?: number;
    countryId?: number;
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


export class FilmShort {
    constructor (obj?: IFilm) {
        Object.assign(this, obj);
    }

    id?: number;
    hasExternalSource?: boolean;
    archiveId?: number;
    archiveName?: string;
    inventoryNumber?: string;
    countryId?: number;
    countryName?: string;
    countryCode?: string;
    content?: string;
    currentProcessTypeName?: string;

    createdOn?: Date;
    updatedOn?: Date;
    createdBy?: string;
    updatedBy?: string;
    deleted?: boolean;
    createdByDisplayName?: string;
    updatedByDisplayName?: string;
}

export class FilmCard implements IFilmCard {
    constructor (obj?: IFilmCard) {
        Object.assign(this, obj);
    }

    id?: number;
    systemIdentifier?: string;
    isDraft?: boolean;
    isCurrent?: boolean;
    readonly?: boolean;
    filmId?: number;
    filmSystemIdentifier?: string;
    archiveId?: number;    
    inventoryNumber?: number;
    countryId?: number;
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

export class FilmCardParentData {
    constructor (obj?: IFilm) {
        this.filmId = obj?.id;
        this.systemIdentifier = obj?.systemIdentifier;
        this.archiveId = obj?.archiveId;
        this.archiveName = obj?.archiveName;
        this.inventoryNumber = obj?.inventoryNumber;
        this.countryId = obj?.countryId;
        this.countryName = obj?.countryName;
        this.countryCode = obj?.countryCode;
        this.source = obj?.source;
    }

    filmId?: number;
    systemIdentifier?: string;
    archiveId?: number;    
    archiveName?: string;
    inventoryNumber?: number;
    countryId?: number;
    countryName?: string;
    countryCode?: string;
    source?: string;
}

export class FilmPackageDocument {
    constructor (obj?: IFilmPackageDocument) {
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
    hashCode?: string;
}

export class FilmPackageDocumentCreateModel {
    entitySystemIdentifier?: string;
    entityType?: string;
	packageId?: number;    
    documentTypeId?: number;
    description?: string;
	file: File | null = null;
    skipValidation: boolean = false;
}

export class FilmPackageDocumentUpdateModel {
    id?: number;
    entitySystemIdentifier?: string;
    entityType?: string;
	packageId?: number;    
    documentTypeId?: number;
    description?: string;
	file: File | null = null;
    skipValidation: boolean = false;
}

export class FilmChangeStepModel {
    filmId: number | null = null;
    filmSystemIdentifier: string | null = null;
    stepType: number | null = null;
    comment?: string;
    assignedToUserId?: string;
    assignedToRoleId?: string;
    endDate?: Date | null;
}

export class PrintedFilmCard {
    country: string | null = null;
    countryCode: string | null = null;
    city: string | null = null;
    archiveOriginals: string | null = null;
    archive: string | null = null;
    documentsCipher: string | null = null;
    number: string | null = null;
    title: string | null = null;
    copyType: number | null = null;
    startDateDay: number | null = null;
    startDateMonth: number | null = null;
    startDateYear: number | null = null;
    endDateDay: number | null = null;
    endDateMonth: number | null = null;
    endDateYear: number | null = null;
    documentsFormat: string | null = null;
    documentsLanguage: Array<string> | null = null;
    filmingExtent: string | null = null;
    acceptedOnDay: number | null = null;
    acceptedOnMonth: number | null = null;
    acceptedOnYear: number | null = null;
    copyVolume: string | null = null;
    source: string | null = null;
    notes: string | null = null;
    documentsCharacteristics: string | null = null;
    createdByDisplayName: string | null = null;
    createdOn: Date | null = null;
}

export class FilmReview {
    systemIdentifier?: string;
    userId: string | null = null;
    readerName: string | null = null;
    filmSystemIdentifier: string | null = null;
    accessAllowed: boolean | null = null;
    deleted: boolean | null = null;
}

export class CreateFilmReview {
    systemIdentifier?: string;
    createdOn: Date | null = null;
    createdBy: string | null = null;
    updatedOn: Date | null = null;
    updatedBy: string | null = null;
    userId: string | null = null;
    readerName: string | null = null;
    filmSystemIdentifier: string | null = null;
    accessAllowed: boolean | null = null;
    deleted: boolean | null = null;

    createdByDisplayName: string | null = null;
    updatedByDisplayName: string | null = null;
    filmNumber: string | null = null;
    filmInventoryNumber: number | null = null;
    firstName: string | null = null;
    surname: string | null = null;
    lastName: string | null = null;
}
