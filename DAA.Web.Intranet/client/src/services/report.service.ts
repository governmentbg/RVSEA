import http from '@/services/http.service';
import {
    externalSourceSuffix,
    allFromDropdownValue,
    allFromDropdownInternalValue,
    allFromDropdownExternalValue,
    noDropdownItemValue,
    noDropdownItemInternalValue,
    noDropdownItemExternalValue,
    ReportGridRequestModel,
    ReportGridResponseModel,
    ReportGridWithSummaryGridResponseModel,
    ReportGridWithSummaryGridResponseModel1,
    FundMemoriesListInternalReportSummary,
    FundReportFiltersModel,
    FundReport,
    FundAvailabilityReport,
    FundsReportSummary,
    FundAvailabilityReportFiltersModel,
    FundsListReport,
    FundMemoriesListInternalReportModel,
    FundMemoriesListInternalReportFiltersModel,
    FundMemoriesListReport,
    FundReportSummary1,
    FundReportSummary2,
    PartialReceiptsListReport,
    ReceiptsListReport,
    WorkListForPriorityRestorationReport,
    ListFiltersModel,
    InventoryBook,
    AccountAndDescriptionOfFilmDocumentsBook,
    InventoryBookOfCopiesFromForeignArchives,
    CompilationAndNTOOfEDocumentsCombinedModel,
    CompilationAndNTOOfEDocumentsFiltersModel,
    CompilationAndNTOOfEDocuments,
    InsuranceFundOfCopiesOfForeignArchives,
    RegisterOfDigitizedDocumentsReportFiltersModel,
    RegisterOfDigitizedDocumentsReport,
    CountOfUsedCopiesOfDocumentsFromForeignArchivesFiltersModel,
    CountOfUsedCopiesOfDocumentsFromForeignArchivesReport,
    //CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined,
    CountOfUsedCopiesOfDocumentsFromForeignArchivesCombinedBeforeSplit,
    WorkDoneOnDigitalObjectsCombinedReportInputModel,
    QualityControlReport,
    QualityControlCombined,
    DigitalObjectsPreparationReport,
    DigitalObjectsPreparationCombined,
    SpecialRegistrationListReportModel,
    SpecialRegistrationListReportFiltersModel,
    NumberOfArchiveEntitiesOrderedByReaderReportFiltersModel,
    NumberOfArchiveEntitiesOrderedByReaderReport,
    NumberOfArchiveEntitiesOrderedByReaderCombined,
    NumberOfArchiveEntitiesOrderedByEmployeeReportFiltersModel,
    NumberOfArchiveEntitiesOrderedByEmployeeReport,
    NumberOfArchiveEntitiesOrderedByEmployeeCombined,
    MostUsedRequestEntitiesReportModel,
    MostUsedRequestEntitiesReportFiltersModel,
    ReportGridResponseModel1,
    NumberOfDocumentsOrderedByReaderReportFiltersModel,
    NumberOfDocumentsOrderedByReaderReport,
    NumberOfDocumentsOrderedByReaderReportCombined,
    NumberOfDocumentsOrderedByEmployeeReportFiltersModel,
    NumberOfDocumentsOrderedByEmployeeReport,
    NumberOfDocumentsOrderedByEmployeeReportCombined,
    ActiveProcessesReportFiltersModel,
    ActiveProcessesReportModel,
    ReportGridResponseModel2,
    InventoryReportFiltersModel,
    InventoryReport,
    InventoryReportCombined,
    ListOfRoughDocumentsReportFiltersModel,
    ListOfRoughDocumentsReport,
    ListOfRoughDocumentsReportCombined,
    DigitalDocumentsUsageReportFiltersModel,
    DigitalDocumentsUsageReportSummaryModel,
    DigitalDocumentsUsageReportModel,
    ListOfPartialReceiptsInArchiveReportFiltersModel,
    ListOfPartialReceiptsInArchiveReport,
    ListOfPartialReceiptsInArchiveReportCombined,
    UserActionsJournalReportFiltersModel,
    UserActionsJournalReport,
    CardForm1SummaryExternalData,
    ReportServiceResultModel,
    FundDataReportFiltersModel,
    FundDataReportSummary,
    FundDataReport,
    WorkDoneOnDigitalObjectsReportFiltersModel,
    WorkDoneOnDigitalObjectsReportModel,
    CardForm1DataFiltersModel,
    CardForm1Data,
    RegisterOfDigitizedDocumentsSummaryAndCombined,
} from '@/models/reports';
import { appStore } from '@/store/app';
import BaseService from '@/services/base.service';
import { ReportResultType } from '@/enums/reports';

