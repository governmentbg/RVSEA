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
}

const numberService = new NumberService();
export default numberService;
