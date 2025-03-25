import { GridOptions } from '@/models/grid';
import http from '@/services/http.service';
import { appStore } from '@/store/app';
import { IDigitalObject, IDigitalObjectDraft } from '@/interfaces/digitalObject';
import { DigitalObjectReviewFilterModel, DigitalObjectReviewDisplayModel } from '@/models/digitalObject';
import { ReportGridRequestModel, ReportGridResponseModel } from '@/models/reports';

class DigitalObjectService {
    private url = appStore().getters.baseUrl + '/api/digitalobjects';

    getDocumentDigitalObjectsUrl(
        documentSysId?: string,
        documentHasExternalSource?: boolean,
        documentExternalIdentifier?: number,
        digitized?: boolean
    ) {
        const url = new URL(`${this.url}/listByDocument/${documentSysId ?? ''}`);
        if (documentHasExternalSource) {
            url.searchParams.append('documentHasExternalSource', documentHasExternalSource.toString());
        }
        if (documentHasExternalSource && documentExternalIdentifier) {
            url.searchParams.append('documentExternalIdentifier', documentExternalIdentifier.toString());
        }
        if (digitized !== undefined) {
            url.searchParams.append('digitized', String(digitized));
        }

        return url.toString();
    }

    // downloadDigitalObjectUrl(
    //     sysId?: string,
    //     hasExternalSource?: boolean,
    //     externalIdentifier?: number,
    //     isInline?: boolean
    // ) {
    //     const url = new URL(`${this.url}/download/${sysId ?? ''}${isInline ? '?isInline=true' : ''}`);
    //     if (hasExternalSource) {
    //         url.searchParams.append('hasExternalSource', hasExternalSource.toString());
    //     }
    //     if (hasExternalSource && externalIdentifier) {
    //         url.searchParams.append('documentExternalIdentifier', externalIdentifier.toString());
    //     }

    //     return url.toString();
    // }

    streamDigitalObjectUrl(sysId: string, inline?: boolean) {
        const url = new URL(`${this.url}/stream/${sysId}`);
        if (inline) {
            url.searchParams.append('inline', String(inline));
        }
        return url.toString();
    }

    streamDigitalObjectDraftUrl(sysId: string, inline?: boolean) {
        const url = new URL(`${this.url}/draft/stream/${sysId}`);
        if (inline) {
            url.searchParams.append('inline', String(inline));
        }
        return url.toString();
    }

    async getDocumentDigitalObjects(
        options: GridOptions,
        documentSysId?: string,
        documentHasExternalSource?: boolean,
        documentExternalIdentifier?: number,
        digitized?: boolean
    ) {
        const url = new URL(`${this.url}/listByDocument/${documentSysId ?? ''}`);
        if (documentHasExternalSource) {
            url.searchParams.append('documentHasExternalSource', documentHasExternalSource.toString());
        }
        if (documentHasExternalSource && documentExternalIdentifier) {
            url.searchParams.append('documentExternalIdentifier', documentExternalIdentifier.toString());
        }
        if (digitized !== undefined) {
            url.searchParams.append('digitized', String(digitized));
        }

        const response = await http.post(url.toString(), options);
        return response.data.data;
    }

    async getInventoryDigitalObjects(
        options: GridOptions,
        inventorySysId?: string,
        inventoryHasExternalSource?: boolean,
        inventoryExternalIdentifier?: number
    ) {
        const url = new URL(`${this.url}/listByInventory/${inventorySysId ?? ''}`);
        if (inventoryHasExternalSource) {
            url.searchParams.append('inventoryHasExternalSource', inventoryHasExternalSource.toString());
        }
        if (inventoryHasExternalSource && inventoryExternalIdentifier) {
            url.searchParams.append('inventoryExternalIdentifier', inventoryExternalIdentifier.toString());
        }

        const response = await http.post(url.toString(), options);
        return response.data.data;
    }

    async streamDigitalObjectFile(
        sysId: string,
        inline?: boolean
    ) {
        const url = this.streamDigitalObjectUrl(sysId, inline)
        const response = await http.get(url.toString(), undefined, undefined, { responseType: "blob" });
        return response.data;
    }

