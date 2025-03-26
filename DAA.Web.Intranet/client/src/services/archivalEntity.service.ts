import { GridOptions } from '@/models/grid';
import { SearchedArchiveEntityRequestModel, ArchivalEntityShort, DocumentAncestorsData } from '@/models/archivalEntity';
import http from '@/services/http.service';
import { appStore } from '@/store/app';
import { IArchivalEntity, IArchivalEntityDraft } from '@/interfaces/archivalEntity';

class ArchiveEntityService {
    private url = appStore().getters.baseUrl + '/api/archivalEntities';

    getArchivalEntitiesUrl = () => `${this.url}/listall`;

    async getInventoryArchivalEntities(
        options: GridOptions,
        inventorySysId?: string,
        inventoryHasExternalSource?: boolean,
        inventoryExternalIdentifier?: number,
        searchInventoryNumberString?: string
    ) {
        const url = new URL(`${this.url}/listByInventory/${inventorySysId ?? ''}`);
        if (inventoryHasExternalSource) {
            url.searchParams.append('inventoryHasExternalSource', inventoryHasExternalSource.toString());
        }
        if (inventoryHasExternalSource && inventoryExternalIdentifier) {
            url.searchParams.append('inventoryExternalIdentifier', inventoryExternalIdentifier.toString());
        }
        if (searchInventoryNumberString) {
            url.searchParams.append('searchInventoryNumberString', searchInventoryNumberString);
        }

        const response = await http.post(url.toString(), options);
        return response.data.data;
    }

    async getArchivalEntitiesByAvailabilityStatus(
        options: GridOptions,
        availabilityStatus: number,
        fundSysId: string,
        searchInventoryNumberString?: string
    ) {
        const url = new URL(`${this.url}/listByAvailabilityStatus/${availabilityStatus}`);
        if (fundSysId) {
            url.searchParams.append('fundSystemIdentifier', fundSysId);
        }
        if (searchInventoryNumberString) {
            url.searchParams.append('searchInventoryNumberString', searchInventoryNumberString);
        }

        console.log(url.toString());

        const response = await http.post(url.toString(), options);
        return response.data.data;
    }

    async displayArchivalEntity(
        sysId?: string,
        hasExternalSource?: boolean,
        externalIdentifier?: number
    ): Promise<IArchivalEntity> {
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

    async createArchivalEntity(data: IArchivalEntityDraft) {
        const response = await http.post(`${this.url}`, data);
        return response;
    }

    async updateArchivalEntity(data: IArchivalEntity) {
        const response = await http.put(`${this.url}`, data);
        return response;
    }

    async deleteArchivalEntity(sysId: string) {
        const response = await http.delete(`${this.url}/${sysId}`);
        return response;
    }

    async deleteArchivalEntityDraft(id: number) {
        const response = await http.delete(`${this.url}/draft/${id}`);
        return response;
    }

    // async getInternalArchiveEntity(
    //   id: number
    // ): Promise<ArchiveEntityDisplayModel> {
    //   const response = await http.get(`${this.url}/id/${id}`);
    //   return response.data.data;
    // }

    // async getExternalArchiveEntity(
    //   id: number
    // ): Promise<ArchiveEntityDisplayModel> {
    //   const response = await http.get(`${this.url}/externalIdentifier/${id}`);
    //   return response.data.data;
    // }

    //Вземане на необх информация за създаване на Документ
    async getDocumentAncestorsData(id: number): Promise<DocumentAncestorsData> {
        const response = await http.get(`${this.url}/ancestorsData/${id}`);
        return response.data;
    }
    async getDocumentAncestorsDataById(id: number): Promise<DocumentAncestorsData> {
        const response = await http.get(`${this.url}/ancestorsDataById/${id}`);
        return response.data;
    }

    // async createArchiveEntity(data: ArchiveEntityCreateModel) {
    //   const response = await http.post(`${this.url}`, data);
    //   return response;
    // }

    // async updateArchiveEntity(data: ArchiveEntityUpdateModel) {
    //   const response = await http.put(`${this.url}`, data);
    //   return response;
    // }

    // async getArchiveEntitiesByInventory(
    //   model: ArchiveEntityPerInventoryRequestModel
    // ): Promise<GridResponseModel<ArchiveEntityOfListDisplayModel>> {
    //   const response = await http.post(`${this.url}/listPerInventory`, model);
    //   return response.data.data;
    // }

    // async getAll(model: GridOptions): Promise<GridResponseModel<GridOptions>> {
    //   const response = await http.post(`${this.url}/listall`, model);
    //   return response.data.data;
    // }

    // async deleteArchiveEntity(id: number) {
    //   const response = await http.delete(`${this.url}/${id}`);
    //   return response;
    // }

    async getArchiveEntitiesShort(model: SearchedArchiveEntityRequestModel): Promise<ArchivalEntityShort> {
        const response = await http.post(`${this.url}/search`, model);
        return response.data.data.result;
    }

    async archivalEntityFromPackage(
        inventorySysId: string,
        packageDocuments: Array<number>
    ): Promise<ArchivalEntityShort> {
        const response = await http.post(`${this.url}/archivalEntityFromPackage/${inventorySysId}`, packageDocuments);
        console.log(response);

        return response;
    }

    getArchivalEntityPublicUserReviewsUrl(systemIdentifier?: string) {
        const url = new URL(`${this.url}/archivalEntityPublicUsersReviews/${systemIdentifier ?? ''}`);
        return url.toString();
    }
}

const archiveEntityService = new ArchiveEntityService();
export default archiveEntityService;
