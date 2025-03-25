import http from "@/services/http.service";
import { appStore } from "@/store/app";

class ImportService {
  private url = appStore().getters.baseUrl + "/api/import";

  async importFile(inventorySysId: string, data: File) {
    const formData = new FormData();
		formData.append("file", data!);

    const response = await http.post(`${this.url}/archivalEntities/${inventorySysId}?readPackagesSheet=true&readInventorySheet=false`, formData);
    return response;
  }

}

const importService = new ImportService();
export default importService;
