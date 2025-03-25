import { ProcessModel, ProcessStepModel } from "@/models/process";
import { CommissionReportSubmitModel } from '@/models/commission';
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class ProcessRawInventoriesProcessService {
    private url = appStore().getters.baseUrl + "/api/processrawinventoriesprocess";

    async fundHasRawInventoriesInSEA(sysId: string): Promise<boolean> {
        const response = await http.get(`${this.url}/fundHasRawInventoriesInSEA/${sysId}`);
        return response.data.data;
    }

    async startProcess(model: ProcessModel): Promise<number> {
        const response = await http.post(`${this.url}/start`, model);
        return response.data.data;
    }

    async undoProcessChanges(processId: number) {
        const response = await http.post(`${this.url}/undochanges/${processId}`, null);
        return response;
    }
    
	async getSelectedRawInventories(sysId: string): Promise<Array<string>> {
		const response = await http.get(`${this.url}/getSelectedRawInventories/${sysId}`);
		return response.data.data;
	}

    async saveSelectedRawInventories(fundSystemIdentifier: string, processId: number, selectedRawInventories: Array<string>) {
		const url = new URL(`${this.url}/saveSelectedRawInventories/${fundSystemIdentifier}`);
		url.searchParams.append("processId", processId.toString());
		url.searchParams.append("selectedRawInventories", selectedRawInventories.join(','));
		
		const response = await http.post(url.toString(), {});
		return response;
	}

    async createNormalInventories(processId: number) {
        const response = await http.post(`${this.url}/createnormalinventories/${processId}`, null);
        return response;
    }

    async createReport(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/report/create`, data);
        return response.data.data;
    }

    async sendReport(data: CommissionReportSubmitModel) {
        const response = await http.post(`${this.url}/report/send`, data);
        return response;
    }

    async startApplyingChanges(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/changes/start`, data);
        return response.data.data;
    }

    async addReportToSessionAgenda(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/report/addtoagenda`, data);
        return response;
    }

    async sendToAddSessionAgendaItemStandpoint(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/agendaitem/send`, data);
        return response;
    }

    async sendSessionAgendaItemStandpoint(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/standpoint/send`, data);
        return response;
    }

    async sendToAddSessionAgendaItemStandpointComment(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/standpoint/addcomment`, data);
        return response;
    }

    async addSessionAgendaItemStandpointComment(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/standpoint/createcomment`, data);
        return response;
    }

    async sendSessionAgendaItemStandpointComment(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/standpoint/sendcomment`, data);
        return response;
    }

    async setSessionAgendaItem(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/agendaitem/set`, data);
        return response;
    }

    async sendReportApprovalResult(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/report/approval`, data);
        return response.data.data;
    }

    async applyReportModifications(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/report/applychanges`, data);
        return response.data.data;
    }

    async sendForModificationsRevision(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/report/sendchanges`, data);
        return response.data.data;
    }

    async modificationsRevision(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/report/revision`, data);
        return response.data.data;
    }

    async sendForModificationsAffirmation(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/report/affirmation/send`, data);
        return response.data.data;
    }

    async sendModificationsAffirmationResult(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/report/affirmation`, data);
        return response.data.data;
    }

    async sendToRegistrar(data: ProcessStepModel) {
        const response = await http.post(`${this.url}/sendToRegistrar`, data);
        return response.data.data;
    }

    async completeProcess(processId: number) {
        const response = await http.post(`${this.url}/complete/${processId}`, null);
        return response;
    }

    
    async deleteDocumentDraft(id: number) {
        const response = await http.delete(`${this.url}/document/${id}`);
        return response;
    }
    
    async deleteArchivalEntityDraft(id: number) {
        const response = await http.delete(`${this.url}/archivalEntity/${id}`);
        return response;
    }

    async markInvaluableFiles(inventorySysId: string) {
        const response = await http.post(`${this.url}/markInvaluableFiles/${inventorySysId}`, null);
        return response;
    }
}

const processService = new ProcessRawInventoriesProcessService();
export default processService;
