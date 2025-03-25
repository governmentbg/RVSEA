import { ICommissionReportFile } from '@/interfaces/commission';
import { CommissionReportModel } from '@/models/commission';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class CommissionReportService {
    private url = appStore().getters.baseUrl + '/api/commissionreports';

    async getById(id: number): Promise<CommissionReportModel> {
        const response = await http.get(`${this.url}/${id}`);
        return response.data.data;
    }

    async getByProcessId(processId: number): Promise<CommissionReportModel> {
        const response = await http.get(`${this.url}/process/${processId}`);
        return response.data.data;
    }

    async create(data: CommissionReportModel): Promise<number> {
        const response = await http.post(`${this.url}`, data);
        return response.data.data;
    }

    async update(data: CommissionReportModel) {
        const response = await http.put(`${this.url}`, data);
        return response.data.data;
    }

    async getNextReportNumber(): Promise<number> {
        const response = await http.get(`${this.url}/nextNumber`);
        return response.data.data;
    }

    async getFiles(reportId: number): Promise<Array<ICommissionReportFile>> {
        const url = new URL(`${this.url}/files`);
        url.searchParams.append('reportId', reportId.toString());

        const response = await http.get(url.toString());
        return response.data.data;
    }

    async deleteFile(id: number, reportId: number): Promise<void> {
        const url = new URL(`${this.url}/files/${id}`);
        url.searchParams.append('reportId', reportId.toString());

        const response = await http.delete(url.toString());
        return response.data.data;
    }

    async uploadFiles(files: File[], reportId: number): Promise<void> {
        const url = new URL(`${this.url}/files/upload`);
        url.searchParams.append('reportId', reportId.toString());

        const formData = new FormData();
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            formData.append('files', file);
        }

        const response = await http.post(url.toString(), formData);
        return response;
    }

    reportFileDownloadUrl(id: number, reportId: number, processId: number, isInline?: boolean) {
        const url = new URL(`${this.url}/files/download/${id}`);
        url.searchParams.append('reportId', reportId.toString());
        url.searchParams.append('processId', processId.toString());
        if (isInline) {
            url.searchParams.append('isInline', String(isInline));
        }

        return url.toString();
    }

    async getListOfReportsByArchiveId(archiveId: number): Promise<CommissionReportModel[]> {
        const url = new URL(`${this.url}/list/${archiveId}`);
        const response = await http.get(url.toString());

        return response.data.data;
    }
}

const commissionReportService = new CommissionReportService();
export default commissionReportService;
