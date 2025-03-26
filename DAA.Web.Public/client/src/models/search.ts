export class SearchModel {
  constructor(obj?: SearchModel) {
    if (obj) {
      Object.assign(this, obj);
    }
  }
  //searchDrafts: boolean = false;
  archiveId?: string[] = [];
  descriptionLevelCode?: string[] = [];
  descriptionLevelCodeExternal?: string[] = [];
  fundNumber?: string;
  inventoryNumber?: string;
  archivalEntityNumber?: string;
  cmfNumber?: string;
  cmfCountriesOfOriginCodes?: string[] = [];
  advancedSearch?: boolean;
  searchFileContent?: boolean;
  foreignarchives?: boolean;
  searchByDigitalCopies?: string;
  fundArrayCode?: string[] = [];
  fundArrayCodeExternal?: string[] = [];
  name?: string;
  keyWords?: string;
  dateFrom?: Date | null = null;
  dateTo?: Date | null = null;
  itemsPerPage?: number;
  page?: number;
  searchString?: string;
  sortBy?: string;
  sortByType?: string;
  sortDesc?: boolean;
}
