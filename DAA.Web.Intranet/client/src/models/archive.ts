import { IArchive } from "@/interfaces/archive";

export class Archive implements IArchive {
    constructor (obj?: IArchive) {
        Object.assign(this, obj);
    }
    id?: number;
    name = '';
    code?: number;
    sortOrder?: number;
    externalIdentifier?: number;
    hasExternalSource?: boolean;
}