import { ISessionAgendaItem, ISessionAgendaItemStandpoint } from '@/interfaces/commission';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class SessionAgendaService {
    private url = appStore().getters.baseUrl + '/api/sessionagenda';

    displaySessionAgendaItemStandpointsUrl(itemId: number) {
        const url = new URL(`${this.url}/standpoint/list/${itemId}`);
        return url.toString();
    }

    async getSessionAgenda(sessionId: number): Promise<ISessionAgendaItem[]> {
        const url = new URL(`${this.url}/list/${sessionId}`);
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async getSessionAgendaItemCount(sessionId: number): Promise<number> {
        const url = new URL(`${this.url}/item/count/session/${sessionId}`);
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async displaySessionAgendaItem(id: number): Promise<ISessionAgendaItem> {
        const url = new URL(`${this.url}/item/${id}`);
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async displaySessionAgendaItemByProcess(processId: number): Promise<ISessionAgendaItem> {
        const url = new URL(`${this.url}/item/process/${processId}`);
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async displaySessionAgendaItemStandpoint(id: number): Promise<ISessionAgendaItemStandpoint> {
        const url = new URL(`${this.url}/standpoint/${id}`);
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async displaySessionAgendaItemStandpointByItem(itemId: number): Promise<ISessionAgendaItemStandpoint> {
        const url = new URL(`${this.url}/standpoint/item/${itemId}`);
        const response = await http.get(url.toString());

        return response.data.data;
    }

    async displaySessionAgendaItemStandpointByProcess(processId: number): Promise<ISessionAgendaItemStandpoint> {
        const url = new URL(`${this.url}/standpoint/process/${processId}`);
        const response = await http.get(url.toString());

        return response.data.data;
    }

    async displaySessionAgendaItemStandpointsByProcess(processId: number): Promise<ISessionAgendaItemStandpoint[]> {
        const url = new URL(`${this.url}/standpoint/list/process/${processId}`);
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async displaySessionAgendaItemStandpoints(itemId: number): Promise<ISessionAgendaItemStandpoint[]> {
        const url = new URL(`${this.url}/standpoint/list/${itemId}`);
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async createSessionAgendaItem(data: ISessionAgendaItem): Promise<number> {
        const url = new URL(`${this.url}/item`);

        const response = await http.post(url.toString(), data);
        return response.data.data;
    }

    async createSessionAgendaItemStandpoint(data: ISessionAgendaItemStandpoint): Promise<number> {
        const url = new URL(`${this.url}/standpoint`);

        const response = await http.post(url.toString(), data);
        return response.data.data;
    }

    async updateSessionAgendaItem(data: ISessionAgendaItem): Promise<number> {
        const url = new URL(`${this.url}/item`);

        const response = await http.put(url.toString(), data);
        return response.data.data;
    }

    async updateSessionAgendaItemStandpoint(data: ISessionAgendaItemStandpoint): Promise<number> {
        const url = new URL(`${this.url}/standpoint`);

        const response = await http.put(url.toString(), data);
        return response.data.data;
    }

    async setSessionAgendaItemStandpointStatus(data: ISessionAgendaItemStandpoint): Promise<number> {
        const url = new URL(`${this.url}/standpoint/status`);

        const response = await http.put(url.toString(), data);
        return response.data.data;
    }

    async deleteSessionAgendaItem(id: number): Promise<void> {
        const url = new URL(`${this.url}/item/${id}`);

        const response = await http.delete(url.toString());
        return response;
    }
}

const sessionAgendaService = new SessionAgendaService();
export default sessionAgendaService;
