import http from "@/services/http.service";
import { appStore } from "@/store/app";

class SettingsService {
    private url = appStore().getters.baseUrl + "/api/settings";

	async getVersion() {
        const response = await http.get(`${this.url}/version`);
        return response.data;
    }
}

const service = new SettingsService();
export default service;
