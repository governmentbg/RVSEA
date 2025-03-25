using DAA.Data;
using DAA.Models.Reports;

namespace DAA.Services.Admin
{
    public interface IReportService
    {
        public Task<ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundPublicReport>> GetFundsPublicReport(CancellationToken token,
            ReportGridRequestModel<FundPublicReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundInternalReport>> GetFundsInternalReport(CancellationToken token,
            ReportGridRequestModel<FundPublicReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundAvailabilityReport>> GetFundAvailabilityReport(CancellationToken token,
            ReportGridRequestModel<FundAvailabilityReportInputModel> model);
        Task<ReportGridResponseModel<FundsListPublicReport>> GetFundsListReport(CancellationToken token, ReportGridRequestModel<ListPublicReportInputModel> model);
        Task<ReportGridResponseModel<FundsListReport>> GetFundsListInternalReport(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<FundDataReportSummary, FundDataPublicReport>> GetFundsDataPublicReport(
            CancellationToken token, ReportGridRequestModel<FundDataPublicReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<FundDataReportSummary, FundDataInternalReport>> GetFundsDataInernalReport(
            CancellationToken token, ReportGridRequestModel<FundDataInternalReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<FundReportSummary2,FundMemoryPublicReport>> GetFundMemoriesPublicReport(CancellationToken token, ReportGridRequestModel<ListPublicReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<FundMemoriesListInternalReportSummary, FundMemoriesListInternalReport>> GetFundMemoriesListInternalReport(CancellationToken token,
            ReportGridRequestModel<FundMemoriesListInternalReportFiltersModel> model);
        Task<ReportGridWithSummaryGridResponseModel<FundReportSummary2, FundMemoriesListReport>> GetFundMemoriesListReport(
            CancellationToken token, ReportGridRequestModel<ListReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<RegisterOfDigitalObjectsReportSummary, RegisterOfDigitalObjectsPublicReport>>
            GetRegisterOfDigitalObjectsPublicReport(CancellationToken token, ReportGridRequestModel<RegisterOfDigitalObjectsPublicReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<FundReportSummary1, PartialReceiptsPublicReport>>
            GetPartialReceiptsPublicReport(CancellationToken token, ReportGridRequestModel<PartialReceiptsPublicReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<FundReportSummary1, PartialReceiptsListReport>> GetPartialReceiptsListReport(
            CancellationToken token, ReportGridRequestModel<ListReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<FundReportSummary2, ReceiptsListReport>> GetReceiptsListReport(
            CancellationToken token, ReportGridRequestModel<ReceiptsListReportInputModel> model);
        Task<ReportGridResponseModel<WorkListForPriorityRestorationReport>> GetWorkListForPriorityRestorationReport(CancellationToken token,
            ReportGridRequestModel<ListReportInputModel> model);
        Task<ReportGridResponseModel<InventoryBook>> GetInventoryBook(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model);
        Task<ReportGridResponseModel<AccountAndDescriptionOfFilmDocumentsBook>> GetAccountAndDescriptionOfFilmDocumentsBook(CancellationToken token,
            ReportGridRequestModel<ListReportInputModel> model);
        Task<ReportGridResponseModel<InsuranceFundOfCopiesOfForeignArchives>> GetInsuranceFundOfCopiesOfForeignArchives(CancellationToken token,
            ReportGridRequestModel<ListReportInputModel> model);
        Task<ReportGridResponseModel<InventoryBookOfCopiesFromForeignArchives>> GetInventoryBookOfCopiesFromForeignArchives(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<CompilationAndNTOOfEDocumentsCombined, CompilationAndNTOOfEDocumentsReport>> GetCompilationAndNTOOfEDocuments(CancellationToken token, ReportGridRequestModel<CompilationAndNTOOfEDocumentsInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<RegisterOfDigitizedDocumentsSummaryAndCombined, RegisterOfDigitizedDocumentsReport>> GetRegisterOfDigitizedDocumentsReport(CancellationToken token, ReportGridRequestModel<RegisterOfDigitizedDocumentsReportInputModel> model);
        Task<RegisterOfDigitizedDocumentsSummaryAndCombined> GetRegisterOfDigitizedDocumentsReportSummary(CancellationToken token, ReportGridRequestModel<RegisterOfDigitizedDocumentsReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined, CountOfUsedCopiesOfDocumentsFromForeignArchivesReport>> GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport(CancellationToken token, ReportGridRequestModel<CountOfUsedCopiesOfDocumentsFromForeignArchivesReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<QualityControlCombined, QualityControlReport>> GetQualityControlReport(CancellationToken token, ReportGridRequestModel<WorkDoneOnDigitalObjectsCombinedReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<DigitalObjectsPreparationCombined, DigitalObjectsPreparationReport>> GetDigitalObjectsPreparationReport(CancellationToken token, ReportGridRequestModel<WorkDoneOnDigitalObjectsCombinedReportInputModel> model);
        Task<ReportGridResponseModel<SpecialRegistrationListReport>> GetSpecialRegistrationListReport(CancellationToken token,
            ReportGridRequestModel<SpecialRegistrationListReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<NumberOfArchiveEntitiesOrderedByReaderCombined, NumberOfArchiveEntitiesOrderedByReaderReport>> GetNumberOfArchiveEntitiesOrderedByReaderReport(ReportGridRequestModel<NumberOfArchiveEntitiesOrderedByReaderInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<NumberOfArchiveEntitiesOrderedByEmployeeCombined, NumberOfArchiveEntitiesOrderedByEmployeeReport>> GetNumberOfArchiveEntitiesOrderedByEmployeeReport(ReportGridRequestModel<NumberOfArchiveEntitiesOrderedByEmployeeInputModel> model);
        Task<ReportGridResponseModel<MostUsedRequestEntitiesReport>> GetMostUsedRequestEntitiesReport(CancellationToken token, ReportGridRequestModel<MostUsedRequestEntitiesReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<NumberOfDocumentsOrderedByReaderReportCombined, NumberOfDocumentsOrderedByReaderReport>> GeNumberOfDocumentsOrderedByReaderReport(CancellationToken token, ReportGridRequestModel<NumberOfDocumentsOrderedByReaderReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<NumberOfDocumentsOrderedByEmployeeReportCombined, NumberOfDocumentsOrderedByEmployeeReport>> GeNumberOfDocumentsOrderedByEmployeeReport(CancellationToken token, ReportGridRequestModel<NumberOfDocumentsOrderedByEmployeeReportInputModel> model);
        Task<ReportGridResponseModel<ActiveProcessesReport>> GetActiveProcessesReport(CancellationToken token, ReportGridRequestModel<ActiveProcessesReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<InventoryReportCombined, InventoryReport>> GetInventoryReport(CancellationToken token, ReportGridRequestModel<InventoryReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<ListOfRoughDocumentsReportCombined, ListOfRoughDocumentsReport>> GetListOfRoughDocumentsReport(CancellationToken token, ReportGridRequestModel<ListOfRoughDocumentsReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel1<DigitalDocumentsUsageReportSummary, DigitalDocumentsUsageReport>> GetDigitalDocumentsUsageReport(CancellationToken token,
            ReportGridRequestModel<DigitalDocumentsUsageReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<ListOfPartialReceiptsInArchiveReportCombined, ListOfPartialReceiptsInArchiveReport>> GetListOfPartialReceiptsInArchiveReport(CancellationToken token, ReportGridRequestModel<ListOfPartialReceiptsInArchiveReportInputModel> model);
        Task<ReportGridResponseModel<UserActionsJournalReport>> GetUserActionsJournalReport(CancellationToken token, ReportGridRequestModel<UserActionsJournalReportInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<CardForm1SummaryExternalData, CardForm1Data>> GetCardForm1Data(
            ReportGridRequestModel<CardForm1DataInputModel> model);
        Task<ReportGridWithSummaryGridResponseModel<CardForm1SummaryExternalData, CardForm1Data>> GetCardForm1AData(
         ReportGridRequestModel<CardForm1DataInputModel> model , int? fundExternalIdentifier);
        Task<ReportGridResponseModel<WorkDoneOnDigitalObjectsReport>> GetWorkDoneOnDigitalObjectsReport(
            CancellationToken token, ReportGridRequestModel<WorkDoneOnDigitalObjectsReportInputModel> model);
    }
}
