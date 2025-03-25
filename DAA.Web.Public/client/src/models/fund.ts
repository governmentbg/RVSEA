import { IFund } from '@/interfaces/fund';

export class Fund implements IFund {
    constructor(obj?: IFund) {
        Object.assign(this, obj);
    }
    systemIdentifier?: string;
    archiveId?: number;
    externalIdentifier?: number;
    hasExternalSource?: boolean;
    externalSourceUpdatedOn?: Date;
    numberArray?: string;
    number?: string;
    title?: string;
    descriptionLevelCode?: string;
    typeCode?: string;
    statusCode?: string;
    industryTypeCodes?: Array<string>;
    languageCodes?: Array<string>;
    hasNoChronologicalScope?: boolean;
    startDateYear?: number;
    startDateMonth?: number;
    startDateDay?: number;
    endDateYear?: number;
    endDateMonth?: number;
    endDateDay?: number;
    approxmateChronologicalScope?: string;
    bytes?: number;
    linearMeters?: number;
    otherMetrics?: string;
    inventoryCount?: number;
    archivalEntityCount?: number;
    documentCount?: number;
    fundCreatorTitleHistory?: string;
    fundCreatorActivityHistory?: string;
    fundCreatorBiographicalHistory?: string;
    documentsProvider?: string;
    documentsDescription?: string;
    valuableDocumentsInventoryCount?: string;
    invaluableDocumentsInventoryCount?: string;
    documentsAccessDescription?: string;
    history?: string;
    relatedFunds?: string;
    notes?: string;
    enrolledBytes?: number;
    enrolledInventoryCount?: number;
    deductedBytes?: number;
    deductedInventoryCount?: number;
    resultMessage?: string;
}
