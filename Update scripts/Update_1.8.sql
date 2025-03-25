SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.8'
where Code = 'DB_VERSION'

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundPublicReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null, 
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by Archive, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				isnull(fund.LinearMeters, 0) as LinearMeters,
				null as DigitalSize,
				convert(bigint, fund.InvetoryCount) as InventoryCount,
				convert(bigint, fund.AECount) as AECount,
				fund.ImmediateSourceOfAcquisition,
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
				fund.Number,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
				(select Value + '';''
					from Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''IndustryIndex''
					FOR XML path(''''), elements) as IndustryIndex,
				(select Value + '';''
					from Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''MethodOfAcquisition''
					FOR XML path(''''), elements) as MethodOfAcquisition,
				fund.TextDate,
				(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) as EndDate,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				fund.Title,
				fund.Note,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.LevelOfDescriptionGid) as LevelOfDescription,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE
				((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				isnull(LinearMeters, 0) as LinearMeters,
				Bytes as DigitalSize, -- реално е MB, името на колоната трябва да се смени
				InventoryCount,
				ArchivalEntityCount as AECount,
				DocumentsProvider as ImmediateSourceOfAcquisition,
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,
				Number,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = TypeCode) as FundType,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
						and nv.EntityId=Id
					FOR XML path(''''), elements) as IndustryIndex,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
						and nv.EntityId=Id
					FOR XML path(''''), elements) as MethodOfAcquisition,
				ApproxmateChronologicalScope as TextDate,
				(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, EndDateDay) + ''.'', '''') + isnull(convert(varchar, EndDateMonth) + ''.'', '''') + isnull(convert(varchar, EndDateYear), '''')) as EndDate,
				convert(varchar, CreatedOn, 104) as CreationDate,
				Title,
				Notes as Note,
				(SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as FundStatus,
				(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = DescriptionLevelCode) as LevelOfDescription,
				f.NumberNumeric as IntNumber
			FROM Funds f
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 1 -- fund 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				LinearMeters float NULL, 
				DigitalSize bigint NULL,
				InventoryCount bigint NULL,
				AECount bigint NULL,
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				FundType nvarchar(MAX) NULL,
				IndustryIndex nvarchar(MAX) NULL,
				MethodOfAcquisition nvarchar(MAX) NULL,
				TextDate nvarchar(256) NULL,
				StartDate varchar(256) NULL,
				EndDate varchar(50) NULL,
				CreationDate varchar(50) NULL,
				Title nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				FundStatus nvarchar(MAX) NULL,
				LevelOfDescription nvarchar(MAX) NULL,
				IntNumber int null
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
			UNION
			' +
			@localQuery + @sqlFinalPart;	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + @sqlFinalPart +''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetPartialReceiptsListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveGid nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by Archive, IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				CONCAT(fund.ImmediateSourceOfAcquisition, '' / '',
					(
						select Value + '';''
						from Nomenclature n1
						inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
						where n1._retired=''3000-01-01'' 
							and on1._retired=''3000-01-01''
							and on1.FundGid = fund.Gid 
							and n1.Type=''MethodOfAcquisition''
						FOR XML path(''''), elements
					)) as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				CONCAT(round(isnull(cast(fund.LinearMeters as decimal(18,2)), 0),2), '' / '', fund.ExtentOther) as VolumeInSheets,
				null as DigitalSize,
				fund.Note,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE 
				(''-999'' in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')) OR fund.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')))  
					AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END


	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,
				Number,
				convert(varchar, CreatedOn, 104) as CreationDate,
				CONCAT(DocumentsProvider, '' / '',(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
						and nv.EntityId=Id
					FOR XML path(''''), elements)) as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				Title,
				CONCAT(round(isnull(cast(LinearMeters as decimal(18,2)), 0),2), '' / '', OtherMetrics) as VolumeInSheets,
				Bytes as DigitalSize, -- реално е MB, името на колоната трябва да се смени
				Notes as Note,
				NumberNumeric as IntNumber
			FROM Funds 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 4
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				ImmediateSourceOfAcquisitionPlusMethodOfAcquisition nvarchar(MAX) NULL,
				Title nvarchar(MAX) NULL,
				VolumeInSheets  nvarchar(300) NULL,
				DigitalSize bigint NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
			UNION
			' +
			@localQuery + @sqlFinalPart;	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + @sqlFinalPart +''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoriesListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveGid nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by Archive, IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	DECLARE @methodOfAcquisitionQueryRemote VARCHAR(MAX) = '
		(
			select Value + '';''
			from  Nomenclature n1
			inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
			where n1._retired=''3000-01-01'' 
				and on1._retired=''3000-01-01''
				and on1.FundGid = fund.Gid 
				and n1.Type=''MethodOfAcquisition''
			FOR XML path(''''), elements
		)';
	DECLARE @methodOfAcquisitionQueryLocal VARCHAR(MAX) = '
		(
			select ValueCode + '';''
			from  NomenclatureValues nv
			where nv.EntityType=''fund'' 
				and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
				and nv.EntityId=Id
			FOR XML path(''''), elements
		)';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				COALESCE(
					fund.ImmediateSourceOfAcquisition + '' / '' + ' + @methodOfAcquisitionQueryRemote +  ', 
					fund.ImmediateSourceOfAcquisition + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryRemote + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				(select Value + '';''
					from Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''CreatingType''
					FOR XML path(''''), elements) as CreatingType,
				isnull(fund.LinearMeters, 0),
				null as DigitalSize,
				fund.Note,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE (''-999'' in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')) OR fund.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '',''))) 
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3)';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,
				Number,
				convert(varchar, CreatedOn, 104) as CreationDate,
				COALESCE(
					DocumentsProvider + '' / '' + ' + @methodOfAcquisitionQueryLocal +  ', 
					DocumentsProvider + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryLocal + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				Title,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''CREATION_METHOD'' 
						and nv.EntityId=Id
					FOR XML path(''''), elements) as CreatingType,
				isnull(LinearMeters, 0),
				Bytes as DigitalSize, -- реално е MB, името на колоната трябва да се смени
				Notes as Note,
				NumberNumeric as IntNumber
			FROM Funds 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				ImmediateSourceOfAcquisitionPlusMethodOfAcquisition nvarchar(MAX) NULL,
				Title nvarchar(MAX) NULL,
				CreatingType nvarchar(2000) NULL,
				LinearMeters float NULL,
				DigitalSize bigint NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
			UNION
			' +
			@localQuery + @sqlFinalPart;	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + @sqlFinalPart +''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO




if not exists (select null from sys.columns where name = 'NotificationType' and object_id = object_id ('dbo.TaskTemplates'))
begin 
	alter table dbo.TaskTemplates add NotificationType nvarchar(50)
end
go

 
if object_id ('FK_TaskTemplates_NotificationType') is null
begin
	alter table dbo.TaskTemplates
	add constraint FK_TaskTemplates_NotificationType FOREIGN KEY ( NotificationType ) references N.NotificationType(Code)
end
go

if not exists (select null from TaskTemplates where NotificationType = 'NewApplication')
begin
	insert into TaskTemplates([Title], [Description], [RelatedContentUrl], [NotificationType])
	values(N'Ново заявление от фондообразувател', N'<p>Получено е ново #applicationType# от #applicantFullName#, #applicantEmail# с #documentsOrigin#:</p>#internalDisplayUrl#', '#internalDisplayUrl#', 'NewApplication')
end
go


if not exists (select null from sys.columns where name = 'NotificationType' and object_id = object_id ('dbo.Tasks'))
begin 
	alter table dbo.Tasks add NotificationType nvarchar(50)
end
go


if object_id ('FK_Tasks_NotificationType') is null
begin
	alter table dbo.Tasks
	add constraint FK_Tasks_NotificationType FOREIGN KEY ( NotificationType ) references N.NotificationType(Code)
end
go

if not exists (select null from TaskTemplates where NotificationType = 'AssignedApplication')
begin
	insert into TaskTemplates([Title], [Description], [RelatedContentUrl], [NotificationType])
	values(N'Насочено заявление на фондообразувател за преглед', N'<p>Одобрено #applicationType# от #applicantFullName#, #applicantEmail# с #documentsOrigin# е насочено към Вас за преглед:</p> #displayUrl#', '#displayUrl#', 'AssignedApplication')
end
go


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetReceiptsListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveGid nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by Archive, IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	DECLARE @methodOfAcquisitionQueryRemote VARCHAR(MAX) = '
		(
			select Value + '';''
			from  Nomenclature n1
			inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
			where n1._retired=''3000-01-01'' 
				and on1._retired=''3000-01-01''
				and on1.FundGid = fund.Gid 
				and n1.Type=''MethodOfAcquisition''
			FOR XML path(''''), elements
		)';
	DECLARE @methodOfAcquisitionQueryLocal VARCHAR(MAX) = '
		(
			select ValueCode + '';''
			from  NomenclatureValues nv
			where nv.EntityType=''fund'' 
				and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
				and nv.EntityId=Id
			FOR XML path(''''), elements
		)';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN	
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				COALESCE(
					fund.ImmediateSourceOfAcquisition + '' / '' + ' + @methodOfAcquisitionQueryRemote +  ', 
					fund.ImmediateSourceOfAcquisition + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryRemote + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				cast(fund.AECount as bigint) as ArchiveEntitiesCount,
				isnull(fund.LinearMeters, 0),
				null as DigitalSize,
				(
					select (isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) + ''; '' 
					from  Document_Modified d
					where d.FundLGid = fund.LGid 
					FOR XML path(''''), elements
				) as DocumentsEndDates,
				fund.Note,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE 
				(''-999'' in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')) OR fund.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '',''))) 
					AND (fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1) 
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,
				Number,
				convert(varchar, CreatedOn, 104) as CreationDate,
				COALESCE(
					DocumentsProvider + '' / '' + ' + @methodOfAcquisitionQueryLocal +  ',
					DocumentsProvider + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryLocal + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				Title,
				ArchivalEntityCount as ArchiveEntitiesCount,
				isnull(LinearMeters, 0) as LinearMeters,
				Bytes as DigitalSize, -- реално е MB, името на колоната трябва да се смени
				(
					select (isnull(convert(varchar, EndDateDay) + ''.'', '''') + isnull(convert(varchar, EndDateMonth) + ''.'', '''') + isnull(convert(varchar, EndDateYear), '''')) + ''; '' 
					from  Documents d
					where d.FundSystemIdentifier = SystemIdentifier 
					FOR XML path(''''), elements
				) as DocumentsEndDates,
				Notes as Note,
				NumberNumeric as IntNumber
			FROM Funds 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode IN(1, 2, 4)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				ImmediateSourceOfAcquisitionPlusMethodOfAcquisition nvarchar(MAX) NULL,
				Title nvarchar(MAX) NULL,
				ArchiveEntitiesCount bigint NULL,
				LinearMeters float NULL, 
				DigitalSize bigint NULL,
				DocumentsEndDates nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
			UNION
			' +
			@localQuery + @sqlFinalPart;	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + @sqlFinalPart +''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = 'DECLARE @methodOfAcquisitionQueryLocal VARCHAR(MAX);' + @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetAccountAndDescriptionOfFilmDocumentsBook] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				Number,		
				coalesce(
					convert(varchar, FARevicedOnDay, 104) + ''.'' + convert(varchar, FARevicedOnMonth, 104) + ''.'' + convert(varchar, FARecivedOnYear, 104), 
					convert(varchar, FARecivedOnYear, 104)) as ReceivedOn,
				-- Title, null за всички редове 
				CreationAuthor,
				-- оригинал/копие,
				ImmediateSourceOfAcquisition, -- null за всички рдеове 
				(select Value3 from Nomenclature n where n.Gid = CountryGid) as CountryOfOrigin,
				--NULL as DocumentsCharacteristics,
				--InventoryShortDescroption as InventoryShortDescription, съпроводителна текстова документация
				--документ, въз основа на който е приет, 
				coalesce(
					(Number + '' / '' 
						+ (select Number from Inventory_Modified i where i.FundLGid = LGid) + '' / ''
						+ (select top(1) Number from ArchiveEntity_Modified ae where ae.FundLGid = LGid)),
					(Number + '' / '' 
						+ (select Number from Inventory_Modified i where i.FundLGid = LGid) + '' / ''),
					(Number + '' / / '' 
						+ (select top(1) Number from ArchiveEntity_Modified ae where ae.FundLGid = LGid))					
					) as FundNumberAndInventoryAndArchiveEntiry, -- отнесен към фонд №, инвентарен опис, архивна единица  -- този ред гърми гърми за някой ред от данните, затова слагам top(1)!
				--наличие на застрахователно копие/вид носител
				Note,
				IntNumber
			FROM Fund_Modified as fund
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
				  AND LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				convert(varchar(256), InventoryNumber) as Number,			
				(isnull(convert(varchar, AcceptedOnDay) + ''.'', '''') + isnull(convert(varchar, AcceptedOnMonth) + ''.'', '''') + isnull(convert(varchar, AcceptedOnYear), '''')) as ReceivedOn,
				-- NULL as Title, -- няма го при нас
				NULL as CreationAuthor, -- това не е много ясно
				-- оригинал/копие,
				Source as ImmediateSourceOfAcquisition,
				(select Text from [N].[Nomenclatures] n where n.Id = CountryId) as CountryOfOrigin,
				--DocumentsCharacteristics,
				-- съпроводителна текстова документация,
				-- документ, въз основа на който е приет, 
				NULL as FundNumberAndInventoryAndArchiveEntiry,
				--наличие на застрахователно копие/вид носител,
				Notes as Note,
				InventoryNumber as IntNumber
			FROM Films
			WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0
				Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Number nvarchar(256) NULL,			
				ReceivedOn varchar(50) NULL,
				-- Title,
				CreationAuthor nvarchar(256) NULL,
				-- оригинал/копие,
				ImmediateSourceOfAcquisition nvarchar(2000) NULL,
				CountryOfOrigin nvarchar(MAX) NULL,
				-- DocumentsCharacteristics,
				-- съпроводителна текстова документация,
				-- документ, въз основа на който е приет,
				FundNumberAndInventoryAndArchiveEntiry nvarchar(50) NULL,
				--наличие на застрахователно копие/вид носител,
				Note nvarchar(MAX) NULL,
				IntNumber int null			
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
			UNION
			' +
			@localQuery + @sqlFinalPart;	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + @sqlFinalPart +''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetAccountAndDescriptionOfFilmDocumentsBookSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
				  AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Films 
			WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0
				Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery;
	END


	EXEC (@sql);
END
GO


if not exists (select null from N.NotificationType where Code = 'AddApplicationPackages')
begin 
	insert into N.NotificationType(Code, Text)
	values('AddApplicationPackages', N'Добавяне на пакети към заявление')
end 
go

if not exists (select null from Notification.NotificationTemplate where NotificationTypeCode = 'AddApplicationPackages')
begin
	insert into Notification.NotificationTemplate(NotificationTypeCode, Subject, Body)
	values('AddApplicationPackages', N'Добавяне на пакети към заявление', N'<p>Регистриран е опис по Вашето #applicationType# с номер #applicationNumber#. Следва да добавите пакети А и Б към заявлението!</p>')
end
go



if not exists (select null from N.NotificationType where Code = 'ApplicationPackagesAdded')
begin 
	insert into N.NotificationType(Code, Text)
	values('ApplicationPackagesAdded', N'Добавени пакети към заявление')
end 
go

if not exists (select null from TaskTemplates where NotificationType = 'ApplicationPackagesAdded')
begin
	insert into TaskTemplates([Title], [Description], [RelatedContentUrl], [NotificationType])
	values(N'Добавени пакети към заявление', N'<p>Фондообразувателят е качил пакети А и Б към #applicationType# с номер #applicationNumber#:</p>#internalDisplayUrl#', '#internalDisplayUrl#', 'ApplicationPackagesAdded')
end
go



commit