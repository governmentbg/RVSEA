import { ICommissionDecision } from '@/interfaces/commission';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class CommissionDecisionService {
    private url = appStore().getters.baseUrl + '/api/commissiondecisions';

    async getDecisionById(id: number): Promise<ICommissionDecision> {
        const response = await http.get(`${this.url}/${id}`);
        return response.data.data;
    }

    async getDecisionBySessionAgendaId(sessionAgendaId: number): Promise<ICommissionDecision> {
        const response = await http.get(`${this.url}/session/agenda/${sessionAgendaId}`);
        return response.data.data;
    }

    async getDecisionByProcessId(processId: number): Promise<ICommissionDecision> {
        const response = await http.get(`${this.url}/process/${processId}`);
        return response.data.data;
    }

    async getDecisionBySessionId(sessionId: number): Promise<ICommissionDecision[]> {
        const response = await http.get(`${this.url}/session/${sessionId}`);
        return response.data.data;
    }

    async getDecisionCountBySessionId(sessionId: number): Promise<number> {
        const response = await http.get(`${this.url}/count/session/${sessionId}`);
        return response.data.data;
    }

    async createDecision(data: ICommissionDecision) {
        const response = await http.post(`${this.url}`, data);
        return response.data.data;
    }

    async updateDecision(data: ICommissionDecision) {
        const response = await http.put(`${this.url}`, data);
        return response.data.data;
    }

    async createOrUpdate(data: ICommissionDecision) {
        const response = await http.post(`${this.url}/createOrUpdate`, data);
        return response.data.data.data;
    }
    getFileDownloadUrl(agendaId: number): string {
        return `${this.url}/download/${agendaId}`;
    }
}

const commissionDecisionService = new CommissionDecisionService();
export default commissionDecisionService;
