import { GridOptions } from "@/models/grid";
import {
  //SearchedArchiveEntityRequestModel,
  // ArchiveEntityShort,
  DocumentAncestorsData,
} from "@/models/archivalEntity";
import http from "@/services/http.service";
import { appStore } from "@/store/app";
import { IArchivalEntity } from "@/interfaces/archivalEntity";
import { defaultGuidString } from "@/helpers/format.helper";

class ArchiveEntityService {
  private url = appStore().getters.baseUrl + "/api/archivalEntities";

  async getInventoryArchivalEntities(
    options: GridOptions,
    inventorySysId?: string,
    inventoryHasExternalSource?: boolean,
    inventoryExternalIdentifier?: number,
    searchInventoryNumberString?: string
  ) {
    const url = new URL(`${this.url}/listByInventory/${inventorySysId ?? ""}`);
    if (inventoryHasExternalSource) {
      url.searchParams.append(
        "inventoryHasExternalSource",
        inventoryHasExternalSource.toString()
      );
    }
    if (inventoryHasExternalSource && inventoryExternalIdentifier) {
      url.searchParams.append(
        "inventoryExternalIdentifier",
        inventoryExternalIdentifier.toString()
      );
    }
    if (searchInventoryNumberString) {
      url.searchParams.append(
        "searchInventoryNumberString",
        searchInventoryNumberString
      );
    }

    const response = await http.post(url.toString(), options);
    return response.data.data;
  }

  async displayArchivalEntity(
    sysId?: string,
    hasExternalSource?: boolean,
    externalIdentifier?: number
  ): Promise<IArchivalEntity> {
    const url = new URL(`${this.url}/${sysId ?? ""}`);
    if (hasExternalSource) {
      url.searchParams.append(
        "hasExternalSource",
        hasExternalSource.toString()
      );
    }
    if (hasExternalSource && externalIdentifier) {
      url.searchParams.append(
        "externalIdentifier",
        externalIdentifier.toString()
      );
    }

    const response = await http.get(url.toString());
    return response.data.data;
  }

  async getDocumentAncestorsDataById(id: number): Promise<DocumentAncestorsData> {
    const response = await http.get(`${this.url}/ancestorsDataById/${id}`);
    return response.data;
  }

  async displayArchivalEntityDraft(sysId: string): Promise<IArchivalEntity> {
    const url = new URL(`${this.url}/getDraft/${sysId ?? defaultGuidString}`);
    
    const response = await http.get(url.toString());
    return response.data.data;
  }

  async modifyArchivalEntityDraft(data: IArchivalEntity) {
    const response = await http.post(`${this.url}`, { ...data});
    return response;
  }
  
}

const archiveEntityService = new ArchiveEntityService();
export default archiveEntityService;
