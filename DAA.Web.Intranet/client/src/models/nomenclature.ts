import { INomenclature, INomenclatureValue } from "@/interfaces/nomenclature";

export class Nomenclature implements INomenclature {
  constructor(obj?: INomenclature) {
    Object.assign(this, obj);
  }
  id?: number;
  code: string = "";
  text: string = "";
  description?: string;
  inactive?: boolean;
  locked?: boolean;
}

export class NomenclatureValue implements INomenclatureValue {
  constructor(obj?: INomenclatureValue) {
    Object.assign(this, obj);
  }
  id?: number;
  code: string = "";
  text: string = "";
  sortOrder?: number;
  parentId: number | undefined;
  parentCode?: string;
  parentText?: string;
  description?: string;
  inactive?: boolean;
  locked?: boolean;
}

export class NomenclatureValueKey {
  id: number | undefined;
  parentId: number | undefined;
}

export enum NomenclatureCodes {
  TaskPriority = "PRIORITY",
  TaskResolutionType = "RESOLUTION_TYPE",
}
