import { defaultGuidString } from "@/helpers/format.helper";
import { IInventory } from "@/interfaces/inventory";
import { GridOptions } from "@/models/grid";
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class InventoryService {
  private url = appStore().getters.baseUrl + "/api/inventories";

  async getFundInventories(
    options: GridOptions,
    fundSysId?: string,
    hasExternalSource?: boolean,
    externalIdentifier?: number
  ) {
    const url = new URL(`${this.url}/listbyfund/${fundSysId ?? ""}`);
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
    const response = await http.post(url.toString(), options);
    return response.data.data;
  }

  async displayInventory(
    sysId?: string,
    hasExternalSource?: boolean,
    externalIdentifier?: number
  ): Promise<IInventory> {
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

  async displayInventoryDraft(sysId: string): Promise<IInventory> {
    const url = new URL(`${this.url}/getDraft/${sysId ?? defaultGuidString}`);
    
    const response = await http.get(url.toString());
    return response.data.data;
  }
  
  async modifyInventoryDraft(data: IInventory) {
    const response = await http.post(`${this.url}`, { ...data});
    return response;
  }
}

const inventoryService = new InventoryService();
export default inventoryService;
