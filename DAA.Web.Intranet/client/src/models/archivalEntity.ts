import { IArchivalEntity, IArchivalEntityDraft } from "@/interfaces/archivalEntity";
//import { GridOptions } from "@/models/grid";

export class ArchivalEntity implements IArchivalEntity {
  constructor(obj?: IArchivalEntity) {
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
    hasExternalSource?: boolean;
    externalIdentifier?: number;
    number?: string;
    numberNumeric?: number;
    descriptionLevelCode?: string;
    statusCode?: string;
    availabilityStatusCode?: number;
    creationMethodCodes?: Array<string>;
    languageCodes?: Array<string>;
    originalityCodes?: Array<string>;
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
    archivalEntityCount?: number;
    documentCount?: number;
    boxCount?: number;
    rollCount?: number;
    fundCreatorTitleHistory?: string;
    fundCreatorActivityHistory?: string;
    fundCreatorBiographicalHistory?: string;
    documentsProvider?: string;
    documentsDescription?: string;
    documentsAccessDescription?: string;
    history?: string;
    notes?: string;
    audioDocumentArchivalEntityCount?: number;
    photoDocumentArchivalEntityCount?: number;
    videoDocumentArchivalEntityCount?: number;
    digitalDocumentArchivalEntityCount?: number;
    classificationScheme?:string;
    abbreviationList?: string;
    microfilmedArchivalEntityCount?: number;
    digitizedArchivalEntityCount?: number;
    negativeFrameCount?: number;
    positiveFrameCount?: number;
    // createdOn?: Date;
    // deletedOn?: Date;
    // updatedOn?: Date;
    // createdBy?: string;
    // deletedBy?: string;
    // updatedBy?: string;
    // deleted?: boolean;
    // createdByUserName?: string;
    // createdByDisplayName?: string;
    // updatedByUserName?: string;
    // updatedByDisplayName?: string;
    // deletedByUserName?: string;
    // deletedByDisplayName?: string;
    resultMessage?: string; //TODO Remove this shit

    descriptionAuthor?: string;
    cypher?: string;
    textDocsCount?: number;
    graphicalDocsCount?: number;
    phase?: string;
    part?: string;
    stage?: string
    otherLanguage?: string;
    numberArray?: string;
    classificationSchemeIndex?: string;
}

export class ArchivalEntityDraft extends ArchivalEntity implements IArchivalEntityDraft {
  constructor(obj?: IArchivalEntityDraft) {
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

export class ArchivalEntityShort {
  constructor(obj?: IArchivalEntity) {
    Object.assign(this, obj);
    this.calculatedIdentifier = this.systemIdentifier + '|' + this.id?.toString() + '|' + this.externalIdentifier?.toString();
  }

  id?: number;
  systemIdentifier?: string;
  hasExternalSource?: boolean;
  externalIdentifier?: number;
  calculatedIdentifier?: string;
  isDraft?: boolean;
  archiveId?: number;
  archiveCode?: number;
  archiveName?: string;
  fundDraftId?: number;
  fundSystemIdentifier?: string;
  fundHasExternalSource?: boolean;
  fundExternalIdentiier?: number;
  fundNumber?: string;
  inventoryDraftId?: number;
  inventorySystemIdentifier?: string;
  inventoryHasExternalSource?: boolean;
  inventoryExternalIdentiier?: number;
  inventoryNumber?: string;
  number?: string;
  title?: string;
  approximateChronologicalScope?: string;
  descriptionLevelCode?: string;
  descriptionLevelText?: string;
  availabilityStatusCode?: number;
  availabilityStatusText?: string;
  statusCode?: string;
  statusText?: string;
  calculatedTitle?: string;
  commonId?: string; //TODO Remove
  name?: string; //TODO Remove
}

/* eslint-disable @typescript-eslint/no-explicit-any */
export class SearchedArchiveEntityRequestModel {
  constructor(obj?: any) {
    Object.assign(this, obj);
  }

  inventoryInternaIdentifier?: number;
  inventoryExternalIdentifier?: number;
  hasInventoryExternalSource?: boolean;
  searchText?: string;
}

export class DocumentAncestorsData {
  constructor(obj?: any) {
    Object.assign(this, obj);
  }

  archiveName?: string;
  archiveCode?: number;
  fundExternalIdentifier?: number;
  fundNumber?: string;
  inventoryExternalIdentifier?: number;
  inventoryNumber?: number;
  archiveEntityNumber?: string;
}
