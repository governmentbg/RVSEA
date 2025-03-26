import { ProcessModel } from "@/models/process";
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class EditDataProcessService {
  private url = appStore().getters.baseUrl + "/api/editdataprocess";

  async startProcess(model: ProcessModel): Promise<number> {
    const response = await http.post(`${this.url}/start`, model);
    return response.data.data;
  }
  
  async completeProcess(processId: number) {
    const response = await http.post(`${this.url}/complete/${processId}`, null);
    return response;
  }

  async undoProcessChanges(processId: number) {
    const response = await http.post(`${this.url}/undochanges/${processId}`, null);
    return response;
  }
}

const processService = new EditDataProcessService();
export default processService;
