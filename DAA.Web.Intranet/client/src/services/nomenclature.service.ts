import http from "./http.service";
import { appStore } from "@/store/app";
import { INomenclature, INomenclatureValue } from "@/interfaces/nomenclature";
import { DataTable } from "@/models/dataTable";

export class NomenclatureService {
  private url = appStore().getters.baseUrl + "/api/nomenclatures";

  getNomenclaturesUrl() {
    return `${this.url}/listall`;
  }

  getNomenclatureValuesUrl(parentId?: number) {
    return `${this.url}/values/list/${parentId}`;
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  async getNomenclatures(model: any): Promise<DataTable<INomenclature>> {
    const response = await http.post(`${this.url}/list`, model);
    return response.data.data;
  }

  async getNomenclatureValues(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    model: any,
    parentId: number
  ): Promise<DataTable<INomenclatureValue>> {
    const response = await http.post(
      `${this.url}/values/list/${parentId}`,
      model
    );
    return response.data.data;
  }

  async getNomenclature(id: number): Promise<INomenclature> {
    const response = await http.get(`${this.url}/${id}`);
    return response.data.data;
  }

  async getNomenclatureValue(
    id: number,
    parentId: number
  ): Promise<INomenclatureValue> {
    const response = await http.get(`${this.url}/${parentId}/values/${id}`);
    return response.data.data;
  }

  async createNomenclature(model: INomenclature) {
    const response = await http.post(`${this.url}`, model);
    return response;
  }
  async createNomenclatureValue(model: INomenclatureValue) {
    const response = await http.post(`${this.url}/values`, model);
    return response;
  }
  async updateNomenclature(data: INomenclature) {
    const response = await http.put(`${this.url}`, data);
    return response;
  }
  async updateNomenclatureValue(data: INomenclatureValue) {
    const response = await http.put(`${this.url}/values`, data);
    return response;
  }
  async deleteNomenclature(id: number) {
    const response = await http.delete(`${this.url}/` + id);
    return response;
  }
  async deleteNomenclatureValue(id: number) {
    const response = await http.delete(`${this.url}/values/` + id);
    return response;
  }
}

const nomenclatureService = new NomenclatureService();
export default nomenclatureService;
