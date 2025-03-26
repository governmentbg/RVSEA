import { SearchModel } from '@/models/search';
import http from '@/services/http.service';
import { appStore } from '@/store/app';
//import moment from 'moment';
import BaseService from './base.service';

class SearchService extends BaseService {
    private url = appStore().getters.baseUrl + '/api/search';

    async getResultFromSearchCriteria(data: SearchModel) {
        // const formData = new FormData();
        // if (data.archiveId) {
        //     data.archiveId.forEach((element) => {
        //         formData.append('archiveId', element);
        //     });
        // }
        // if (data.descriptionLevelCode) {
        //     data.descriptionLevelCode.forEach((element) => {
        //         formData.append('descriptionLevelCode', element);
        //     });
        // }
        // if (data.descriptionLevelCodeExternal) {
        //     data.descriptionLevelCodeExternal.forEach((element) => {
        //         formData.append('descriptionLevelCodeExternal', element);
        //     });
        // }
        // if (data.fundArrayCodeExternal) {
        //     data.fundArrayCodeExternal.forEach((element) => {
        //         formData.append('fundArrayCodeExternal', element);
        //     });
        // }
        // if (data.fundNumber) {
        //     formData.append('fundNumber', data.fundNumber!.toString());
        // }
        // if (data.cmfNumber) {
        //     formData.append('cmfNumber', data.cmfNumber!.toString());
        // }
        // if (data.inventoryNumber) {
        //     formData.append('inventoryNumber', data.inventoryNumber!.toString());
        // }
        // if (data.archivalEntityNumber) {
        //     formData.append('archivalEntityNumber', data.archivalEntityNumber!.toString());
        // }
        // if (data.cmfNumber) {
        //     formData.append('cmfNumber', data.cmfNumber!.toString());
        // }
        // if (data.cmfCountriesOfOriginCodes) {
        //     data.cmfCountriesOfOriginCodes.forEach((element) => {
        //         formData.append('cmfCountriesOfOriginCodes', element);
        //     });
        // }
        // if (data.advancedSearch) {
        //     formData.append('advancedSearch', data.advancedSearch!.toString());
        // } else {
        //     formData.append('advancedSearch', false.toString());
        // }
        // if (data.foreignarchives) {
        //     formData.append('foreignarchives', data.foreignarchives!.toString());
        // }
        // if (data.searchByDigitalCopies) {
        //     formData.append('searchByDigitalCopies', data.searchByDigitalCopies!.toString());
        // }
        // if (data.fundArrayCode) {
        //     data.fundArrayCode.forEach((element) => {
        //         formData.append('fundArrayCode', element);
        //     });
        // }
        // if (data.name) {
        //     formData.append('name', data.name!.toString());
        // }
        // if (data.keyWords) {
        //     formData.append('keyWords', data.keyWords!.toString());
        // }
        // if (data.dateFrom) {
        //     formData.append('dateFrom', moment(data.dateFrom!).format('YYYY-MM-DD')); // workaround, заради проблем с форматите - може би проблемът е, че се ползва в formData
        // }
        // if (data.dateTo) {
        //     formData.append('dateTo', moment(data.dateTo!).format('YYYY-MM-DD'));
        // }
        // if (data.itemsPerPage) {
        //     formData.append('itemsPerPage', data.itemsPerPage!.toString());
        // }
        // if (data.page) {
        //     formData.append('page', data.page!.toString());
        // }
        // if (data.searchString) {
        //     formData.append('searchString', data.searchString!.toString());
        // }
        // if (data.sortBy) {
        //     formData.append('sortBy', data.sortBy!.toString());
        // }
        // if (data.sortByType) {
        //     formData.append('sortByType', data.sortByType!.toString());
        // }
        // if (data.sortDesc) {
        //     formData.append('sortDesc', data.sortDesc!.toString());
        // }

        // const response = await http.post(`${this.url}/getall`, formData, undefined, undefined, {
        //     cancelToken: this.source.token,
        // });
        
        const response = await http.post(`${this.url}/getall`, data, undefined, undefined, {
            signal: this.abortSignal,
        });
        return response.data.data;
    }
}

const searchService = new SearchService();
export default searchService;
