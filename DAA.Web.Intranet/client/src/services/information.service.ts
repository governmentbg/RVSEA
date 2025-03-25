import { GridOptions } from '@/models/grid';
import { appStore } from '@/store/app';
import http from '@/services/http.service';
import { IInformation } from '@/interfaces/information';

class InformationService {
    private url = appStore().getters.baseUrl + '/api/information';

    async list(options: GridOptions) {
        const url = new URL(`${this.url}/list`);
        const response = await http.post(url.toString(), options);
        return response.data.data;
    }

    async get(id: number) {
        const url = new URL(`${this.url}/getById/${id}`);
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async listCarouselItems(options: GridOptions) {
        const url = new URL(`${this.url}/listCarouselItems`);
        const response = await http.post(url.toString(), options);
        return response.data.data;
    }

    async listCalendarItems(dates: Date[]) {
        const url = new URL(`${this.url}/listCalendarItems`);
        const response = await http.post(url.toString(), { dates });
        return response.data.data;
    }

    async create(model: IInformation) {
        const response = await http.post(`${this.url}`, model);
        return response;
    }

    async update(model: IInformation) {
        const response = await http.put(`${this.url}`, model);
        return response;
    }

    async delete(id: number | undefined) {
        const response = await http.delete(`${this.url}/` + id);
        return response;
    }
}

const informationService = new InformationService();
export default informationService;
