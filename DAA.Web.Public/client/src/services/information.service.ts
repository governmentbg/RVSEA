import { GridOptions } from '@/models/grid';
import { appStore } from '@/store/app';
import http from '@/services/http.service';

class InformationService {
    private url = appStore().getters.baseUrl + '/api/information';

    async listCarouselItems(options: GridOptions) {
        const url = new URL(`${this.url}/listCarouselItems`);
        const response = await http.post(url.toString(), options);
        return response.data.data;
    }

    async get(id: number) {
        const url = new URL(`${this.url}/getById/${id}`);
        const response = await http.get(url.toString());
        return response.data.data;
    }
}

const informationService = new InformationService();
export default informationService;
