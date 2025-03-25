import { ProcessType } from '@/enums/process';
import { DeductionProcessCreateModel, DeductionProcessViewModel } from '@/models/deductionProcess';
import { BusinessObjectType } from '@/models/grid';
import { ResponseResult } from '@/models/responseResult';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class DeductionService {
    private url = appStore().getters.baseUrl + '/api/deductionProcess';

    async getById(sysId?: string, entityType?: string): Promise<DeductionProcessViewModel> {
        const url = new URL(`${this.url}/${sysId ?? ''}`);
        if (entityType) {
            url.searchParams.append('entityType', entityType.toString());
        }

        const response = await http.get(url.toString());

        return response.data.data;
    }

    async start(
        id: string,
        externalIdentifier: number,
        entityType: string,
        archiveId: number
    ): Promise<ResponseResult> {
        const submitData = new DeductionProcessCreateModel();

        switch (entityType) {
            case BusinessObjectType.document:
                submitData.documentSystemIdentifier = id;
                submitData.documentEntityExternalIdentifier = externalIdentifier;
                break;
            case BusinessObjectType.archivalEntity:
                submitData.archivalEntitySystemIdentifier = id;
                submitData.archivalEntityExternalIdentifier = externalIdentifier;
                break;
            case BusinessObjectType.inventory:
                submitData.inventorySystemIdentifier = id;
                submitData.inventoryExternalIdentifier = externalIdentifier;
                break;
            case BusinessObjectType.fund:
                submitData.fundSystemIdentifier = id;
                submitData.fundExternalIdentifier = externalIdentifier;
                break;
        }

        submitData.procedureType = ProcessType.DeductData;
        submitData.archiveId = archiveId;

        const response = await http.post(`${this.url}/create`, submitData);
        return response.data.data;
    }

    async updateStep(data: DeductionProcessViewModel) {
        const response = await http.put(`${this.url}/updateStep`, data);
        return response.data.data;
    }

    async terminateProcess(data: DeductionProcessViewModel) {
        const response = await http.put(`${this.url}/terminate`, data);
        return response.data.data;
    }

    async saveChanges(data: DeductionProcessViewModel) {
        const response = await http.put(`${this.url}/save`, data);
        return response.data.data;
    }

    async stepBack(val: DeductionProcessViewModel) {
        const response = await http.put(`${this.url}/stepBack`, val);
        return response.data.data;
    }

    async undoChanges(val: DeductionProcessViewModel) {
        const response = await http.put(`${this.url}/undoChanges`, val);
        return response.data.data;
    }
}

const deductionProcessService = new DeductionService();
export default deductionProcessService;
