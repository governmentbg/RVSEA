import { IFilm, IFilmCard } from '@/interfaces/film'; //, IFilmCard, IFilmPackageDocument

export class Film implements IFilm {
    constructor(obj?: IFilm) {
        Object.assign(this, obj);
    }
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

export class FilmCard implements IFilmCard {
    constructor(obj?: IFilmCard) {
        Object.assign(this, obj);
    }
    systemIdentifier?: string;
    filmSystemIdentifier?: string;
    inventoryNumber?: number;
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
