import { IFundReconstructionModel } from "@/interfaces/fundReconstruction";
import { ProcessModel, ProcessStepModel } from "@/models/process";
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class ReconstructFundDataProcessService {
  private url = appStore().getters.baseUrl + "/api/reconstructfunddataprocess";

  async startProcess(model: ProcessModel): Promise<number> {
      const response = await http.post(`${this.url}/start`, model);
      return response.data.data;
  }

  async completeProcess(processId: number) {
      const response = await http.post(`${this.url}/complete/${processId}`, null);
      return response;
  }

  async undoProcessChanges(processId: number) {
      const response = await http.post(`${this.url}/undochanges/${processId}`, null);
      return response;
  }

  async requestPublicAccessSuspension(data: ProcessStepModel) {
      const response = await http.post(`${this.url}/access/request`, data);
      return response.data.data;
  }

  async suspendPublicAccess(data: ProcessStepModel) {
      const response = await http.post(`${this.url}/access/suspend`, data);
      return response.data.data;
  }

  async startApplyingChanges(data: ProcessStepModel) {
      const response = await http.post(`${this.url}/changes/start`, data);
      return response.data.data;
  }

  async deductData(data: Array<IFundReconstructionModel>) {
      const response = await http.post(`${this.url}/changes/deduction`, data);
      return response.data.data;
  }

  async createReport(data: ProcessStepModel) {
    const response = await http.post(`${this.url}/report/create`, data);
    return response;
  }

  async sendReport(data: ProcessStepModel) {
    const response = await http.post(`${this.url}/report/send`, data);
    return response;
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

  async sendForModificationsRegistration(data: ProcessStepModel) {
    const response = await http.post(`${this.url}/registration/send`, data);
    return response.data.data;
  }

  async startModificationsRegistration(data: ProcessStepModel) {
    const response = await http.post(`${this.url}/registration`, data);
    return response.data.data;
  }
}

const processService = new ReconstructFundDataProcessService();
export default processService;
