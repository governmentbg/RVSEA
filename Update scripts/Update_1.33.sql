SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.33'
where Code = 'DB_VERSION'
go

-- Process steps
  IF NOT EXISTS(SELECT 1 FROM N.ProcessSteps WHERE ID = 1019)
  BEGIN
	INSERT INTO N.ProcessSteps (Id, ProcessTypeId, Code, Text, AllowTaskTemplate)
	VALUES (1019, NULL, 'SendForAffirmation', 'Изпращане за утвърждаване', 1)
  END
  IF NOT EXISTS(SELECT 1 FROM N.ProcessSteps WHERE ID = 1020)
  BEGIN
	INSERT INTO N.ProcessSteps (Id, ProcessTypeId, Code, Text, AllowTaskTemplate)
	VALUES (1020, NULL, 'Affirmation', 'Утвърждаване', 0)
  END
  GO

   IF NOT EXISTS(SELECT 1 FROM ProcessRelatedSteps WHERE ProcessTypeId = 1 AND StepId = 1019)
  BEGIN 
	INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId,AsigneeGoups) VALUES (1, 1019, 1020, 'V1')
  END
  GO

  IF NOT EXISTS(SELECT 1 FROM ProcessRelatedSteps WHERE ProcessTypeId = 2 AND StepId = 1019)
  BEGIN 
	INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId,AsigneeGoups) VALUES (2, 1019, 1020, 'V1')
  END
  GO

  IF NOT EXISTS(SELECT 1 FROM ProcessRelatedSteps WHERE ProcessTypeId = 14 AND StepId = 1019)
  BEGIN 
	INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId,AsigneeGoups) VALUES (14, 1019, 1020, 'V1')
  END
  GO

  IF NOT EXISTS(SELECT 1 FROM ProcessRelatedSteps WHERE ProcessTypeId = 15 AND StepId = 1019)
  BEGIN 
	INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId,AsigneeGoups) VALUES (15, 1019, 1020, 'V1')
  END
  GO

  IF NOT EXISTS(SELECT 1 FROM ProcessRelatedSteps WHERE ProcessTypeId = 16 AND StepId = 1019)
  BEGIN 
	INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId,AsigneeGoups) VALUES (16, 1019, 1020, 'V1')
  END
  GO

  IF NOT EXISTS(SELECT 1 FROM ProcessRelatedSteps WHERE ProcessTypeId = 19 AND StepId = 1019)
  BEGIN 
	INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId,AsigneeGoups) VALUES (19, 1019, 1020, 'V1')
  END
  GO

  IF NOT EXISTS(SELECT 1 FROM ProcessRelatedSteps WHERE ProcessTypeId = 20 AND StepId = 1019)
  BEGIN 
	INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId,AsigneeGoups) VALUES (20, 1019, 1020, 'V1')
  END
  GO

-- END Process steps

--Task templates
IF NOT EXISTS(SELECT 1 FROM TaskTemplates WHERE Title = 'Утвърждаване на промени' AND ProcessStepTypeId IS NULL)
BEGIN
	INSERT INTO TaskTemplates(ProcessStepTypeId, Title, Description, RelatedContentUrl, NotificationType)
	VALUES	(null,'Утвърждаване на промени','<p>Възложена Ви е задача за утвърждаване на промени</p>','#displayUrl#',null)
END
GO

IF NOT EXISTS (SELECT 1 FROM TaskTemplatesSteps WHERE ProcessStep_Id = 1020)
BEGIN
	INSERT INTO TaskTemplatesSteps (TaskTemplate_Id, ProcessStep_Id)
	SELECT Id, 1020 FROM TaskTemplates WHERE Title = 'Утвърждаване на промени' AND ProcessStepTypeId IS NULL
END
GO
--END Task templates

