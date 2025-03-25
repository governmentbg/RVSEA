--SCRIPT CLOSED! USE THE NEXT ONE!

SET XACT_ABORT ON
GO

BEGIN TRANSACTION

update dbo._Version 
set Value = '1.43'
where Code = 'DB_VERSION'
go

update dbo._Version 
set Value = '1.1.35'
where Code = 'APP_VERSION'
go


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetDigitalObjectsPreparationReport]
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
	@Employee nvarchar(max) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	DECLARE @condition VARCHAR(MAX) = '
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @Employee  + ''', '',''))) 
				OR (convert(varchar(36), d.CreatedBy, 104) in (select element from dbo.SplitString(''' + @Employee + ''', '',''))))
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '',''))) 
				OR (convert(varchar(4), do.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			 AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(d.CreatedOn as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as date)))
			 AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(d.CreatedOn as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as date)))
	'

	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
		 a.Name as Archive
		,up.DisplayName as Employer
		,SUM(NewDocuments) as NewDocuments
		,SUM(NewDo) as NewDo
		,SUM(RecreatedDocuments) as RecreatedDocuments
		,SUM(RecreatedDo) as RecreatedDo
     FROM
   (SELECT 
        ISNULL(New.ArchiveId, Recreated.ArchiveId) as ArchiveId
	   ,ISNULL(New.UserId, Recreated.UserId) as UserId
	   ,ISNULL(COUNT(New.DocumentSystemIdentifier), 0) as NewDocuments
	   ,SUM(ISNULL(New.DoCount, 0)) as NewDo
	   ,ISNULL(COUNT(Recreated.DocumentSystemIdentifier), 0) as RecreatedDocuments
	   ,SUM(ISNULL(Recreated.DoCount, 0)) as RecreatedDo
	  FROM 
			(SELECT 
	    		 d.SystemIdentifier as DocumentSystemIdentifier
				,d.ArchiveId as ArchiveId
				,COUNT(do.SystemIdentifier) as DoCount
				,d.CreatedBy as UserId
			  FROM Documents as d
	     LEFT JOIN DigitalObjects as do
	            ON d.SystemIdentifier = do.DocumentSystemIdentifier
			  JOIN Archives as a
			    ON a.Id = d.ArchiveId
		     WHERE d.StatusCode = 1
			 ' + @condition + '
		  GROUP BY d.SystemIdentifier, d.ArchiveId, d.CreatedBy) as New
 FULL JOIN
			(SELECT 
	    		  d.SystemIdentifier as DocumentSystemIdentifier
				 ,d.ArchiveId as ArchiveId
			     ,COUNT(do.SystemIdentifier) as DoCount
				 ,d.CreatedBy as UserId
		       FROM Documents as d
	      LEFT JOIN DigitalObjects as do
	             ON d.SystemIdentifier = do.DocumentSystemIdentifier
			   JOIN Archives as a
			     ON a.Id = d.ArchiveId
		      WHERE d.StatusCode = 9
			  ' + @condition + '
		   GROUP BY d.SystemIdentifier, d.ArchiveId, d.CreatedBy) as Recreated
	   ON New.documentSystemIdentifier = Recreated.documentSystemIdentifier
 GROUP BY ISNULL(New.ArchiveId, Recreated.ArchiveId), ISNULL(New.UserId, Recreated.UserId)) as Final
     JOIN Archives as a
	   ON a.Id = Final.ArchiveId
	 JOIN AspNetUsers as u
	   ON Final.UserId = u.Id
LEFT JOIN AspNetUserProfiles as up
	   ON u.Id = up.UserId
 GROUP BY a.Name, up.DisplayName
 ORDER BY Archive, Employer'
	END

	BEGIN
		SET @sql = @localQuery + @sqlFinalPart;
	END

	--print @sql;
	EXEC (@sql);
END
GO


BEGIN

UPDATE ProcessTimeline SET StepTypeId = 57
WHERE  StepTypeId = 56 and  ProcessId in(SELECT Id FROM Process WHERE ProcessTypeId = 8 and Completed = 1)

END
GO

BEGIN
 UPDATE ProcessTimeline SET StepTypeId = 58
 WHERE  StepTypeId = 56 and  ProcessId in(SELECT Id FROM Process WHERE ProcessTypeId = 9 and Completed=1)

 END
 GO

/****** Object:  StoredProcedure [dbo].[sp_GetQualityControlReport]    Script Date: 12.8.2024 г. 10:46:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetQualityControlReport]
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
	@Employee nvarchar(max) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	DECLARE @condition VARCHAR(MAX) = '
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @Employee  + ''', '',''))) 
				OR (convert(varchar(36), pt.CreatedBy, 104) in (select element from dbo.SplitString(''' + @Employee + ''', '',''))))
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '',''))) 
				OR (convert(varchar(4), do.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			 AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(pt.CreatedOn as date) >= CONVERT(nvarchar(50),''' + COALESCE(@DateFrom, 'null') + ''', 23)))
			 AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(pt.CreatedOn as date) <= CONVERT(nvarchar(50),''' + COALESCE(@DateTo, 'null') + ''', 23)))
	'

	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
		 a.Name as Archive
		,up.DisplayName as Employer
		,SUM(AcceptedDocuments) + SUM(ReturnedDocuments) as CheckedDocuments
		,SUM(AcceptedDo) + SUM(ReturnedDo) as CheckedDo
		,SUM(AcceptedDocuments) as AcceptedDocuments
		,SUM(AcceptedDo) as AcceptedDo
		,SUM(ReturnedDocuments) as ReturnedDocuments
		,SUM(ReturnedDo) as ReturnedDo
     FROM
   (
   (SELECT 
        ISNULL(Returned.ArchiveId, Accepted.ArchiveId) as ArchiveId
	   ,ISNULL(Returned.UserId, Accepted.UserId) as UserId
	   ,ISNULL(COUNT(Accepted.DocumentSystemIdentifier), 0) as AcceptedDocuments
	   ,SUM(ISNULL(Accepted.DoCount, 0)) as AcceptedDo
	   ,ISNULL(COUNT(Returned.DocumentSystemIdentifier), 0) as ReturnedDocuments
	   ,SUM(ISNULL(Returned.DoCount, 0)) as ReturnedDo

	  FROM 
			  (SELECT 
				 InnerTable.DocumentSystemIdentifier as DocumentSystemIdentifier
	    		,InnerTable.ArchiveId as ArchiveId
	    		,COUNT(InnerTable.DOCount) as DoCount
				,InnerTable.UserId as UserId
	    	   FROM
			(SELECT 
	    		 d.SystemIdentifier as DocumentSystemIdentifier
	    		,d.ArchiveId as ArchiveId
	    		,null as DoCount
				,pt.CreatedBy as UserId
	    	   FROM Documents as d
	      LEFT JOIN DigitalObjects as do
	             ON d.SystemIdentifier = do.DocumentSystemIdentifier
			   JOIN Process as p
	    	     ON p.DocumentSystemIdentifier = d.SystemIdentifier
	    	   JOIN ProcessTimeline as pt
	    	     ON p.Id = pt.ProcessId
			   JOIN Archives as a
			     ON a.Id = d.ArchiveId
	    	  WHERE pt.StepTypeId IN (22, 27)		 
	    	  AND pt.Completed = 1
			     ' + @condition + '
	       	  
UNION
		SELECT 
	    		 d.SystemIdentifier as DocumentSystemIdentifier
	    		,d.ArchiveId as ArchiveId
	    		,do.SystemIdentifier as DoCount
				,pt.CreatedBy as UserId
	    	   FROM Documents as d
	      LEFT JOIN DigitalObjects as do
	             ON d.SystemIdentifier = do.DocumentSystemIdentifier
			   JOIN Process as p
	    	     ON p.DocumentSystemIdentifier = d.SystemIdentifier
	    	   JOIN ProcessTimeline as pt
	    	     ON p.Id = pt.ProcessId
			   JOIN Archives as a
			     ON a.Id = d.ArchiveId
	    	  WHERE pt.StepTypeId IN (28, 31)
	    	  AND pt.Completed = 1 
			  ' + @condition + ' ) as InnerTable
	       
	       GROUP BY InnerTable.DocumentSystemIdentifier, InnerTable.ArchiveId, InnerTable.UserId )as Returned
 FULL JOIN
(SELECT 
				 InnerTable.DocumentSystemIdentifier as DocumentSystemIdentifier
	    		,InnerTable.ArchiveId as ArchiveId
	    		,COUNT(InnerTable.DOCount) as DoCount
				,InnerTable.UserId as UserId
	    	   FROM
(SELECT
	    		 d.SystemIdentifier as DocumentSystemIdentifier
	    		,d.ArchiveId as ArchiveId
	    		,NULL as DoCount
				,pt.CreatedBy as UserId
	    	   FROM Documents as d
			   LEFT JOIN DigitalObjects as do
	             ON d.SystemIdentifier = do.DocumentSystemIdentifier
			   JOIN Process as p
	    	     ON p.DocumentSystemIdentifier = d.SystemIdentifier
	    	   JOIN ProcessTimeline as pt
	    	     ON p.Id = pt.ProcessId
			   JOIN Archives as a
			     ON a.Id = d.ArchiveId 
	    	   WHERE pt.StepTypeId= 56
			   AND  pt.Completed = 1
			   ' + @condition + '

UNION 
		 SELECT
	    		 d.SystemIdentifier as DocumentSystemIdentifier
	    		,d.ArchiveId as ArchiveId
	    		,do.SystemIdentifier as DoCount
				,pt.CreatedBy as UserId
	    	   FROM Documents as d
	      LEFT JOIN DigitalObjects as do
	             ON d.SystemIdentifier = do.DocumentSystemIdentifier
			   JOIN Process as p
	    	     ON p.DocumentSystemIdentifier = d.SystemIdentifier
	    	   JOIN ProcessTimeline as pt
	    	     ON p.Id = pt.ProcessId
			   JOIN Archives as a
			     ON a.Id = d.ArchiveId 
	    	  WHERE pt.StepTypeId IN (57, 58)
		        AND pt.Completed = 1
			  ' + @condition + ') as InnerTable

	GROUP BY InnerTable.DocumentSystemIdentifier, InnerTable.ArchiveId, InnerTable.UserId) as Accepted

	
	on Returned.DocumentSystemIdentifier = Accepted.DocumentSystemIdentifier

	 GROUP BY ISNULL(Returned.ArchiveId, Accepted.ArchiveId), ISNULL(Returned.DocumentSystemIdentifier, Accepted.DocumentSystemIdentifier), ISNULL(Returned.DoCount, Accepted.DoCount), ISNULL(Returned.UserId, Accepted.UserId))

			  ) as Final
     JOIN Archives as a
	   ON a.Id = Final.ArchiveId
	 JOIN AspNetUsers as u
	   ON Final.UserId = u.Id
