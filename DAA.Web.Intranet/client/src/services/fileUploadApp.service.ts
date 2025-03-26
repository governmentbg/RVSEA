import { ProcessKind } from '@/enums/processKind';
import { ChecksumsVerifyResultModel } from '@/models/checksumsVerifyResultModel ';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class FileUploadAppService {
    private url = appStore().getters.baseUrl + '/api/fileUploadApp';

    async verifyChecksums(data: ProcessKind): Promise<ChecksumsVerifyResultModel> {
        const response = await http.post(`${this.url}/verifyChecksums`, data);
        return response.data;
    }
}

const fileUploadAppService = new FileUploadAppService();
export default fileUploadAppService;