-- Package document templates
UPDATE PackageADocsTemplates SET Title = 'Инвентарен опис' WHERE ID IN (
SELECT Id FROM PackageADocsTemplates WHERE Title = 'Печат на инвентарен опис')
GO
--END package document templates

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsReport]
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
	
	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder,IntNumber, NumberArray asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) =  '
		SELECT
			a.Name as Archive,
			funds.Number as FundNumber,
			funds.Title as Title,
			(select n1.Text from N.Nomenclatures n1 where funds.AcquisitionMethodId = n1.Id) as MethodOfAcquisitions,
			(select t.Text from N.FundType as t where t.Code = funds.TypeCode) as Type,
			CAST(funds.ApproxmateChronologicalScope as nvarchar(256)) as ChronologicalScope,
			funds.CreatedOn as DateOfFiling,
			(select s.Text from N.Status as s where s.Code = funds.StatusCode) as Status,
			(select dl.Text from N.FundDescriptionLevel as dl where dl.Code = funds.DescriptionLevelCode) as LevelOfDescription,
			fsi.EnrolledInventoryCount as InventoryCount,
			fsi.EnrolledArchivalEntityCount as AeCount,
			--fsi.EnrolledDocumentCount as DocumentCount,
			(select count(d.SystemIdentifier) from v_DigitalObjects d where funds.SystemIdentifier = d.FundSystemIdentifier AND a.Deleted = 0 AND d.IsDigitized=0) as DocumentCount,
			--fsi.FileTypes as FileFormats,
			(select distinct
				(select t2.AllSplitAndDistinct from (
				select STRING_AGG(t1.E,  ''; '') AllSplitAndDistinct
				from (select distinct trim(element) E
					  from dbo.SplitString(STRING_AGG(d.FileType, ''; ''), ''; '')
					) t1) t2) FileFormats
					from v_DigitalObjects  d where funds.SystemIdentifier =d.FundSystemIdentifier
					AND d.Deleted = 0 AND d.IsDigitized=0) as FileFormats,
			--fsi.EnrolledBytes as Bytes,
			(select sum(d.FileSize) from v_DigitalObjects d where funds.SystemIdentifier = d.FundSystemIdentifier AND a.Deleted = 0 AND d.IsDigitized=0) as Bytes,
			(select sum(d.Duration) from v_DigitalObjects d where funds.SystemIdentifier = d.FundSystemIdentifier AND a.Deleted = 0 AND d.IsDigitized=0) as Duration,
			funds.Notes as Note,
			funds.NumberNumeric as IntNumber,
			a.SortOrder,
			funds.SystemIdentifier,
			funds.ExternalIdentifier,
			funds.HasExternalSource,
			funds.NumberArray as NumberArray
		FROM Funds as funds
		LEFT JOIN v_FundSizeInfo as fsi ON funds.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
		INNER JOIN Archives a ON a.Id = funds.ArchiveId AND a.Deleted = 0
		WHERE funds.ExternalIdentifier IS NULL AND funds.HasExternalSource = 0 AND funds.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR (funds.NumberArray in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
				OR ((select Code from N.Nomenclatures n1 where n1.Id = funds.AcquisitionMethodId) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '','')) AND TypeCode not in (''4'', ''5'')) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				OR (''-998'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				OR ((select top 1  ProcessTypeId from Process as p where p.FundSystemIdentifier = funds.SystemIdentifier and p.Deleted = 0 and p.Completed = 1 order by p.CreatedOn DESC) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))))	
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
				OR (cast((select top(1) Process.CreatedOn from Process where funds.SystemIdentifier = Process.FundSystemIdentifier) as date) >= cast(''' + COALESCE(@ProcessStartDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ProcessEndDate, 'null') + ''' = ''null'') 
				OR (cast((select top(1) Process.UpdatedOn from Process where funds.SystemIdentifier = Process.FundSystemIdentifier) as date) <= cast(''' + COALESCE(@ProcessEndDate, 'null') + ''' as datetime2)))				
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FileFormats + ''', '','')))
				OR (exists((
					(select distinct(
				select t2.AllSplitAndDistinct from (
				select STRING_AGG(t1.E,  ''; '') AllSplitAndDistinct
				from (select distinct trim(element) E
					  from dbo.SplitString(STRING_AGG(d.FileType, ''; ''), ''; '')
					) t1) t2) FileFormats
					from v_DigitalObjects  d where funds.SystemIdentifier =d.FundSystemIdentifier
					AND d.Deleted = 0 AND d.IsDigitized=0
					)) INTERSECT (select element from dbo.SplitString(''' + @FileFormats + ''', '','')))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundLevelOfdescriptionCodes + ''', '',''))) 
				OR (funds.DescriptionLevelCode in (select element from dbo.SplitString(''' + @FundLevelOfdescriptionCodes + ''', '',''))))	
		';
				
		SET @sql = @localQuery + @sqlFinalPart;
	END
	print(@sql);
	EXEC (@sql);
END

GO

----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------
commit