const aStore = appStore();

class ReportService extends BaseService {
    private reportsRootUrl: string = `${aStore.getters.baseUrl}/api/report`;

    private getSplitValues(codes: string[]) {
        const internalCodes = [] as string[];
        const externalCodes = [] as string[];

        for (let index = 0; index < codes.length; index++) {
            if (codes[index] === allFromDropdownValue) {
                externalCodes.push(allFromDropdownValue);
                internalCodes.push(allFromDropdownValue);
            } else if (codes[index] === allFromDropdownExternalValue) {
                externalCodes.push(allFromDropdownValue);
            } else if (codes[index] === allFromDropdownInternalValue) {
                internalCodes.push(allFromDropdownValue);
            } else if (codes[index] === noDropdownItemValue) {
                externalCodes.push(noDropdownItemValue);
                internalCodes.push(noDropdownItemValue);
            } else if (codes[index] === noDropdownItemExternalValue) {
                externalCodes.push(noDropdownItemValue);
            } else if (codes[index] === noDropdownItemInternalValue) {
                internalCodes.push(noDropdownItemValue);
            } else if (
                codes[index].slice(externalSourceSuffix.length * -1, codes[index].length) === externalSourceSuffix
            ) {
                // is external source
                const code = codes[index].slice(0, externalSourceSuffix.length * -1);
                externalCodes.push(code);
            } else {
                internalCodes.push(codes[index]);
            }
        }

        return { externalCodes, internalCodes };
    }

    // private setDefaultValuesIfNeeded(externalCodes: string[], inernalCodes: string[]) {
    //     if (externalCodes.length === 0 && inernalCodes.length == 0) {
    //         externalCodes.push(allFromDropdownValue);
    //         inernalCodes.push(allFromDropdownValue);
    //     }
    // }

    private prepareArchiveForRequest(filters: ListFiltersModel) {
        const splitArchives = this.getSplitValues(filters.Archives as string[]);
        (filters.ArchiveGid as string[]) = [...splitArchives.externalCodes];
        (filters.ArchiveCodesInternal as string[]) = [...splitArchives.internalCodes];
    }

