import http from "@/services/http.service";
import { appStore } from "@/store/app";
import { FileDownloadModel } from '@/models/file';

class SettingsService {
    private url = appStore().getters.baseUrl + "/api/settings";

    async downloadFileUploaderApp(version: number): Promise<FileDownloadModel> {
		const response = await http.get(`${this.url}/download/fileUploaderApp/${version}`);
		return response.data.data;
	}

	async getVersion() {
        const response = await http.get(`${this.url}/version`);
        return response.data;
    }

    async convertToPdf(data: File) {
        const formData = new FormData();
        formData.append('uploadedFile', data);
        
        const response = await http.put(`${this.url}/converter`, formData);
        return response.data.data;
    }
}

const service = new SettingsService();
export default service;
