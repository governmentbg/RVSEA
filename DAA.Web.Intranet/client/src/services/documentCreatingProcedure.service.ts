/* eslint-disable @typescript-eslint/no-explicit-any */
import { ProcedureCreateModel, ProcedureViewModel } from '@/models/documentCreateProc';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class DocumentService {
    private url = appStore().getters.baseUrl + '/api/documentCreatingProcedure';

    async get(id: string): Promise<ProcedureViewModel> {
        const response = await http.get(`${this.url}/id/${id}`);
        return response.data.data;
    }
    async startProcess(val: ProcedureCreateModel) {
        const response = await http.post(`${this.url}/startProcess`, val);
        return response.data;
    }
    async goNextStep(data: ProcedureViewModel) {
        const formData = new FormData();
        formData.append('id', data.id!.toString());
        formData.append('completed', data.completed!.toString());
        formData.append('documentSystemIdentifier', data.documentSystemIdentifier!);
        formData.append('procedureStepTypeId', data.procedureStepTypeId!.toString());
        formData.append('procedureType', data.procedureType!.toString());
        if (data.readyForImport) {
            formData.append('readyForImport', data.readyForImport!.toString());
        }
        if (data.assignToRoleId) {
            formData.append('assignToRoleId', data.assignToRoleId!.toString());
        }
        if (data.assignToUserId) {
            formData.append('assignToUserId', data.assignToUserId!.toString());
        }
        formData.append('documentId', data.documentId!.toString());
        if (data.procedureStepName) {
            formData.append('procedureStepName', data.procedureStepName!.toString());
        }
        if (data.comments?.length) {
            formData.append('comments', data.comments[0].text as string);
        }
        if (data.files) {
            data.files.forEach((element) => {
                formData.append('files', element);
            });
        }
        if (data.masterFiles) {
            data.masterFiles.forEach((element) => {
                formData.append('masterFiles', element);
            });
        }
        if (data.derivativesFiles) {
            data.derivativesFiles.forEach((element) => {
                formData.append('derivativesFiles', element);
            });
        }
        const response = await http.put(`${this.url}/nextStep`, formData);
        return response.data.data;
    }
    async saveChanges(data: ProcedureViewModel) {
        const formData = new FormData();
        formData.append('id', data.id!.toString());
        formData.append('completed', data.completed!.toString());
        formData.append('documentSystemIdentifier', data.documentSystemIdentifier!);
        formData.append('procedureStepTypeId', data.procedureStepTypeId!.toString());
        formData.append('procedureType', data.procedureType!.toString());
        if (data.readyForImport) {
            formData.append('readyForImport', data.readyForImport!.toString());
        }
        if (data.assignToRoleId) {
            formData.append('assignToRoleId', data.assignToRoleId!.toString());
        }
        if (data.assignToUserId) {
            formData.append('assignToUserId', data.assignToUserId!.toString());
        }
        formData.append('documentId', data.documentId!.toString());
        if (data.procedureStepName) {
            formData.append('procedureStepName', data.procedureStepName!.toString());
        }
        if (data.comments?.length) {
            formData.append('comments', data.comments[0].text as string);
        }
        if (data.files) {
            data.files.forEach((element) => {
                formData.append('files', element);
            });
        }
        if (data.masterFiles) {
            data.masterFiles.forEach((element) => {
                formData.append('masterFiles', element);
            });
        }
        if (data.derivativesFiles) {
            data.derivativesFiles.forEach((element) => {
                formData.append('derivativesFiles', element);
            });
        }
        formData.append('skipMasterValidation', data.skipMasterValidation!.toString());
        formData.append('skipDerivativeValidation', data.skipDerivativeValidation!.toString());
        formData.append('skipDemoValidation', data.skipDemoValidation!.toString());

        const response = await http.put(`${this.url}/saveChanges`, formData);
        return response.data.data;
    }
    async goPreviousStep(val: ProcedureViewModel) {
        const response = await http.put(`${this.url}/previousStep`, val);
        return response.data.data;
    }
    getDocumentFilesUrl(documentId: string): string {
        return `${this.url}/getallfiles/${documentId}`;
    }
    async deleteDocumentFile(fileId: string, id: number) {
        const response = await http.delete(`${this.url}/${fileId}/${id}`);
        return response.data;
    }
    getFileDownloadUrl(fileId: string): string {
        return `${this.url}/download/${fileId}`;
    }
}

const documentProcedureService = new DocumentService();
export default documentProcedureService;