    public async getFundsReport(
        model: ReportGridRequestModel<FundReportFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundReport>>> {
        if (model.Filters.ReportResultType == ReportResultType.InternalDB) {
            model.Filters.StatusesInternal = [...model.Filters.Statuses];
            model.Filters.FundArraysInternal = [...model.Filters.FundArrays];
            model.Filters.FundTypesInternal = [...model.Filters.FundTypes];
            model.Filters.IndustryIndexesInternal = [...model.Filters.IndustryIndexes];
            model.Filters.MethodsOfAcquisitionInternal = [...model.Filters.MethodsOfAcquisition];

            model.Filters.StatusGids = [];
            model.Filters.PeriodGids = [];
            model.Filters.FundTypeGids = [];
            model.Filters.IndustryIndexGids = [];
            model.Filters.MethodOfAcquisitionGids = [];

            if (!model.Filters.IndustryIndexes.length) {
                model.Filters.IndustryIndexesInternal.push('-999');
            }
        }
        if (model.Filters.ReportResultType == ReportResultType.ExternalDB) {
            model.Filters.StatusGids = [...model.Filters.Statuses];
            model.Filters.PeriodGids = [...model.Filters.FundArrays];
            model.Filters.FundTypeGids = [...model.Filters.FundTypes];
            model.Filters.IndustryIndexGids = [...model.Filters.IndustryIndexes];
            model.Filters.MethodOfAcquisitionGids = [...model.Filters.MethodsOfAcquisition];

            model.Filters.StatusesInternal = [];
            model.Filters.FundArraysInternal = [];
            model.Filters.FundTypesInternal = [];
            model.Filters.IndustryIndexesInternal = [];
            model.Filters.MethodsOfAcquisitionInternal = [];

            if (!model.Filters.IndustryIndexes.length) {
                model.Filters.IndustryIndexGids.push('-999');
            }
        }

        const response = await http.post(`${this.reportsRootUrl}/funds`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundReport>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getFundAvailabilityReport(
        model: ReportGridRequestModel<FundAvailabilityReportFiltersModel>
    ): Promise<
        ReportServiceResultModel<ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundAvailabilityReport>>
    > {
        if (model.Filters.ReportResultType !== ReportResultType.BothDBs) {
            if (model.Filters.ReportResultType == ReportResultType.InternalDB) {
                (model.Filters.StatusesInternal as string[]) = [...model.Filters.Statuses] as string[];
                (model.Filters.FundArraysInternal as string[]) = [...model.Filters.FundArrays];
                (model.Filters.FundTypesInternal as string[]) = [...model.Filters.FundTypes];
                (model.Filters.MethodsOfAcquisitionInternal as string[]) = [...model.Filters.MethodsOfAcquisition];

                model.Filters.StatusGids = [];
                model.Filters.PeriodGids = [];
                model.Filters.FundTypeGids = [];
                model.Filters.MethodOfAcquisitionGids = [];
                model.Filters.ArchiveGids = [];
            } else {
                (model.Filters.StatusGids as string[]) = [...model.Filters.Statuses] as string[];
                (model.Filters.PeriodGids as string[]) = [...model.Filters.FundArrays];
                (model.Filters.FundTypeGids as string[]) = [...model.Filters.FundTypes];
                (model.Filters.MethodOfAcquisitionGids as string[]) = [...model.Filters.MethodsOfAcquisition];

                model.Filters.StatusesInternal = [];
                model.Filters.FundArraysInternal = [];
                model.Filters.FundTypesInternal = [];
                model.Filters.MethodsOfAcquisitionInternal = [];
            }
        }
        (model.Filters.ArchiveCodesInternal as string[]) = [...model.Filters.Archives] as string[];

        const response = await http.post(`${this.reportsRootUrl}/fundsAvailability`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundAvailabilityReport>
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getFundMemoriesListInternalReport(
        model: ReportGridRequestModel<FundMemoriesListInternalReportFiltersModel>
    ): Promise<
        ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                FundMemoriesListInternalReportSummary,
                FundMemoriesListInternalReportModel
            >
        >
    > {
        if (model.Filters.ReportResultType !== ReportResultType.BothDBs) {
            if (model.Filters.ReportResultType == ReportResultType.InternalDB) {
                (model.Filters.StatusesInternal as string[]) = [...model.Filters.Statuses] as string[];
                (model.Filters.FundArraysInternal as string[]) = [...model.Filters.FundArrays];
                (model.Filters.MethodsOfAcquisitionInternal as string[]) = [...model.Filters.MethodsOfAcquisition];

                model.Filters.StatusGids = [];
                model.Filters.PeriodGids = [];
                model.Filters.MethodOfAcquisitionGids = [];
                model.Filters.ArchiveGids = [];
            } else {
                (model.Filters.StatusGids as string[]) = [...model.Filters.Statuses] as string[];
                (model.Filters.PeriodGids as string[]) = [...model.Filters.FundArrays];
                (model.Filters.MethodOfAcquisitionGids as string[]) = [...model.Filters.MethodsOfAcquisition];

                model.Filters.StatusesInternal = [];
                model.Filters.FundArraysInternal = [];
                model.Filters.MethodsOfAcquisitionInternal = [];
            }
        }
        (model.Filters.ArchiveCodesInternal as string[]) = [...model.Filters.Archives] as string[];

        const response = await http.post(
            `${this.reportsRootUrl}/fundMemoriesListInternalReport`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return {
            // не може да се ползва стандартния конструктор
            data: response.data.data,
            metadata: response.data.message,
        };
    }

    public async getFundsListReport(
        model: ReportGridRequestModel<ListFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridResponseModel<FundsListReport>>> {
        this.prepareArchiveForRequest(model.Filters);

        const response = await http.post(`${this.reportsRootUrl}/fundsList`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<ReportGridResponseModel<FundsListReport>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getFundMemoriesListReport(
        model: ReportGridRequestModel<ListFiltersModel>
    ): Promise<
        ReportServiceResultModel<ReportGridWithSummaryGridResponseModel<FundReportSummary2, FundMemoriesListReport>>
    > {
        this.prepareArchiveForRequest(model.Filters);

        const response = await http.post(`${this.reportsRootUrl}/fundMemoriesList`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<FundReportSummary2, FundMemoriesListReport>
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getPartialReceiptsListReport(
        model: ReportGridRequestModel<ListFiltersModel>
    ): Promise<
        ReportServiceResultModel<ReportGridWithSummaryGridResponseModel<FundReportSummary1, PartialReceiptsListReport>>
    > {
        this.prepareArchiveForRequest(model.Filters);

        const response = await http.post(`${this.reportsRootUrl}/partialReceiptsList`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<FundReportSummary1, PartialReceiptsListReport>
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getReceiptsListReport(
        model: ReportGridRequestModel<ListFiltersModel>
    ): Promise<
        ReportServiceResultModel<ReportGridWithSummaryGridResponseModel<FundReportSummary2, ReceiptsListReport>>
    > {
        this.prepareArchiveForRequest(model.Filters);

        const response = await http.post(`${this.reportsRootUrl}/receiptsList`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<FundReportSummary2, ReceiptsListReport>
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getWorkListForPriorityRestorationReport(
        model: ReportGridRequestModel<ListFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridResponseModel<WorkListForPriorityRestorationReport>>> {
        this.prepareArchiveForRequest(model.Filters);

        const response = await http.post(
            `${this.reportsRootUrl}/workListForPriorityRestoration`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return new ReportServiceResultModel<ReportGridResponseModel<WorkListForPriorityRestorationReport>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getInventoryBook(
        model: ReportGridRequestModel<ListFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridResponseModel<InventoryBook>>> {
        this.prepareArchiveForRequest(model.Filters);

        const response = await http.post(`${this.reportsRootUrl}/inventoryBook`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<ReportGridResponseModel<InventoryBook>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getAccountAndDescriptionOfFilmDocumentsBook(
        model: ReportGridRequestModel<ListFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridResponseModel<AccountAndDescriptionOfFilmDocumentsBook>>> {
        this.prepareArchiveForRequest(model.Filters);

        const response = await http.post(
            `${this.reportsRootUrl}/accountAndDescriptionOfFilmDocumentsBook`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return new ReportServiceResultModel<ReportGridResponseModel<AccountAndDescriptionOfFilmDocumentsBook>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getInventoryBookOfCopiesFromForeignArchives(
        model: ReportGridRequestModel<ListFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridResponseModel<InventoryBookOfCopiesFromForeignArchives>>> {
        const splitArchives = this.getSplitValues(model.Filters.Archives as string[]);
        (model.Filters.ArchiveGid as string[]) = [...splitArchives.externalCodes];
        (model.Filters.ArchiveCodesInternal as string[]) = [...splitArchives.internalCodes];
        const response = await http.post(
            `${this.reportsRootUrl}/inventoryBookOfCopiesFromForeignArchives`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return new ReportServiceResultModel<ReportGridResponseModel<InventoryBookOfCopiesFromForeignArchives>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getCompilationAndNTOOfEDocumentsReport(
        model: ReportGridRequestModel<CompilationAndNTOOfEDocumentsFiltersModel>
    ): Promise<
        ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                CompilationAndNTOOfEDocumentsCombinedModel,
                CompilationAndNTOOfEDocuments
            >
        >
    > {
        const response = await http.post(
            `${this.reportsRootUrl}/compilationAndNTOOfEDocuments`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                CompilationAndNTOOfEDocumentsCombinedModel,
                CompilationAndNTOOfEDocuments
            >
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getInsuranceFundOfCopiesOfForeignArchives(
        model: ReportGridRequestModel<ListFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridResponseModel<InsuranceFundOfCopiesOfForeignArchives>>> {
        this.prepareArchiveForRequest(model.Filters);

        const response = await http.post(
            `${this.reportsRootUrl}/insuranceFundOfCopiesOfForeignArchives`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return new ReportServiceResultModel<ReportGridResponseModel<InsuranceFundOfCopiesOfForeignArchives>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getRegisterOfDigitizedDocumentsReportSummary(
        model:ReportGridRequestModel<RegisterOfDigitizedDocumentsReportFiltersModel>
    ): Promise<
        RegisterOfDigitizedDocumentsSummaryAndCombined
    > {
        const splitArchives = this.getSplitValues(model.Filters.Archives as string[]);
        (model.Filters.ArchiveGids as string[]) = [...splitArchives.externalCodes];
        (model.Filters.ArchiveCodesInternal as string[]) = [...splitArchives.internalCodes];

        const response = await http.post(
            `${this.reportsRootUrl}/registerOfDigitizedDocumentsReportSummary`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );
        
        return response.data.data
    }

    public async getRegisterOfDigitizedDocumentsReport(
        model: ReportGridRequestModel<RegisterOfDigitizedDocumentsReportFiltersModel>
    ): Promise<
        ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                RegisterOfDigitizedDocumentsSummaryAndCombined,
                RegisterOfDigitizedDocumentsReport
            >
        >
    > {
        const splitArchives = this.getSplitValues(model.Filters.Archives as string[]);
        (model.Filters.ArchiveGids as string[]) = [...splitArchives.externalCodes];
        (model.Filters.ArchiveCodesInternal as string[]) = [...splitArchives.internalCodes];

        const response = await http.post(
            `${this.reportsRootUrl}/registerOfDigitizedDocumentsReport`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                RegisterOfDigitizedDocumentsSummaryAndCombined,
                RegisterOfDigitizedDocumentsReport
            >
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getCountOfUsedCopiesOfDocumentsFromForeignArchivesReport(
        model: ReportGridRequestModel<CountOfUsedCopiesOfDocumentsFromForeignArchivesFiltersModel>
    ): Promise<
        ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                CountOfUsedCopiesOfDocumentsFromForeignArchivesCombinedBeforeSplit,
                CountOfUsedCopiesOfDocumentsFromForeignArchivesReport
            >
        >
    > {
        const splitArchives = this.getSplitValues(model.Filters.Archives as string[]);
        (model.Filters.ArchiveGids as string[]) = [...splitArchives.externalCodes];
        (model.Filters.ArchiveCodesInternal as string[]) = [...splitArchives.internalCodes];

        const response = await http.post(
            `${this.reportsRootUrl}/countOfUsedCopiesOfDocumentsFromForeignArchivesReport`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                CountOfUsedCopiesOfDocumentsFromForeignArchivesCombinedBeforeSplit,
                CountOfUsedCopiesOfDocumentsFromForeignArchivesReport
            >
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getQualityControlReport(
        model: ReportGridRequestModel<WorkDoneOnDigitalObjectsCombinedReportInputModel>
    ): Promise<ReportGridWithSummaryGridResponseModel<QualityControlCombined, QualityControlReport>> {
        const response = await http.post(`${this.reportsRootUrl}/qualityControlReport`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });
        return response.data;
    }

    public async getDigitalObjectsPreparationReport(
        model: ReportGridRequestModel<WorkDoneOnDigitalObjectsCombinedReportInputModel>
    ): Promise<ReportGridWithSummaryGridResponseModel<DigitalObjectsPreparationCombined, DigitalObjectsPreparationReport>> {
        const response = await http.post(`${this.reportsRootUrl}/digitalObjectsPreparationReport`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });
        return response.data;
    }

    public async getSpecialRegistrationListReport(
        model: ReportGridRequestModel<SpecialRegistrationListReportFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridResponseModel<SpecialRegistrationListReportModel>>> {
        const response = await http.post(
            `${this.reportsRootUrl}/specialRegistrationListReport`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return new ReportServiceResultModel<ReportGridResponseModel<SpecialRegistrationListReportModel>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getNumberOfArchiveEntitiesOrderedByReaderReport(
        model: ReportGridRequestModel<NumberOfArchiveEntitiesOrderedByReaderReportFiltersModel>
    ): Promise<
        ReportGridWithSummaryGridResponseModel<
            NumberOfArchiveEntitiesOrderedByReaderCombined,
            NumberOfArchiveEntitiesOrderedByReaderReport
        >
    > {
        const splitArchives = this.getSplitValues(model.Filters.Archives as string[]);
        (model.Filters.ArchiveGids as string[]) = [...splitArchives.externalCodes];
        (model.Filters.ArchiveCodesInternal as string[]) = [...splitArchives.internalCodes];

        const splitInventories = this.getSplitValues(model.Filters.Inventories as string[]);
        (model.Filters.InventoryGids as string[]) = [...splitInventories.externalCodes];
        (model.Filters.InventoryInternal as string[]) = [...splitInventories.internalCodes];

        const splitFunds = this.getSplitValues(model.Filters.Funds as string[]);
        (model.Filters.FundTypeGids as string[]) = [...splitFunds.externalCodes];
        (model.Filters.FundTypesInternal as string[]) = [...splitFunds.internalCodes];

        const archiveEntitiesDescriptionLevels = this.getSplitValues(
            model.Filters.ArchiveEntitiesDescriptionLevels as string[]
        );
        (model.Filters.ArchiveEntitiesDescriptionLevelsGids as string[]) = [
            ...archiveEntitiesDescriptionLevels.externalCodes,
        ];
        (model.Filters.ArchiveEntitiesDescriptionLevelsInternal as string[]) = [
            ...archiveEntitiesDescriptionLevels.internalCodes,
        ];

        const response = await http.post(
            `${this.reportsRootUrl}/numberOfArchiveEntitiesOrderedByReaderReport`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return response.data;
    }

    public async getNumberOfArchiveEntitiesOrderedByEmployeeReport(
        model: ReportGridRequestModel<NumberOfArchiveEntitiesOrderedByEmployeeReportFiltersModel>
    ): Promise<
        ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                NumberOfArchiveEntitiesOrderedByEmployeeCombined,
                NumberOfArchiveEntitiesOrderedByEmployeeReport
            >
        >
    > {
        const splitArchives = this.getSplitValues(model.Filters.Archives as string[]);
        (model.Filters.ArchiveGids as string[]) = [...splitArchives.externalCodes];
        (model.Filters.ArchiveCodesInternal as string[]) = [...splitArchives.internalCodes];

        const splitInventories = this.getSplitValues(model.Filters.Inventories as string[]);
        (model.Filters.InventoryGids as string[]) = [...splitInventories.externalCodes];
        (model.Filters.InventoryInternal as string[]) = [...splitInventories.internalCodes];

        const splitFunds = this.getSplitValues(model.Filters.Funds as string[]);
        (model.Filters.FundTypeGids as string[]) = [...splitFunds.externalCodes];
        (model.Filters.FundTypesInternal as string[]) = [...splitFunds.internalCodes];

        // const splitEmployeeNames = this.getSplitValues(model.Filters.EmployeeNames as string[]);
        // (model.Filters.EmployeeNamesGids as string[]) = [...splitEmployeeNames.externalCodes];
        // (model.Filters.EmployeeNamesInternal as string[]) = [...splitEmployeeNames.internalCodes];

        const response = await http.post(
            `${this.reportsRootUrl}/numberOfArchiveEntitiesOrderedByEmployeeReport`,
            model
        );

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                NumberOfArchiveEntitiesOrderedByEmployeeCombined,
                NumberOfArchiveEntitiesOrderedByEmployeeReport
            >
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getMostUsedRequestEntitiesReport(
        model: ReportGridRequestModel<MostUsedRequestEntitiesReportFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridResponseModel1<MostUsedRequestEntitiesReportModel>>> {
        const response = await http.post(
            `${this.reportsRootUrl}/mostUsedRequestEntitiesReport`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return new ReportServiceResultModel<ReportGridResponseModel1<MostUsedRequestEntitiesReportModel>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getNumberOfDocumentsOrderedByReaderReport(
        model: ReportGridRequestModel<NumberOfDocumentsOrderedByReaderReportFiltersModel>
    ): Promise<
        ReportGridWithSummaryGridResponseModel<
            NumberOfDocumentsOrderedByReaderReportCombined,
            NumberOfDocumentsOrderedByReaderReport
        >
    > {
        const response = await http.post(
            `${this.reportsRootUrl}/numberOfDocumentsOrderedByReaderReport`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );
        return response.data;
    }

    public async getNumberOfDocumentsOrderedByEmployeeReport(
        model: ReportGridRequestModel<NumberOfDocumentsOrderedByEmployeeReportFiltersModel>
    ): Promise<
        ReportGridWithSummaryGridResponseModel<
            NumberOfDocumentsOrderedByEmployeeReportCombined,
            NumberOfDocumentsOrderedByEmployeeReport
        >
    > {
        const response = await http.post(
            `${this.reportsRootUrl}/numberOfDocumentsOrderedByEmployeeReport`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );
        return response.data;
    }

    public async getActiveProcessesReport(
        model: ReportGridRequestModel<ActiveProcessesReportFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridResponseModel2<ActiveProcessesReportModel>>> {
        if (model.Filters.ReportResultType !== ReportResultType.BothDBs) {
            if (model.Filters.ReportResultType == ReportResultType.InternalDB) {
                (model.Filters.ProcessTypesInternal as string[]) = [...model.Filters.ProcessTypes];
                model.Filters.ProcessGids = [];
            } else {
                (model.Filters.ProcessGids as string[]) = [...model.Filters.ProcessTypes];
                model.Filters.ProcessTypesInternal = [];
            }
        }

        const splitUsers = this.getSplitValues(model.Filters.Users as string[]);
        (model.Filters.UserGids as string[]) = [...splitUsers.externalCodes];
        (model.Filters.UserIdsInternal as string[]) = [...splitUsers.internalCodes];
        const response = await http.post(`${this.reportsRootUrl}/activeProcesses`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<ReportGridResponseModel2<ActiveProcessesReportModel>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getInventoryReport(
        model: ReportGridRequestModel<InventoryReportFiltersModel>
    ): Promise<
        ReportServiceResultModel<ReportGridWithSummaryGridResponseModel<InventoryReportCombined, InventoryReport>>
    > {
        const response = await http.post(`${this.reportsRootUrl}/inventoryReport`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<InventoryReportCombined, InventoryReport>
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getListOfRoughDocumentsReport(
        model: ReportGridRequestModel<ListOfRoughDocumentsReportFiltersModel>
    ): Promise<ReportGridWithSummaryGridResponseModel<ListOfRoughDocumentsReportCombined, ListOfRoughDocumentsReport>> {
        if (model.Filters.ReportResultType == ReportResultType.InternalDB) {
            (model.Filters.FundTypesInternal as string[]) = [...model.Filters.FundTypes];
            (model.Filters.MethodsOfAcquisitionInternal as string[]) = [
                ...(model.Filters.MethodsOfAcquisition as string[]),
            ];
            (model.Filters.IndustryIndexesInternal as string[]) = [...(model.Filters.IndustryIndexes as string[])];

            model.Filters.FundTypeGids = [];
            model.Filters.MethodOfAcquisitionGids = [];
            model.Filters.IndustryIndexGids = [];
        } else if (model.Filters.ReportResultType !== ReportResultType.ExternalDB) {
            {
                (model.Filters.FundTypeGids as string[]) = [...model.Filters.FundTypes];
                (model.Filters.MethodOfAcquisitionGids as string[]) = [
                    ...(model.Filters.MethodsOfAcquisition as string[]),
                ];
                (model.Filters.IndustryIndexGids as string[]) = [...(model.Filters.IndustryIndexes as string[])];

                model.Filters.FundTypesInternal = [];
                model.Filters.MethodsOfAcquisitionInternal = [];
                model.Filters.IndustryIndexesInternal = [];
            }
        }

        const response = await http.post(
            `${this.reportsRootUrl}/listOfRoughDocumentsReport`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );
        return response.data;
    }

    public async getDigitalDocumentsUsageReport(
        model: ReportGridRequestModel<DigitalDocumentsUsageReportFiltersModel>
    ): Promise<
        ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel1<
                DigitalDocumentsUsageReportSummaryModel,
                DigitalDocumentsUsageReportModel
            >
        >
    > {
        const response = await http.post(`${this.reportsRootUrl}/digitalDocumentsUsage`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel1<
                DigitalDocumentsUsageReportSummaryModel,
                DigitalDocumentsUsageReportModel
            >
        >({
            data: response.data,
            metadata: response.message,
        });
    }

    public async getListOfPartialReceiptsInArchiveReport(
        model: ReportGridRequestModel<ListOfPartialReceiptsInArchiveReportFiltersModel>
    ): Promise<
        ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                ListOfPartialReceiptsInArchiveReportCombined,
                ListOfPartialReceiptsInArchiveReport
            >
        >
    > {
        if (model.Filters.ReportResultType !== ReportResultType.BothDBs) {
            if (model.Filters.ReportResultType == ReportResultType.InternalDB) {
                (model.Filters.FundArraysInternal as string[]) = [...(model.Filters.FundArrays as string[])];

                (model.Filters.MethodsOfAcquisitionInternal as string[]) = [
                    ...(model.Filters.MethodsOfAcquisition as string[]),
                ];

                model.Filters.PeriodGids = [];
                model.Filters.MethodOfAcquisitionGids = [];
            } else {
                (model.Filters.PeriodGids as string[]) = [...(model.Filters.FundArrays as string[])];
                (model.Filters.MethodOfAcquisitionGids as string[]) = [
                    ...(model.Filters.MethodsOfAcquisition as string[]),
                ];

                model.Filters.FundArraysInternal = [];
                model.Filters.MethodsOfAcquisitionInternal = [];
            }
        }

        const response = await http.post(
            `${this.reportsRootUrl}/listOfPartialReceiptsInArchiveReport`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<
                ListOfPartialReceiptsInArchiveReportCombined,
                ListOfPartialReceiptsInArchiveReport
            >
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getUserActionsJournalReport(
        model: ReportGridRequestModel<UserActionsJournalReportFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridResponseModel<UserActionsJournalReport>>> {
        const response = await http.post(
            `${this.reportsRootUrl}/userActionsJournalReport`,
            model,
            undefined,
            undefined,
            { cancelToken: this.source.token }
        );

        return new ReportServiceResultModel<ReportGridResponseModel<UserActionsJournalReport>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getCardForm1Data(
        model: ReportGridRequestModel<CardForm1DataFiltersModel>
    ): Promise<ReportGridWithSummaryGridResponseModel<CardForm1SummaryExternalData, CardForm1Data>> {
        const response = await http.post(`${this.reportsRootUrl}/cardForm1Data`, model);
        return response.data;
    }

    public async getCardForm1AlData(
        model: ReportGridRequestModel<CardForm1DataFiltersModel>
    ): Promise<ReportGridWithSummaryGridResponseModel<CardForm1SummaryExternalData, CardForm1Data>> {
        const response = await http.post(`${this.reportsRootUrl}/cardForm1AData`, model);
        return response.data;
    }

    public async getFundsDataReport(
        model: ReportGridRequestModel<FundDataReportFiltersModel>
    ): Promise<
        ReportServiceResultModel<ReportGridWithSummaryGridResponseModel<FundDataReportSummary, FundDataReport>>
    > {
        if (model.Filters.ReportResultType == ReportResultType.InternalDB) {
            (model.Filters.StatusesInternal as string[]) = [...model.Filters.Statuses] as string[];
            (model.Filters.FundArraysInternal as string[]) = [...model.Filters.FundArrays];
            (model.Filters.FundTypesInternal as string[]) = [...model.Filters.FundTypes];
            (model.Filters.IndustryIndexesInternal as string[]) = [...model.Filters.IndustryIndexes];
            (model.Filters.MethodsOfAcquisitionInternal as string[]) = [...model.Filters.MethodsOfAcquisition];

            model.Filters.StatusGids = [];
            model.Filters.PeriodGids = [];
            model.Filters.FundTypeGids = [];
            model.Filters.IndustryIndexGids = [];
            model.Filters.MethodOfAcquisitionGids = [];
        } else if (model.Filters.ReportResultType == ReportResultType.ExternalDB) {
            (model.Filters.StatusGids as string[]) = [...model.Filters.Statuses] as string[];
            (model.Filters.PeriodGids as string[]) = [...model.Filters.FundArrays];
            (model.Filters.FundTypeGids as string[]) = [...model.Filters.FundTypes];
            (model.Filters.IndustryIndexGids as string[]) = [...model.Filters.IndustryIndexes];
            (model.Filters.MethodOfAcquisitionGids as string[]) = [...model.Filters.MethodsOfAcquisition];

            model.Filters.StatusesInternal = [];
            model.Filters.FundArraysInternal = [];
            model.Filters.FundTypesInternal = [];
            model.Filters.IndustryIndexesInternal = [];
            model.Filters.MethodsOfAcquisitionInternal = [];
        }

        const response = await http.post(`${this.reportsRootUrl}/fundsData`, model, undefined, undefined, {
            cancelToken: this.source.token,
        });

        return new ReportServiceResultModel<
            ReportGridWithSummaryGridResponseModel<FundDataReportSummary, FundDataReport>
        >({
            data: response.data.data,
            metadata: response.data.message,
        });
    }

    public async getWorkDoneOnDigitalObjectsReport(
        model: ReportGridRequestModel<WorkDoneOnDigitalObjectsReportFiltersModel>
    ): Promise<ReportServiceResultModel<ReportGridResponseModel<WorkDoneOnDigitalObjectsReportModel>>> {
        const response = await http.post(
            `${this.reportsRootUrl}/workDoneOnDigitalObjects`,
            model,
            undefined,
            undefined,
            {
                cancelToken: this.source.token,
            }
        );

        return new ReportServiceResultModel<ReportGridResponseModel<WorkDoneOnDigitalObjectsReportModel>>({
            data: response.data.data,
            metadata: response.data.message,
        });
    }
}

const reportService = new ReportService();
export default reportService;
