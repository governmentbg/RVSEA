import { IInventory, IInventoryDraft } from "@/interfaces/inventory";
import { GridOptions } from "@/models/grid";
import {
  InventoryShort,
  SearchedInventoryRequestModel,
} from "@/models/inventory";
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class InventoryService {
  private url = appStore().getters.baseUrl + "/api/inventories";

  getInventoriesUrl(includeDrafts?: boolean): string {
    const url = new URL(`${this.url}/listall`);
    if (includeDrafts !== undefined) {
      url.searchParams.append("includeDrafts", includeDrafts.toString());
    }
    //return `${this.url}/listall`;
    return url.toString();
  }

  async getFundInventories(options: GridOptions, fundSysId?: string, hasExternalSource?: boolean, externalIdentifier?: number) {
    const url = new URL(`${this.url}/listbyfund/${fundSysId ?? ''}`);
    if (hasExternalSource) {
      url.searchParams.append("hasExternalSource", hasExternalSource.toString());
    }
    if (hasExternalSource && externalIdentifier) {
      url.searchParams.append("externalIdentifier", externalIdentifier.toString());
    }

    const response = await http.post(url.toString(), options);
    return response.data.data;
  }

  async displayInventory(sysId?: string, hasExternalSource?: boolean, externalIdentifier?: number, includeDrafts?: boolean): Promise<IInventory> {
    const url = new URL(`${this.url}/${sysId ?? ''}`);
    if (hasExternalSource) {
      url.searchParams.append("hasExternalSource", hasExternalSource.toString());
    }
    if (hasExternalSource && externalIdentifier) {
      url.searchParams.append("externalIdentifier", externalIdentifier.toString());
    }
    if (includeDrafts !== undefined) {
      url.searchParams.append("includeDrafts", includeDrafts.toString());
    }
    //const response = await http.get(`${this.url}/${id}`);
    const response = await http.get(url.toString());
    return response.data.data;
  }
  async createInventory(data: IInventoryDraft, startProcess = true) {
    const response = await http.post(`${this.url}`, { ...data, startProcess });
    return response;
  }
  async updateInventory(data: IInventory) {
    const response = await http.put(`${this.url}`, data);
    return response;
  }
  async deleteInventory(sysId: string) {
    const response = await http.delete(`${this.url}/${sysId}`);
    return response;
  }

  async deleteInventoryDraft(id: number) {
    const response = await http.delete(`${this.url}/draft/${id}`);
    return response;
  }

  async getInventoriesShort(
    model: SearchedInventoryRequestModel
  ): Promise<InventoryShort> {
    const response = await http.post(`${this.url}/search`, model);
    return response.data.data.result;
  }
  async getByFundId(fundId: number): Promise<InventoryShort> {
    const response = await http.get(`${this.url}/getByFundId/${fundId}`);
    return response.data.data;
  }
  getInventoryPublicUserReviewsUrl(systemIdentifier?: string) {
    const url = new URL(`${this.url}/inventoryPublicUsersReviews/${systemIdentifier ?? ''}`);
    return url.toString();
  }
}

const inventoryService = new InventoryService();
export default inventoryService;
