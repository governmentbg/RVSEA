import { GridOptions } from '@/models/grid';
import http from '@/services/http.service';
import { appStore } from '@/store/app';
import { IDocument, IDocumentDraft } from '@/interfaces/document';

class DocumentService {
    private url = appStore().getters.baseUrl + '/api/documents';

    getDocumentsUrl = () => `${this.url}/listall`;

    async getArchivalEntityDocuments(
        options: GridOptions,
        archivalEntitySysId?: string,
        archivalEntityHasExternalSource?: boolean,
        archivalEntityExternalIdentifier?: number,
        searchArchivalEntityNumber?: string,
        searchArchivalEntityStartSheet?: number,
        searchArchivalEntityEndSheet?: number
    ) {
        const url = new URL(`${this.url}/listByArchivalEntity/${archivalEntitySysId ?? ''}`);
        if (archivalEntityHasExternalSource) {
            url.searchParams.append('archivalEntityHasExternalSource', archivalEntityHasExternalSource.toString());
        }
        if (archivalEntityHasExternalSource && archivalEntityExternalIdentifier) {
            url.searchParams.append('archivalEntityExternalIdentifier', archivalEntityExternalIdentifier.toString());
        }
        if (searchArchivalEntityNumber) {
            url.searchParams.append('searchArchivalEntityNumber', searchArchivalEntityNumber);
        }
        if (searchArchivalEntityStartSheet) {
            url.searchParams.append('searchArchivalEntityStartSheet', searchArchivalEntityStartSheet.toString());
        }
        if (searchArchivalEntityEndSheet) {
            url.searchParams.append('searchArchivalEntityEndSheet', searchArchivalEntityEndSheet.toString());
        }

        const response = await http.post(url.toString(), options);
        return response.data.data;
    }

    async getDocumentsByAvailabilityStatus(
        options: GridOptions,
        availabilityStatus: number,
        fundSysId: string,
        searchArchivalEntityNumber?: string,
        searchArchivalEntityStartSheet?: number,
        searchArchivalEntityEndSheet?: number
    ) {
        const url = new URL(`${this.url}/listByAvailabilityStatus/${availabilityStatus}`);
        if (fundSysId) {
            url.searchParams.append('fundSystemIdentifier', fundSysId);
        }
        if (searchArchivalEntityNumber) {
            url.searchParams.append('searchArchivalEntityNumber', searchArchivalEntityNumber);
        }
        if (searchArchivalEntityStartSheet) {
            url.searchParams.append('searchArchivalEntityStartSheet', searchArchivalEntityStartSheet.toString());
        }
        if (searchArchivalEntityEndSheet) {
            url.searchParams.append('searchArchivalEntityEndSheet', searchArchivalEntityEndSheet.toString());
        }

        console.log(url.toString());

        const response = await http.post(url.toString(), options);
        return response.data.data;
    }

    async displayDocument(
        sysId?: string,
        hasExternalSource?: boolean,
        externalIdentifier?: number
    ): Promise<IDocument> {
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

    async createDocument(data: IDocumentDraft) {
        const response = await http.post(`${this.url}`, data);
        return response;
    }

    async updateDocument(data: IDocument) {
        const response = await http.put(`${this.url}`, data);
        return response;
    }

    async deleteDocument(sysId: string) {
        const response = await http.delete(`${this.url}/${sysId}`);
        return response;
    }

    async deleteDocumentDraft(id: number) {
        const response = await http.delete(`${this.url}/draft/${id}`);
        return response;
    }

    getDocumentPublicUserReviewsUrl(systemIdentifier?: string) {
        const url = new URL(`${this.url}/documentPublicUsersReviews/${systemIdentifier ?? ''}`);
        return url.toString();
    }
}

const documentService = new DocumentService();
export default documentService;
