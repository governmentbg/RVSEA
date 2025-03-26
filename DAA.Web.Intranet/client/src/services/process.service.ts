import { IProcess, IProcessTimeline } from '@/interfaces/process';
//import { ProcessModel } from "@/models/process"
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class ProcessService {
    private url = appStore().getters.baseUrl + '/api/process';

    async getProcess(processId: number): Promise<IProcess> {
        const url = new URL(`${this.url}/${processId}`);

        const response = await http.get(url.toString());
        return response.data.data;
    }

    async getTimeline(processId: number): Promise<IProcessTimeline[]> {
        const response = await http.get(`${this.url}/timeline/${processId}`);
        return response.data.data;
    }

    async getCurrentActiveProcess(
        entityType: string,
        entitySysId?: string,
        includeParent?: boolean,
        externalIdentifier?: number
    ) {
        const url = new URL(`${this.url}/current/${entityType}`);
        if (entitySysId) {
            url.searchParams.append('entitySysId', entitySysId.toString());
        }
        if (includeParent) {
            url.searchParams.append('includeParent', includeParent.toString());
        }
        if (externalIdentifier) {
            url.searchParams.append('externalIdentifier', externalIdentifier.toString());
        }
        //const response = await http.get(`${this.url}/current/${entityType}/${entitySysId}`);
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async getIsCurrentUserInProcess(processId: number): Promise<boolean> {
        const url = new URL(`${this.url}/currentUser/inProcess/${processId}`);

        const response = await http.get(url.toString());
        return response.data.data;
    }

    async getIsCurrentUserInProcessStep(processId: number, processStepId: number): Promise<boolean> {
        const url = new URL(`${this.url}/currentUser/inStep/${processStepId}`);
        url.searchParams.append('processId', processId.toString());

        const response = await http.get(url.toString());
        return response.data.data;
    }

    async getLastProcessType(sysId?: string): Promise<number> {
        const response = await http.get(`${this.url}/lastProcessType/${sysId}`);
        return response.data.data;
    }
}

const processService = new ProcessService();
export default processService;
