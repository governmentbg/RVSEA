import http from '@/services/http.service';
import { appStore } from '@/store/app';

class NumberService {
    private url = appStore().getters.baseUrl + '/api/number';

    public formatEntityNumber(entityNumber: number, entityArray?: string): string {
        let numberString = entityNumber.toString();
        if (entityArray && entityArray !== 'Без индекс') {
            numberString = numberString + entityArray;
        }
        return numberString;
    }
    // async generateFundNumber(archive: number, fundArray: string | undefined, levelOfDescriptionCode: string) : Promise<string> {
    //   const fundArrayLocal = fundArray ? fundArray : 'noIndex';
    //   const response = await http.get(`${this.url}/generateFundNumber/${archive}/${fundArrayLocal}/${parseInt(levelOfDescriptionCode)}`);
    //   return response.data.data;
    // }

    async getFundNumberNumeric(archiveId: number, descriptionLevel: string, fundArray: string) {
        const url = new URL(`${this.url}/fund`);
        url.searchParams.append('archiveId', archiveId.toString());
        url.searchParams.append('descriptionLevel', descriptionLevel);
        url.searchParams.append('fundArray', fundArray);
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async getInventoryNumberNumeric(
        archiveId: number,
        fundSystemIdentifier: string,
        descriptionLevel: string,
        inventoryArray: string
    ) {
        const url = new URL(`${this.url}/inventory`);
        url.searchParams.append('archiveId', archiveId.toString());
        url.searchParams.append('fundSystemIdentifier', fundSystemIdentifier);
        url.searchParams.append('descriptionLevel', descriptionLevel);
        url.searchParams.append('inventoryArray', inventoryArray);
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async getArchivalEnitityNumberNumeric(
        archiveId: number,
        inventorySystemIdentifier: string,
        descriptionLevel: string
    ) {
        const url = new URL(`${this.url}/archivalEntity`);
        url.searchParams.append('archiveId', archiveId.toString());
        url.searchParams.append('inventorySystemIdentifier', inventorySystemIdentifier);
        url.searchParams.append('descriptionLevel', descriptionLevel);
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async getDocumentNumberNumeric(
        archiveId: number,
        inventorySystemIdentifier: string,
        archivalEntitySystemIdentifier: string
    ) {
        const url = new URL(`${this.url}/document`);
        url.searchParams.append('archiveId', archiveId.toString());
        url.searchParams.append('inventorySystemIdentifier', inventorySystemIdentifier);
        url.searchParams.append('archivalEntitySystemIdentifier', archivalEntitySystemIdentifier);
        const response = await http.get(url.toString());
        return response.data.data;
    }
    // async getLastFundNumberExternal(archive: number, fundArray: string | undefined, levelOfDescriptionCode: string) : Promise<number> {
    //   const fundArrayLocal = fundArray ? fundArray : 'noIndex';
    //   const response = await http.get(`${this.url}/getLastFundNumberExternal/${archive}/${fundArrayLocal}/${parseInt(levelOfDescriptionCode)}`);
    //   return response.data.data;
    // }

    // async generateInventoryNumber(
    //   archive: number, fundExternalIdentifier: number | undefined, fundSystemIdentifier: string, fundArray: string | undefined, levelOfDescriptionCode: string) : Promise<string> {
    //   const fundExternalIdentifierLocal = fundExternalIdentifier ? fundExternalIdentifier : -1;
    //   const fundArrayLocal = fundArray ? fundArray : 'noIndex';
    //   const response = await http.get(`${this.url}/generateInventoryNumber/${archive}/${fundExternalIdentifierLocal}/${fundSystemIdentifier}/${fundArrayLocal}/${parseInt(levelOfDescriptionCode)}`);
    //   return response.data.data;
    // }

    // async getLastInventoryNumberExternal(
    //   archive: number, fundExternalIdentifier: number | undefined, fundArray: string | undefined, levelOfDescriptionCode: string) : Promise<number> {
    //   const fundExternalIdentifierLocal = fundExternalIdentifier ? fundExternalIdentifier : -1;
    //   const response = await http.get(`${this.url}/getLastInventoryNumberExternal/${archive}/${fundExternalIdentifierLocal}/${fundArray}/${parseInt(levelOfDescriptionCode)}`);
    //   return response.data.data;
    // }

    // async getNextArchivalEntityNumberExternal(archive: number, inventoryExternalIdentifier: number | undefined) : Promise<string> {
    //   const inventoryExternalIdentifierLocal = inventoryExternalIdentifier ? inventoryExternalIdentifier : -1;
    //   const response = await http.get(`${this.url}/getNextArchivalEntityNumberExternal/${archive}/${inventoryExternalIdentifierLocal}`);
    //   return response.data.data;
    // }
}

const numberService = new NumberService();
export default numberService;