LEFT JOIN AspNetUserProfiles as up
	   ON u.Id = up.UserId
 GROUP BY a.Name, up.DisplayName
 ORDER BY Archive, Employer'
	END

	BEGIN
		SET @sql = @localQuery + @sqlFinalPart;
	END

	print @sql;
	EXEC (@sql);
END
GO


-- 16.08 4938 ДАА Забележки - Разлика във визуализацията на файловите имена
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocumentDigitalObjects]
	@LinkedServer nvarchar(255) = '', 
	@DocumentIdentifier uniqueidentifier = NULL,
	@DocumentHasExternalSource bit,
	@DocumentExternalIdentifier int = NULL,
	@Digitized bit NULL,
	@IncludeDeleted bit = false,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteDigitalObjectsQuery nvarchar(max) = '';
	DECLARE @RemoteDigitalObjects TABLE (
		Id int 
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,IsDraft bit
		,ParentId int
		,ParentSystemIdentifier uniqueidentifier
		,ArchiveCode int
		,ArchiveName nvarchar(255)
		,DocumentHasExternalSource bit
		,DocumentExternalIdentifier int
		,DocumentNumber nvarchar(50)
		,ArchivalEntityHasExternalSource bit
		,ArchivalEntityExternalIdentifier int
		,ArchivalEntityNumber nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,TypeCode int
		,Name nvarchar(max)
		,SourceName nvarchar(max)
		,FileType nvarchar(50)
		,UncPath nvarchar(max)
		,IsDigitized bit
		,IsImported bit
	);

	DECLARE @LocalDigitalObjectsQuery nvarchar(max) = '';
	DECLARE @LocalDigitalObjects TABLE (
		Id int 
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,IsDraft bit
		,ParentId int
		,ParentSystemIdentifier uniqueidentifier
		,ArchiveCode int
		,ArchiveName nvarchar(255)
		,DocumentHasExternalSource bit
		,DocumentExternalIdentifier int
		,DocumentNumber nvarchar(50)
		,ArchivalEntityHasExternalSource bit
		,ArchivalEntityExternalIdentifier int
		,ArchivalEntityNumber nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,TypeCode int
		,Name nvarchar(max)
		,SourceName nvarchar(max)
		,FileType nvarchar(50)
		,UncPath nvarchar(max)
		,IsDigitized bit
		,IsImported bit
	);


	IF (@DocumentHasExternalSource = 1 AND (@Digitized IS NULL OR @Digitized = 1))
	BEGIN 
		SET @RemoteDigitalObjectsQuery = CAST('' as nvarchar(max)) +
		'select -1 as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,CAST(1 as bit) as HasExternalSource
				,img.Gid as ExternalIdentifier
				,CAST(0 as bit) as IsDraft
				,CAST(NULL as int) ParentId
				,CAST(NULL as uniqueidentifier) ParentSystemIdentifier
				,(select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
				,(select Name from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
				,CAST(1 as bit) as DocumentHasExternalSource
				,doc.LGid as DocumentExternalIdentifier
				,doc.Number as DocumentNumber
				,CAST(1 as bit) as ArchivalEntityHasExternalSource
				,doc.AELGid as ArchivalEntityExternalIdentifier
				,(select Number from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = doc.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityNumber
				,CAST(1 as bit) as InventoryHasExternalSource
				,doc.InventoryLGid as InventoryExternalIdentifier
				,(select Number from [Archiving].[dbo].Inventory_Active inv where inv.LGid = doc.InventoryLGid and inv._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
				,CAST(1 as bit) as FundHasExternalSource
				,doc.FundLGid as FundExternalIdentifier
				,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = doc.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
				,CAST(2 as int) as TypeCode' + '
				--,CONCAT((select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000''''), ''''_'''',doc.LGid, ''''_'''', REVERSE(SUBSTRiNG(REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath))))))),0, CHARINDEX(''''_'''',REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath)))))))))), ''''_d'''', ''''.jpg'''') as Name
				--,CONCAT((select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000''''), ''''_'''',doc.LGid, ''''_'''', REVERSE(SUBSTRiNG(REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath))))))),0, CHARINDEX(''''_'''',REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath)))))))))), ''''_d'''', ''''.jpg'''') as SourceName
				--,REPLACE(REPLACE(REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))), ''''m'''', ''''d''''), REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''.'''',REVERSE(img.FilePath)))), ''''jpg'''') as Name
				--,REPLACE(REPLACE(REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))), ''''m'''', ''''d''''), REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''.'''',REVERSE(img.FilePath)))), ''''jpg'''') as SourceName
				,(CASE
			    	WHEN img.FilePath LIKE ''''%o!o%''''
			    	THEN REPLACE(REPLACE(REVERSE(SUBSTRING(REVERSE(REVERSE(SUBSTRING(REVERSE(img.FilePath), 0, LEN(img.FilePath) - LEN(SUBSTRING(img.FilePath, 0, CHARINDEX(''''!'''', img.FilePath))) - 1))),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))), ''''m'''', ''''d''''), REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''.'''',REVERSE(img.FilePath)))), ''''jpg'''')
			    	ELSE REPLACE(REPLACE(REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))), ''''m'''', ''''d''''), REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''.'''',REVERSE(img.FilePath)))), ''''jpg'''')
			    END) as Name
			    
			    ,(CASE
			    	WHEN img.FilePath LIKE ''''%o!o%''''
			    	THEN REPLACE(REPLACE(REVERSE(SUBSTRING(REVERSE(REVERSE(SUBSTRING(REVERSE(img.FilePath), 0, LEN(img.FilePath) - LEN(SUBSTRING(img.FilePath, 0, CHARINDEX(''''!'''', img.FilePath))) - 1))),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))), ''''m'''', ''''d''''), REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''.'''',REVERSE(img.FilePath)))), ''''jpg'''')
			    	ELSE REPLACE(REPLACE(REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))), ''''m'''', ''''d''''), REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''.'''',REVERSE(img.FilePath)))), ''''jpg'''')
			    END) as SourceName
				,''''jpg'''' as FileType
				,img.FilePath as UncPath
				,CAST(1 as bit) as IsDigitized
				,CAST(0 as bit) as IsImported
		   from dbo.Image img 
		   join dbo.Document_Active doc on img.DocumentGid = doc.Gid and doc._retired = ''''3000-01-01 00:00:00.000''''
		  where doc.LGid = ' + CAST(@DocumentExternalIdentifier as nvarchar(50)) + ' and img._retired = ''''3000-01-01 00:00:00.000''''' + '

		  union ' + '
		
		 select -1 as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,CAST(1 as bit) as HasExternalSource
				,img.Gid as ExternalIdentifier
				,CAST(0 as bit) as IsDraft
				,CAST(NULL as int) ParentId
				,CAST(NULL as uniqueidentifier) ParentSystemIdentifier
				,(select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
				,(select Name from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
				,CAST(1 as bit) as DocumentHasExternalSource
				,doc.LGid as DocumentExternalIdentifier
				,doc.Number as DocumentNumber
				,CAST(1 as bit) as ArchivalEntityHasExternalSource
				,doc.AELGid as ArchivalEntityExternalIdentifier
				,(select Number from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = doc.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityNumber
				,CAST(1 as bit) as InventoryHasExternalSource
				,doc.InventoryLGid as InventoryExternalIdentifier
				,(select Number from [Archiving].[dbo].Inventory_Active inv where inv.LGid = doc.InventoryLGid and inv._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
				,CAST(1 as bit) as FundHasExternalSource
				,doc.FundLGid as FundExternalIdentifier
				,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = doc.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
				,CAST(1 as int) as TypeCode
				--,REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))) as Name
				--,REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))) as SourceName
				,(CASE
			    	WHEN img.FilePath LIKE ''''%o!o%''''
			    	THEN REVERSE(SUBSTRING(REVERSE(REVERSE(SUBSTRING(REVERSE(img.FilePath), 0, LEN(img.FilePath) - LEN(SUBSTRING(img.FilePath, 0, CHARINDEX(''''!'''', img.FilePath))) - 1))),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))) 
			    	ELSE REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))) 
			     END) as Name
			    
			     ,(CASE
			    	WHEN img.FilePath LIKE ''''%o!o%''''
			    	THEN REVERSE(SUBSTRING(REVERSE(REVERSE(SUBSTRING(REVERSE(img.FilePath), 0, LEN(img.FilePath) - LEN(SUBSTRING(img.FilePath, 0, CHARINDEX(''''!'''', img.FilePath))) - 1))),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))) 
			    	ELSE REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))) 
			     END) as SourceName
				,REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''.'''',REVERSE(img.FilePath)))) as FileType
				,img.FilePath as UncPath
				,CAST(1 as bit) as IsDigitized
				,CAST(0 as bit) as IsImported
		   from dbo.Image img 
		   join dbo.Document_Active doc on img.DocumentGid = doc.Gid and doc._retired = ''''3000-01-01 00:00:00.000''''
		  where doc.LGid = ' + CAST(@DocumentExternalIdentifier as nvarchar(50)) + ' and img._retired = ''''3000-01-01 00:00:00.000''''';

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteDigitalObjectsQuery + ''' )';
		
		INSERT INTO @RemoteDigitalObjects 
		EXEC(@RemoteQuery)

	END

	IF @DocumentIdentifier IS NOT NULL
	BEGIN
		PRINT(@DocumentIdentifier);

		INSERT INTO @LocalDigitalObjects
		SELECT	dig.Id as Id
				,dig.SystemIdentifier as SystemIdentifier
				,ISNULL(dig.HasExternalSource, CAST(0 as bit)) as HasExternalSource
				,dig.ExternalIdentifier as ExternalIdentifier
				,dig.IsDraft
				,dig.ParentId as ParentId
				,dig.ParentSystemIdentifier as ParentSystemIdentifier
				,dig.ArchiveCode as ArchiveCode
				,dig.ArchiveName as ArchiveName
				,dig.DocumentHasExternalSource as DocumentHasExternalSource
				,dig.DocumentExternalIdentifier as DocumentExternalIdentifier
				,dig.DocumentNumber as DocumentNumber
				,dig.ArchivalEntityHasExternalSource as ArchivalEntityHasExternalSource
				,dig.ArchivalEntityExternalIdentifier as ArchivalEntityExternalIdentifier
				,dig.ArchivalEntityNumber as ArchivalEntityNumber
				,dig.InventoryHasExternalSource as InventoryHasExternalSource
				,dig.InventoryExternalIdentifier as InventoryExternalIdentifier
				,dig.InventoryNumber as InventoryNumber
				,dig.FundHasExternalSource as FundHasExternalSource
				,dig.FundExternalIdentifier as FundExternalIdentifier
				,dig.FundNumber FundNumber
				,dig.TypeCode as TypeCode
				,dig.Name as Name
				,dig.SourceName as SourceName
				,dig.FileType
				,dig.UncPath as UncPath
				,dig.IsDigitized as IsDigitized
				,dig.IsImported as IsImported
		  FROM dbo.v_DigitalObjects dig
		 WHERE dig.DocumentSystemIdentifier = @DocumentIdentifier
		   AND (dig.HasExternalSource IS NULL OR dig.HasExternalSource = 0)
		   AND (@Digitized IS NULL OR dig.IsDigitized = @Digitized)
		   AND (@IncludeDeleted = 1 OR dig.Deleted = 0)

	END
	IF (@Paging = 1)
	BEGIN
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @LocalDigitalObjects
			  UNION
			 SELECT *
			   FROM @RemoteDigitalObjects
		   ) Documents
		ORDER BY SourceName
		OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
	END
	ELSE
	BEGIN
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @LocalDigitalObjects
			  UNION
			 SELECT *
			   FROM @RemoteDigitalObjects
		   ) Documents
		ORDER BY SourceName
	END
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocument] 
	@LinkedServer nvarchar(50),
	@Identifier int
AS
BEGIN
	SET NOCOUNT ON;

	declare @sql varchar(max) = '
		SELECT
			-1 as Id
			,NULL as SystemIdentifier
			,CAST(1 as bit) as HasExternalSource
			,LGid as ExternalIdentifier
			,(select CAST(Code as nvarchar(50)) from Nomenclature n where n.Gid = StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusCode
			,(select Value from Nomenclature n where n.Gid = StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusText
			,(select Code from Nomenclature n where n.Gid = AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusCode
			,(select Value from Nomenclature n where n.Gid = AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusText
			,(select a.Code from Archive a where a.Gid = ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			,(select a.Name from Archive a where a.Gid = ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			,CAST(1 AS BIT) as FundHasExternalSource
			,FundLGid as FundExternalIdentifier
			,(SELECT Number FROM Fund_Active AS fund WHERE fund.LGid = FundLGid) AS FundNumber
			,CAST(1 AS BIT) as InventoryHasExternalSource
			,InventoryLGid as InventoryExternalIdentifier
			,(SELECT Number FROM Inventory_Active AS inventory WHERE inventory.LGid = InventoryLGid) AS InventoryNumber
			,CAST(1 AS BIT) as ArchivalEntityHasExternalSource
			,AELGid as ArchivalEntityExternalIdentifier
			,(SELECT Number FROM ArchiveEntity_Active AS ae WHERE ae.LGid = AELGid) AS ArchivalEntityNumber
            ,Number
			,Title
			,(select CAST(Code as nvarchar(50)) from Nomenclature n where n.Gid= d.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelCode
			,(select Value from Nomenclature n where n.Gid= d.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelText
			,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.DocumentGid = d.Gid and n.Type = ''CreatingType'' for XML PATH('''')), 1, 1, '''') as CreationMethodText
			  ,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.DocumentGid = d.Gid and n.Type = ''Originality'' for XML PATH('''')), 1, 1, '''') as OriginalityText
			  ,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.DocumentGid = d.Gid and n.Type = ''Language'' for XML PATH('''')), 1, 1, '''') as LanguageText
            ,[IsNoDate] as HasNoChronologicalScope
			,[StartDateYear]
			,[StartDateMonth]
			,[StartDateDay]
			,[EndDateYear]
			,[EndDateMonth]
			,[EndDateDay]
			,TextDate as ApproximateChronologicalScope
			,PlaceOfCreation AS Location
			--,[MagnetTapesCount] as TapeCount
			--,[MicrofilmsCount] as MicrofilmCount
			--,[FramesCount] as FrameCount
			--,[VideoTapesCount] as VideoTapeCount
			--,[ElectrCount] as DigitalDeviceCount
			,DimensionInCentimeters as SizeCm
			--,[ExtentOther] as OtherMetrics -- дали е това от ИСДА?
			,[ExtendedContentDescription] as Description
			,[SpecificDetails] as Features
			--,NULL as Condition -- не го намирам
			,[CopyMicrofilm] as MicrofilmedCopyCount
			,[CopyDigital] as DigitizedCopyCount
			,[CopyXerox] as PaperCopyCount
			,[CopyNegativFrames] as NegativeFrameCount
			,[CopyPositiveFrames] as PositiveFrameCount
			,[CopyOther] as OtherCopyCount
			--,NULL as EnrolledBytes
			--,[AveilabilityDocumentsCountAssigned] as EnrolledDocumentCount
			--,[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters
		    --,NULL as DeductedBytes
			--,[AveilabilityDocumentsCountDeducted] as DeductedDocumentCount
			--,[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
			,Note as Notes
			,null as DocumentsAccessDescription
			,d.CreationDate as CreatedOn
			,d.CreationAuthor as CreatedByDisplayName
			,d.ModificationDate as UpdatedOn
			,d.ModificationAuthor as UpdatedByDisplayName
			,[PaperCount] as SheetCount
			,IsNull(d.HasDigitalObject,0) as HasDigitizedDigitalObjects
			,CAST(ln.ListFrom as int) as StartSheetNumber
			,CAST(ln.ListTo as int) as EndSheetNumber
		 FROM Document_Active d
		 JOIN ListNumber as ln on d.Gid = ln.DocumentGid
		WHERE 
			LGid = ' + CAST(@Identifier as varchar(10));
			
	set @sql = REPLACE(@sql, '''', '''''');
	declare @result varchar(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''')';

	exec (@result);
END
GO
-- END 16.08 4938 ДАА Забележки - Разлика във визуализацията на файловите имена

COMMIT 