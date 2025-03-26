USE [DAA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE IF EXISTS [dbo].[sp_SearchFunds]
GO

CREATE PROCEDURE [dbo].[sp_SearchFunds] 
	@LinkedServer nvarchar(50),
	@ArchiveCode int,
	@DescriptionLevel nvarchar(255),
	@SearchText nvarchar(255) = '',
	@Limit int = 1000000
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteFundsQuery nvarchar(max) = '';
    DECLARE @RemoteFunds TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,IsDraft bit
		,ArchiveId int
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,Number nvarchar(50)
		,Title nvarchar(max)
	);

	DECLARE @LocalFunds TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,IsDraft bit
		,ArchiveId int
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,Number nvarchar(50)
		,Title nvarchar(max)
	);

	DECLARE @DescriptionLevelCodes nvarchar(255) = '1,2,3,4'

	IF @DescriptionLevel IS NOT NULL
		SET @DescriptionLevelCodes = @DescriptionLevel


	SET @RemoteFundsQuery = CAST('' as nvarchar(max)) +
	'SELECT TOP(' + CAST(@Limit as nvarchar(50)) + ') 
			-1 as Id
			,CAST(NULL as uniqueidentifier) as SystemIdentifier
			,CAST(1 as bit) as HasExternalSource
			,fund.[LGid] as ExternalIdentifier
			,CAST(0 as bit) as IsDraft
			,CAST(NULL as int) as ArchiveId
			,(select Code from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
			,(select Name from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
			,(select Value from [Archiving].[dbo].Nomenclature n where n.Gid = fund.FundArrayGid and n._retired = ''''3000-01-01 00:00:00.000'''') as NumberArray
			,fund.[Number] as Number
			,fund.[Title] as Title
		FROM [Archiving].[dbo].[Fund_Active] fund
		WHERE fund.ArchiveGid in (select a.Gid from [Archiving].[dbo].[Archive] a where a.Code = ' + CAST(@ArchiveCode as nvarchar(5)) + ')
		AND fund.LevelOfDescriptionGid in (select n.Gid from [Archiving].[dbo].[Nomenclature] n where n.type = ''''LevelOfDescription'''' and n.Code in (' + @DescriptionLevelCodes + '))
		AND fund.Number LIKE ''''%' + @SearchText + '%'''''

	PRINT @RemoteFundsQuery
		
	DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteFundsQuery + ''' )';
		
	INSERT INTO @RemoteFunds 
	EXEC(@RemoteQuery)

		
	

	INSERT INTO @LocalFunds
	SELECT TOP (@Limit) 
			fund.Id
			,fund.SystemIdentifier as SystemIdentifier
			,fund.HasExternalSource
			,fund.ExternalIdentifier
			,fund.IsDraft
			,fund.ArchiveId
			,fund.ArchiveCode
			,fund.ArchiveName
			,fund.NumberArray
			,fund.[Number] as Number
			,fund.Title
		FROM [dbo].[v_Funds] fund
		WHERE fund.ArchiveId in (select a.Id from dbo.Archives a where a.Code = @ArchiveCode)
		AND fund.DescriptionLevelCode IN (select trim(value) from  STRING_SPLIT (@DescriptionLevelCodes, ','))
		AND fund.HasExternalSource = 0
		AND fund.Deleted = 0
		AND fund.Number LIKE '%' + @SearchText + '%'


	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalFunds
		  UNION
		 SELECT *
		   FROM @RemoteFunds
	   ) inventories
	ORDER BY Number




	--declare @sql varchar(max) = 
	--	'SELECT TOP ' + CAST(@Limit AS nvarchar(10)) + ' -- top го слагам, за да не дава грешка
	--		NULL as Id,
	--		fund.LGid as ExternalIdentifier,	
	--		fund.Number,
	--		fund.Title,
	--		CAST(1 AS BIT) as HasExternalSource
	--	FROM [Archiving].[dbo].Fund_Active as fund
	--	WHERE fund.ArchiveGid = ' + CAST(@ArchiveCodeExternal as varchar(10)) + ' AND
	--		(fund.LevelOfDescriptionGid = (select Gid from [Archiving].[dbo].Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1))
	--			AND fund.Number LIKE ''%' + @SearchText + '%''';

	--set @sql = REPLACE(@sql, '''', '''''');
	--declare @linkedServerQuery varchar(max) = '
	--	DECLARE @remoteFundsTable TABLE (
	--		[Id] [int] NULL,
	--		[ExternalIdentifier] [int] NOT NULL,
	--		[Number] [nvarchar](50) NULL,
	--		[Title] [nvarchar](max) NOT NULL,
	--		[HasExternalSource] BIT NOT NULL
	--	);

	--	INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');

	--	SELECT * FROM @remoteFundsTable
	--	UNION 
	--	SELECT TOP ' + CAST(@Limit AS nvarchar(10)) + ' -- top го слагам, за да не дава грешка
	--		Id,
	--		ExternalIdentifier,	
	--		Number,
	--		Title,
	--		HasExternalSource
	--	FROM dbo.Funds f 
	--	WHERE (SELECT a.Code FROM dbo.Archives a WHERE a.Id=f.ArchiveId) = ' + CAST(@ArchiveCodeInternal as varchar(10)) + ' AND f.Number LIKE ''%' + @SearchText + '%''
	--		AND NOT EXISTS(SELECT 1 FROM @remoteFundsTable rft WHERE f.ExternalIdentifier = rft.ExternalIdentifier)
	--	ORDER BY Number';

	--	--print @linkedServerQuery;
	--EXEC (@linkedServerQuery);	
END
GO
