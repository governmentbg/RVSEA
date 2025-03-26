import { IFundReconstructionModel } from "@/interfaces/fundReconstruction";

export class FundReconstructionModel implements IFundReconstructionModel {
    constructor(obj?: IFundReconstructionModel) {
        Object.assign(this, obj);
    }

    id?: number;
    processId?: number;
    archiveId?: number;
    fundSystemIdentifier?: string;
    sourceInventorySystemIdentifier?: string;
    sourceArchivalEntitySystemIdentifier?: string;
    sourceDocumentSystemIdentifier?: string;
    targetInventorySystemIdentifier?: string;
    targetArchivalEntitySystemIdentifier?: string;
    targetDocumentSystemIdentifier?: string;
    availabilityStatusCode?: number;
}