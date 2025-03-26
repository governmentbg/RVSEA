import { IProcess } from '@/interfaces/process';
import { IApplicationDisplay, IApprove, IReject } from '@/models/applications';
import { IPackagesFormData } from '@/models/packages';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class ApplicationService {
    private url = appStore().getters.baseUrl + '/api/EDocsCollectingApplications';

    packageDocumentStreamUrl(id: number, inline?: boolean) {
        const url = new URL(`${this.url}/packageDocument/stream/${id}${inline ? '?inline=true' : ''}`);
        return url.toString();
    }

    get(id: number): Promise<IApplicationDisplay> {
        return http.get(`${this.url}/${id}`).then((response) => response.data as IApplicationDisplay);
    }

    getRelatedProcess(id: number): Promise<IProcess> {
        return http.get(`${this.url}/${id}/process`).then((response) => response.data as IProcess);
    }

    approve(data: IApprove) {
        return http.post(`${this.url}/approve`, data);
    }

    reject(data: IReject) {
        return http.post(`${this.url}/reject`, data);
    }

    getPackages(applicationId: number): Promise<IPackagesFormData> {
        return http.get(`${this.url}/packages/${applicationId}`).then((response) => response.data);
    }

    approvePackages(data: IApprove) {
        return http.post(`${this.url}/ApprovePackages`, data);
    }

    rejectPackages(data: IReject) {
        return http.post(`${this.url}/RejectPackages`, data);
    }
    cancelPackages(data: IReject) {
        return http.post(`${this.url}/CancelPackages`, data);
    }

    async streamPackageDocumentFile(id: number, inline?: boolean) {
        const url = this.packageDocumentStreamUrl(id, inline)
        const response = await http.get(url.toString(), undefined, undefined, { responseType: "blob" });
        return response.data;
    }
}
const applicationService = new ApplicationService();
export default applicationService;
