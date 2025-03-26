import http from "@/services/http.service";
import { appStore } from "@/store/app";

class LinksService {
    private url = appStore().getters.baseUrl + "/api/links";

    async getDaaSurveysLink():Promise<string> {
		const response = await http.get(`${this.url.toString()}/getLink`);
		return response.data.data;
	}
}

const linksService = new LinksService();
export default linksService;