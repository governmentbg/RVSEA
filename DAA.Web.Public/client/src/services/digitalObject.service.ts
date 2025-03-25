import { GridOptions } from '@/models/grid';
import http from '@/services/http.service';
import { appStore } from '@/store/app';
import { userStore as useUserStore } from '@/store/user';
import { IDigitalObject } from '@/interfaces/digitalObject';
//import { ConfirmationModel } from '@/models/authentication';

class DigitalObjectService {
    private url = appStore().getters.baseUrl + '/api/digitalobjects';
    private userStore = useUserStore();

    getDocumentDigitalObjectsUrl(
        documentSysId?: string,
        documentHasExternalSource?: boolean,
        documentExternalIdentifier?: number
    ) {
        const url = new URL(`${this.url}/listByDocument/${documentSysId ?? ''}`);
        if (documentHasExternalSource) {
            url.searchParams.append('documentHasExternalSource', documentHasExternalSource.toString());
        }
        if (documentHasExternalSource && documentExternalIdentifier) {
            url.searchParams.append('documentExternalIdentifier', documentExternalIdentifier.toString());
        }

        return url.toString();
    }

    streamDigitalObjectDraftFileUrl(sysId: string, inline?: boolean, token?: string): string {
        // const confirmationModel = new ConfirmationModel;
        // if(this.userStore.getters.userId) {
        //     confirmationModel.userId = this.userStore.getters.userId;
        //     confirmationModel.confirmationToken = this.userStore.getters.token;
        // }
        // const url = new URL(`${this.url}/downloadDarivative/${sysId}?download=true`);
        // if(this.userStore.getters.userId && token) {
        //     url.searchParams.append('userId', this.userStore.getters.userId)
        //     url.searchParams.append('token', token)
        // }
        // return url.toString();

        const url = new URL(`${this.url}/draft/stream/${sysId ?? ''}${inline ? '?isInline=true' : ''}`);
        if (this.userStore.getters.userId && token) {
            url.searchParams.append('userId', this.userStore.getters.userId!);
            url.searchParams.append('token', token);
        }

        return url.toString();
    }

    streamDigitalObjectFileUrl(
        sysId?: string,
        hasExternalSource?: boolean,
        externalIdentifier?: number,
        inline?: boolean,
        token?: string
    ) {
        const url = new URL(`${this.url}/stream/${sysId ?? ''}${inline ? '?isInline=true' : ''}`);
        if (hasExternalSource) {
            url.searchParams.append('hasExternalSource', hasExternalSource.toString());
        }
        if (hasExternalSource && externalIdentifier) {
            url.searchParams.append('documentExternalIdentifier', externalIdentifier.toString());
        }
        // if (this.userStore.getters.email) {
        //     url.searchParams.append('email', this.userStore.getters.email);
        // }
        if (this.userStore.getters.userId && token) {
            url.searchParams.append('userId', this.userStore.getters.userId!);
            url.searchParams.append('token', token);
        }

        return url.toString();
    }

    async getDocumentDigitalObjects(
        options: GridOptions,
        documentSysId?: string,
        documentHasExternalSource?: boolean,
        documentExternalIdentifier?: number
    ) {
        const url = new URL(`${this.url}/listByDocument/${documentSysId ?? ''}`);
        if (documentHasExternalSource) {
            url.searchParams.append('documentHasExternalSource', documentHasExternalSource.toString());
        }
        if (documentHasExternalSource && documentExternalIdentifier) {
            url.searchParams.append('documentExternalIdentifier', documentExternalIdentifier.toString());
        }

        const response = await http.post(url.toString(), options);
        return response.data;
    }

    async displayDigitalObject(
        sysId?: string,
        hasExternalSource?: boolean,
        externalIdentifier?: number
    ): Promise<IDigitalObject> {
        const url = new URL(`${this.url}/${sysId ?? ''}`);
        if (hasExternalSource) {
            url.searchParams.append('hasExternalSource', hasExternalSource.toString());
        }
        if (hasExternalSource && externalIdentifier) {
            url.searchParams.append('externalIdentifier', externalIdentifier.toString());
        }

        const response = await http.get(url.toString());
        return response.data.data;
    }

    async streamDigitalObjectFile(
        sysId: string,
        hasExternalSource?: boolean,
        externalIdentifier?: number,
        token?: string,
        inline?: boolean
    ) {
        const url = this.streamDigitalObjectFileUrl(sysId, hasExternalSource, externalIdentifier, inline, token)
        const response = await http.get(url.toString(), undefined, undefined, { responseType: "blob" });
        return response.data;
    }

    async streamDigitalObjectDraftFile(
        sysId: string,
        token?: string,
        inline?: boolean
    ) {
        const url = this.streamDigitalObjectDraftFileUrl(sysId, inline, token)
        const response = await http.get(url.toString(), undefined, undefined, { responseType: "blob" });
        return response.data;
    }

}

const digitalObjectService = new DigitalObjectService();
export default digitalObjectService;
