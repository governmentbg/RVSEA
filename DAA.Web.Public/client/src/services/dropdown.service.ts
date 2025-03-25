import { IDropdownOption } from '@/interfaces/dropdown';
import { i18n } from '@/language';
import {
    allFromDropdownExternalValue,
    allFromDropdownInternalValue,
    allFromDropdownValue,
    externalSourceSuffix,
} from '@/models/reports';
import http from '@/services/http.service';
import { appStore } from '@/store/app';
import { DocumentObjectStatusCode } from '@/enums/documentObjectStatusCode';
import { IMessage } from '@/interfaces/notification';
import { Ref } from 'vue';
import { displayMessage } from '@/helpers/notification.helper';

class DropdownService {
    private url = appStore().getters.baseUrl + '/api/dropdown';
    private allFromDropdownItem = { code: allFromDropdownValue, label: i18n.global.t('common.selectAll') };
    private allFromDropdownItemInternal = {
        code: allFromDropdownInternalValue,
        label: i18n.global.t('common.selectAll'),
        hasExternalSource: false,
    };
    private allFromDropdownItemExternal = {
        code: allFromDropdownExternalValue,
        label: i18n.global.t('common.selectAll'),
        hasExternalSource: true,
    };
    private isdaText = `(${i18n.global.t('common.isda')})`;
    private seaText = `(${i18n.global.t('common.sea')})`;
    private allFromDropdownItems = [
        this.allFromDropdownItem,
        this.allFromDropdownItemExternal,
        this.allFromDropdownItemInternal,
    ];

    async getArchives(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/archives`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getArchivesInternalAndExternal(
        //  hasAllFromDropdownItem = false,
        err?: Ref<IMessage>
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/archives`);
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
        }
        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundArrays(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/fundArrays`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundArraysInternalAndExternal(err?: Ref<IMessage>): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/fundArrays`);
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
        }
        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundTypes(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/fundTypes`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundTypesInternalAndExternal(err?: Ref<IMessage>): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/fundTypes`);
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
        }
        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundStatuses(err?: Ref<IMessage>): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/fundStatuses`);
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
        }
        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundStatusesInternalAndExternal(
        hasAllFromDropdownItem = false,
        err?: Ref<IMessage>
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/fundStatuses`);
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
        }

        return !hasAllFromDropdownItem
            ? this.differentiateInternalFromExternal([...response.data.data])
            : [...this.differentiateInternalFromExternal([...this.allFromDropdownItems, ...response.data.data])];
    }

    async getAllDescriptionLevels(err?: Ref<IMessage>): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/getAllDescLevels`);
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
        }
        return [this.allFromDropdownItem, ...response.data.data];
    }
    //Защо е необходим нов метод, след като трябва да се коригира съществуващия?????????
    async getAllDescLevelsForPublicSearch(err?: Ref<IMessage>): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/getAllDescLevelsForPublicSerarch`);
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
        }
        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getAcquisitionMethods(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/acquisitionMethods`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getAcquisitionMethodsInternalAndExternal(err?: Ref<IMessage>): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/acquisitionMethods`);
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
        }

        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getIndustryIndexes(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/industryIndexes`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getIndustryIndexesInternalAndExternal(err?: Ref<IMessage>): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/industryIndexes`);
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
        }

        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getFilmCountries(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/filmCountries`);
        return response.data.data;
    }

    getApplicationTypes(): Promise<IDropdownOption[]> {
        return http.get(`${this.url}/applicationTypes`).then((x) => x.data.data);
    }

    getDocumentObjectStatuses(hasAllFromDropdownItem = false): IDropdownOption[] {
        const options = [
            { code: DocumentObjectStatusCode.Active + '', label: i18n.global.t('reports.active') },
            { code: DocumentObjectStatusCode.Deleted + '', label: i18n.global.t('reports.deleted') },
        ];
        const items = [this.allFromDropdownItem, ...options];
        return !hasAllFromDropdownItem ? options : [...items];
    }

    private differentiateInternalFromExternal(items: IDropdownOption[]) {
        const result = [] as IDropdownOption[];
        items.forEach((item: IDropdownOption) => {
            if (item.hasExternalSource) {
                const label = `${item.label} ${this.isdaText}`;
                if (
                    item.code != allFromDropdownValue &&
                    item.code != allFromDropdownInternalValue &&
                    item.code != allFromDropdownExternalValue
                ) {
                    result.push({ code: `${item.code}${externalSourceSuffix}`, label: label, hasExternalSource: true });
                } else {
                    result.push({ code: item.code, label: label, hasExternalSource: true });
                }
            } else if (item.code == allFromDropdownValue) {
                result.push({ code: item.code, label: item.label });
            } else {
                result.push({ code: item.code, label: `${item.label} ${this.seaText}`, hasExternalSource: false });
            }
        });

        return result;
    }

    async getNomenclaturesByCode(code: string): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/nomenclatures/code/${code}`);
        return response.data.data;
    }
}

const dropdownService = new DropdownService();
export default dropdownService;
