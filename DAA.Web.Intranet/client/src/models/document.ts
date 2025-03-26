import { IDocument, IDocumentDraft } from "@/interfaces/document";
import { GridOptions } from "@/models/grid";

export class Document implements IDocument {
  constructor(obj?: IDocument) {
    Object.assign(this, obj);
  }

  id?: number;
  systemIdentifier?: string;
  isDraft?: boolean;
  archiveId?: number;
  fundDraftId?: number;
  fundSystemIdentifier?: string;
  fundExternalIdentifier?: number;
  fundHasExternalSource?: boolean;
  inventoryDraftId?: number;
  inventorySystemIdentifier?: string;
  inventoryExternalIdentifier?: number;
  inventoryHasExternalSource?: boolean;
  archivalEntityDraftId?: number;
  archivalEntitySystemIdentifier?: string;
  archivalEntityExternalIdentifier?: number;
  archivalEntityHasExternalSource?: boolean;
  externalIdentifier?: number;
  inventoryNumberArray?: string;
  inventoryNumberNumeric?: number;
  number?: string;
  title?: string;
  descriptionLevelCode?: string;
  statusCode?: string;
  availabilityStatusCode?: number;
  creationMethodCodes?: Array<string>;
  languageCodes?: Array<string>;
  originalityCodes?: Array<string>;
  fileTypeCodes?: Array<string>;
  scaling?: string;
  location?: string;
  bytes?: number;
  sheetCount?: number;
  startSheetNumber?: number;
  endSheetNumber?: number;
  digitalDevice?: string;
  duration?: number;
  sizeCm?: string;
  author?: string;
  description?: string;
  documentsAccessDescription?: string;
  features?: string;
  microfilmedCopyCount?: number;
  digitizedCopyCount?: number;
  paperCopyCount?: number;
  negativeFrameCount?: number;
  positiveFrameCount?: number;
  otherCopyCount?: string;
  transcription?: string;
  notes?: string;
  hasNoChronologicalScope?: boolean;
  startDateYear?: number;
  startDateMonth?: number;
  startDateDay?: number;
  endDateYear?: number;
  endDateMonth?: number;
  endDateDay?: number;
  approximateChronologicalScope?: string;
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
  resultMessage?: string;

  descriptionAuthor?: string
  cypher?: string
  textDocsCount?: number
  graphicalDocsCount?: number
  phase?: string
  part?: string
  stage?: string
  otherLanguage?: string
}

export class DocumentDraft extends Document implements IDocumentDraft {
  constructor(obj?: IDocumentDraft) {
    super(obj)
    Object.assign(this, obj);
  }

  isCurrent?: boolean;
  readOnly?: boolean;
  workflowTypeCode?: string;
  workflowTypeText?: string;
  workflowId?: number;
  workflowStepTypeCode?: string;
  workflowStepTypeText?: string;
  workflowStepId?: number;
}

export class DocumentPerInventoryRequestModel {
  constructor(obj?: unknown) {
    Object.assign(this, obj);
  }

  hasInventoryExternalSource?: boolean;
  inventoryExternalIdentifier?: number;
  inventoryInternalIdentifier?: number;
  dataSourceRequestModel?: GridOptions;
}

export class DocumentShort {
  //TODO да се направи интерфейс
  constructor(obj?: unknown) {
    Object.assign(this, obj);
  }

  id?: number;
  externalIdentifier?: number;
  commonId?: string;
  hasExternalSource?: boolean;
  name?: string;
}

export class DocumentOfListDisplayModel {
  //TODO да се направи интерфейс
  constructor(obj?: unknown) {
    Object.assign(this, obj);
  }

  number?: string;
  title?: string;
  descriptionLevel?: string;
  //status?: string; засега го няма при нас
  id?: number;
  externalIdentifier?: number;
  hasExternalSource?: boolean;
  commonId?: string;
}
