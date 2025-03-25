SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsSummary] 
	@RowsOfPage int = 5000,
	@Page int = 1,
	@FundArraysInternal nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ProcessStartDate nvarchar(100) = null,
	@ProcessEndDate nvarchar(100) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@StatusesInternal nvarchar(max) = null,
	@ProcessTypes nvarchar(max) = null,
	@FileFormats nvarchar(max) = null,
	@FundLevelOfdescriptionCodes nvarchar(max) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @localQuery VARCHAR(max) = '
		SELECT COUNT_BIG(*) TotalRows
		FROM Funds 
		WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR (funds.NumberArray in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
				OR ((select top 1 convert(varchar(4), n.Text, 104) from NomenclatureValues as v join N.Nomenclatures as n on n.Id = v.NomenclatureId where v.EntityId = funds.Id and v.EntityType = ''fund'' and v.NomenclatureCode = ''ACQUISITION_METHOD'') in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '','')) AND TypeCode not in (''4'', ''5'')) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				OR ((select top 1 convert(varchar(4), ProcessTypeId, 104) from Process as p where p.FundId = funds.Id) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
				OR (cast(funds.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(funds.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(coalesce(
					convert(varchar, funds.StartDateYear, 104) + ''.'' + convert(varchar, funds.StartDateMonth, 104) + ''.'' + convert(varchar, funds.StartDateDay, 104),
					convert(varchar, funds.StartDateYear, 104) + ''.'' + convert(varchar, funds.StartDateMonth, 104),
					convert(varchar, funds.StartDateYear, 104)) as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(coalesce(
					convert(varchar, funds.EndDateYear, 104) + ''.'' + convert(varchar, funds.EndDateMonth, 104) + ''.'' + convert(varchar, funds.EndDateDay, 104),
					convert(varchar, funds.EndDateYear, 104) + ''.'' + convert(varchar, funds.EndDateMonth, 104),
					convert(varchar, funds.EndDateYear, 104)) as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ProcessStartDate, 'null') + ''' = ''null'') 
				OR (cast((select Process.CreatedOn from Process where funds.Id = Process.FundId) as date) >= cast(''' + COALESCE(@ProcessStartDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ProcessEndDate, 'null') + ''' = ''null'') 
				OR (cast((select Process.UpdatedOn from Process where funds.Id = Process.FundId) as date) <= cast(''' + COALESCE(@ProcessEndDate, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FileFormats + ''', '',''))) 
				OR ((select convert(varchar(4), n.Text, 104) from NomenclatureValues as v join N.Nomenclatures as n on n.Id = v.NomenclatureId join Documents as d on n.Id = d.FileFormatCode where d.FundSystemIdentifier = funds.SystemIdentifier) in (select element from dbo.SplitString(''' + @FileFormats + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundLevelOfdescriptionCodes + ''', '',''))) 
				OR (funds.DescriptionLevelCode in (select element from dbo.SplitString(''' + @FundLevelOfdescriptionCodes + ''', '',''))))		
	';

	SET @sql = @localQuery;
	EXEC (@sql);
END
GO
