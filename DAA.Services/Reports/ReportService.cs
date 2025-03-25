using DAA.Data;
using Microsoft.Extensions.Localization;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using DAA.Models.Reports;
using Microsoft.Extensions.Options;
using DAA.Models.Configuration;
using DAA.Extensions.DateTime;
using DAA.Extensions.Exceptions;
using SqlException = Microsoft.Data.SqlClient.SqlException;
using DAA.Shared;

namespace DAA.Services.Admin
{
    public class ReportService : BaseService, IReportService
    {
        private readonly LinkedServerSettings _linkedServerSettings;

        private const string ExternalEntitySufix = "_ext";
        private const string EntityTypeFundPrefix = "fund_";
        private const string EntityTypeInventoryPrefix = "inv_";
        private const string EntityTypeArchivalEntityPrefix = "ae_";
        private const string EntityTypeDocumentPrefix = "doc_";
        private const string DropdownOptionCodeSellectAll = "-999";
        private const string DropdownOptionCodeSellectAllInternal = "-998";
        private const string DropdownOptionCodeSellectAllExternal = "-997";
        private const string _descriptionLevelsDictionaryFundInternal = "fundInternal";
        private const string _descriptionLevelsDictionaryInventoryInternal = "inventoryInternal";
        private const string _descriptionLevelsDictionaryArchivalEntityInternal = "archivalEntityInternal";
        private const string _descriptionLevelsDictionaryDocumentInternal = "documentInternal";
        private const string _descriptionLevelsDictionaryExternal = "external";
        //private const string _processTypeCodePreparationOfADigitalObject = "PreparationOfADigitalObject";
        private const int DBRequestTimeoutTypeNumber = -2;

        public ReportService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IOptions<LinkedServerSettings> linkedServerConfig
        )
            : base(context, localizer)
        {
            _context.Database.SetCommandTimeout(300);
            _linkedServerSettings = linkedServerConfig.Value;
        }

