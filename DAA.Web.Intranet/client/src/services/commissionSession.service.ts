import { ICommissionSession } from '@/interfaces/commission';
import { CommissionSessionModel } from '@/models/commission';
import { SessionProtocol, SessionProtocolUploadFileModel } from '@/models/protocol';
import { GenerateProtocolModel, SessionEditModel } from '@/models/sessionProtocolData';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class CommissionSessionService {
    private url = appStore().getters.baseUrl + '/api/commissionsessions';

    getListAllSessionsUrl = () => `${this.url}/listall`;

    getListUpcomingSessionsUrl = () => `${this.url}/list/upcoming`;

    getListPastSessionsUrl = () => `${this.url}/list/past`;

    async getSession(id: number): Promise<ICommissionSession> {
        const response = await http.get(`${this.url}/${id}`);
        return response.data.data;
    }
    async createSession(data: CommissionSessionModel) {
        const response = await http.post(`${this.url}/create`, data);
        return response.data.data;
    }
    async updateSession(data: CommissionSessionModel) {
        const response = await http.put(`${this.url}/edit`, data);
        return response.data.data;
    }
    async editSessionProtocol(data: SessionProtocol) {
        const response = await http.put(`${this.url}/editProtocolContent`, data);
        return response.data;
    }
    async generateSessionProtocol(data: GenerateProtocolModel) {
        const response = await http.post(`${this.url}/generate`, data);
        return response.data.data;
    }
    async sendProtocolForApproval(data: number) {
        const response = await http.put(`${this.url}/sendProtocolForApproval`, data);
        return response.data.data;
    }
    async approvalProtocol(data: number) {
        const response = await http.put(`${this.url}/approvalProtocol`, data);
        return response.data.data;
    }
    async getSessionProtocolContent(id: number) {
        const response = await http.get(`${this.url}/getProtocolContent/${id}`);
        return response.data.data;
    }
    async deleteSession(id: number) {
        const response = await http.delete(`${this.url}/${id}`);
        return response;
    }
    async uploadSessionProtocol(data: SessionProtocolUploadFileModel) {
        const formData = new FormData();
        if (data.sessionId) {
            formData.append('sessionId', data.sessionId!.toString());
        }
        if (data.files) {
            data.files.forEach((element) => {
                formData.append('files', element);
            });
        }
        const response = await http.put(`${this.url}/upload`, formData);
        return response.data;
    }

    async rejectProtocol(data: number, rejectReason: string) {
        const response = await http.put(`${this.url}/rejectProtocol/${data}`, rejectReason);
        return response.data.data;
    }

    getFileDownloadUrl(sessionId: number): string {
        return `${this.url}/download/${sessionId}`;
    }
    async getSessionProtocolData(model: SessionProtocol) {
        const response = await http.put(`${this.url}/getProtocolData`, model);
        return response.data.data;
    }
    async editSessionAgendas(model: SessionEditModel) {
        const response = await http.put(`${this.url}/editSessionAgendaList`, model);
        return response.data;
    }
}

const commissionSessionService = new CommissionSessionService();
export default commissionSessionService;
