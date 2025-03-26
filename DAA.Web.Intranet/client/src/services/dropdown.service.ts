import { RoleNames } from '@/enums/roles';
import { IDropdownOption } from '@/interfaces/dropdown';
import { i18n } from '@/language';
import { FundShort } from '@/models/fund';
import { InventoryShort } from '@/models/inventory';
import {
    allFromDropdownExternalValue,
    allFromDropdownInternalValue,
    allFromDropdownValue,
    externalSourceSuffix,
    noDropdownItemExternalValue,
    noDropdownItemInternalValue,
    noDropdownItemValue,
} from '@/models/reports';
import http from '@/services/http.service';
import { appStore } from '@/store/app';
import { DocumentObjectStatusCode } from '@/enums/documentObjectStatusCode';
import { ReportResultType } from '@/enums/reports';
import { IMessage } from '@/interfaces/notification';
import { Ref } from 'vue';
import { displayMessage } from '@/helpers/notification.helper';
class DropdownService {
    private url = appStore().getters.baseUrl + '/api/dropdown';
    private allFromDropdownItem = { code: allFromDropdownValue, label: i18n.global.t('common.selectAll') };
    private allFromDropdownItemWithId = {
        id: allFromDropdownValue,
        code: allFromDropdownValue,
        label: i18n.global.t('common.selectAll'),
    };
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
    private noDropdownItem = { code: noDropdownItemValue, label: i18n.global.t('reports.noActiveProcess') };
    private noDropdownItemInternal = {
        code: noDropdownItemInternalValue,
        label: i18n.global.t('reports.noActiveProcess'),
        hasExternalSource: false,
    };
    private noDropdownItemExternal = {
        code: noDropdownItemExternalValue,
        label: i18n.global.t('reports.noActiveProcess'),
        hasExternalSource: true,
    };
    private noActiveProcessDropdownItems = [
        this.noDropdownItem,
        this.noDropdownItemInternal,
        this.noDropdownItemExternal,
    ];
    private hasAllFromDropdownItem = false;
    constructor() {
        this.getFundDescriptionLevels.bind(this);
    }

    async getArchives(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/archives`);
        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getArchivesExternal(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/external/archives`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getArchivesInternalAndExternal(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/archives`);
        if (!this.hasExternalItem(response.data.data)) {
            return [this.allFromDropdownItem, ...response.data.data];
        }
        return !hasAllFromDropdownItem
            ? this.differentiateInternalFromExternal([...response.data.data])
            : [...this.differentiateInternalFromExternal([...this.allFromDropdownItems, ...response.data.data])];
    }

    async getRoles(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/roles`);
        return response.data.data;
    }