        public async Task<ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundPublicReport>> GetFundsPublicReport(CancellationToken token,
            ReportGridRequestModel<FundPublicReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundPublicReports.FromSqlRaw("EXECUTE dbo.GetFundPublicReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.Statuses!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundsReportSummaries.FromSqlRaw("EXECUTE dbo.GetFundReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.Statuses!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundPublicReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalFunds ?? 0,
                    Summary = summary[0]
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

                var rows = await _context.FundPublicReports.FromSqlRaw("EXECUTE dbo.GetFundPublicReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18}",
              _linkedServerSettings.LinkedServer,
              (int)Shared.ReportResultType.InternalDB,
              JoinStrings(model.Filters.PeriodGids!),
              JoinStrings(model.Filters.FundArraysInternal!),
              JoinStrings(model.Filters.FundTypeGids!),
              JoinStrings(model.Filters.FundTypesInternal!),
              JoinStrings(model.Filters.IndustryIndexGids!),
              JoinStrings(model.Filters.IndustryIndexesInternal!),
              JoinStrings(model.Filters.MethodOfAcquisitionGids!),
              JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
              model.Filters.RegisteredFrom != null
                     ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                     : DBNull.Value,
                 model.Filters.RegisteredTo != null
                     ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                     : DBNull.Value,
              JoinStrings(model.Filters.Statuses!),
              JoinStrings(model.Filters.Archives!),
              model.Filters.TextDate,
              model.Filters.DateFrom,
              model.Filters.DateTo,
              model.ItemsPerPage,
              model.Page
          ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundsReportSummaries.FromSqlRaw("EXECUTE dbo.GetFundReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.Statuses!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundPublicReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalFunds ?? 0,
                    Summary = summary[0],
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundInternalReport>> GetFundsInternalReport(CancellationToken token,
            ReportGridRequestModel<FundPublicReportInputModel> model)
        {
            //if (model.Filters.ReportResultType == (int)Shared.ReportResultType.AllDB)
            //{ 


            //}
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundInternalReports.FromSqlRaw("EXECUTE dbo.GetFundInternalReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.Statuses!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.StatusGids)
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundsReportSummaries.FromSqlRaw("EXECUTE dbo.GetFundInternalReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.Statuses!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    JoinStrings(model.Filters.StatusGids)
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundInternalReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalFunds ?? 0,
                    Summary = summary[0]
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

                var rows = await _context.FundInternalReports.FromSqlRaw("EXECUTE dbo.GetFundInternalReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19}",
                _linkedServerSettings.LinkedServer!,
               (int)Shared.ReportResultType.InternalDB,
               JoinStrings(model.Filters.PeriodGids!),
               JoinStrings(model.Filters.FundArraysInternal!),
               JoinStrings(model.Filters.FundTypeGids!),
               JoinStrings(model.Filters.FundTypesInternal!),
               JoinStrings(model.Filters.IndustryIndexGids!),
               JoinStrings(model.Filters.IndustryIndexesInternal!),
               JoinStrings(model.Filters.MethodOfAcquisitionGids!),
               JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
               model.Filters.RegisteredFrom != null
                      ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                      : DBNull.Value,
                  model.Filters.RegisteredTo != null
                      ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                      : DBNull.Value,
               JoinStrings(model.Filters.Statuses!),
               JoinStrings(model.Filters.Archives!),
               model.Filters.TextDate,
               model.Filters.DateFrom,
               model.Filters.DateTo,
               model.ItemsPerPage,
               model.Page,
               JoinStrings(model.Filters.StatusGids!)
           ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundsReportSummaries.FromSqlRaw("EXECUTE dbo.GetFundInternalReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17}",
                    _linkedServerSettings.LinkedServer!,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.Statuses!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                       JoinStrings(model.Filters.StatusGids)
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundInternalReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalFunds ?? 0,
                    Summary = summary[0],
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundAvailabilityReport>> GetFundAvailabilityReport(CancellationToken token,
            ReportGridRequestModel<FundAvailabilityReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundAvailabilityReports.FromSqlRaw("EXECUTE dbo.GetFundAvailabilityReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    JoinStrings(model.Filters.ProcessGids!),
                    JoinStrings(model.Filters.ProcessTypesInternal!),
                    JoinStrings(model.Filters.FileFormats.Any() ? model.Filters.FileFormats : new List<string> { DropdownOptionCodeSellectAll }),
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var totalRows = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetFundAvailabilityReportTotalRows {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    JoinStrings(model.Filters.ProcessGids!),
                    JoinStrings(model.Filters.ProcessTypesInternal!),
                    JoinStrings(model.Filters.FileFormats.Any() ? model.Filters.FileFormats : new List<string> { DropdownOptionCodeSellectAll })
                ).ToListAsync(token);

                var summary = await _context.FundAvailabilityReportSummaries.FromSqlRaw("EXECUTE dbo.GetFundAvailabilityReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    JoinStrings(model.Filters.ProcessGids!),
                    JoinStrings(model.Filters.ProcessTypesInternal!),
                    JoinStrings(model.Filters.FileFormats.Any() ? model.Filters.FileFormats : new List<string> { DropdownOptionCodeSellectAll })
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundAvailabilityReport>
                {
                    Items = rows,
                    TotalCount = totalRows[0].TotalRows,
                    Summary = summary[0]
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundAvailabilityReports.FromSqlRaw("EXECUTE dbo.GetFundAvailabilityReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    JoinStrings(model.Filters.ProcessGids!),
                    JoinStrings(model.Filters.ProcessTypesInternal!),
                    JoinStrings(model.Filters.FileFormats.Any() ? model.Filters.FileFormats : new List<string> { DropdownOptionCodeSellectAll }),
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var totalRows = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetFundAvailabilityReportTotalRows {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    JoinStrings(model.Filters.ProcessGids!),
                    JoinStrings(model.Filters.ProcessTypesInternal!),
                    JoinStrings(model.Filters.FileFormats.Any() ? model.Filters.FileFormats : new List<string> { DropdownOptionCodeSellectAll })
                ).ToListAsync(token);

                var summary = await _context.FundAvailabilityReportSummaries.FromSqlRaw("EXECUTE dbo.GetFundAvailabilityReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    JoinStrings(model.Filters.ProcessGids!),
                    JoinStrings(model.Filters.ProcessTypesInternal!),
                    JoinStrings(model.Filters.FileFormats.Any() ? model.Filters.FileFormats : new List<string> { DropdownOptionCodeSellectAll })
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundsReportSummary, FundAvailabilityReport>
                {
                    Items = rows,
                    TotalCount = totalRows[0].TotalRows,
                    Summary = summary[0],
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridResponseModel<FundsListPublicReport>> GetFundsListReport(CancellationToken token, ReportGridRequestModel<ListPublicReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundsListPublicReports.FromSqlRaw("EXECUTE dbo.GetFundsListReport {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.AllDB,
                    JoinStrings(model.Filters.Archives),
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetFundsListReportSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.AllDB,
                    JoinStrings(model.Filters.Archives)
                ).ToListAsync(token);

                return new ReportGridResponseModel<FundsListPublicReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows
                };
            }
            catch (SqlException ex)
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundsListPublicReports.FromSqlRaw("EXECUTE dbo.GetFundsListReport {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.Archives),
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetFundsListReportSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                     (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.Archives)
                ).ToListAsync(token);

                return new ReportGridResponseModel<FundsListPublicReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridResponseModel<FundsListReport>> GetFundsListInternalReport(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundsListInternalReports.FromSqlRaw("EXECUTE dbo.GetFundsListInternalReport {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal),
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetFundsListInternalReportSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal)
                ).ToListAsync(token);

                return new ReportGridResponseModel<FundsListReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundsListInternalReports.FromSqlRaw("EXECUTE dbo.GetFundsListInternalReport {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal),
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetFundsListInternalReportSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                     (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal)
                ).ToListAsync(token);

                return new ReportGridResponseModel<FundsListReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<FundDataReportSummary, FundDataPublicReport>> GetFundsDataPublicReport(
            CancellationToken token, ReportGridRequestModel<FundDataPublicReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundDataPublicReports.FromSqlRaw("EXECUTE dbo.GetFundDataPublicReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.AllDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.Filters.LGid,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundDataReportSummaries.FromSqlRaw("EXECUTE dbo.GetFundDataPublicReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.AllDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.Filters.LGid
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundDataReportSummary, FundDataPublicReport>
                {
                    Items = rows,
                    TotalCount = summary[0].Funds,
                    Summary = summary[0]
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception exc)
            {

                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundDataPublicReports.FromSqlRaw("EXECUTE dbo.GetFundDataPublicReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.Filters.LGid,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundDataReportSummaries.FromSqlRaw("EXECUTE dbo.GetFundDataPublicReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.Filters.LGid
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundDataReportSummary, FundDataPublicReport>
                {
                    Items = rows,
                    TotalCount = summary[0].Funds,
                    Summary = summary[0],
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<FundDataReportSummary, FundDataInternalReport>> GetFundsDataInernalReport(
            CancellationToken token, ReportGridRequestModel<FundDataInternalReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundDataInternalReports.FromSqlRaw("EXECUTE dbo.GetFundDataInternalReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.Filters.LGid,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundDataReportSummaries.FromSqlRaw("EXECUTE dbo.GetFundDataInternalReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.Filters.LGid
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundDataReportSummary, FundDataInternalReport>
                {
                    Items = rows,
                    TotalCount = summary[0].Funds,
                    Summary = summary[0]
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundDataInternalReports.FromSqlRaw("EXECUTE dbo.GetFundDataInternalReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20}",
                    _linkedServerSettings.LinkedServer,
                     (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.Filters.LGid,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundDataReportSummaries.FromSqlRaw("EXECUTE dbo.GetFundDataInternalReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.IndustryIndexGids!),
                    JoinStrings(model.Filters.IndustryIndexesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.Filters.LGid
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundDataReportSummary, FundDataInternalReport>
                {
                    Items = rows,
                    TotalCount = summary[0].Funds,
                    Summary = summary[0],
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }


        public async Task<ReportGridWithSummaryGridResponseModel<FundReportSummary2, FundMemoryPublicReport>> GetFundMemoriesPublicReport(CancellationToken token, ReportGridRequestModel<ListPublicReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundMemoryPublicReports.FromSqlRaw("EXECUTE dbo.GetFundMemoryPublicReport {0},{1},{2},{3},{4}",
                   _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.AllDB,
                   JoinStrings(model.Filters.Archives),
                   model.ItemsPerPage,
                   model.Page
               ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.
                var summary = await _context.FundReportsSummaries2.FromSqlRaw("EXECUTE dbo.GetFundMemoryPublicReportSummary {0},{1},{2}",
                     _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.AllDB,
                    JoinStrings(model.Filters.Archives)
                 ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundReportSummary2, FundMemoryPublicReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0]
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception ex)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundMemoryPublicReports.FromSqlRaw("EXECUTE dbo.GetFundMemoryPublicReport {0},{1},{2},{3},{4}",
                   _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                   JoinStrings(model.Filters.Archives),
                   model.ItemsPerPage,
                   model.Page
               ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.
                var summary = await _context.FundReportsSummaries2.FromSqlRaw("EXECUTE dbo.GetFundMemoryPublicReportSummary {0},{1},{2}",
                   _linkedServerSettings.LinkedServer,
                  (int)Shared.ReportResultType.InternalDB,
                  JoinStrings(model.Filters.Archives)
               ).ToListAsync(token);


                return new ReportGridWithSummaryGridResponseModel<FundReportSummary2, FundMemoryPublicReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0],
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<FundMemoriesListInternalReportSummary, FundMemoriesListInternalReport>> GetFundMemoriesListInternalReport(CancellationToken token,
                ReportGridRequestModel<FundMemoriesListInternalReportFiltersModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundMemoriesListInternalReports.FromSqlRaw("EXECUTE dbo.GetFundMemoriesListInternalReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.Statuses!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.


                var summary = await _context.FundMemoriesListInternalReportSummaries.FromSqlRaw("EXECUTE dbo.GetFundMemoriesListInternalReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.Statuses!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundMemoriesListInternalReportSummary, FundMemoriesListInternalReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0]
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundMemoriesListInternalReports.FromSqlRaw("EXECUTE dbo.GetFundMemoriesListInternalReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.Statuses!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundMemoriesListInternalReportSummaries.FromSqlRaw("EXECUTE dbo.GetFundMemoriesListInternalReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.Statuses!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundMemoriesListInternalReportSummary, FundMemoriesListInternalReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0],
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<FundReportSummary2, FundMemoriesListReport>> GetFundMemoriesListReport(
            CancellationToken token, ReportGridRequestModel<ListReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundMemoriesListReports.FromSqlRaw("EXECUTE dbo.GetFundMemoriesListReport {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal),
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundReportsSummaries2.FromSqlRaw("EXECUTE dbo.GetFundMemoriesListReportSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal)
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundReportSummary2, FundMemoriesListReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0],
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.FundMemoriesListReports.FromSqlRaw("EXECUTE dbo.GetFundMemoriesListReport {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal),
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundReportsSummaries2.FromSqlRaw("EXECUTE dbo.GetFundMemoriesListReportSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal)
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundReportSummary2, FundMemoriesListReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0],
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<RegisterOfDigitalObjectsReportSummary, RegisterOfDigitalObjectsPublicReport>>
            GetRegisterOfDigitalObjectsPublicReport(CancellationToken token, ReportGridRequestModel<RegisterOfDigitalObjectsPublicReportInputModel> model)
        {
            int? docLGid = null;
            string? systemIdentifier = null;
            if (model.Filters.SystemId != null && int.TryParse(model.Filters.SystemId, out int parsedInt))
            {
                docLGid = parsedInt;
                systemIdentifier = string.Empty;
            }
            else
            if (model.Filters.SystemId != null && Guid.TryParse(model.Filters.SystemId, out _))
            {
                docLGid = -1;
                systemIdentifier = model.Filters.SystemId;
            }
            else if (model.Filters.SystemId != null)
            {
                // няма да се върне нищо
                docLGid = -1;
                systemIdentifier = string.Empty;
            }

            try
            {
                var rows = await _context.RegisterPublicReports.FromSqlRaw("EXECUTE dbo.GetRegisterOfDigitalObjectsPublicReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                    _linkedServerSettings.LinkedServer!,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.DigitalObjectStatuses!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value,
                    docLGid.HasValue ? docLGid.Value : DBNull.Value,
                    string.IsNullOrWhiteSpace(systemIdentifier) ? DBNull.Value : systemIdentifier,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);

                var summary = await _context.RegisterReportSummaries.FromSqlRaw("EXECUTE dbo.GetRegisterOfDigitalObjectsPublicReportSummary {0},{1},{2},{3},{4},{5},{6},{7}",
                    _linkedServerSettings.LinkedServer!,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.DigitalObjectStatuses!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value,
                    docLGid.HasValue ? docLGid.Value : DBNull.Value,
                    string.IsNullOrWhiteSpace(systemIdentifier) ? DBNull.Value : systemIdentifier
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<RegisterOfDigitalObjectsReportSummary, RegisterOfDigitalObjectsPublicReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0]
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception ex)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }
                return new ReportGridWithSummaryGridResponseModel<RegisterOfDigitalObjectsReportSummary, RegisterOfDigitalObjectsPublicReport>
                {
                    Items = new List<RegisterOfDigitalObjectsPublicReport>(),
                    TotalCount = 0,
                    Summary = new RegisterOfDigitalObjectsReportSummary
                    {
                        TotalBytesCount = 0,
                        TotalDuration = 0,
                        TotalImageCount = 0,
                        TotalRows = 0
                    }
                };
            }
        }

        public async Task<ReportGridResponseSummaryOnlyModel<RegisterOfDigitalObjectsReportSummary>>
           GetRegisterOfDigitalObjectsPublicReportSummary(CancellationToken token, ReportGridRequestModel<RegisterOfDigitalObjectsPublicReportInputModel> model)
        {
            int? docLGid = null;
            string? systemIdentifier = null;
            if (model.Filters.SystemId != null && int.TryParse(model.Filters.SystemId, out int parsedInt))
            {
                docLGid = parsedInt;
                systemIdentifier = string.Empty;
            }
            else
            if (model.Filters.SystemId != null && Guid.TryParse(model.Filters.SystemId, out _))
            {
                docLGid = -1;
                systemIdentifier = model.Filters.SystemId;
            }
            else if (model.Filters.SystemId != null)
            {
                // няма да се върне нищо
                docLGid = -1;
                systemIdentifier = string.Empty;
            }

            try
            {
                var summary = await _context.RegisterReportSummaries.FromSqlRaw("EXECUTE dbo.GetRegisterOfDigitalObjectsPublicReportSummary {0},{1},{2},{3},{4},{5},{6},{7}",
                    _linkedServerSettings.LinkedServer!,
                    (int)Shared.ReportResultType.AllDB,
                    JoinStrings(model.Filters.DigitalObjectStatuses!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value,
                    docLGid.HasValue ? docLGid.Value : DBNull.Value,
                    string.IsNullOrWhiteSpace(systemIdentifier) ? DBNull.Value : systemIdentifier
                ).ToListAsync(token);

                return new ReportGridResponseSummaryOnlyModel<RegisterOfDigitalObjectsReportSummary> { Summary = summary[0] };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception ex)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                var summary = await _context.RegisterReportSummaries.FromSqlRaw("EXECUTE dbo.GetRegisterOfDigitalObjectsPublicReportSummary {0},{1},{2},{3},{4},{5},{6},{7}",
                    _linkedServerSettings.LinkedServer!,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.DigitalObjectStatuses!),
                    JoinStrings(model.Filters.Archives!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value,
                    docLGid.HasValue ? docLGid.Value : DBNull.Value,
                    string.IsNullOrWhiteSpace(systemIdentifier) ? DBNull.Value : systemIdentifier
                ).ToListAsync(token);

                return new ReportGridResponseSummaryOnlyModel<RegisterOfDigitalObjectsReportSummary>
                {
                    Summary = summary[0],
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<FundReportSummary1, PartialReceiptsPublicReport>>
            GetPartialReceiptsPublicReport(CancellationToken token, ReportGridRequestModel<PartialReceiptsPublicReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.PartialReceiptsPublicReports.FromSqlRaw("EXECUTE dbo.GetPartialReceiptsPublicReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.AllDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundReportSummaries1.FromSqlRaw("EXECUTE dbo.GetPartialReceiptsPublicReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.AllDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundReportSummary1, PartialReceiptsPublicReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0]
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception exc)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.PartialReceiptsPublicReports.FromSqlRaw("EXECUTE dbo.GetPartialReceiptsPublicReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundReportSummaries1.FromSqlRaw("EXECUTE dbo.GetPartialReceiptsPublicReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.PeriodGids!),
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodOfAcquisitionGids!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    JoinStrings(model.Filters.StatusGids!),
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.TextDate,
                    model.Filters.DateFrom,
                    model.Filters.DateTo
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundReportSummary1, PartialReceiptsPublicReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0],
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<FundReportSummary1, PartialReceiptsListReport>> GetPartialReceiptsListReport(
            CancellationToken token, ReportGridRequestModel<ListReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.PartialReceiptsListReports.FromSqlRaw("EXECUTE dbo.GetPartialReceiptsListReport {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundReportSummaries1.FromSqlRaw("EXECUTE dbo.GetPartialReceiptsListReportSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundReportSummary1, PartialReceiptsListReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0],
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.PartialReceiptsListReports.FromSqlRaw("EXECUTE dbo.GetPartialReceiptsListReport {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundReportSummaries1.FromSqlRaw("EXECUTE dbo.GetPartialReceiptsListReportSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundReportSummary1, PartialReceiptsListReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0],
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<FundReportSummary2, ReceiptsListReport>> GetReceiptsListReport(
            CancellationToken token, ReportGridRequestModel<ReceiptsListReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.ReceiptsListReports.FromSqlRaw("EXECUTE dbo.GetReceiptsListReport {0},{1},{2},{3},{4},{5},{6}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundReportsSummaries2.FromSqlRaw("EXECUTE dbo.GetReceiptsListReportSummary {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundReportSummary2, ReceiptsListReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0],
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.ReceiptsListReports.FromSqlRaw("EXECUTE dbo.GetReceiptsListReport {0},{1},{2},{3},{4},{5},{6}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.FundReportsSummaries2.FromSqlRaw("EXECUTE dbo.GetReceiptsListReportSummary {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<FundReportSummary2, ReceiptsListReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = summary[0],
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridResponseModel<WorkListForPriorityRestorationReport>> GetWorkListForPriorityRestorationReport(CancellationToken token,
            ReportGridRequestModel<ListReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.WorkListForPriorityRestorationReports.FromSqlRaw("EXECUTE dbo.GetWorkListForPriorityRestorationReport {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetWorkListForPriorityRestorationReportSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);

                return new ReportGridResponseModel<WorkListForPriorityRestorationReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.WorkListForPriorityRestorationReports.FromSqlRaw("EXECUTE dbo.GetWorkListForPriorityRestorationReport {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetWorkListForPriorityRestorationReportSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);

                return new ReportGridResponseModel<WorkListForPriorityRestorationReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridResponseModel<InventoryBook>> GetInventoryBook(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.InventoryBooks.FromSqlRaw("EXECUTE dbo.sp_GetInventoryBook {0},{1},{2},{3}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.sp_GetInventoryBookSummary {0},{1}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType
                ).ToListAsync(token);

                return new ReportGridResponseModel<InventoryBook>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.InventoryBooks.FromSqlRaw("EXECUTE dbo.sp_GetInventoryBook {0},{1},{2},{3}",
                    _linkedServerSettings.LinkedServer,
                     (int)Shared.ReportResultType.InternalDB,
                    model.ItemsPerPage,
                    model.Page
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.sp_GetInventoryBookSummary {0},{1}",
                    _linkedServerSettings.LinkedServer,
                     (int)Shared.ReportResultType.InternalDB
                ).ToListAsync(token);

                return new ReportGridResponseModel<InventoryBook>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridResponseModel<AccountAndDescriptionOfFilmDocumentsBook>> GetAccountAndDescriptionOfFilmDocumentsBook(CancellationToken token,
            ReportGridRequestModel<ListReportInputModel> model)
        {
            try
            {

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.AccountAndDescriptionOfFilmDocumentsBooks.FromSqlRaw("EXECUTE dbo.GetAccountAndDescriptionOfFilmDocumentsBook {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetAccountAndDescriptionOfFilmDocumentsBookSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);

                return new ReportGridResponseModel<AccountAndDescriptionOfFilmDocumentsBook>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.AccountAndDescriptionOfFilmDocumentsBooks.FromSqlRaw("EXECUTE dbo.GetAccountAndDescriptionOfFilmDocumentsBook {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetAccountAndDescriptionOfFilmDocumentsBookSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);

                return new ReportGridResponseModel<AccountAndDescriptionOfFilmDocumentsBook>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridResponseModel<InsuranceFundOfCopiesOfForeignArchives>> GetInsuranceFundOfCopiesOfForeignArchives(CancellationToken token,
            ReportGridRequestModel<ListReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.InsuranceFundsOfCopiesOfForeignArchives.FromSqlRaw("EXECUTE dbo.GetInsuranceFundOfCopiesOfForeignArchives {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetInsuranceFundOfCopiesOfForeignArchivesSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);

                return new ReportGridResponseModel<InsuranceFundOfCopiesOfForeignArchives>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.InsuranceFundsOfCopiesOfForeignArchives.FromSqlRaw("EXECUTE dbo.GetInsuranceFundOfCopiesOfForeignArchives {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                     (int)Shared.ReportResultType.InternalDB,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);
#pragma warning restore CS8604 // Possible null reference argument.

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetInsuranceFundOfCopiesOfForeignArchivesSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                     (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);

                return new ReportGridResponseModel<InsuranceFundOfCopiesOfForeignArchives>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };

            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        private static string JoinStrings(IList<string> strings) => string.Join(",", strings);

        public async Task<ReportGridResponseModel<InventoryBookOfCopiesFromForeignArchives>> GetInventoryBookOfCopiesFromForeignArchives(CancellationToken token,
            ReportGridRequestModel<ListReportInputModel> model)
        {
            try
            {

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.InventoryBookOfCopiesFromForeignArchives.FromSqlRaw("EXECUTE dbo.sp_GetInventoryBookOfCopiesFromForeignArchivesReport {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                    Convert.ToInt32(model.Filters.ReportResultType),
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);

#pragma warning restore CS8604 // Possible null reference argument.
                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.sp_GetInventoryBookOfCopiesFromForeignArchivesSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    model.Filters.ReportResultType,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);
                return new ReportGridResponseModel<InventoryBookOfCopiesFromForeignArchives>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.InventoryBookOfCopiesFromForeignArchives.FromSqlRaw("EXECUTE dbo.sp_GetInventoryBookOfCopiesFromForeignArchivesReport {0},{1},{2},{3},{4}",
                    _linkedServerSettings.LinkedServer,
                   (int)Shared.ReportResultType.InternalDB,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);

#pragma warning restore CS8604 // Possible null reference argument.
                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.sp_GetInventoryBookOfCopiesFromForeignArchivesSummary {0},{1},{2}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                ).ToListAsync(token);

                return new ReportGridResponseModel<InventoryBookOfCopiesFromForeignArchives>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<CompilationAndNTOOfEDocumentsCombined, CompilationAndNTOOfEDocumentsReport>> GetCompilationAndNTOOfEDocuments(CancellationToken token,
            ReportGridRequestModel<CompilationAndNTOOfEDocumentsInputModel> model)
        {
            if (model.Filters.FileFormats!.ToArray().Length == 0)
            {
                model.Filters.FileFormats = new List<string>() { DropdownOptionCodeSellectAll };
            };
            if (model.Filters.FundLevelOfdescriptionCodes!.ToArray().Length == 0) { model.Filters.FundLevelOfdescriptionCodes = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.FundTypesInternal!.ToArray().Length == 0) { model.Filters.FundTypesInternal = new List<string>() { DropdownOptionCodeSellectAll }; };
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.CompilationAndNTOOfEDocumentsReport.FromSqlRaw("EXECUTE dbo.sp_GetCompilationAndNTOOfEDocumentsReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    model.Filters.ProcessStartDate,
                    model.Filters.ProcessEndDate,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ProcessTypes!),
                    JoinStrings(model.Filters.FileFormats!),
                    JoinStrings(model.Filters.FundLevelOfdescriptionCodes!)
                ).ToListAsync(token);

                foreach (var row in rows)
                {
                    row.DateOfFiling = row.DateOfFiling.UtcToLocalTime();
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var summary = await _context.CompilationAndNTOOfEDocumentsSummary.FromSqlRaw("EXECUTE dbo.sp_GetCompilationAndNTOOfEDocumentsSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    model.Filters.ProcessStartDate,
                    model.Filters.ProcessEndDate,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ProcessTypes!),
                    JoinStrings(model.Filters.FileFormats!),
                    JoinStrings(model.Filters.FundLevelOfdescriptionCodes!)
                ).ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var combined = await _context.CompilationAndNTOOfEDocumentsCombined.FromSqlRaw("EXECUTE dbo.sp_GetCompilationAndNTOOfEDocumentsCombinedData {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.FundArraysInternal!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    JoinStrings(model.Filters.MethodsOfAcquisitionInternal!),
                    model.Filters.RegisteredFrom != null
                        ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                        : DBNull.Value,
                    model.Filters.RegisteredTo != null
                        ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                        : DBNull.Value,
                    model.Filters.ProcessStartDate,
                    model.Filters.ProcessEndDate,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.DateFrom,
                    model.Filters.DateTo,
                    JoinStrings(model.Filters.StatusesInternal!),
                    JoinStrings(model.Filters.ProcessTypes!),
                    JoinStrings(model.Filters.FileFormats!),
                    JoinStrings(model.Filters.FundLevelOfdescriptionCodes!)
                ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<CompilationAndNTOOfEDocumentsCombined, CompilationAndNTOOfEDocumentsReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = combined.ToArray().Length > 0
                            ? combined[0]
                            : new CompilationAndNTOOfEDocumentsCombined { }
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<RegisterOfDigitizedDocumentsSummaryAndCombined> GetRegisterOfDigitizedDocumentsReportSummary(CancellationToken token,
            ReportGridRequestModel<RegisterOfDigitizedDocumentsReportInputModel> model)
        {
            //К.Манов по желание на ИСДА справката ще работи само за с данни от СЕА!
            model.Filters.ReportResultType = 3;

            try
            {


                var summary = await _context.RegisterOfDigitizedDocumentsSummary.FromSqlRaw("EXECUTE dbo.sp_GetRegisterOfDigitizedDocumentsSummary {0},{1},{2},{3},{4},{5},{6}",
                    _linkedServerSettings.LinkedServer,
                    Convert.ToInt32(model.Filters.ReportResultType),
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value
                    ).ToListAsync(token);

                var combined = await _context.RegisterOfDigitizedDocumentsCombined.FromSqlRaw("EXECUTE dbo.sp_GetRegisterOfDigitizedDocumentsCombined {0},{1},{2},{3},{4},{5},{6}",
                    _linkedServerSettings.LinkedServer,
                    Convert.ToInt32(model.Filters.ReportResultType),
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value
                    ).ToListAsync(token);

                return new RegisterOfDigitizedDocumentsSummaryAndCombined()
                {
                    Summary = summary.ToArray().Length > 0
                            ? summary[0]
                            : new RegisterOfDigitizedDocumentsSummary { },
                    Combined = combined.ToArray().Length > 0
                            ? combined[0]
                            : new RegisterOfDigitizedDocumentsCombined { },
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

                var summary = await _context.RegisterOfDigitizedDocumentsSummary.FromSqlRaw("EXECUTE dbo.sp_GetRegisterOfDigitizedDocumentsSummary {0},{1},{2},{3},{4},{5},{6}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value
                    ).ToListAsync(token);


                var combined = await _context.RegisterOfDigitizedDocumentsCombined.FromSqlRaw("EXECUTE dbo.sp_GetRegisterOfDigitizedDocumentsCombined {0},{1},{2},{3},{4},{5},{6}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value
                    ).ToListAsync(token);

                return new RegisterOfDigitizedDocumentsSummaryAndCombined()
                {
                    Summary = summary.ToArray().Length > 0
                            ? summary[0]
                            : new RegisterOfDigitizedDocumentsSummary { },
                    Combined = combined.ToArray().Length > 0
                            ? combined[0]
                            : new RegisterOfDigitizedDocumentsCombined { },
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<RegisterOfDigitizedDocumentsSummaryAndCombined, RegisterOfDigitizedDocumentsReport>> GetRegisterOfDigitizedDocumentsReport(CancellationToken token,
            ReportGridRequestModel<RegisterOfDigitizedDocumentsReportInputModel> model)
        {
            //По желание на ИСДА справката е само за системата на СЕА
            model.Filters.ReportResultType = 3;

            try
            {

                var rows = await _context.RegisterOfDigitizedDocumentsReport.FromSqlRaw("EXECUTE dbo.sp_GetRegisterOfDigitizedDocumentsReport {0},{1},{2},{3},{4},{5},{6}",
                    _linkedServerSettings.LinkedServer,
                    Convert.ToInt32(model.Filters.ReportResultType),
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value
                    ).ToListAsync(token);


                var summary = await _context.RegisterOfDigitizedDocumentsSummary.FromSqlRaw("EXECUTE dbo.sp_GetRegisterOfDigitizedDocumentsSummary {0},{1},{2},{3},{4},{5},{6}",
                    _linkedServerSettings.LinkedServer,
                    Convert.ToInt32(model.Filters.ReportResultType),
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value
                    ).ToListAsync(token);

                var combined = await _context.RegisterOfDigitizedDocumentsCombined.FromSqlRaw("EXECUTE dbo.sp_GetRegisterOfDigitizedDocumentsCombined {0},{1},{2},{3},{4},{5},{6}",
                    _linkedServerSettings.LinkedServer,
                    Convert.ToInt32(model.Filters.ReportResultType),
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value
                    ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<RegisterOfDigitizedDocumentsSummaryAndCombined, RegisterOfDigitizedDocumentsReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = new RegisterOfDigitizedDocumentsSummaryAndCombined
                    {
                        Summary = summary.ToArray().Length > 0
                            ? summary[0]
                            : new RegisterOfDigitizedDocumentsSummary { },
                        Combined = combined.ToArray().Length > 0
                            ? combined[0]
                            : new RegisterOfDigitizedDocumentsCombined { },
                    },


                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }


                var rows = await _context.RegisterOfDigitizedDocumentsReport.FromSqlRaw("EXECUTE dbo.sp_GetRegisterOfDigitizedDocumentsReport {0},{1},{2},{3},{4},{5},{6}",
                    _linkedServerSettings.LinkedServer,
                   (int)Shared.ReportResultType.InternalDB,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value
                    ).ToListAsync(token);


                var summary = await _context.RegisterOfDigitizedDocumentsSummary.FromSqlRaw("EXECUTE dbo.sp_GetRegisterOfDigitizedDocumentsSummary {0},{1},{2},{3},{4},{5},{6}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value
                    ).ToListAsync(token);


                var combined = await _context.RegisterOfDigitizedDocumentsCombined.FromSqlRaw("EXECUTE dbo.sp_GetRegisterOfDigitizedDocumentsCombined {0},{1},{2},{3},{4},{5},{6}",
                    _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    model.Filters.RegisteredFrom.HasValue
                        ? model.Filters.RegisteredFrom.Value
                        : DBNull.Value,
                    model.Filters.RegisteredTo.HasValue
                        ? model.Filters.RegisteredTo.Value
                        : DBNull.Value
                    ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<RegisterOfDigitizedDocumentsSummaryAndCombined, RegisterOfDigitizedDocumentsReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = new RegisterOfDigitizedDocumentsSummaryAndCombined
                    {
                        Summary = summary.ToArray().Length > 0
                            ? summary[0]
                            : new RegisterOfDigitizedDocumentsSummary { },
                        Combined = combined.ToArray().Length > 0
                            ? combined[0]
                            : new RegisterOfDigitizedDocumentsCombined { },
                    },
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined, CountOfUsedCopiesOfDocumentsFromForeignArchivesReport>> GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport(CancellationToken token, ReportGridRequestModel<CountOfUsedCopiesOfDocumentsFromForeignArchivesReportInputModel> model)
        {
            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.CountOfUsedCopiesOfDocumentsFromForeignArchivesReport.FromSqlRaw("EXECUTE dbo.sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport {0},{1},{2},{3},{4}",
                     _linkedServerSettings.LinkedServer,
                    Convert.ToInt32(model.Filters.ReportResultType),
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                    ).ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var summary = await _context.CountOfUsedCopiesOfDocumentsFromForeignArchivesSummary.FromSqlRaw("EXECUTE dbo.sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesSummary {0},{1},{2},{3},{4}",
                     _linkedServerSettings.LinkedServer,
                    Convert.ToInt32(model.Filters.ReportResultType),
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                    ).ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var combined = await _context.CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined.FromSqlRaw("EXECUTE dbo.sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesCombined {0},{1},{2},{3},{4}",
                     _linkedServerSettings.LinkedServer,
                    Convert.ToInt32(model.Filters.ReportResultType),
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                    ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined, CountOfUsedCopiesOfDocumentsFromForeignArchivesReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = combined.ToArray().Length > 0
                            ? combined[0]
                            : new CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined { }
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var rows = await _context.CountOfUsedCopiesOfDocumentsFromForeignArchivesReport.FromSqlRaw("EXECUTE dbo.sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport {0},{1},{2},{3},{4}",
                     _linkedServerSettings.LinkedServer,
                     (int)Shared.ReportResultType.InternalDB,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                    ).ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var summary = await _context.CountOfUsedCopiesOfDocumentsFromForeignArchivesSummary.FromSqlRaw("EXECUTE dbo.sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesSummary {0},{1},{2},{3},{4}",
                     _linkedServerSettings.LinkedServer,
                    (int)Shared.ReportResultType.InternalDB,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                    ).ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var combined = await _context.CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined.FromSqlRaw("EXECUTE dbo.sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesCombined {0},{1},{2},{3},{4}",
                     _linkedServerSettings.LinkedServer,
                     (int)Shared.ReportResultType.InternalDB,
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodesInternal!)
                    ).ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined, CountOfUsedCopiesOfDocumentsFromForeignArchivesReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = combined.ToArray().Length > 0
                            ? combined[0]
                            : new CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined { },
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }
        public async Task<ReportGridWithSummaryGridResponseModel<QualityControlCombined, QualityControlReport>> GetQualityControlReport(CancellationToken token, ReportGridRequestModel<WorkDoneOnDigitalObjectsCombinedReportInputModel> model)
        {
#pragma warning disable CS8604 // Possible null reference argument.
            var rows = await _context.QualityControlReport.FromSqlRaw("EXECUTE dbo.sp_GetQualityControlReport {0},{1},{2},{3},{4},{5},{6}",
                model.ItemsPerPage,
                model.Page,
                JoinStrings(model.Filters.ArchiveCodes!),
                JoinStrings(model.Filters.Statuses!),
                JoinStrings(model.Filters.Employees!),
                model.Filters.DateFrom,
                model.Filters.DateTo
                ).ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
            var combined = await _context.QualityControlCombined.FromSqlRaw("EXECUTE dbo.sp_GetQualityControlCombined {0},{1},{2},{3},{4},{5},{6}",
                model.ItemsPerPage,
                model.Page,
                JoinStrings(model.Filters.ArchiveCodes!),
                JoinStrings(model.Filters.Statuses!),
                JoinStrings(model.Filters.Employees!),
                model.Filters.DateFrom,
                model.Filters.DateTo
                ).ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
            var summary = await _context.QualityControlSummary.FromSqlRaw("EXECUTE dbo.sp_GetQualityControlSummary {0},{1},{2},{3},{4},{5},{6}",
                model.ItemsPerPage,
                model.Page,
                JoinStrings(model.Filters.ArchiveCodes!),
                JoinStrings(model.Filters.Statuses!),
                JoinStrings(model.Filters.Employees!),
                model.Filters.DateFrom,
                model.Filters.DateTo
                ).ToListAsync(token);

            return new ReportGridWithSummaryGridResponseModel<QualityControlCombined, QualityControlReport>
            {
                Items = rows,
                TotalCount = summary[0].TotalRows,
                Summary = combined.ToArray().Length > 0
                            ? combined[0]
                            : new QualityControlCombined { }
            };
        }

        public async Task<ReportGridWithSummaryGridResponseModel<DigitalObjectsPreparationCombined, DigitalObjectsPreparationReport>> GetDigitalObjectsPreparationReport(CancellationToken token, ReportGridRequestModel<WorkDoneOnDigitalObjectsCombinedReportInputModel> model)
        {
#pragma warning disable CS8604 // Possible null reference argument.
            var rows = await _context.DigitalObjectsPreparationReport.FromSqlRaw("EXECUTE dbo.sp_GetDigitalObjectsPreparationReport {0},{1},{2},{3},{4},{5},{6}",
                model.ItemsPerPage,
                model.Page,
                JoinStrings(model.Filters.ArchiveCodes!),
                JoinStrings(model.Filters.Statuses!),
                JoinStrings(model.Filters.Employees!),
                model.Filters.DateFrom,
                model.Filters.DateTo
                ).ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
            var combined = await _context.DigitalObjectsPreparationCombined.FromSqlRaw("EXECUTE dbo.sp_GetDigitalObjectsPreparationCombined {0},{1},{2},{3},{4},{5},{6}",
                model.ItemsPerPage,
                model.Page,
                JoinStrings(model.Filters.ArchiveCodes!),
                JoinStrings(model.Filters.Statuses!),
                JoinStrings(model.Filters.Employees!),
                model.Filters.DateFrom,
                model.Filters.DateTo
                ).ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
            var summary = await _context.DigitalObjectsPreparationSummary.FromSqlRaw("EXECUTE dbo.sp_GetDigitalObjectsPreparationSummary {0},{1},{2},{3},{4},{5},{6}",
                model.ItemsPerPage,
                model.Page,
                JoinStrings(model.Filters.ArchiveCodes!),
                JoinStrings(model.Filters.Statuses!),
                JoinStrings(model.Filters.Employees!),
                model.Filters.DateFrom,
                model.Filters.DateTo
                ).ToListAsync(token);

            return new ReportGridWithSummaryGridResponseModel<DigitalObjectsPreparationCombined, DigitalObjectsPreparationReport>
            {
                Items = rows,
                TotalCount = summary[0].TotalRows,
                Summary = combined.ToArray().Length > 0
                            ? combined[0]
                            : new DigitalObjectsPreparationCombined { }
            };
        }

        public async Task<ReportGridResponseModel<SpecialRegistrationListReport>> GetSpecialRegistrationListReport(CancellationToken token,
            ReportGridRequestModel<SpecialRegistrationListReportInputModel> model)
        {
            try
            {
                var rows = await _context.SpecialRegistrationLists.FromSqlRaw("EXECUTE dbo.GetSpecialRegistrationListReport {0},{1},{2},{3},{4},{5},{6},{7},{8}",
                        _linkedServerSettings.LinkedServer,
                        JoinStrings(model.Filters.ArchiveGids),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                        model.Filters.ArchiveEntityNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        model.Filters.IsInRisk,
                        JoinStrings(model.Filters.DescriptionLevel),
                        model.ItemsPerPage,
                        model.Page)
                    .ToListAsync(token);

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetSpecialRegistrationListReportSummary {0},{1},{2},{3},{4},{5},{6}",
                        _linkedServerSettings.LinkedServer,
                        JoinStrings(model.Filters.ArchiveGids),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                        model.Filters.ArchiveEntityNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        model.Filters.IsInRisk,
                        JoinStrings(model.Filters.DescriptionLevel))
                    .ToListAsync(token);

                return new ReportGridResponseModel<SpecialRegistrationListReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows
                };
            }
            catch (SqlException)
            {
                return new ReportGridResponseModel<SpecialRegistrationListReport>
                {
                    Items = new List<SpecialRegistrationListReport> { },
                    TotalCount = 0,
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }
        public async Task<ReportGridWithSummaryGridResponseModel<NumberOfArchiveEntitiesOrderedByReaderCombined, NumberOfArchiveEntitiesOrderedByReaderReport>> GetNumberOfArchiveEntitiesOrderedByReaderReport(ReportGridRequestModel<NumberOfArchiveEntitiesOrderedByReaderInputModel> model)
        {
            //model.ItemsPerPage = Int32.MaxValue;
            var rows = new List<NumberOfArchiveEntitiesOrderedByReaderReport>();
            if (model.Filters.InventoryGids.ToArray().Length == 0) { model.Filters.InventoryGids = new List<string>() { "0" }; };
            if (model.Filters.InventoryInternal.ToArray().Length == 0) { model.Filters.InventoryInternal = new List<string>() { "0" }; };
            if (model.Filters.FundTypeGids.ToArray().Length == 0) { model.Filters.FundTypeGids = new List<string>() { "0" }; };
            if (model.Filters.FundTypesInternal.ToArray().Length == 0) { model.Filters.FundTypesInternal = new List<string>() { "0" }; };

#pragma warning disable CS8604 // Possible null reference argument.
            if (model.Filters.StatisticDataOnly == false)
            {
                rows = await _context.NumberOfArchiveEntitiesOrderedByReaderReport.FromSqlRaw("EXECUTE dbo.sp_GetNumberOfArchiveEntitiesOrderedByReaderReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13}",
                 _linkedServerSettings.LinkedServer,
                Convert.ToInt32(model.Filters.ReportResultType),
                model.ItemsPerPage,
                model.Page,
                JoinStrings(model.Filters.ArchiveCodesInternal!),
                JoinStrings(model.Filters.InventoryGids),
                JoinStrings(model.Filters.InventoryInternal),
                model.Filters.DateFrom!,
                JoinStrings(model.Filters.ArchiveEntitiesDescriptionLevelsGids!),
                JoinStrings(model.Filters.ArchiveEntitiesDescriptionLevelsInternal!),
                JoinStrings(model.Filters.FundTypeGids),
                JoinStrings(model.Filters.FundTypesInternal),
                model.Filters.DateTo!,
                model.Filters.StatisticDataOnly!
                ).ToListAsync();
            }

#pragma warning disable CS8604 // Possible null reference argument.
            var summary = await _context.NumberOfArchiveEntitiesOrderedByReaderSummary.FromSqlRaw("EXECUTE dbo.sp_GetNumberOfArchiveEntitiesOrderedByReaderSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13}",
                 _linkedServerSettings.LinkedServer,
                Convert.ToInt32(model.Filters.ReportResultType),
                model.ItemsPerPage,
                model.Page,
                JoinStrings(model.Filters.ArchiveCodesInternal!),
                JoinStrings(model.Filters.InventoryGids),
                JoinStrings(model.Filters.InventoryInternal),
                model.Filters.DateFrom!,
                JoinStrings(model.Filters.ArchiveEntitiesDescriptionLevelsGids!),
                JoinStrings(model.Filters.ArchiveEntitiesDescriptionLevelsInternal!),
                JoinStrings(model.Filters.FundTypeGids),
                JoinStrings(model.Filters.FundTypesInternal),
                model.Filters.DateTo!,
                model.Filters.StatisticDataOnly!
                ).ToListAsync();

#pragma warning disable CS8604 // Possible null reference argument.
            var combined = await _context.NumberOfArchiveEntitiesOrderedByReaderCombined.FromSqlRaw("EXECUTE dbo.sp_GetNumberOfArchiveEntitiesOrderedByReaderCombined {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13}",
                 _linkedServerSettings.LinkedServer,
                Convert.ToInt32(model.Filters.ReportResultType),
                model.ItemsPerPage,
                model.Page,
                JoinStrings(model.Filters.ArchiveCodesInternal!),
                JoinStrings(model.Filters.InventoryGids),
                JoinStrings(model.Filters.InventoryInternal),
                model.Filters.DateFrom!,
                JoinStrings(model.Filters.ArchiveEntitiesDescriptionLevelsGids!),
                JoinStrings(model.Filters.ArchiveEntitiesDescriptionLevelsInternal!),
                JoinStrings(model.Filters.FundTypeGids),
                JoinStrings(model.Filters.FundTypesInternal),
                model.Filters.DateTo!,
                model.Filters.StatisticDataOnly!
                ).ToListAsync();

            return new ReportGridWithSummaryGridResponseModel<NumberOfArchiveEntitiesOrderedByReaderCombined, NumberOfArchiveEntitiesOrderedByReaderReport>
            {
                Items = rows,
                TotalCount = summary[0].TotalRows,
                Summary = combined.ToArray().Length > 0
                        ? combined[0]
                        : new NumberOfArchiveEntitiesOrderedByReaderCombined { }
            };
        }

        public async Task<ReportGridWithSummaryGridResponseModel<NumberOfArchiveEntitiesOrderedByEmployeeCombined, NumberOfArchiveEntitiesOrderedByEmployeeReport>> GetNumberOfArchiveEntitiesOrderedByEmployeeReport(ReportGridRequestModel<NumberOfArchiveEntitiesOrderedByEmployeeInputModel> model)
        {
            try
            {
                //model.ItemsPerPage = Int32.MaxValue;
                var rows = new List<NumberOfArchiveEntitiesOrderedByEmployeeReport>();
                if (model.Filters.InventoryGids.ToArray().Length == 0) { model.Filters.InventoryGids = new List<string>() { "0" }; };
                if (model.Filters.InventoryInternal.ToArray().Length == 0) { model.Filters.InventoryInternal = new List<string>() { "0" }; };
                if (model.Filters.FundTypeGids.ToArray().Length == 0) { model.Filters.FundTypeGids = new List<string>() { "0" }; };
                if (model.Filters.FundTypesInternal.ToArray().Length == 0) { model.Filters.FundTypesInternal = new List<string>() { "0" }; };
#pragma warning disable CS8604 // Possible null reference argument.
                if (model.Filters.StatisticDataOnly == false)
                {
                    rows = await _context.NumberOfArchiveEntitiesOrderedByEmployeeReport.FromSqlRaw("EXECUTE dbo.sp_GetNumberOfArchiveEntitiesOrderedByEmployeeReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                     _linkedServerSettings.LinkedServer,
                    Convert.ToInt32(model.Filters.ReportResultType),
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.EmployeeNamesGids!),
                    JoinStrings(model.Filters.EmployeeNamesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    JoinStrings(model.Filters.InventoryGids!),
                    JoinStrings(model.Filters.InventoryInternal!),
                    model.Filters.DateFrom!,
                    JoinStrings(model.Filters.AchiveEntitiesDescriptionLevelsGids!),
                    JoinStrings(model.Filters.AchiveEntitiesDescriptionLevelsInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    model.Filters.DateTo!,
                    model.Filters.StatisticDataOnly!
                    ).ToListAsync();
                }

#pragma warning disable CS8604 // Possible null reference argument.
                var summary = await _context.NumberOfArchiveEntitiesOrderedByEmployeeSummary.FromSqlRaw("EXECUTE dbo.sp_GetNumberOfArchiveEntitiesOrderedByEmployeeSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                     _linkedServerSettings.LinkedServer,
                    Convert.ToInt32(model.Filters.ReportResultType),
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.EmployeeNamesGids!),
                    JoinStrings(model.Filters.EmployeeNamesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    JoinStrings(model.Filters.InventoryGids!),
                    JoinStrings(model.Filters.InventoryInternal!),
                    model.Filters.DateFrom!,
                    JoinStrings(model.Filters.AchiveEntitiesDescriptionLevelsGids!),
                    JoinStrings(model.Filters.AchiveEntitiesDescriptionLevelsInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    model.Filters.DateTo!,
                    model.Filters.StatisticDataOnly!
                    ).ToListAsync();

#pragma warning disable CS8604 // Possible null reference argument.
                var combined = await _context.NumberOfArchiveEntitiesOrderedByEmployeeCombined.FromSqlRaw("EXECUTE dbo.sp_GetNumberOfArchiveEntitiesOrderedByEmployeeCombined {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                     _linkedServerSettings.LinkedServer,
                    Convert.ToInt32(model.Filters.ReportResultType),
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.EmployeeNamesGids!),
                    JoinStrings(model.Filters.EmployeeNamesInternal!),
                    JoinStrings(model.Filters.ArchiveCodesInternal!),
                    JoinStrings(model.Filters.InventoryGids!),
                    JoinStrings(model.Filters.InventoryInternal!),
                    model.Filters.DateFrom!,
                    JoinStrings(model.Filters.AchiveEntitiesDescriptionLevelsGids!),
                    JoinStrings(model.Filters.AchiveEntitiesDescriptionLevelsInternal!),
                    JoinStrings(model.Filters.FundTypeGids!),
                    JoinStrings(model.Filters.FundTypesInternal!),
                    model.Filters.DateTo!,
                    model.Filters.StatisticDataOnly!
                    ).ToListAsync();

                return new ReportGridWithSummaryGridResponseModel<NumberOfArchiveEntitiesOrderedByEmployeeCombined, NumberOfArchiveEntitiesOrderedByEmployeeReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = combined.ToArray().Length > 0
                        ? combined[0]
                        : new NumberOfArchiveEntitiesOrderedByEmployeeCombined { }
                };
            }
            catch (SqlException)
            {
                return new ReportGridWithSummaryGridResponseModel<NumberOfArchiveEntitiesOrderedByEmployeeCombined, NumberOfArchiveEntitiesOrderedByEmployeeReport>
                {
                    Items = new List<NumberOfArchiveEntitiesOrderedByEmployeeReport> { },
                    TotalCount = 0,
                    Summary = new NumberOfArchiveEntitiesOrderedByEmployeeCombined { },
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
        }

        public async Task<ReportGridResponseModel<MostUsedRequestEntitiesReport>> GetMostUsedRequestEntitiesReport(CancellationToken token,
            ReportGridRequestModel<MostUsedRequestEntitiesReportInputModel> model)
        {
            var descriptionLevelsSplit = SplitDescriptionLevels((List<string>?)model.Filters.DescriptionLevels);

            var descriptionLevelsExternalParam = model.Filters.ReportResultType != (int)Shared.ReportResultType.ExternalDB

                ? JoinStrings(model.Filters.DescriptionLevelsExternal)
                : JoinStrings(descriptionLevelsSplit[_descriptionLevelsDictionaryExternal]);

            var descriptionLevelsFundParam = JoinStrings(descriptionLevelsSplit[_descriptionLevelsDictionaryFundInternal]);
            var descriptionLevelsInventoryParam = JoinStrings(descriptionLevelsSplit[_descriptionLevelsDictionaryInventoryInternal]);
            var descriptionLevelsArchivalEntityParam = JoinStrings(descriptionLevelsSplit[_descriptionLevelsDictionaryArchivalEntityInternal]);
            var descriptionLevelsDocumentParam = JoinStrings(descriptionLevelsSplit[_descriptionLevelsDictionaryDocumentInternal]);

            try
            {
                var rows = await _context.MostUsedRequestEntitiesReport.FromSqlRaw("EXECUTE dbo.GetMostUsedRequestEntitiesReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                        JoinStrings(model.Filters.Archives),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                        model.Filters.ArchiveEntityNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        model.Filters.DocumentNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        descriptionLevelsExternalParam,
                        descriptionLevelsFundParam,
                        descriptionLevelsInventoryParam,
                        descriptionLevelsArchivalEntityParam,
                        descriptionLevelsDocumentParam,
                        model.ItemsPerPage,
                        model.Page)
                    .ToListAsync(token);

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetMostUsedRequestEntitiesReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                        JoinStrings(model.Filters.Archives),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                        model.Filters.ArchiveEntityNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        model.Filters.DocumentNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        descriptionLevelsExternalParam,
                        descriptionLevelsFundParam,
                        descriptionLevelsInventoryParam,
                        descriptionLevelsArchivalEntityParam,
                        descriptionLevelsDocumentParam)
                    .ToListAsync(token);

                var usageCountTotalSummary = await _context.UsageCountTotalSummary.FromSqlRaw("EXECUTE dbo.GetMostUsedRequestEntitiesReportTotalCount {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                        JoinStrings(model.Filters.Archives),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                        model.Filters.ArchiveEntityNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        model.Filters.DocumentNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        descriptionLevelsExternalParam,
                        descriptionLevelsFundParam,
                        descriptionLevelsInventoryParam,
                        descriptionLevelsArchivalEntityParam,
                        descriptionLevelsDocumentParam)
                    .ToListAsync(token);

                return new ReportGridResponseModel1<MostUsedRequestEntitiesReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    UsageCountTotal = usageCountTotalSummary[0].UsageCountTotal
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

                var rows = await _context.MostUsedRequestEntitiesReport.FromSqlRaw("EXECUTE dbo.GetMostUsedRequestEntitiesReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13}",
                      _linkedServerSettings.LinkedServer,
                      (int)Shared.ReportResultType.InternalDB,
                      JoinStrings(model.Filters.Archives),
                      model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                      model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                      model.Filters.ArchiveEntityNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                      model.Filters.DocumentNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                      descriptionLevelsExternalParam,
                      descriptionLevelsFundParam,
                      descriptionLevelsInventoryParam,
                      descriptionLevelsArchivalEntityParam,
                      descriptionLevelsDocumentParam,
                      model.ItemsPerPage,
                      model.Page)
                  .ToListAsync(token);

                var summary = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetMostUsedRequestEntitiesReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        JoinStrings(model.Filters.Archives),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                        model.Filters.ArchiveEntityNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        model.Filters.DocumentNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        descriptionLevelsExternalParam,
                        descriptionLevelsFundParam,
                        descriptionLevelsInventoryParam,
                        descriptionLevelsArchivalEntityParam,
                        descriptionLevelsDocumentParam)
                    .ToListAsync(token);

                var usageCountTotalSummary = await _context.UsageCountTotalSummary.FromSqlRaw("EXECUTE dbo.GetMostUsedRequestEntitiesReportTotalCount {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        JoinStrings(model.Filters.Archives),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                        model.Filters.ArchiveEntityNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        model.Filters.DocumentNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        descriptionLevelsExternalParam,
                        descriptionLevelsFundParam,
                        descriptionLevelsInventoryParam,
                        descriptionLevelsArchivalEntityParam,
                        descriptionLevelsDocumentParam)
                    .ToListAsync(token);

                return new ReportGridResponseModel1<MostUsedRequestEntitiesReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    UsageCountTotal = usageCountTotalSummary[0].UsageCountTotal,
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<NumberOfDocumentsOrderedByReaderReportCombined, NumberOfDocumentsOrderedByReaderReport>> GeNumberOfDocumentsOrderedByReaderReport(CancellationToken token, ReportGridRequestModel<NumberOfDocumentsOrderedByReaderReportInputModel> model)
        {
            var rows = new List<NumberOfDocumentsOrderedByReaderReport>();
            if (model.Filters.ArchiveCodes.ToArray().Length == 0) { model.Filters.ArchiveCodes = new List<string>() { "0" }; };
            if (model.Filters.FundLevelOfdescriptionCodes.ToArray().Length == 0) { model.Filters.FundLevelOfdescriptionCodes = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.LibraryCardNumber == null) { model.Filters.LibraryCardNumber = DropdownOptionCodeSellectAll; };
#pragma warning disable CS8604 // Possible null reference argument.
            if (model.Filters.StatisticDataOnly == false)
            {
                rows = await _context.NumberOfDocumentsOrderedByReaderReport.FromSqlRaw("EXECUTE dbo.sp_GetNumberOfDocumentsOrderedByReaderReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                     model.ItemsPerPage,
                     model.Page,
                     JoinStrings(model.Filters.ArchiveCodes),
                     model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                     JoinStrings(model.Filters.FundLevelOfdescriptionCodes),
                     model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                     model.Filters.LibraryCardNumber != null ? model.Filters.LibraryCardNumber : DBNull.Value,
                     model.Filters.DateFrom != null ? model.Filters.DateFrom : DBNull.Value,
                     model.Filters.DateTo != null ? model.Filters.DateTo : DBNull.Value,
                     model.Filters.StatisticDataOnly)
                 .ToListAsync(token);
            }

            foreach (var row in rows)
            {
                row.AccessDate = row.AccessDate.UtcToLocalTime();
            }

#pragma warning disable CS8604 // Possible null reference argument.
            var combined = await _context.NumberOfDocumentsOrderedByReaderReportCombined.FromSqlRaw("EXECUTE dbo.sp_GetNumberOfDocumentsOrderedByReaderReportCombined {0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodes),
                    model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                    JoinStrings(model.Filters.FundLevelOfdescriptionCodes),
                    model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                    model.Filters.LibraryCardNumber != null ? model.Filters.LibraryCardNumber : DBNull.Value,
                    model.Filters.DateFrom != null ? model.Filters.DateFrom.ToString() : DBNull.Value,
                    model.Filters.DateTo != null ? model.Filters.DateTo.ToString() : DBNull.Value,
                    model.Filters.StatisticDataOnly!)
                .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
            var summary = await _context.NumberOfDocumentsOrderedByReaderReportSummary.FromSqlRaw("EXECUTE dbo.sp_GetNumberOfDocumentsOrderedByReaderReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodes),
                    model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                    JoinStrings(model.Filters.FundLevelOfdescriptionCodes),
                    model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                    model.Filters.LibraryCardNumber != null ? model.Filters.LibraryCardNumber : DBNull.Value,
                    model.Filters.DateFrom != null ? model.Filters.DateFrom.ToString() : DBNull.Value,
                    model.Filters.DateTo != null ? model.Filters.DateTo.ToString() : DBNull.Value,
                    model.Filters.StatisticDataOnly!)
                .ToListAsync(token);

            return new ReportGridWithSummaryGridResponseModel<NumberOfDocumentsOrderedByReaderReportCombined, NumberOfDocumentsOrderedByReaderReport>
            {
                Items = rows,
                TotalCount = summary[0].TotalRows,
                Summary = combined.ToArray().Length > 0
                        ? combined[0]
                        : new NumberOfDocumentsOrderedByReaderReportCombined { }
            };
        }

        public async Task<ReportGridWithSummaryGridResponseModel<NumberOfDocumentsOrderedByEmployeeReportCombined, NumberOfDocumentsOrderedByEmployeeReport>> GeNumberOfDocumentsOrderedByEmployeeReport(CancellationToken token, ReportGridRequestModel<NumberOfDocumentsOrderedByEmployeeReportInputModel> model)
        {
            var rows = new List<NumberOfDocumentsOrderedByEmployeeReport>();
            if (model.Filters.ArchiveCodes.ToArray().Length == 0) { model.Filters.ArchiveCodes = new List<string>() { "0" }; };
            if (model.Filters.FundLevelOfdescriptionCodes.ToArray().Length == 0) { model.Filters.FundLevelOfdescriptionCodes = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.Employee == null) { model.Filters.Employee = DropdownOptionCodeSellectAll; };
#pragma warning disable CS8604 // Possible null reference argument.
            if (model.Filters.StatisticDataOnly == false)
            {
                rows = await _context.NumberOfDocumentsOrderedByEmployeeReport.FromSqlRaw("EXECUTE dbo.sp_GetNumberOfDocumentsOrderedByEmployeeReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodes),
                    model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                    JoinStrings(model.Filters.FundLevelOfdescriptionCodes),
                    model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                    model.Filters.Employee != null ? model.Filters.Employee : DBNull.Value,
                    model.Filters.DateFrom != null ? model.Filters.DateFrom : DBNull.Value,
                    model.Filters.DateTo != null ? model.Filters.DateTo : DBNull.Value,
                    model.Filters.StatisticDataOnly)
                .ToListAsync(token);
            }

            foreach (var row in rows)
            {
                row.AccessDate = row.AccessDate.UtcToLocalTime();
            }

#pragma warning disable CS8604 // Possible null reference argument.
            var combined = await _context.NumberOfDocumentsOrderedByEmployeeReportCombined.FromSqlRaw("EXECUTE dbo.sp_GetNumberOfDocumentsOrderedByEmployeeReportCombined {0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodes),
                    model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                    JoinStrings(model.Filters.FundLevelOfdescriptionCodes),
                    model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                    model.Filters.Employee != null ? model.Filters.Employee : DBNull.Value,
                    model.Filters.DateFrom != null ? model.Filters.DateFrom.ToString() : DBNull.Value,
                    model.Filters.DateTo != null ? model.Filters.DateTo.ToString() : DBNull.Value,
                    model.Filters.StatisticDataOnly!)
                .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
            var summary = await _context.NumberOfDocumentsOrderedByEmployeeReportSummary.FromSqlRaw("EXECUTE dbo.sp_GetNumberOfDocumentsOrderedByEmployeeReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                    model.ItemsPerPage,
                    model.Page,
                    JoinStrings(model.Filters.ArchiveCodes),
                    model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                    JoinStrings(model.Filters.FundLevelOfdescriptionCodes),
                    model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                    model.Filters.Employee != null ? model.Filters.Employee : DBNull.Value,
                    model.Filters.DateFrom != null ? model.Filters.DateFrom.ToString() : DBNull.Value,
                    model.Filters.DateTo != null ? model.Filters.DateTo.ToString() : DBNull.Value,
                    model.Filters.StatisticDataOnly!)
                .ToListAsync(token);

            return new ReportGridWithSummaryGridResponseModel<NumberOfDocumentsOrderedByEmployeeReportCombined, NumberOfDocumentsOrderedByEmployeeReport>
            {
                Items = rows,
                TotalCount = summary[0].TotalRows,
                Summary = combined.ToArray().Length > 0
                        ? combined[0]
                        : new NumberOfDocumentsOrderedByEmployeeReportCombined { }
            };
        }

        public async Task<ReportGridWithSummaryGridResponseModel<InventoryReportCombined, InventoryReport>> GetInventoryReport(
            CancellationToken token, ReportGridRequestModel<InventoryReportInputModel> model)
        {
            var rows = new List<InventoryReport>();
            if (model.Filters.Archives.ToArray().Length == 0) { model.Filters.Archives = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.Statuses.ToArray().Length == 0) { model.Filters.Statuses = new List<string>() { DropdownOptionCodeSellectAll }; };

            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                rows = await _context.InventoryReport.FromSqlRaw("EXECUTE dbo.sp_GetInventoryReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.Statuses),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                    )
                    .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var combined = await _context.InventoryReportCombined.FromSqlRaw("EXECUTE dbo.sp_GetInventoryReportCombined {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.Statuses),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                    )
                    .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var summary = await _context.InventoryReportSummary.FromSqlRaw("EXECUTE dbo.sp_GetInventoryReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.Statuses),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                    )
                    .ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<InventoryReportCombined, InventoryReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = combined.ToArray().Length > 0
                            ? combined[0]
                            : new InventoryReportCombined { }
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                rows = await _context.InventoryReport.FromSqlRaw("EXECUTE dbo.sp_GetInventoryReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.Statuses),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                    )
                    .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var combined = await _context.InventoryReportCombined.FromSqlRaw("EXECUTE dbo.sp_GetInventoryReportCombined {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}",
                        _linkedServerSettings.LinkedServer,
                       (int)Shared.ReportResultType.InternalDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.Statuses),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                    )
                    .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var summary = await _context.InventoryReportSummary.FromSqlRaw("EXECUTE dbo.sp_GetInventoryReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.Statuses),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                    )
                    .ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<InventoryReportCombined, InventoryReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = combined.ToArray().Length > 0
                            ? combined[0]
                            : new InventoryReportCombined { },
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<ListOfRoughDocumentsReportCombined, ListOfRoughDocumentsReport>> GetListOfRoughDocumentsReport(
            CancellationToken token, ReportGridRequestModel<ListOfRoughDocumentsReportInputModel> model)
        {
            var rows = new List<ListOfRoughDocumentsReport>();
            if (model.Filters.Archives.ToArray().Length == 0) { model.Filters.Archives = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.FundTypeGids.ToArray().Length == 0) { model.Filters.FundTypeGids = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.FundTypesInternal.ToArray().Length == 0) { model.Filters.FundTypesInternal = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.IndustryIndexGids.ToArray().Length == 0) { model.Filters.IndustryIndexGids = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.IndustryIndexesInternal.ToArray().Length == 0) { model.Filters.IndustryIndexesInternal = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.MethodOfAcquisitionGids.ToArray().Length == 0) { model.Filters.MethodOfAcquisitionGids = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.MethodsOfAcquisitionInternal.ToArray().Length == 0) { model.Filters.MethodsOfAcquisitionInternal = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.Statuses.ToArray().Length == 0 || model.Filters.Statuses[0] == DropdownOptionCodeSellectAll) { model.Filters.Statuses = new List<string>() { "1", "2", "6", "7", "10", "14", }; };

            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                rows = await _context.ListOfRoughDocumentsReport.FromSqlRaw("EXECUTE dbo.sp_GetListOfRoughDocumentsReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.FundTypeGids),
                        JoinStrings(model.Filters.FundTypesInternal),
                        JoinStrings(model.Filters.IndustryIndexGids),
                        JoinStrings(model.Filters.IndustryIndexesInternal),
                        JoinStrings(model.Filters.MethodOfAcquisitionGids),
                        JoinStrings(model.Filters.MethodsOfAcquisitionInternal),
                        JoinStrings(model.Filters.Statuses),
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                        )
                    .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var combined = await _context.ListOfRoughDocumentsReportCombined.FromSqlRaw("EXECUTE dbo.sp_GetListOfRoughDocumentsReportCombined {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.FundTypeGids),
                        JoinStrings(model.Filters.FundTypesInternal),
                        JoinStrings(model.Filters.IndustryIndexGids),
                        JoinStrings(model.Filters.IndustryIndexesInternal),
                        JoinStrings(model.Filters.MethodOfAcquisitionGids),
                        JoinStrings(model.Filters.MethodsOfAcquisitionInternal),
                        JoinStrings(model.Filters.Statuses),
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                        )
                    .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var summary = await _context.ListOfRoughDocumentsReportSummary.FromSqlRaw("EXECUTE dbo.sp_GetListOfRoughDocumentsReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.FundTypeGids),
                        JoinStrings(model.Filters.FundTypesInternal),
                        JoinStrings(model.Filters.IndustryIndexGids),
                        JoinStrings(model.Filters.IndustryIndexesInternal),
                        JoinStrings(model.Filters.MethodOfAcquisitionGids),
                        JoinStrings(model.Filters.MethodsOfAcquisitionInternal),
                        JoinStrings(model.Filters.Statuses),
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                        )
                    .ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<ListOfRoughDocumentsReportCombined, ListOfRoughDocumentsReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = combined.ToArray().Length > 0
                            ? combined[0]
                            : new ListOfRoughDocumentsReportCombined { }
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

#pragma warning disable CS8604 // Possible null reference argument.
                rows = await _context.ListOfRoughDocumentsReport.FromSqlRaw("EXECUTE dbo.sp_GetListOfRoughDocumentsReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.FundTypeGids),
                        JoinStrings(model.Filters.FundTypesInternal),
                        JoinStrings(model.Filters.IndustryIndexGids),
                        JoinStrings(model.Filters.IndustryIndexesInternal),
                        JoinStrings(model.Filters.MethodOfAcquisitionGids),
                        JoinStrings(model.Filters.MethodsOfAcquisitionInternal),
                        JoinStrings(model.Filters.Statuses),
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                        )
                    .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var combined = await _context.ListOfRoughDocumentsReportCombined.FromSqlRaw("EXECUTE dbo.sp_GetListOfRoughDocumentsReportCombined {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.FundTypeGids),
                        JoinStrings(model.Filters.FundTypesInternal),
                        JoinStrings(model.Filters.IndustryIndexGids),
                        JoinStrings(model.Filters.IndustryIndexesInternal),
                        JoinStrings(model.Filters.MethodOfAcquisitionGids),
                        JoinStrings(model.Filters.MethodsOfAcquisitionInternal),
                        JoinStrings(model.Filters.Statuses),
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                        )
                    .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var summary = await _context.ListOfRoughDocumentsReportSummary.FromSqlRaw("EXECUTE dbo.sp_GetListOfRoughDocumentsReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.FundTypeGids),
                        JoinStrings(model.Filters.FundTypesInternal),
                        JoinStrings(model.Filters.IndustryIndexGids),
                        JoinStrings(model.Filters.IndustryIndexesInternal),
                        JoinStrings(model.Filters.MethodOfAcquisitionGids),
                        JoinStrings(model.Filters.MethodsOfAcquisitionInternal),
                        JoinStrings(model.Filters.Statuses),
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                        )
                    .ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<ListOfRoughDocumentsReportCombined, ListOfRoughDocumentsReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = combined.ToArray().Length > 0
                            ? combined[0]
                            : new ListOfRoughDocumentsReportCombined { }
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel<ListOfPartialReceiptsInArchiveReportCombined, ListOfPartialReceiptsInArchiveReport>> GetListOfPartialReceiptsInArchiveReport(
            CancellationToken token, ReportGridRequestModel<ListOfPartialReceiptsInArchiveReportInputModel> model)
        {
            var rows = new List<ListOfPartialReceiptsInArchiveReport>();
            if (model.Filters.Archives.ToArray().Length == 0) { model.Filters.Archives = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.PeriodGids.ToArray().Length == 0) { model.Filters.PeriodGids = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.FundArraysInternal.ToArray().Length == 0) { model.Filters.FundArraysInternal = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.Statuses.ToArray().Length == 0) { model.Filters.Statuses = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.MethodOfAcquisitionGids.ToArray().Length == 0) { model.Filters.MethodOfAcquisitionGids = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.MethodsOfAcquisitionInternal.ToArray().Length == 0) { model.Filters.MethodsOfAcquisitionInternal = new List<string>() { DropdownOptionCodeSellectAll }; };

            try
            {
#pragma warning disable CS8604 // Possible null reference argument.
                rows = await _context.ListOfPartialReceiptsInArchiveReport.FromSqlRaw("EXECUTE dbo.sp_GetListOfPartialReceiptsInArchiveReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.PeriodGids),
                        JoinStrings(model.Filters.FundArraysInternal),
                        JoinStrings(model.Filters.Statuses),
                        JoinStrings(model.Filters.MethodOfAcquisitionGids),
                        JoinStrings(model.Filters.MethodsOfAcquisitionInternal),
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                        )
                    .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var combined = await _context.ListOfPartialReceiptsInArchiveReportCombined.FromSqlRaw("EXECUTE dbo.sp_GetListOfPartialReceiptsInArchiveReportCombined {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.PeriodGids),
                        JoinStrings(model.Filters.FundArraysInternal),
                        JoinStrings(model.Filters.Statuses),
                        JoinStrings(model.Filters.MethodOfAcquisitionGids),
                        JoinStrings(model.Filters.MethodsOfAcquisitionInternal),
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                        )
                    .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var summary = await _context.ListOfPartialReceiptsInArchiveReportSummary.FromSqlRaw("EXECUTE dbo.sp_GetListOfPartialReceiptsInArchiveReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType != null ? model.Filters.ReportResultType : (int)Shared.ReportResultType.AllDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.PeriodGids),
                        JoinStrings(model.Filters.FundArraysInternal),
                        JoinStrings(model.Filters.Statuses),
                        JoinStrings(model.Filters.MethodOfAcquisitionGids),
                        JoinStrings(model.Filters.MethodsOfAcquisitionInternal),
                        model.Filters.RegisteredFrom!,
                        model.Filters.RegisteredTo!,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                        )
                    .ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<ListOfPartialReceiptsInArchiveReportCombined, ListOfPartialReceiptsInArchiveReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = combined.ToArray().Length > 0
                        ? combined[0]
                        : new ListOfPartialReceiptsInArchiveReportCombined { }
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }


#pragma warning disable CS8604 // Possible null reference argument.
                rows = await _context.ListOfPartialReceiptsInArchiveReport.FromSqlRaw("EXECUTE dbo.sp_GetListOfPartialReceiptsInArchiveReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.PeriodGids),
                        JoinStrings(model.Filters.FundArraysInternal),
                        JoinStrings(model.Filters.Statuses),
                        JoinStrings(model.Filters.MethodOfAcquisitionGids),
                        JoinStrings(model.Filters.MethodsOfAcquisitionInternal),
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                        )
                    .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var combined = await _context.ListOfPartialReceiptsInArchiveReportCombined.FromSqlRaw("EXECUTE dbo.sp_GetListOfPartialReceiptsInArchiveReportCombined {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.PeriodGids),
                        JoinStrings(model.Filters.FundArraysInternal),
                        JoinStrings(model.Filters.Statuses),
                        JoinStrings(model.Filters.MethodOfAcquisitionGids),
                        JoinStrings(model.Filters.MethodsOfAcquisitionInternal),
                        model.Filters.RegisteredFrom != null
                            ? new DateTime(model.Filters.RegisteredFrom!.Value.Year, model.Filters.RegisteredFrom!.Value.Month, model.Filters.RegisteredFrom!.Value.Day)
                            : DBNull.Value,
                        model.Filters.RegisteredTo != null
                            ? new DateTime(model.Filters.RegisteredTo!.Value.Year, model.Filters.RegisteredTo!.Value.Month, model.Filters.RegisteredTo!.Value.Day)
                            : DBNull.Value,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                        )
                    .ToListAsync(token);

#pragma warning disable CS8604 // Possible null reference argument.
                var summary = await _context.ListOfPartialReceiptsInArchiveReportSummary.FromSqlRaw("EXECUTE dbo.sp_GetListOfPartialReceiptsInArchiveReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.Archives),
                        JoinStrings(model.Filters.PeriodGids),
                        JoinStrings(model.Filters.FundArraysInternal),
                        JoinStrings(model.Filters.Statuses),
                        JoinStrings(model.Filters.MethodOfAcquisitionGids),
                        JoinStrings(model.Filters.MethodsOfAcquisitionInternal),
                        model.Filters.RegisteredFrom!,
                        model.Filters.RegisteredTo!,
                        model.Filters.ChronologicalScope,
                        model.Filters.ChronologicalScopeStartDate,
                        model.Filters.ChronologicalScopeEndDate
                        )
                    .ToListAsync(token);

                return new ReportGridWithSummaryGridResponseModel<ListOfPartialReceiptsInArchiveReportCombined, ListOfPartialReceiptsInArchiveReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows,
                    Summary = combined.ToArray().Length > 0
                    ? combined[0]
                    : new ListOfPartialReceiptsInArchiveReportCombined { },
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };

            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridResponseModel<UserActionsJournalReport>> GetUserActionsJournalReport(CancellationToken token, ReportGridRequestModel<UserActionsJournalReportInputModel> model)
        {
            var rows = new List<UserActionsJournalReport>();
            if (model.Filters.EmployeeNames.ToArray().Length == 0) { model.Filters.EmployeeNames = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.ArchiveCodes.ToArray().Length == 0) { model.Filters.ArchiveCodes = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.Process.ToArray().Length == 0) { model.Filters.Process = new List<string>() { DropdownOptionCodeSellectAll }; };
            if (model.Filters.DescriptionLevel.ToArray().Length == 0) { model.Filters.DescriptionLevel = new List<string>() { DropdownOptionCodeSellectAll }; };

            try
            {
                rows = await _context.UserActionsJournalReport.FromSqlRaw("EXECUTE dbo.sp_GetUserActionsJournalReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}",
                        _linkedServerSettings.LinkedServer,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.EmployeeNames),
                        JoinStrings(model.Filters.ArchiveCodes),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                        model.Filters.ArchiveEntityNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        model.Filters.DateFrom != null ? model.Filters.DateFrom : DBNull.Value,
                        model.Filters.DateTo != null ? model.Filters.DateTo : DBNull.Value,
                        JoinStrings(model.Filters.Process),
                        model.Filters.KmfNumber != null ? model.Filters.KmfNumber : DBNull.Value,
                        JoinStrings(model.Filters.DescriptionLevel))
                    .ToListAsync(token);


                var summary = await _context.UserActionsJournalReportSummary.FromSqlRaw("EXECUTE dbo.sp_GetUserActionsJournalReportSummary {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}",
                    _linkedServerSettings.LinkedServer,
                        model.ItemsPerPage,
                        model.Page,
                        JoinStrings(model.Filters.EmployeeNames),
                        JoinStrings(model.Filters.ArchiveCodes),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.InventoryNumber != null ? model.Filters.InventoryNumber : DBNull.Value,
                        model.Filters.ArchiveEntityNumber != null ? model.Filters.ArchiveEntityNumber : DBNull.Value,
                        model.Filters.DateFrom != null ? model.Filters.DateFrom : DBNull.Value,
                        model.Filters.DateTo != null ? model.Filters.DateTo : DBNull.Value,
                        JoinStrings(model.Filters.Process),
                        model.Filters.KmfNumber != null ? model.Filters.KmfNumber : DBNull.Value,
                        JoinStrings(model.Filters.DescriptionLevel))
                    .ToListAsync(token);

                return new ReportGridResponseModel<UserActionsJournalReport>
                {
                    Items = rows,
                    TotalCount = summary[0].TotalRows
                };
            }
            catch (SqlException)
            {
                return new ReportGridResponseModel<UserActionsJournalReport>
                {
                    Items = new List<UserActionsJournalReport> { },
                    TotalCount = 0,
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        private static Dictionary<string, List<string>> SplitDescriptionLevels(List<string>? descriptionLevels)
        {
            Dictionary<string, List<string>> descriptionLevelsSplit = new()
            {
                { _descriptionLevelsDictionaryFundInternal, new List<string>() },
                { _descriptionLevelsDictionaryInventoryInternal, new List<string>() },
                { _descriptionLevelsDictionaryArchivalEntityInternal, new List<string>() },
                { _descriptionLevelsDictionaryDocumentInternal, new List<string>() },
                { _descriptionLevelsDictionaryExternal, new List<string>() }
            };

            if (descriptionLevels == null || !descriptionLevels.Any())
            {
                descriptionLevelsSplit[_descriptionLevelsDictionaryFundInternal].Add(DropdownOptionCodeSellectAll);
                descriptionLevelsSplit[_descriptionLevelsDictionaryInventoryInternal].Add(DropdownOptionCodeSellectAll);
                descriptionLevelsSplit[_descriptionLevelsDictionaryArchivalEntityInternal].Add(DropdownOptionCodeSellectAll);
                descriptionLevelsSplit[_descriptionLevelsDictionaryDocumentInternal].Add(DropdownOptionCodeSellectAll);
                descriptionLevelsSplit[_descriptionLevelsDictionaryExternal].Add(DropdownOptionCodeSellectAll);

                return descriptionLevelsSplit;
            }

            foreach (var item in descriptionLevels)
            {
                //if (item == DropdownOptionCodeSellectAllInternal)
                //{
                //    descriptionLevelsSplit[_descriptionLevelsDictionaryFundInternal].Add(DropdownOptionCodeSellectAll);
                //    descriptionLevelsSplit[_descriptionLevelsDictionaryInventoryInternal].Add(DropdownOptionCodeSellectAll);
                //    descriptionLevelsSplit[_descriptionLevelsDictionaryArchivalEntityInternal].Add(DropdownOptionCodeSellectAll);
                //    descriptionLevelsSplit[_descriptionLevelsDictionaryDocumentInternal].Add(DropdownOptionCodeSellectAll);

                //}
                //else if (item == DropdownOptionCodeSellectAllExternal)
                //{
                //    descriptionLevelsSplit["External"].Add(DropdownOptionCodeSellectAll);
                //}
                if (item == DropdownOptionCodeSellectAll)
                {
                    descriptionLevelsSplit[_descriptionLevelsDictionaryFundInternal].Add(DropdownOptionCodeSellectAll);
                    descriptionLevelsSplit[_descriptionLevelsDictionaryInventoryInternal].Add(DropdownOptionCodeSellectAll);
                    descriptionLevelsSplit[_descriptionLevelsDictionaryArchivalEntityInternal].Add(DropdownOptionCodeSellectAll);
                    descriptionLevelsSplit[_descriptionLevelsDictionaryDocumentInternal].Add(DropdownOptionCodeSellectAll);
                    descriptionLevelsSplit[_descriptionLevelsDictionaryExternal].Add(DropdownOptionCodeSellectAll);
                }
                else
                {
                    if (item.IndexOf(ExternalEntitySufix) > 0)
                    {
                        descriptionLevelsSplit["external"].Add(StripStrings(item));
                    }
                    else
                    {
                        if (item.Contains(EntityTypeFundPrefix))
                        {
                            descriptionLevelsSplit[_descriptionLevelsDictionaryFundInternal].Add(StripStrings(item));
                        }
                        else if (item.Contains(EntityTypeInventoryPrefix))
                        {
                            descriptionLevelsSplit[_descriptionLevelsDictionaryInventoryInternal].Add(StripStrings(item));
                        }
                        else if (item.Contains(EntityTypeArchivalEntityPrefix))
                        {
                            descriptionLevelsSplit[_descriptionLevelsDictionaryArchivalEntityInternal].Add(StripStrings(item));
                        }
                        else if (item.Contains(EntityTypeDocumentPrefix))
                        {
                            descriptionLevelsSplit[_descriptionLevelsDictionaryDocumentInternal].Add(StripStrings(item));
                        }
                    }
                }
            }

            return descriptionLevelsSplit;
        }

        private static string StripStrings(string originalStr)
        {
            return originalStr
                .Replace(ExternalEntitySufix, string.Empty)
                .Replace(EntityTypeFundPrefix, string.Empty)
                .Replace(EntityTypeInventoryPrefix, string.Empty)
                .Replace(EntityTypeArchivalEntityPrefix, string.Empty)
                .Replace(EntityTypeDocumentPrefix, string.Empty);
        }

        public async Task<ReportGridResponseModel<ActiveProcessesReport>> GetActiveProcessesReport(CancellationToken token, ReportGridRequestModel<ActiveProcessesReportInputModel> model)
        {
            try
            {
                // Обекти, за които има активен процес
                var rows = await _context.ActiveProcessesReport.FromSqlRaw("EXECUTE dbo.GetActiveProcessesReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType,
                        JoinStrings(model.Filters.ProcessGids),
                        JoinStrings(model.Filters.ProcessTypesInternal),
                        JoinStrings(model.Filters.Archives),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.ProcessStartedFrom != null ? model.Filters.ProcessStartedFrom : DBNull.Value,
                        model.Filters.ProcessStartedTo != null ? model.Filters.ProcessStartedTo : DBNull.Value,
                        JoinStrings(model.Filters.UserGids),
                        JoinStrings(model.Filters.UserIdsInternal),
                        model.ItemsPerPage,
                        model.Page)
                    .ToListAsync(token);

                // Това се ползва за странициране - общ брой редове с обекти, за които има активен процес
                var totalRows = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetActiveProcessesReportTotalRows {0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType,
                        JoinStrings(model.Filters.ProcessGids),
                        JoinStrings(model.Filters.ProcessTypesInternal),
                        JoinStrings(model.Filters.Archives),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.ProcessStartedFrom != null ? model.Filters.ProcessStartedFrom : DBNull.Value,
                        model.Filters.ProcessStartedTo != null ? model.Filters.ProcessStartedTo : DBNull.Value,
                        JoinStrings(model.Filters.UserGids),
                        JoinStrings(model.Filters.UserIdsInternal))
                    .ToListAsync(token);

                // Това се ползва за общ брой процеси
                var total = await _context.ActiveProcessesReportTotal.FromSqlRaw("EXECUTE dbo.GetActiveProcessesReportCount {0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                        _linkedServerSettings.LinkedServer,
                        model.Filters.ReportResultType,
                        JoinStrings(model.Filters.ProcessGids),
                        JoinStrings(model.Filters.ProcessTypesInternal),
                        JoinStrings(model.Filters.Archives),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.ProcessStartedFrom != null ? model.Filters.ProcessStartedFrom : DBNull.Value,
                        model.Filters.ProcessStartedTo != null ? model.Filters.ProcessStartedTo : DBNull.Value,
                        JoinStrings(model.Filters.UserGids),
                        JoinStrings(model.Filters.UserIdsInternal))
                    .ToListAsync(token);

                return new ReportGridResponseModel2<ActiveProcessesReport>
                {
                    Items = rows,
                    TotalCount = totalRows[0].TotalRows,
                    Total = total[0].Total
                };
            }
            catch (SqlException e)
            {
                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    throw new Exception(e.Message);
                }

                if (model.Filters.ReportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    throw new Exception(_localizer.GetString("ISDADataCannotBeDisplayedForbid"));
                }

                var rows = await _context.ActiveProcessesReport.FromSqlRaw("EXECUTE dbo.GetActiveProcessesReport {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        JoinStrings(model.Filters.ProcessGids),
                        JoinStrings(model.Filters.ProcessTypesInternal),
                        JoinStrings(model.Filters.Archives),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.ProcessStartedFrom != null ? model.Filters.ProcessStartedFrom : DBNull.Value,
                        model.Filters.ProcessStartedTo != null ? model.Filters.ProcessStartedTo : DBNull.Value,
                        JoinStrings(model.Filters.UserGids),
                        JoinStrings(model.Filters.UserIdsInternal),
                        model.ItemsPerPage,
                        model.Page)
                    .ToListAsync(token);

                var totalRows = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetActiveProcessesReportTotalRows {0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        JoinStrings(model.Filters.ProcessGids),
                        JoinStrings(model.Filters.ProcessTypesInternal),
                        JoinStrings(model.Filters.Archives),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.ProcessStartedFrom != null ? model.Filters.ProcessStartedFrom : DBNull.Value,
                        model.Filters.ProcessStartedTo != null ? model.Filters.ProcessStartedTo : DBNull.Value,
                        JoinStrings(model.Filters.UserGids),
                        JoinStrings(model.Filters.UserIdsInternal))
                    .ToListAsync(token);

                var total = await _context.ActiveProcessesReportTotal.FromSqlRaw("EXECUTE dbo.GetActiveProcessesReportCount {0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                        _linkedServerSettings.LinkedServer,
                        (int)Shared.ReportResultType.InternalDB,
                        JoinStrings(model.Filters.ProcessGids),
                        JoinStrings(model.Filters.ProcessTypesInternal),
                        JoinStrings(model.Filters.Archives),
                        model.Filters.FundNumber != null ? model.Filters.FundNumber : DBNull.Value,
                        model.Filters.ProcessStartedFrom != null ? model.Filters.ProcessStartedFrom : DBNull.Value,
                        model.Filters.ProcessStartedTo != null ? model.Filters.ProcessStartedTo : DBNull.Value,
                        JoinStrings(model.Filters.UserGids),
                        JoinStrings(model.Filters.UserIdsInternal))
                    .ToListAsync(token);

                return new ReportGridResponseModel2<ActiveProcessesReport>
                {
                    Items = rows,
                    TotalCount = totalRows[0].TotalRows,
                    Total = total[0].Total,
                    Message = Constants.ISDADataCannotBeDisplayedMessageKey
                };
            }
            catch (DBRequestTimeoutException)
            {
                throw new DBRequestTimeoutException();
            }
            catch (Exception e)
            {
                if (token.IsCancellationRequested)
                {
                    token.ThrowIfCancellationRequested();
                }

                throw new Exception(e.Message);
            }
        }

        public async Task<ReportGridWithSummaryGridResponseModel1<DigitalDocumentsUsageReportSummary, DigitalDocumentsUsageReport>> GetDigitalDocumentsUsageReport(CancellationToken token,
            ReportGridRequestModel<DigitalDocumentsUsageReportInputModel> model)
        {
            var rows = await _context.DigitalDocumentsUsageReport.FromSqlRaw("EXECUTE dbo.GetDigitalDocumentsUsageReport {0},{1},{2},{3},{4},{5}",
                JoinStrings(model.Filters.Statuses),
                JoinStrings(model.Filters.Archives),
                model.Filters.DateFrom != null ? model.Filters.DateFrom.Split('T')[0] : DBNull.Value,
                model.Filters.DateTo != null ? model.Filters.DateTo.Split('T')[0] : DBNull.Value,
                model.ItemsPerPage,
                model.Page
            ).ToListAsync(token);

            var totalRows = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetDigitalDocumentsUsageReportTotalRows {0},{1},{2},{3}",
                JoinStrings(model.Filters.Statuses),
                JoinStrings(model.Filters.Archives),
                model.Filters.DateFrom != null ? model.Filters.DateFrom.Split('T')[0] : DBNull.Value,
                model.Filters.DateTo != null ? model.Filters.DateTo.Split('T')[0] : DBNull.Value
            ).ToListAsync(token);

            var summary = await _context.DigitalDocumentsUsageReportSummary.FromSqlRaw("EXECUTE dbo.GetDigitalDocumentsUsageReportSummary {0},{1},{2},{3}",
                JoinStrings(model.Filters.Statuses),
                JoinStrings(model.Filters.Archives),
                model.Filters.DateFrom != null ? model.Filters.DateFrom.Split('T')[0] : DBNull.Value,
                model.Filters.DateTo != null ? model.Filters.DateTo.Split('T')[0] : DBNull.Value
            ).ToListAsync(token);

            return new ReportGridWithSummaryGridResponseModel1<DigitalDocumentsUsageReportSummary, DigitalDocumentsUsageReport>
            {
                Items = rows,
                TotalCount = totalRows[0].TotalRows,
                Summary = summary
            };
        }

        public async Task<ReportGridResponseModel<WorkDoneOnDigitalObjectsReport>> GetWorkDoneOnDigitalObjectsReport(
            CancellationToken token, ReportGridRequestModel<WorkDoneOnDigitalObjectsReportInputModel> model)
        {
            // Решавам да ползвам процедура, защото с EF Core резултатът не ме удовлетворява като сложност и бързина

            var rows = await _context.WorkDoneOnDigitalObjectsReport.FromSqlRaw("EXECUTE dbo.GetWorkDoneOnDigitalObjectsReport {0},{1},{2},{3},{4},{5},{6},{7},{8}",
                JoinStrings(model.Filters.ArchiveCodes),
                JoinStrings(model.Filters.FundArrays),
                JoinStrings(model.Filters.UserIds),
                JoinStrings(model.Filters.ProcessSteps),
                JoinStrings(model.Filters.DigitalObjectStatuses),
                model.Filters.CreatedFrom.HasValue
                    ? model.Filters.CreatedFrom.Value
                    : DBNull.Value,
                model.Filters.CreatedTo.HasValue
                    ? model.Filters.CreatedTo.Value
                    : DBNull.Value,
                model.ItemsPerPage,
                model.Page
            ).ToListAsync();

            var result = new ReportGridResponseModel<WorkDoneOnDigitalObjectsReport>()
            {
                Items = rows,
                TotalCount = rows != null && rows.Count > 0 ? rows[0].TotalCount : 0,
            };

            return result;
        }

        public async Task<ReportGridWithSummaryGridResponseModel<CardForm1SummaryExternalData, CardForm1Data>> GetCardForm1Data(ReportGridRequestModel<CardForm1DataInputModel> model)
        {
            var rows = await _context.CardForm1ExternalData.FromSqlRaw("EXECUTE dbo.GetCardForm1 {0},{1},{2},{3},{4},{5}",
                _linkedServerSettings.LinkedServer,
                model.Filters.SystemIdentifier,
                model.Filters.HasExternalSource,
                model.Filters.ExternalIdentifier,
                model.ItemsPerPage,
                model.Page
            ).ToListAsync();

            var summaryExternal = model.Filters.HasExternalSource
                ?
                await _context.CardForm1SummaryExternalData.FromSqlRaw("EXECUTE dbo.GetCardForm1FundDataExternal {0},{1},{2},{3}",
                _linkedServerSettings.LinkedServer,
                model.Filters.ExternalIdentifier,
                model.ItemsPerPage,
                model.Page).ToListAsync()
                :
                new List<CardForm1SummaryExternalData>();

            var summaryInternal = !model.Filters.HasExternalSource || model.Filters.SystemIdentifier.HasValue
              ?
              await _context.CardForm1SummaryInternalData.FromSqlRaw("EXECUTE dbo.GetCardForm1FundDataInernal {0},{1},{2}",
              model.Filters.SystemIdentifier,
              model.ItemsPerPage,
              model.Page
              ).ToListAsync()
             :
             new List<CardForm1SummaryInternalData>();

            if (summaryInternal.Any())
            {
                if (summaryExternal.Any())
                {
                    summaryExternal[0].InventoriesCount = summaryExternal[0].InventoriesCount + (summaryInternal[0].InventoriesCount.HasValue ? summaryInternal[0].InventoriesCount : 0);
                    summaryExternal[0].ArchivalEntitiesCount = summaryExternal[0].ArchivalEntitiesCount + (summaryInternal[0].ArchivalEntitiesCount.HasValue ? summaryInternal[0].ArchivalEntitiesCount : 0);
                    summaryExternal[0].Size = summaryInternal[0].Size;
                }
                else
                {
                    summaryExternal.Add(new CardForm1SummaryExternalData()
                    {
                        InventoriesCount = summaryInternal[0].InventoriesCount,
                        ArchivalEntitiesCount = summaryInternal[0].ArchivalEntitiesCount,
                        Size = summaryInternal[0].Size,
                        Archive = summaryInternal[0].Archive,
                        ArchiveCode = summaryInternal[0].ArchiveCode,
                        CreationDate = summaryInternal[0].CreationDate,
                        IndustryIndex = summaryInternal[0].IndustryIndex,
                        MethodOfAcquisition = summaryInternal[0].MethodOfAcquisition,
                        Number = summaryInternal[0].Number,
                        Title = summaryInternal[0].Title,
                        Type = summaryInternal[0].Type
                    });
                }
            }

            var totalRows = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetCardForm1TotalRows {0},{1},{2},{3},{4},{5}",
              _linkedServerSettings.LinkedServer,
              model.Filters.SystemIdentifier,
              model.Filters.HasExternalSource,
              model.Filters.ExternalIdentifier,
              model.ItemsPerPage,
              model.Page
           ).ToListAsync();


            return new ReportGridWithSummaryGridResponseModel<CardForm1SummaryExternalData, CardForm1Data>
            {
                Items = rows,
                TotalCount = totalRows[0].TotalRows,
                Summary = summaryExternal.Any() ? summaryExternal[0] : null
            };
        }

        public async Task<ReportGridWithSummaryGridResponseModel<CardForm1SummaryExternalData, CardForm1Data>> GetCardForm1AData(ReportGridRequestModel<CardForm1DataInputModel> model, int? fundExternalIdentifier)
        {
            var rows = await _context.CardForm1ExternalData.FromSqlRaw("EXECUTE dbo.GetCardForm1A {0},{1},{2},{3}",
                 _linkedServerSettings.LinkedServer,
                 model.Filters.SystemIdentifier,
                 model.Filters.HasExternalSource,
                 model.Filters.ExternalIdentifier
             ).ToListAsync();

            var summary = new List<CardForm1SummaryExternalData>();

            if (model.Filters.HasExternalSource && model.Filters.ExternalIdentifier.HasValue && fundExternalIdentifier.HasValue)
            {
                summary = await _context.CardForm1SummaryExternalData.FromSqlRaw("EXECUTE dbo.GetCardForm1FundDataExternal {0},{1},{2},{3}",
                   _linkedServerSettings.LinkedServer,
                   fundExternalIdentifier,
                   model.ItemsPerPage,
                   model.Page).ToListAsync();
            }
            else
            {
                var fundSysId = await _context.VInventories
                    .Where(i => i.SystemIdentifier == model.Filters.SystemIdentifier!)
                    .Select(i => i.FundSystemIdentifier)
                    .FirstOrDefaultAsync();

                var summaryInt = await _context.CardForm1SummaryInternalData.FromSqlRaw("EXECUTE dbo.GetCardForm1FundDataInernal {0},{1},{2}",
                 fundSysId,
                 model.ItemsPerPage,
                 model.Page
                 ).ToListAsync();
                //Защо няма проверки за null?????
                if (summaryInt != null && summaryInt[0] != null)
                {
                    summary.Add(new CardForm1SummaryExternalData()
                    {
                        Archive = summaryInt[0].Archive,
                        ArchiveCode = summaryInt[0].ArchiveCode,
                        Number = summaryInt[0].Number,
                        Title = summaryInt[0].Title,
                    });
                }
            }

            var totalRows = await _context.TotalRows.FromSqlRaw("EXECUTE dbo.GetCardForm1TotalRows {0},{1},{2},{3},{4},{5}",
              _linkedServerSettings.LinkedServer,
              model.Filters.SystemIdentifier,
              model.Filters.HasExternalSource,
              model.Filters.ExternalIdentifier,
              model.ItemsPerPage,
              model.Page
           ).ToListAsync();


            return new ReportGridWithSummaryGridResponseModel<CardForm1SummaryExternalData, CardForm1Data>
            {
                Items = rows,
                TotalCount = totalRows[0].TotalRows,
                Summary = summary.Any() ? summary[0] : null
            };
        }
    }
}
