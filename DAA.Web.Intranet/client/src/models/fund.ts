import { IFund, IFundDraft } from "@/interfaces/fund";

export class Fund implements IFund {
  constructor(obj?: IFund) {
    Object.assign(this, obj);
  }
  id?: number;
  systemIdentifier?: string;
  archiveId?: number;
  externalIdentifier?: number;
  hasExternalSource?: boolean;
  externalSourceUpdatedOn?: Date;
  numberArray?: string;
  numberNumeric?: number;
  number?: string;
  title?: string;
  descriptionLevelCode?: string;
  typeCode?: string;
  statusCode?: string;
  acquisitionMethodId?: number;
  //acquisitionMethodCodes?: Array<string>; //TODO Remove
  industryTypeCodes?: Array<string>;
  fileTypeCodes?: Array<string>;
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

export class FundDraft extends Fund implements IFundDraft {
  constructor(obj?: IFundDraft) {
    super(obj);
    Object.assign(this, obj);
  }
  isCurrent?: boolean;
  readOnly?: boolean;
	workflowTypeCode?: string;
  workflowId?: number;
	workflowStepTypeCode?: string;
  workflowStepId?: number;
}

export class FundShort {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  constructor(obj?: IFund) {
    Object.assign(this, obj);
    this.calculatedIdentifier = this.systemIdentifier + '|' + this.id?.toString() + '|' + this.externalIdentifier?.toString();
    this.longTitle = this.number + ' - ' + this.title;
  }

  // id?: number;
  // externalIdentifier?: number;
  // commonId?: string;
  // hasExternalSource?: boolean;
  // name?: string;
  id?: number;
  systemIdentifier?: string;
  externalIdentifier?: number;
  calculatedIdentifier?: string;
  hasExternalSource?: boolean;
  isDraft?: boolean;
  archiveId?: number;
  archiveCode?: number;
  archiveName?: string;
  numberArray?: string;
  number?: string;
  title?: string;
  longTitle?: string;
}