    async getStatuses(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/statuses`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getStatusesReduced(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/statusesReduced`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getStatusesReduced2(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/statusesReduced2`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getRoughDocumentsStatuses(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/roughDocumentsStatuses`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getAvailabilityStatuses(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/availabilitystatuses`);
        return response.data.data;
    }

    async getRolesInArchive(archiveId: number, roles: RoleNames[]): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/rolesInArchive/${archiveId}/${roles}`);
        return response.data.data;
    }

    async getFundArrays(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/fundArrays`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundArraysInternalAndExternal(
        reportResultType = ReportResultType.BothDBs,
        err?: Ref<IMessage>
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/fundArrays/${reportResultType}`);

        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
            return [this.allFromDropdownItem, ...response.data.data];
        }

        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundArraysInternalAndExternalReduced(
        reportResultType = ReportResultType.BothDBs,
        err?: Ref<IMessage>
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/fundArraysReduced/${reportResultType}`);

        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');

            return [this.allFromDropdownItem, ...response.data.data];
        }
        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundTypes(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/fundTypes`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }
    async getFundTypesReducedForCHP(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/fundTypesReducedCHP`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundTypesReduced(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/fundTypesReduced`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundTypesInternalAndExternal(
        reportResultType = ReportResultType.BothDBs,
        err?: Ref<IMessage>
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/fundTypes/${reportResultType}`);
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
            return [this.allFromDropdownItem, ...response.data.data];
        }

        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundTypesInternalAndExternalReduced(
        reportResultType = ReportResultType.BothDBs,
        err?: Ref<IMessage>
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/fundTypesReduced/${reportResultType}`);

        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
            return [this.allFromDropdownItem, ...response.data.data];
        }

        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundStatuses(reportResultType = ReportResultType.BothDBs): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/fundStatuses/${reportResultType}`);
        this.hasAllFromDropdownItem = reportResultType == 1 ? true : false;
        return !this.hasAllFromDropdownItem
            ? [this.allFromDropdownItem, ...response.data.data]
            : [this.allFromDropdownItem, ...response.data.data];
    }

    async getFundStatusesNTOReportReduce(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/fundStatusesNTOReportReduce`);
        return !this.hasAllFromDropdownItem
            ? [this.allFromDropdownItem, ...response.data.data]
            : [this.allFromDropdownItem, ...response.data.data];
    }

    async statusesFundMemoriesReport(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/statusesFundMemoriesReport`);
        return [this.allFromDropdownItem, ...response.data.data];
    }
    async getFundStatusesInternalAndExternal(
        reportResultType = ReportResultType.BothDBs,
        err?: Ref<IMessage>
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/fundStatuses/${reportResultType}`);

        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
            return [this.allFromDropdownItem, ...response.data.data];
        }
        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getDocumentObjectStatuses(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const options = [
            { code: DocumentObjectStatusCode.Active, label: i18n.global.t('reports.active') },
            { code: DocumentObjectStatusCode.Deleted, label: i18n.global.t('reports.deleted') },
        ];
        const items = [this.allFromDropdownItem, ...options];
        return !hasAllFromDropdownItem ? options : [...items];
    }

    async getFundDescriptionLevels(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/fundDescLevels`);
        return response.data.data;
    }

    async GetDescriptionLevelsExternal(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/external/descLevels`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getInventoryArrays(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/inventoryArrays`);
        return response.data.data;
    }

    async getInventoryArraysInternalAndExternal(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/inventoryArrays`);
        const items = this.differentiateInternalFromExternal([...this.allFromDropdownItems, ...response.data.data]);
        return !hasAllFromDropdownItem ? response.data.data : [...items];
    }

    async getInventoryDescriptionLevels(fundDescLevel?: string): Promise<IDropdownOption[]> {
        const url = new URL(`${this.url}/inventoryDescLevels`);

        if (fundDescLevel) {
            url.searchParams.append('fundDescLevel', fundDescLevel);
        }
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async getAcquisitionMethodsInternalAndExternal(
        reportResultType = ReportResultType.BothDBs,
        err?: Ref<IMessage>
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/acquisitionMethods/${reportResultType}`);

        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
            return [this.allFromDropdownItem, ...response.data.data];
        }
        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getAcquisitionMethods(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/acquisitionMethods`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }

    async getProcessTypes(entityType?: string | string[], hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const url = new URL(`${this.url}/processTypes`);
        if (entityType) {
            if (entityType instanceof Array) {
                entityType.forEach((etype) => url.searchParams.append('entityType', etype));
            } else {
                url.searchParams.append('entityType', entityType.toString());
            }
        }
        // const response = await http.get(`${this.url}/processTypes/entityType/${entityType ?? ''}`);
        const response = await http.get(url.toString());
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItemWithId, ...response.data.data];
    }

    async getFunds(searchText: string, archiveCode: number, descriptionLevels?: string[]): Promise<FundShort[]> {
        const url = new URL(`${this.url}/funds`);

        url.searchParams.append('searchText', searchText);
        url.searchParams.append('archiveCode', archiveCode.toString());
        if (descriptionLevels) {
            descriptionLevels.forEach((level) => url.searchParams.append('descriptionLevel', level));
        }
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async getInventories(
        searchText: string,
        fundSysId?: string,
        fundHasExternalSource?: boolean,
        fundExternalIdentifier?: number,
        descriptionLevels?: string[]
    ): Promise<InventoryShort[]> {
        const url = new URL(`${this.url}/inventories`);

        url.searchParams.append('searchText', searchText);
        if (fundSysId) {
            url.searchParams.append('fundSysId', fundSysId);
        }
        if (fundHasExternalSource) {
            url.searchParams.append('fundHasExternalSource', fundHasExternalSource.toString());
        }
        if (fundHasExternalSource && fundExternalIdentifier) {
            url.searchParams.append('fundExternalIdentifier', fundExternalIdentifier.toString());
        }
        if (descriptionLevels) {
            descriptionLevels.forEach((level) => url.searchParams.append('descriptionLevel', level));
        }
        const response = await http.get(url.toString());
        return response.data.data;
    }

    async getNomenclatures(parentId?: number): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/nomenclatures/${parentId ?? ''}`);
        return response.data.data;
    }

    async getNomenclaturesByCode(code: string): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/nomenclatures/code/${code}`);
        return response.data.data;
    }

    async getNomenclatureCodes(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/nomenclatureCodes`);
        return response.data.data;
    }

    async getArchiveEntitiesDescriptionLevels(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/archiveEntityDescLevels`);
        return response.data.data;
    }

    async getArchiveEntitiesDescriptionLevelInternalAndExternal(
        hasAllFromDropdownItem = false
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/archiveEntityDescLevels`);
        const items = this.differentiateInternalFromExternal([...this.allFromDropdownItems, ...response.data.data]);
        return !hasAllFromDropdownItem ? response.data.data : [...items];
    }
    async getDocumentDescriptionLevels(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/documentDescLevels`);
        return response.data.data;
    }

    async getCentralArchive(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/centralArchive`);
        return response.data.data;
    }

    async getReportResultTypes(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/reportResultTypes`);
        const result = [] as IDropdownOption[];
        response.data.data.forEach((option: IDropdownOption) => {
            result.push({ code: parseInt(option.code as string), label: option.label } as IDropdownOption);
        });

        return result;
    }

    async getFilmDocTypes(packageType: string): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/filmDocTypes/${packageType}`);
        return response.data.data;
    }

    async getCollectingProcedures(): Promise<IDropdownOption[]> {
        return http.get(`${this.url}/CollectingProcedures`).then((response) => response.data.data as IDropdownOption[]);
    }

    async getProcessTypesInternalAndExternal(
        reportResultType = ReportResultType.BothDBs,
        err?: Ref<IMessage>
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/processTypes/${reportResultType}`);

        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
            return [this.allFromDropdownItem, ...response.data.data];
        }

        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getFilmPackageBDocs(filmSysId: string): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/filmPackageBDocs/${filmSysId}`);
        return response.data.data;
    }

    async getFilmPackageBDocsUnused(filmSysId: string, cardSysId: string): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/filmPackageBDocsUnused/${filmSysId}/${cardSysId}`);
        return response.data.data;
    }

    async getIndustryIndexesInternalAndExternal(
        reportResultType = ReportResultType.BothDBs,
        err?: Ref<IMessage>
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/industryIndexes/${reportResultType}`);
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
            return [this.allFromDropdownItem, ...response.data.data];
        }
        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getUsersInRoles(archiveId: number, roles: RoleNames[]): Promise<IDropdownOption[]> {
        const rolesAsStr = roles.join(',');
        const response = await http.get(`${this.url}/usersInRoles/${archiveId}/${rolesAsStr}`);
        return response.data.data;
    }

    async getUsersInRolesAllArchives(roles: RoleNames[]): Promise<IDropdownOption[]> {
        const rolesAsStr = roles.join(',');
        const response = await http.get(`${this.url}/usersInRolesAllArchives/${rolesAsStr}`);
        return response.data.data;
    }

    async getFileFormats(): Promise<IDropdownOption[]> {
        return http.get(`${this.url}/fileFormats`).then((response) => response.data.data as IDropdownOption[]);
    }

    async getFileFormatsWithSelectAll(): Promise<IDropdownOption[]> {
        const fileFormats = await http
            .get(`${this.url}/fileFormats`)
            .then((response) => response.data.data as IDropdownOption[]);

        return [...[this.allFromDropdownItem], ...fileFormats];
    }

    async getEPKSessions(archiveId: number): Promise<IDropdownOption[]> {
        return http
            .get(`${this.url}/getEPKSessions/${archiveId}`)
            .then((response) => response.data.data as IDropdownOption[]);
    }

    async getEmployeeNamesInternalAndExternal(
        reportResultType = ReportResultType.BothDBs,
        err?: Ref<IMessage>
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/internalAndExternal/getEmployeeNames/${reportResultType}`);
        const items = this.differentiateInternalFromExternal([...this.allFromDropdownItems, ...response.data.data]);
        this.hasAllFromDropdownItem = reportResultType == 1 ? true : false;
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
            return [this.allFromDropdownItem, ...response.data.data];
        }

        return !this.hasAllFromDropdownItem ? response.data.data : [...items];
    }

    async getEmployeeNamesInternal(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const employeeNames = await http.get(`${this.url}/internal/getEmployeeNames`);

        return !hasAllFromDropdownItem
            ? employeeNames.data.data
            : [this.allFromDropdownItem, ...employeeNames.data.data];
    }

    async getApprovedApplications(type: string, inventorySysId?: string, archiveId?: number): Promise<IDropdownOption[]> {
        const url = new URL(`${this.url}/approvedApplications`);

        url.searchParams.append('applicationType', type);
        if (inventorySysId) {
            url.searchParams.append('inventorySysId', inventorySysId);
        }
        if (archiveId) {
            url.searchParams.append('archiveId', archiveId.toString());
        }
        const response = await http.get(url.toString());
        return response.data.data;
        // return http
        //     .get(`${this.url}/approvedApplications?applicationType=${type}`)
        //     .then((response) => response.data.data as IDropdownOption[]);
    }

    private differentiateInternalFromExternal(items: IDropdownOption[], addLabelExt = true) {
        const result = [] as IDropdownOption[];
        items.forEach((item: IDropdownOption) => {
            if (item.hasExternalSource) {
                const label = `${item.label} ${this.isdaText}`;
                if (
                    item.code != allFromDropdownValue &&
                    item.code != allFromDropdownInternalValue &&
                    //item.code != allFromDropdownExternalValue &&
                    item.code != noDropdownItemValue &&
                    item.code != noDropdownItemInternalValue &&
                    item.code != noDropdownItemExternalValue &&
                    addLabelExt
                ) {
                    if (item.code == allFromDropdownExternalValue) {
                        result.push({
                            code: `${item.code}`,
                            label: label,
                            hasExternalSource: true,
                        });
                    } else
                        result.push({
                            code: `${item.code}${externalSourceSuffix}`,
                            label: label,
                            hasExternalSource: true,
                        });
                } else {
                    result.push({
                        code: `${item.code}${externalSourceSuffix}`,
                        label: item.label,
                        hasExternalSource: true,
                    });
                }
            } else if (item.code == allFromDropdownValue || item.code == noDropdownItemValue || !addLabelExt) {
                result.push({ code: item.code, label: item.label });
            } else {
                result.push({ code: item.code, label: `${item.label} ${this.seaText}`, hasExternalSource: false });
            }
        });

        return result;
    }

    private hasExternalItem(items: IDropdownOption[]) {
        const externalItems = items.filter((item) => item.hasExternalSource);
        return externalItems.length > 0 ? true : false;
    }

    async getReaderProfiles(): Promise<IDropdownOption[]> {
        const readerProfiles = await http.get(`${this.url}/readerProfiles`);
        return readerProfiles.data.data;
    }

    async getAllFilms(): Promise<IDropdownOption[]> {
        const films = await http.get(`${this.url}/films`);
        return films.data.data;
    }
    async getAllDescLevels(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/getAllDescLevels`);
        if (!this.hasExternalItem(response.data.data)) {
            return [this.allFromDropdownItem, ...response.data.data];
        }
        return !hasAllFromDropdownItem
            ? this.differentiateInternalFromExternal([...response.data.data])
            : [...this.differentiateInternalFromExternal([...this.allFromDropdownItems, ...response.data.data])];
    }

    async getFundInventoryAEDocumentDescLevels(
        reportResultType = ReportResultType.BothDBs,
        err?: Ref<IMessage>
    ): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/getFundInventoryAEDocumentDescLevels/${reportResultType}`);
        if (response.status == 200 && response.data.showMessage && err) {
            displayMessage(err, response.data.message, 'warning');
            return [this.allFromDropdownItem, ...response.data.data];
        }
        return [this.allFromDropdownItem, ...response.data.data];
    }

    async getFilmCountries(): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/filmCountries`);
        return response.data.data;
    }

    async getProcessesSteps(): Promise<IDropdownOption[]> {
        const processesSteps = await http.get(`${this.url}/processesSteps`);
        return processesSteps.data.data;
    }

    async getPreparationOfDigitalObjectProcessSteps(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const processesSteps = await http.get(`${this.url}/preparationOfDigitalObjectProcessSteps`);

        return !hasAllFromDropdownItem
            ? processesSteps.data.data
            : [this.allFromDropdownItem, ...processesSteps.data.data];
    }

    async GetSessionTypes(): Promise<IDropdownOption[]> {
        const sessionTypes = await http.get(`${this.url}/getSessionTypes`);
        return sessionTypes.data.data;
    }

    async getLibraryCards(): Promise<IDropdownOption[]> {
        const libraryCards = await http.get(`${this.url}/libraryCards`);
        return libraryCards.data.data;
    }

    async geEmployeeNamesExternal(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const employeeNames = await http.get(`${this.url}/employeeNamesExternal`);
        return !hasAllFromDropdownItem
            ? employeeNames.data.data
            : [this.allFromDropdownItem, ...employeeNames.data.data];
    }

    async GetProcessesExternal(hasAllFromDropdownItem = false): Promise<IDropdownOption[]> {
        const response = await http.get(`${this.url}/external/processes`);
        return !hasAllFromDropdownItem ? response.data.data : [this.allFromDropdownItem, ...response.data.data];
    }
}

const dropdownService = new DropdownService();
export default dropdownService;
