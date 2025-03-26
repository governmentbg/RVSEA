import http from '@/services/http.service';
import {
    externalSourceSuffix,
    allFromDropdownValue,
    allFromDropdownInternalValue,
    allFromDropdownExternalValue,
    RegisterOfDigitalObjectsReportSummary,
    ReportGridRequestModel,
    ReportGridResponseModel,
    FundPublicReport,
    FundPublicReportSummary,
    FundReportFiltersModel,
    FundDataPublicReport,
    FundDataPublicReportSummary,
    FundDataReportFiltersModel,
    FundMemoryPublicReport,
    RegisterOfDigitalObjectsPublicReport,
    RegisterOfDigitalObjectsReportFiltersModel,
    ReportGridWithSummaryGridResponseModel,
    PartialReceiptsPublicReport,
    PartialReceiptsPublicReportFiltersModel,
    ReportServiceResultModel,
    ListFiltersModel,
    FundsListReport,
    FundReportSummary2,
} from '@/models/reports';
import { appStore } from '@/store/app';
import BaseService from './base.service';

const aStore = appStore();
class ReportService extends BaseService {
    private rootUrl: string = `${aStore.getters.baseUrl}/api/report`;

    private getSplitValues(codes: string[]) {
        const internalCodes = [] as string[];
        const externalCodes = [] as string[];

        codes.forEach((code: string) => {
            if (code === allFromDropdownValue) {
                externalCodes.push(allFromDropdownValue);
                internalCodes.push(allFromDropdownValue);
            } else if (code === allFromDropdownExternalValue) {
                externalCodes.push(allFromDropdownValue);
            } else if (code === allFromDropdownInternalValue) {
                internalCodes.push(allFromDropdownValue);
            } else if (code.slice(externalSourceSuffix.length * -1, code.length) === externalSourceSuffix) {
                code = code.slice(0, externalSourceSuffix.length * -1);
                externalCodes.push(code);
            } else {
                internalCodes.push(code);
            }
        });

        return { externalCodes, internalCodes };
    }

    private setDefaultValuesIfNeeded(externalCodes: string[], inernalCodes: string[]) {
        if (externalCodes.length === 0 && inernalCodes.length == 0) {
            externalCodes.push(allFromDropdownValue);
            inernalCodes.push(allFromDropdownValue);
        }
    }

    public async getFundsPublicReport(
        model: ReportGridRequestModel<FundReportFiltersModel>
    ): Promise<
        ReportServiceResultModel<ReportGridWithSummaryGridResponseModel<FundPublicReportSummary, FundPublicReport>>
    > {
        if (!model.Filters.IndustryIndexes.length) {
            model.Filters.IndustryIndexGids.push(allFromDropdownValue);
            model.Filters.IndustryIndexesInternal.push(allFromDropdownValue);
        }
        if (!model.Filters.MethodsOfAcquisition.length) {
            model.Filters.MethodOfAcquisitionGids.push(allFromDropdownValue);
            model.Filters.MethodsOfAcquisitionInternal.push(allFromDropdownValue);
        }

        const response = await http.post(`${this.rootUrl}/funds`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<FundPublicReportSummary, FundPublicReport>
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getFundsDataPublicReport(
        model: ReportGridRequestModel<FundDataReportFiltersModel>
    ): Promise<
        ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<FundDataPublicReportSummary, FundDataPublicReport>
        >
    > {
        const response = await http.post(`${this.rootUrl}/fundsData`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<FundDataPublicReportSummary, FundDataPublicReport>
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getFundMemoriesPublicReport(
        model: ReportGridRequestModel<ListFiltersModel>
    ): Promise<
        ReportServiceResultModel<ReportGridWithSummaryGridResponseModel<FundReportSummary2, FundMemoryPublicReport>>
    > {
        const response = await http.post(`${this.rootUrl}/fundMemories`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<FundReportSummary2, FundMemoryPublicReport>
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getRegisterOfDigitalObjectsPublicReport(
        model: ReportGridRequestModel<RegisterOfDigitalObjectsReportFiltersModel>
    ): Promise<
        ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                RegisterOfDigitalObjectsReportSummary,
                RegisterOfDigitalObjectsPublicReport
            >
        >
    > {
        const response = await http.post(`${this.rootUrl}/registerOfDigitalObjects`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                RegisterOfDigitalObjectsReportSummary,
                RegisterOfDigitalObjectsPublicReport
            >
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getRegisterOfDigitalObjectsPublicReportSummary(
        model: ReportGridRequestModel<RegisterOfDigitalObjectsReportFiltersModel>
    ): Promise<ReportServiceResultModel<RegisterOfDigitalObjectsReportSummary>> {
        const response = await http.post(
            `${this.rootUrl}/registerOfDigitalObjectsSummary`,
            model,
            undefined,
            undefined,
            {
                cancelToken: this.source.token,
            }
        );

        return new ReportServiceResultModel<RegisterOfDigitalObjectsReportSummary>({
            data: response.data.data.summary,
            metadata: response.data.message,
        });
    }

    public async getPartialReceiptsPublicReport(
        model: ReportGridRequestModel<PartialReceiptsPublicReportFiltersModel>
    ): Promise<
        ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<FundPublicReportSummary, PartialReceiptsPublicReport>
        >
    > {
        const response = await http.post(`${this.rootUrl}/partialReceipts`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<FundPublicReportSummary, PartialReceiptsPublicReport>
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getFundsListReport(
        model: ReportGridRequestModel<ListFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridResponseModel<FundsListReport>>> {
        const response = await http.post(`${this.rootUrl}/fundsList`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<ReportGridResponseModel<FundsListReport>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }
}

const reportService = new ReportService();
export default reportService;
