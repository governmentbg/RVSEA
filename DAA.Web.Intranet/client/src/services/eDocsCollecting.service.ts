import { ProcessStep } from '@/enums/process';
import { IProcessStep } from '@/interfaces/process';
import { CommissionReportSubmitModel } from '@/models/commission';
import { IProcessDecision } from '@/models/eDocsCollection';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class EDocsCollectingService {
	private url = appStore().getters.baseUrl + '/api/CollectingProcedure';

	async submitReport(data: CommissionReportSubmitModel) {
		const response = await http.post(`${this.url}/CommitComitteeReport`, data);
		return response.data;
	}

	async sendForStandings(data: CommissionReportSubmitModel) {
		const response = await http.post(`${this.url}/SendForStandpoints`, data);
		return response.data;
	}

	async processDecision(data: IProcessDecision, stage: ProcessStep) {
		let path = 'approval';
		if (stage === ProcessStep.Affirmation) {
			path = 'affirmation';
		}
		if (stage === ProcessStep.SendForRedirect) {
			path = 'redirect';
		}
		const url = new URL(`${this.url}/report/${path}`);
		
		//const response = await http.post(`${this.url}/ProcessDecision`, data);
		const response = await http.post(url.toString(), data);
		return response.data;
	}

	async moveToNextStep(data: IProcessStep) {
		const response = await http.post(`${this.url}/moveToNextStep`, data);
		return response.data;
	}

	async sendModificationRequest(processId: number, comment: string) {
		const response = await http.post(`${this.url}/modificationRequest/${processId}`, comment);
		return response.data;
	}

	async sendSignatureRequest(processId: number, packageId: number, packageDocumentIds: number[]) {

		const url = new URL(`${this.url}/signatureRequest`);

        url.searchParams.append('processId', processId.toString());
        url.searchParams.append('packageId', packageId.toString());
        packageDocumentIds.forEach((documentId) => url.searchParams.append('packageDocumentId', documentId.toString()));
        
        const response = await http.post(url.toString(), null);
		return response.data;
	}

	async sendForRegistration(data: IProcessStep) {
		const response = await http.post(`${this.url}/SendForRegistration`, data);
		return response.data;
	}

	async completeProcess(processId: number) {
		const response = await http.post(`${this.url}/completeProcess/${processId}`, {});
		return response.data;
	}

	async isExternalProcess(id: number) : Promise<boolean> {
		const response = await http.get(`${this.url}/isExternalProcedure/${id}`);
		return response.data.data;
	}

	async getApplicationStatus(processId: number) : Promise<number | undefined> {
		const response = await http.get(`${this.url}/application/status/${processId}`);
		return response.data.data;
	}

	async returnReport(processId: number, comment: string) {
		const response = await http.post(`${this.url}/returnReport`, {
			id: processId,
			reason: comment
		});
		return response.data;
	}

	returnCommissionChanges(data: IProcessStep) {
		return http.post(`${this.url}/ReturnCommissionChanges`, data)
	}
}

const eDocsCollectingService = new EDocsCollectingService();
export default eDocsCollectingService;