    async streamDigitalObjectDraftFile(
        sysId: string,
        inline?: boolean
    ) {
        const url = this.streamDigitalObjectDraftUrl(sysId, inline)
        const response = await http.get(url.toString(), undefined, undefined, { responseType: "blob" });
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

    async createDigitalObject(data: IDigitalObjectDraft, autogenerateDerivative?: boolean): Promise<string> {
        const doData = new FormData();
        doData.append('archiveId', data.archiveId?.toString() ?? '');
        doData.append('fundDraftId', data.fundDraftId?.toString() ?? '');
        doData.append('fundSystemIdentifier', data.fundSystemIdentifier ?? '');
        doData.append('fundExternalIdentifier', data.fundExternalIdentifier?.toString() ?? '');
        doData.append('fundHasExternalSource', data.fundHasExternalSource?.toString() ?? 'false');
        doData.append('inventoryDraftId', data.inventoryDraftId?.toString() ?? '');
        doData.append('inventorySystemIdentifier', data.inventorySystemIdentifier ?? '');
        doData.append('inventoryExternalIdentifier', data.inventoryExternalIdentifier?.toString() ?? '');
        doData.append('inventoryHasExternalSource', data.inventoryHasExternalSource?.toString() ?? 'false');
        doData.append('archivalEntityDraftId', data.archivalEntityDraftId?.toString() ?? '');
        doData.append('archivalEntitySystemIdentifier', data.archivalEntitySystemIdentifier ?? '');
        doData.append('archivalEntityExternalIdentifier', data.archivalEntityExternalIdentifier?.toString() ?? '');
        doData.append('archivalEntityHasExternalSource', data.archivalEntityHasExternalSource?.toString() ?? 'false');
        doData.append('documentDraftId', data.documentDraftId?.toString() ?? '');
        doData.append('documentSystemIdentifier', data.documentSystemIdentifier ?? '');
        doData.append('documentExternalIdentifier', data.documentExternalIdentifier?.toString() ?? '');
        doData.append('documentHasExternalSource', data.documentHasExternalSource?.toString() ?? 'false');
        doData.append('externalIdentifier', data.externalIdentifier?.toString() ?? '');
        doData.append('hasExternalSource', data.hasExternalSource?.toString() ?? 'false');
        doData.append('typeCode', data.typeCode?.toString() ?? '');
        doData.append('name', data.name ?? '');
        doData.append('sourceName', data.sourceName ?? '');
        doData.append('fileType', data.fileType ?? '');
        doData.append('statusCode', data.statusCode ?? '');
        doData.append('isDigitized', data.isDigitized?.toString() ?? 'false');
        doData.append('parentSystemIdentifier', data.parentSystemIdentifier ?? '');
        doData.append('content', data.content!);
        if(data.skipValidation){
            doData.append("skipValidation", data.skipValidation.toString());
        }

        const url = new URL(`${this.url}`);
        if (autogenerateDerivative) {
            url.searchParams.append('autogenerateDerivative', autogenerateDerivative.toString());
        }
        const response = await http.post(url.toString(), doData);

        return response.data.data;
    }

    async updateDigitalObject(data: IDigitalObject): Promise<string> {
        const doData = new FormData();
        doData.append('archiveId', data.archiveId?.toString() ?? '');
        doData.append('fundDraftId', data.fundDraftId?.toString() ?? '');
        doData.append('fundSystemIdentifier', data.fundSystemIdentifier ?? '');
        doData.append('fundExternalIdentifier', data.fundExternalIdentifier?.toString() ?? '');
        doData.append('fundHasExternalSource', data.fundHasExternalSource?.toString() ?? 'false');
        doData.append('inventoryDraftId', data.inventoryDraftId?.toString() ?? '');
        doData.append('inventorySystemIdentifier', data.inventorySystemIdentifier ?? '');
        doData.append('inventoryExternalIdentifier', data.inventoryExternalIdentifier?.toString() ?? '');
        doData.append('inventoryHasExternalSource', data.inventoryHasExternalSource?.toString() ?? 'false');
        doData.append('archivalEntityDraftId', data.archivalEntityDraftId?.toString() ?? '');
        doData.append('archivalEntitySystemIdentifier', data.archivalEntitySystemIdentifier ?? '');
        doData.append('archivalEntityExternalIdentifier', data.archivalEntityExternalIdentifier?.toString() ?? '');
        doData.append('archivalEntityHasExternalSource', data.archivalEntityHasExternalSource?.toString() ?? 'false');
        doData.append('documentDraftId', data.documentDraftId?.toString() ?? '');
        doData.append('documentSystemIdentifier', data.documentSystemIdentifier ?? '');
        doData.append('documentExternalIdentifier', data.documentExternalIdentifier?.toString() ?? '');
        doData.append('documentHasExternalSource', data.documentHasExternalSource?.toString() ?? 'false');
        doData.append('externalIdentifier', data.externalIdentifier?.toString() ?? '');
        doData.append('hasExternalSource', data.hasExternalSource?.toString() ?? 'false');
        doData.append('typeCode', data.typeCode?.toString() ?? '');
        doData.append('name', data.name ?? '');
        doData.append('sourceName', data.sourceName ?? '');
        doData.append('fileType', data.fileType ?? '');
        doData.append('statusCode', data.statusCode ?? '');
        doData.append('content', data.content!);
        doData.append('parentSystemIdentifier', data.parentSystemIdentifier ?? '');
        if(data.skipValidation){
            doData.append("skipValidation", data.skipValidation.toString());
        }
        
        const response = await http.put(`${this.url}`, doData);
        return response.data.data;
    }

    async deleteDigitalObject(sysId: string, includeRelated?: boolean) {
        const url = new URL(`${this.url}/${sysId}`);
        if (includeRelated) {
            url.searchParams.append('includeRelated', String(includeRelated));
        }
        
        const response = await http.delete(url.toString());
        return response;

        // const response = await http.delete(`${this.url}/${sysId}`);
        // return response;
    }

    async deleteDigitalObjectDraft(id: number, includeRelated?: boolean) {
        const url = new URL(`${this.url}/draft/${id}`);
        if (includeRelated) {
            url.searchParams.append('includeRelated', String(includeRelated));
        }
        
        const response = await http.delete(url.toString());
        return response;

        // const response = await http.delete(`${this.url}/draft/${id}`);
        // return response;
    }

    async getDigitalObjectReviewsUrl(
        data: ReportGridRequestModel<DigitalObjectReviewFilterModel>
    ): Promise<ReportGridResponseModel<DigitalObjectReviewDisplayModel>> {
        const response = await http.post(`${this.url}/digitalObjectReviews`, data);
        return response.data;
    }

    // getDownloadDigitalDerivativeObjectUrl(sysId: string, download?: boolean): string {
    //     return `${this.url}/downloadDarivative/${sysId}${download ? '?download=true' : ''}`;
    // }
}

const digitalObjectService = new DigitalObjectService();
export default digitalObjectService;
